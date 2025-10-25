import { GoogleGenerativeAI } from '@google/generative-ai';

// Inicializar o cliente Gemini
const apiKey = process.env.GEMINI_API_KEY;

if (!apiKey) {
  throw new Error('GEMINI_API_KEY não configurada nas variáveis de ambiente');
}

const genAI = new GoogleGenerativeAI(apiKey);

/**
 * Configuração do modelo Gemini Pro
 */
export const getGeminiModel = () => {
  return genAI.getGenerativeModel({
    model: 'gemini-pro',
    generationConfig: {
      temperature: 0.7, // Criatividade moderada
      topK: 40,
      topP: 0.95,
      maxOutputTokens: 2048,
    },
    safetySettings: [
      {
        category: 'HARM_CATEGORY_HARASSMENT',
        threshold: 'BLOCK_MEDIUM_AND_ABOVE',
      },
      {
        category: 'HARM_CATEGORY_HATE_SPEECH',
        threshold: 'BLOCK_MEDIUM_AND_ABOVE',
      },
      {
        category: 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
        threshold: 'BLOCK_MEDIUM_AND_ABOVE',
      },
      {
        category: 'HARM_CATEGORY_DANGEROUS_CONTENT',
        threshold: 'BLOCK_MEDIUM_AND_ABOVE',
      },
    ],
  });
};

/**
 * Envia uma mensagem para o Gemini e retorna a resposta
 * @param prompt - Prompt do sistema (contexto)
 * @param userMessage - Mensagem do usuário
 * @returns Resposta do Gemini
 */
export async function sendToGemini(
  prompt: string,
  userMessage: string
): Promise<{ success: boolean; response?: string; error?: string }> {
  try {
    const model = getGeminiModel();

    // Combinar prompt do sistema com mensagem do usuário
    const fullPrompt = `${prompt}\n\nMensagem do cliente: ${userMessage}`;

    const result = await model.generateContent(fullPrompt);
    const response = await result.response;
    const text = response.text();

    return {
      success: true,
      response: text,
    };
  } catch (error) {
    console.error('Erro ao comunicar com Gemini:', error);
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Erro desconhecido',
    };
  }
}

/**
 * Envia mensagens em formato de chat (histórico de conversa)
 * @param systemPrompt - Prompt do sistema
 * @param messages - Array de mensagens (role: user/model, parts: texto)
 * @returns Resposta do Gemini
 */
export async function sendChatToGemini(
  systemPrompt: string,
  messages: Array<{ role: 'user' | 'model'; parts: string }>
): Promise<{ success: boolean; response?: string; error?: string }> {
  try {
    const model = getGeminiModel();

    // Iniciar chat com histórico
    const chat = model.startChat({
      history: [
        {
          role: 'user',
          parts: [{ text: systemPrompt }],
        },
        {
          role: 'model',
          parts: [{ text: 'Entendido. Estou pronto para ajudar com peças automotivas.' }],
        },
        ...messages.map((msg) => ({
          role: msg.role,
          parts: [{ text: msg.parts }],
        })),
      ],
    });

    // Enviar última mensagem
    const lastMessage = messages[messages.length - 1];
    const result = await chat.sendMessage(lastMessage.parts);
    const response = await result.response;
    const text = response.text();

    return {
      success: true,
      response: text,
    };
  } catch (error) {
    console.error('Erro ao comunicar com Gemini:', error);
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Erro desconhecido',
    };
  }
}

/**
 * Exemplo de uso:
 * 
 * const result = await sendToGemini(
 *   "Você é um assistente especializado em peças automotivas...",
 *   "Preciso de freios para meu Jeep Compass"
 * );
 * 
 * if (result.success) {
 *   console.log(result.response);
 * }
 */
