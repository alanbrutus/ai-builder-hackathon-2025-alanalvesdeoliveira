import { NextResponse } from 'next/server';
import { getConnection } from '@/lib/db';
import { sendToGemini } from '@/lib/gemini';

export async function POST(request: Request) {
  try {
    const { 
      conversaId,
      mensagem, 
      grupoEmpresarial, 
      fabricanteVeiculo, 
      modeloVeiculo 
    } = await request.json();

    if (!conversaId || !mensagem || !grupoEmpresarial || !fabricanteVeiculo || !modeloVeiculo) {
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
      return NextResponse.json({
        success: false,
        error: resultadoIA.error || 'Erro ao processar com IA',
        promptEnviado: promptProcessado // Para debug
      }, { status: 500 });
    }

    const respostaIA = resultadoIA.response;

    // Extrair a parte de análise (resposta ao cliente) e a parte estruturada (peças)
    let respostaCliente = respostaIA;
    let problemasPecas: Array<{ problema: string; peca: string }> = [];

    // Verificar se tem a seção de peças identificadas
    const inicioPecas = respostaIA.indexOf('---PECAS_IDENTIFICADAS---');
    const fimPecas = respostaIA.indexOf('---FIM_PECAS---');

    if (inicioPecas !== -1 && fimPecas !== -1) {
      // Separar resposta do cliente da parte estruturada
      respostaCliente = respostaIA.substring(0, inicioPecas).trim();
      
      // Extrair linhas de peças
      const secaoPecas = respostaIA.substring(inicioPecas + 27, fimPecas).trim();
      const linhas = secaoPecas.split('\n').filter((l: string) => l.trim());

      for (const linha of linhas) {
        if (linha.includes(';')) {
          const [problema, peca] = linha.split(';').map((s: string) => s.trim());
          if (problema && peca) {
            problemasPecas.push({ problema, peca });
          }
        }
      }
    }

    // Se não identificou problemas/peças, retornar apenas a resposta
    if (problemasPecas.length === 0) {
      return NextResponse.json({
        success: true,
        identificado: false,
        mensagem: respostaCliente,
        respostaCompleta: respostaCliente
      });
    }

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

    return NextResponse.json({
      success: true,
      identificado: true,
      problemas: problemasRegistrados,
      pecas: pecasResult.recordset,
      respostaCompleta: respostaCliente,
      respostaOriginal: respostaIA
    });

  } catch (error: any) {
    console.error('Erro ao identificar peças:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
