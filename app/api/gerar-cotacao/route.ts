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

    // 3. Montar prompt para cotação
    const promptCotacao = `
Você é um assistente de vendas especializado em peças automotivas.

O cliente solicitou cotação para as seguintes peças:

${pecas.map((p, i) => `
${i + 1}. ${p.NomePeca}
   - Código: ${p.CodigoPeca || 'Não informado'}
   - Categoria: ${p.CategoriaPeca || 'Geral'}
   - Problema: ${p.DescricaoProblema}
   - Veículo: ${p.MarcaVeiculo || ''} ${p.ModeloVeiculo || ''}
`).join('\n')}

INSTRUÇÕES:
1. Para cada peça, forneça informações de cotação incluindo:
   - Faixa de preço estimada (mínimo e máximo)
   - Links de e-commerce (Mercado Livre, OLX, lojas especializadas)
   - Sugestão de lojas físicas (redes conhecidas como AutoZone, Nakata, etc.)
   - Dicas de compra (original vs paralela, garantia, etc.)

2. Seja específico e útil, fornecendo URLs reais quando possível

3. Organize a resposta de forma clara e profissional

4. Ao final, pergunte se o cliente deseja ajuda com a instalação ou tem outras dúvidas

Responda de forma completa e profissional:
`;

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
