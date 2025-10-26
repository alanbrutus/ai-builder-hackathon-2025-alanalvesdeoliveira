import { NextResponse } from 'next/server';
import { getConnection } from '@/lib/db';
import { sendToGemini } from '@/lib/gemini';

export async function POST(request: Request) {
  try {
    const { conversaId, mensagemCliente } = await request.json();

    if (!conversaId) {
      return NextResponse.json({
        success: false,
        error: 'ID da conversa é obrigatório'
      }, { status: 400 });
    }

    const pool = await getConnection();

    // 1. Verificar se a mensagem tem intenção de cotação
    const intencaoResult = await pool
      .request()
      .input('Mensagem', mensagemCliente)
      .execute('AIHT_sp_VerificarIntencaoCotacao');

    const intencaoCotacao = intencaoResult.recordset[0]?.IntencaoCotacao;
    const palavrasEncontradas = intencaoResult.recordset[0]?.PalavrasEncontradas;

    console.log('🔍 Verificando intenção de cotação...');
    console.log('   Intenção detectada:', intencaoCotacao ? 'SIM' : 'NÃO');
    console.log('   Palavras encontradas:', palavrasEncontradas || 'nenhuma');

    if (!intencaoCotacao) {
      return NextResponse.json({
        success: true,
        intencaoCotacao: false,
        mensagem: 'Mensagem não indica intenção de cotação'
      });
    }

    // 2. Buscar peças identificadas na conversa
    const pecasResult = await pool
      .request()
      .input('ConversaId', conversaId)
      .execute('AIHT_sp_ListarPecasParaCotacao');

    const pecas = pecasResult.recordset;

    if (pecas.length === 0) {
      return NextResponse.json({
        success: true,
        intencaoCotacao: true,
        mensagem: 'Nenhuma peça foi identificada ainda nesta conversa.'
      });
    }

    console.log(`📦 ${pecas.length} peças encontradas para cotação`);

    // 3. Buscar prompt de cotação do banco de dados
    const promptResult = await pool
      .request()
      .input('Contexto', 'cotacao')
      .execute('AIHT_sp_ObterPromptPorContexto');

    let promptTemplate = promptResult.recordset[0]?.ConteudoPrompt;

    if (!promptTemplate) {
      console.warn('⚠️  Prompt de cotação não encontrado, usando padrão');
      promptTemplate = `Preciso que realize um processo de cotação para o {{fabricante_veiculo}} {{modelo_veiculo}} em e-Commerce e lojas presenciais para as peças relacionadas abaixo:

-- Início Peças
{{lista_pecas}}
-- Fim Peças

Para cada peça, forneça: nome, tipo (e-Commerce/Loja Física), link/endereço, preço estimado e condições de pagamento.`;
    }

    // 4. Substituir variáveis no prompt
    const fabricanteVeiculo = pecas[0]?.MarcaVeiculo || 'Veículo';
    const modeloVeiculo = pecas[0]?.ModeloVeiculo || '';
    
    // Formatar lista de peças
    const listaPecas = pecas.map((p, i) => 
      `${i + 1}. ${p.NomePeca} - ${p.CodigoPeca || 'Sem código'}`
    ).join('\n');

    // Substituir variáveis
    const promptCotacao = promptTemplate
      .replace(/\{\{fabricante_veiculo\}\}/g, fabricanteVeiculo)
      .replace(/\{\{modelo_veiculo\}\}/g, modeloVeiculo)
      .replace(/\{\{lista_pecas\}\}/g, listaPecas);

    console.log('📝 Prompt montado com variáveis substituídas');

    // 4. Enviar para Gemini
    console.log('🤖 Enviando para Gemini...');
    const resultadoIA = await sendToGemini(promptCotacao, mensagemCliente);

    if (!resultadoIA.success) {
      console.error('❌ Erro na resposta da IA:', resultadoIA.error);
      return NextResponse.json({
        success: false,
        error: resultadoIA.error
      }, { status: 500 });
    }

    console.log('✅ Cotação gerada com sucesso');

    // 5. Registrar log da chamada
    await pool
      .request()
      .input('ConversaId', conversaId)
      .input('MensagemCliente', mensagemCliente)
      .input('PromptEnviado', promptCotacao)
      .input('RespostaIA', resultadoIA.response)
      .input('Sucesso', true)
      .input('TempoResposta', 0)
      .execute('AIHT_sp_RegistrarLogChamadaIA');

    return NextResponse.json({
      success: true,
      intencaoCotacao: true,
      cotacao: resultadoIA.response,
      pecas: pecas,
      palavrasEncontradas: palavrasEncontradas
    });

  } catch (error: any) {
    console.error('❌ Erro ao gerar cotação:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
