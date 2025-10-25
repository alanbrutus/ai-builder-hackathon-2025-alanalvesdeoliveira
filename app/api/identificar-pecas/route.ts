import { NextResponse } from 'next/server';
import { getConnection } from '@/lib/db';
import { sendToGemini } from '@/lib/gemini';

export async function POST(request: Request) {
  try {
    const { 
      conversaId,
      mensagem,
      nomeCliente,
      grupoEmpresarial, 
      fabricanteVeiculo, 
      modeloVeiculo 
    } = await request.json();

    if (!conversaId || !mensagem || !nomeCliente || !grupoEmpresarial || !fabricanteVeiculo || !modeloVeiculo) {
      return NextResponse.json({
        success: false,
        error: 'Dados incompletos'
      }, { status: 400 });
    }

    // Buscar prompt de identificação
    const pool = await getConnection();
    const promptResult = await pool
      .request()
      .input('Contexto', 'identificacao_pecas')
      .execute('AIHT_sp_ObterPromptPorContexto');

    if (!promptResult.recordset || promptResult.recordset.length === 0) {
      return NextResponse.json({
        success: false,
        error: 'Prompt de identificação não encontrado'
      }, { status: 500 });
    }

    // Processar prompt com variáveis
    let promptProcessado = promptResult.recordset[0].ConteudoPrompt;
    promptProcessado = promptProcessado.replace(/\{\{grupo_empresarial\}\}/g, grupoEmpresarial);
    promptProcessado = promptProcessado.replace(/\{\{fabricante_veiculo\}\}/g, fabricanteVeiculo);
    promptProcessado = promptProcessado.replace(/\{\{modelo_veiculo\}\}/g, modeloVeiculo);
    promptProcessado = promptProcessado.replace(/\{\{mensagem\}\}/g, mensagem);
    promptProcessado = promptProcessado.replace(/\{\{nome_cliente\}\}/g, nomeCliente);

    // Enviar para IA
    const inicioTempo = Date.now();
    const resultadoIA = await sendToGemini(promptProcessado, mensagem);
    const tempoResposta = Date.now() - inicioTempo;

    // Registrar log da chamada
    try {
      await pool
        .request()
        .input('ConversaId', conversaId)
        .input('MensagemCliente', mensagem)
        .input('PromptEnviado', promptProcessado)
        .input('RespostaIA', resultadoIA.response || null)
        .input('Sucesso', resultadoIA.success ? 1 : 0)
        .input('MensagemErro', resultadoIA.error || null)
        .input('TempoResposta', tempoResposta)
        .input('ModeloIA', 'gemini-pro')
        .execute('AIHT_sp_RegistrarChamadaIA');
    } catch (logError) {
      console.error('Erro ao registrar log (não crítico):', logError);
    }

    if (!resultadoIA.success || !resultadoIA.response) {
      console.error('❌ Erro na resposta da IA:', resultadoIA.error);
      return NextResponse.json({
        success: false,
        error: resultadoIA.error || 'Erro ao processar com IA',
        promptEnviado: promptProcessado // Para debug
      }, { status: 500 });
    }

    console.log('✅ IA respondeu com sucesso');
    const respostaIA = resultadoIA.response;
    console.log('📝 Tamanho da resposta:', respostaIA.length, 'caracteres');

    // Extrair a parte de análise (resposta ao cliente) e a parte estruturada (peças)
    let respostaCliente = respostaIA;
    let problemasPecas: Array<{ problema: string; peca: string }> = [];

    // Verificar se tem a seção de peças identificadas
    const inicioPecas = respostaIA.indexOf('---PECAS_IDENTIFICADAS---');
    const fimPecas = respostaIA.indexOf('---FIM_PECAS---');
    
    console.log('🔍 Procurando marcadores...');
    console.log('   Início:', inicioPecas);
    console.log('   Fim:', fimPecas);

    if (inicioPecas !== -1 && fimPecas !== -1) {
      console.log('✅ Marcadores encontrados! Extraindo peças...');
      // Manter a resposta completa para o cliente (incluindo a análise técnica)
      // Apenas remover a seção estruturada de peças
      respostaCliente = respostaIA.substring(0, inicioPecas).trim();
      
      // Extrair linhas de peças
      const secaoPecas = respostaIA.substring(inicioPecas + 27, fimPecas).trim();
      const linhas = secaoPecas.split('\n').filter((l: string) => l.trim());

      let problemaAtual = '';
      
      for (const linha of linhas) {
        if (linha.includes(';')) {
          const partes = linha.split(';').map((s: string) => s.trim());
          
          // Se a linha começa com "Problema", extrair o problema
          if (linha.toLowerCase().startsWith('problema')) {
            problemaAtual = partes[1] || partes[0].replace(/^problema[:\s]*/i, '');
            console.log(`   📌 Problema identificado: ${problemaAtual}`);
          }
          // Se a linha começa com "Peça", extrair as peças
          else if (linha.toLowerCase().startsWith('peça')) {
            // Pode ter múltiplas peças separadas por ;
            for (let i = 1; i < partes.length; i++) {
              const peca = partes[i].trim();
              if (peca && problemaAtual) {
                problemasPecas.push({ problema: problemaAtual, peca });
                console.log(`   ✓ Peça extraída: ${problemaAtual} -> ${peca}`);
              }
            }
          }
          // Formato simples: Problema;Peça
          else if (partes.length >= 2) {
            const [problema, peca] = partes;
            if (problema && peca) {
              problemasPecas.push({ problema, peca });
              console.log(`   ✓ Peça extraída: ${problema} -> ${peca}`);
            }
          }
        }
      }
      console.log(`📦 Total de peças extraídas: ${problemasPecas.length}`);
    } else {
      console.log('⚠️ Marcadores não encontrados - retornando resposta simples');
    }

    // Se não identificou problemas/peças, retornar apenas a resposta
    if (problemasPecas.length === 0) {
      console.log('📤 Retornando resposta sem peças identificadas');
      return NextResponse.json({
        success: true,
        identificado: false,
        mensagem: respostaCliente,
        respostaCompleta: respostaCliente
      });
    }
    
    console.log('💾 Registrando problemas e peças no banco...');

    // Registrar problemas e peças no banco
    const problemasSet = new Set(problemasPecas.map(pp => pp.problema));
    const problemasUnicos = Array.from(problemasSet);
    const problemasRegistrados: any[] = [];

    for (const descricaoProblema of problemasUnicos) {
      const problemaResult = await pool
        .request()
        .input('ConversaId', conversaId)
        .input('DescricaoProblema', descricaoProblema)
        .execute('AIHT_sp_RegistrarProblema');

      const problemaId = problemaResult.recordset[0].Id;
      problemasRegistrados.push({
        id: problemaId,
        descricao: descricaoProblema
      });

      // Registrar peças relacionadas a este problema
      const pecasDoProblema = problemasPecas
        .filter(pp => pp.problema === descricaoProblema)
        .map(pp => pp.peca);

      for (const nomePeca of pecasDoProblema) {
        await pool
          .request()
          .input('ConversaId', conversaId)
          .input('ProblemaId', problemaId)
          .input('NomePeca', nomePeca)
          .input('CategoriaPeca', null)
          .input('Prioridade', 'Média')
          .execute('AIHT_sp_RegistrarPeca');
      }
    }

    // Buscar todas as peças registradas
    const pecasResult = await pool
      .request()
      .input('ConversaId', conversaId)
      .execute('AIHT_sp_ListarPecasConversa');

    console.log('✅ Processo concluído com sucesso!');
    console.log(`   Problemas registrados: ${problemasRegistrados.length}`);
    console.log(`   Peças registradas: ${pecasResult.recordset.length}`);
    
    return NextResponse.json({
      success: true,
      identificado: true,
      problemas: problemasRegistrados,
      pecas: pecasResult.recordset,
      respostaCompleta: respostaCliente,
      respostaOriginal: respostaIA
    });

  } catch (error: any) {
    console.error('❌ ERRO CRÍTICO:', error);
    console.error('   Stack:', error.stack);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
