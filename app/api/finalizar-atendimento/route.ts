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

    console.log('🏁 API Finalizar Atendimento chamada');
    console.log('   ConversaId:', conversaId);
    console.log('   Mensagem:', mensagemCliente);
    console.log('   Cliente:', nomeCliente);
    console.log('   Veículo:', fabricanteVeiculo, modeloVeiculo);

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

    // Processar prompt com variáveis
    let promptProcessado = '';
    
    if (!promptResult.recordset || promptResult.recordset.length === 0) {
      console.warn('⚠️  Prompt de finalização não encontrado, usando resposta padrão');
      promptProcessado = `Responda educadamente ao cliente ${nomeCliente} que possui um ${fabricanteVeiculo} ${modeloVeiculo}. Mensagem do cliente: ${mensagemCliente}`;
    } else {
      promptProcessado = promptResult.recordset[0].ConteudoPrompt || '';
      promptProcessado = promptProcessado.replace(/\{\{nome_cliente\}\}/g, nomeCliente);
      promptProcessado = promptProcessado.replace(/\{\{fabricante_veiculo\}\}/g, fabricanteVeiculo);
      promptProcessado = promptProcessado.replace(/\{\{modelo_veiculo\}\}/g, modeloVeiculo);
      promptProcessado = promptProcessado.replace(/\{\{mensagem_cliente\}\}/g, mensagemCliente);
      promptProcessado = promptProcessado.replace(/\{\{diagnostico_anterior\}\}/g, diagnosticoAnterior || 'Diagnóstico realizado anteriormente');
    }

    // Garantir que o prompt não está vazio
    if (!promptProcessado || promptProcessado.trim() === '') {
      promptProcessado = `Responda educadamente à mensagem: "${mensagemCliente}"`;
    }

    console.log('📝 Prompt de finalização montado');

    // Enviar para IA
    const inicioTempo = Date.now();
    const resultadoIA = await sendToGemini(promptProcessado, mensagemCliente);
    const tempoResposta = Date.now() - inicioTempo;

    console.log(`✅ Resposta de finalização gerada em ${tempoResposta}ms`);

    // Registrar log da chamada
    try {
      console.log('📝 Tentando gravar log...');
      console.log('   PromptEnviado length:', promptProcessado?.length || 0);
      console.log('   RespostaRecebida length:', resultadoIA.response?.length || 0);
      
      await pool
        .request()
        .input('ConversaId', conversaId)
        .input('TipoChamada', 'finalizacao')
        .input('MensagemCliente', mensagemCliente || 'Mensagem não informada')
        .input('PromptEnviado', promptProcessado || 'Prompt não disponível')
        .input('RespostaRecebida', (resultadoIA.success && resultadoIA.response) ? resultadoIA.response : '')
        .input('TempoResposta', tempoResposta)
        .input('Sucesso', resultadoIA.success ? 1 : 0)
        .input('MensagemErro', resultadoIA.error || null)
        .execute('AIHT_sp_RegistrarChamadaIA');
      
      console.log('✅ Log gravado com sucesso');
    } catch (logError) {
      console.error('❌ Erro ao gravar log (não crítico):', logError);
    }

    if (!resultadoIA.success || !resultadoIA.response) {
      return NextResponse.json({
        success: false,
        error: resultadoIA.error || 'Erro ao gerar resposta'
      }, { status: 500 });
    }

    return NextResponse.json({
      success: true,
      mensagem: resultadoIA.response
    });

  } catch (error) {
    console.error('❌ Erro ao finalizar atendimento:', error);
    
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro desconhecido'
    }, { status: 500 });
  }
}
