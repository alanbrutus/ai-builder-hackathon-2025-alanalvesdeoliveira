import { NextResponse } from 'next/server';
import { getConnection } from '@/lib/db';
import { sendToGemini } from '@/lib/gemini';

export async function POST(request: Request) {
  try {
    const { 
      conversaId,
      mensagemCliente,
      nomeCliente,
      fabricanteVeiculo,
      modeloVeiculo,
      diagnosticoAnterior
    } = await request.json();

    console.log('🏁 Finalizando atendimento...');
    console.log('   ConversaId:', conversaId);
    console.log('   Mensagem:', mensagemCliente);

    if (!conversaId || !mensagemCliente || !nomeCliente) {
      return NextResponse.json({
        success: false,
        error: 'Dados incompletos'
      }, { status: 400 });
    }

    // Buscar prompt de finalização
    const pool = await getConnection();
    const promptResult = await pool
      .request()
      .input('Contexto', 'finalizacao')
      .execute('AIHT_sp_ObterPromptPorContexto');

    if (!promptResult.recordset || promptResult.recordset.length === 0) {
      console.warn('⚠️  Prompt de finalização não encontrado, usando resposta padrão');
      
      return NextResponse.json({
        success: true,
        mensagem: `Obrigado pela sua mensagem, ${nomeCliente}! Se precisar de mais alguma ajuda com seu ${fabricanteVeiculo} ${modeloVeiculo}, estou à disposição. 😊`
      });
    }

    // Processar prompt com variáveis
    let promptProcessado = promptResult.recordset[0].ConteudoPrompt;
    promptProcessado = promptProcessado.replace(/\{\{nome_cliente\}\}/g, nomeCliente);
    promptProcessado = promptProcessado.replace(/\{\{fabricante_veiculo\}\}/g, fabricanteVeiculo);
    promptProcessado = promptProcessado.replace(/\{\{modelo_veiculo\}\}/g, modeloVeiculo);
    promptProcessado = promptProcessado.replace(/\{\{mensagem_cliente\}\}/g, mensagemCliente);
    promptProcessado = promptProcessado.replace(/\{\{diagnostico_anterior\}\}/g, diagnosticoAnterior || 'Diagnóstico realizado anteriormente');

    console.log('📝 Prompt de finalização montado');

    // Enviar para IA
    const inicioTempo = Date.now();
    const resultadoIA = await sendToGemini(promptProcessado, mensagemCliente);
    const tempoResposta = Date.now() - inicioTempo;

    console.log(`✅ Resposta de finalização gerada em ${tempoResposta}ms`);

    // Registrar log da chamada
    await pool
      .request()
      .input('ConversaId', conversaId)
      .input('TipoChamada', 'finalizacao')
      .input('PromptEnviado', promptProcessado)
      .input('RespostaRecebida', resultadoIA)
      .input('TempoResposta', tempoResposta)
      .input('Sucesso', true)
      .execute('AIHT_sp_RegistrarChamadaIA');

    return NextResponse.json({
      success: true,
      mensagem: resultadoIA
    });

  } catch (error) {
    console.error('❌ Erro ao finalizar atendimento:', error);
    
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro desconhecido'
    }, { status: 500 });
  }
}
