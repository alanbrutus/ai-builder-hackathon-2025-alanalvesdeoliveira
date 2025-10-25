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
    const resultadoIA = await sendToGemini(promptProcessado, mensagem);

    if (!resultadoIA.success || !resultadoIA.response) {
      return NextResponse.json({
        success: false,
        error: resultadoIA.error || 'Erro ao processar com IA'
      }, { status: 500 });
    }

    const respostaIA = resultadoIA.response;

    // Parsear resposta (formato: Problema;Peça)
    const linhas = respostaIA.split('\n').filter((l: string) => l.trim());
    const problemasPecas: Array<{ problema: string; peca: string }> = [];

    for (const linha of linhas) {
      if (linha.includes(';')) {
        const [problema, peca] = linha.split(';').map((s: string) => s.trim());
        if (problema && peca) {
          problemasPecas.push({ problema, peca });
        }
      }
    }

    // Se não identificou problemas/peças, retornar a resposta da IA
    if (problemasPecas.length === 0) {
      return NextResponse.json({
        success: true,
        identificado: false,
        mensagem: respostaIA
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
