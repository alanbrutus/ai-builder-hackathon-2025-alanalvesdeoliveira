import { NextResponse } from 'next/server';
import { sendToGemini } from '@/lib/gemini';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { prompt, message } = body;

    if (!message) {
      return NextResponse.json(
        {
          success: false,
          error: 'Mensagem é obrigatória',
        },
        { status: 400 }
      );
    }

    // Usar prompt fornecido ou um padrão
    const systemPrompt = prompt || `Você é um assistente virtual especializado em peças automotivas.
Seu objetivo é ajudar clientes a encontrar as peças corretas para seus veículos.
Seja técnico quando necessário, mas sempre explique em termos simples.
Forneça informações sobre compatibilidade, qualidade e preços quando possível.`;

    // Enviar para o Gemini
    const result = await sendToGemini(systemPrompt, message);

    if (result.success) {
      return NextResponse.json({
        success: true,
        response: result.response,
      });
    } else {
      return NextResponse.json(
        {
          success: false,
          error: result.error || 'Erro ao processar mensagem',
        },
        { status: 500 }
      );
    }
  } catch (error) {
    console.error('Erro na API de chat:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erro interno do servidor',
      },
      { status: 500 }
    );
  }
}
