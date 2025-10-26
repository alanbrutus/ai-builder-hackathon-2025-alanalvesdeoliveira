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

    // Processar prompt com variáveis
    let promptProcessado = '';
    
    if (!promptResult.recordset || promptResult.recordset.length === 0) {
      console.warn('⚠️  Prompt de identificação não encontrado, usando prompt padrão');
      promptProcessado = `Você é um assistente especializado em peças automotivas para ${grupoEmpresarial}.
Analise o problema descrito pelo cliente ${nomeCliente} sobre o veículo ${fabricanteVeiculo} ${modeloVeiculo}.
Identifique as peças necessárias e forneça um diagnóstico detalhado.

Problema: ${mensagem}`;
    } else {
      promptProcessado = promptResult.recordset[0].ConteudoPrompt || '';
      promptProcessado = promptProcessado.replace(/\{\{grupo_empresarial\}\}/g, grupoEmpresarial);
      promptProcessado = promptProcessado.replace(/\{\{fabricante_veiculo\}\}/g, fabricanteVeiculo);
      promptProcessado = promptProcessado.replace(/\{\{modelo_veiculo\}\}/g, modeloVeiculo);
      promptProcessado = promptProcessado.replace(/\{\{mensagem\}\}/g, mensagem);
      promptProcessado = promptProcessado.replace(/\{\{nome_cliente\}\}/g, nomeCliente);
    }
    
    // Garantir que o prompt não está vazio
    if (!promptProcessado || promptProcessado.trim() === '') {
      promptProcessado = `Analise o problema: "${mensagem}" para o veículo ${fabricanteVeiculo} ${modeloVeiculo}`;
    }

    // Enviar para IA
    const inicioTempo = Date.now();
    const resultadoIA = await sendToGemini(promptProcessado, mensagem);
    const tempoResposta = Date.now() - inicioTempo;

    // Registrar log da chamada
    try {
      await pool
        .request()
        .input('ConversaId', conversaId)
        .input('TipoChamada', 'identificacao_pecas')
        .input('MensagemCliente', mensagem || 'Mensagem não informada')
        .input('PromptEnviado', promptProcessado || 'Prompt não disponível')
        .input('RespostaRecebida', (resultadoIA.success && resultadoIA.response) ? resultadoIA.response : '')
        .input('TempoResposta', tempoResposta)
        .input('Sucesso', resultadoIA.success ? 1 : 0)
        .input('MensagemErro', resultadoIA.error || null)
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
    let problemasPecas: Array<{ problema: string; peca: string; codigo?: string }> = [];

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
          // Se a linha começa com "Peça", extrair peça e código
          // Formato: Peça;Nome da Peça;Código da Peça
          else if (linha.toLowerCase().startsWith('peça')) {
            const nomePeca = partes[1]?.trim();
            const codigoPeca = partes[2]?.trim();
            
            if (nomePeca && problemaAtual) {
              problemasPecas.push({ 
                problema: problemaAtual, 
                peca: nomePeca,
                codigo: codigoPeca || undefined
              });
              console.log(`   ✓ Peça extraída: ${problemaAtual} -> ${nomePeca}${codigoPeca ? ` (Código: ${codigoPeca})` : ''}`);
            }
          }
          // Formato com 3 colunas: Problema;Peça;Código
          else if (partes.length >= 3) {
            const [problema, peca, codigo] = partes;
            if (problema && peca) {
              problemasPecas.push({ problema, peca, codigo: codigo || undefined });
              console.log(`   ✓ Peça extraída: ${problema} -> ${peca}${codigo ? ` (Código: ${codigo})` : ''}`);
            }
          }
          // Formato com 2 colunas: Problema;Peça (sem código)
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
        .filter(pp => pp.problema === descricaoProblema);

      for (const pecaInfo of pecasDoProblema) {
        await pool
          .request()
          .input('ConversaId', conversaId)
          .input('ProblemaId', problemaId)
          .input('NomePeca', pecaInfo.peca)
          .input('CodigoPeca', pecaInfo.codigo || null)
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
