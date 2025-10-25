# 🤖 Configuração do Google Gemini Pro

## 📋 **Pré-requisitos**

- Conta Google (estudante ou pessoal)
- Acesso ao Google AI Studio

---

## 🔑 **1. Obter API Key do Gemini**

### **Passo 1: Acessar o Google AI Studio**
```
https://makersuite.google.com/app/apikey
```

### **Passo 2: Criar API Key**
1. Clique em **"Create API Key"**
2. Selecione um projeto do Google Cloud (ou crie um novo)
3. Copie a chave gerada

### **Passo 3: Configurar no Projeto**

Crie o arquivo `.env.local` na raiz do projeto:

```bash
# .env.local
GEMINI_API_KEY=AIzaSy...sua_chave_aqui
```

⚠️ **IMPORTANTE:** Nunca commite o arquivo `.env.local` no Git!

---

## 📦 **2. Instalar Dependências**

```bash
npm install
```

Isso instalará o pacote `@google/generative-ai`.

---

## 🧪 **3. Testar a Integração**

### **Opção 1: Via API Route**

```bash
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Você é um especialista em peças automotivas",
    "message": "Preciso de freios para um Jeep Compass 2020"
  }'
```

### **Opção 2: Via Chat Interface**

1. Acesse: http://localhost:3000/chat
2. Complete o fluxo de seleção
3. Digite uma categoria de peça
4. A IA responderá usando o Gemini Pro

---

## 🔧 **4. Configuração do Modelo**

### **Arquivo:** `lib/gemini.ts`

```typescript
model: 'gemini-pro',
generationConfig: {
  temperature: 0.7,      // Criatividade (0.0 - 1.0)
  topK: 40,              // Diversidade de tokens
  topP: 0.95,            // Nucleus sampling
  maxOutputTokens: 2048, // Tamanho máximo da resposta
}
```

### **Ajustar Temperatura:**

- **0.0 - 0.3**: Respostas mais precisas e técnicas
- **0.4 - 0.7**: Balanceado (RECOMENDADO)
- **0.8 - 1.0**: Mais criativo e variado

---

## 📊 **5. Limites do Tier Gratuito**

| Recurso | Limite |
|---------|--------|
| **Requisições/minuto** | 60 |
| **Requisições/dia** | 1.500 |
| **Tokens/minuto** | 32.000 |
| **Custo** | GRATUITO |

---

## 🔌 **6. Uso no Código**

### **Enviar mensagem simples:**

```typescript
import { sendToGemini } from '@/lib/gemini';

const result = await sendToGemini(
  "Você é um especialista em peças automotivas",
  "Preciso de freios para meu Jeep Compass"
);

if (result.success) {
  console.log(result.response);
}
```

### **Chat com histórico:**

```typescript
import { sendChatToGemini } from '@/lib/gemini';

const messages = [
  { role: 'user', parts: 'Tenho um Jeep Compass 2020' },
  { role: 'model', parts: 'Entendi, você tem um Jeep Compass 2020...' },
  { role: 'user', parts: 'Preciso trocar os freios' }
];

const result = await sendChatToGemini(
  "Você é um especialista em peças automotivas",
  messages
);
```

---

## 🛡️ **7. Configurações de Segurança**

O Gemini possui filtros de segurança configurados:

- ✅ **Assédio** - Bloqueado
- ✅ **Discurso de ódio** - Bloqueado
- ✅ **Conteúdo sexual** - Bloqueado
- ✅ **Conteúdo perigoso** - Bloqueado

Configurado em: `lib/gemini.ts` → `safetySettings`

---

## 🐛 **8. Troubleshooting**

### **Erro: "API key not valid"**
- Verifique se a chave está correta no `.env.local`
- Reinicie o servidor: `npm run dev`

### **Erro: "Resource exhausted"**
- Você atingiu o limite de requisições
- Aguarde 1 minuto ou use outra API key

### **Erro: "Cannot find module '@google/generative-ai'"**
```bash
npm install @google/generative-ai
```

### **Resposta vazia ou bloqueada**
- A resposta pode ter sido bloqueada pelos filtros de segurança
- Ajuste os `safetySettings` se necessário

---

## 📝 **9. Exemplo Completo de Integração**

### **No componente de chat:**

```typescript
const handleCategoriaSubmit = async (categoria: string) => {
  setLoading(true);
  
  try {
    // Buscar prompt do banco
    const promptResponse = await fetch('/api/prompts/atendimento');
    const promptData = await promptResponse.json();
    
    // Processar prompt com variáveis
    let systemPrompt = promptData.data.ConteudoPrompt;
    systemPrompt = systemPrompt.replace(/\{\{nome_cliente\}\}/g, name);
    systemPrompt = systemPrompt.replace(/\{\{modelo_veiculo\}\}/g, modeloNome);
    
    // Enviar para Gemini
    const aiResponse = await fetch('/api/chat', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        prompt: systemPrompt,
        message: `Estou interessado em peças da categoria: ${categoria}`
      })
    });
    
    const aiData = await aiResponse.json();
    
    if (aiData.success) {
      addAssistant(aiData.response);
    }
  } catch (error) {
    console.error('Erro:', error);
  } finally {
    setLoading(false);
  }
};
```

---

## 🌟 **10. Recursos Avançados**

### **Multimodal (Imagens):**

```typescript
// Para usar gemini-pro-vision
const model = genAI.getGenerativeModel({ model: 'gemini-pro-vision' });

const imagePart = {
  inlineData: {
    data: base64Image,
    mimeType: 'image/jpeg'
  }
};

const result = await model.generateContent([
  "Identifique esta peça automotiva",
  imagePart
]);
```

### **Streaming de Respostas:**

```typescript
const result = await model.generateContentStream(prompt);

for await (const chunk of result.stream) {
  const chunkText = chunk.text();
  console.log(chunkText);
}
```

---

## 📚 **11. Documentação Oficial**

- **Google AI Studio**: https://makersuite.google.com/
- **Documentação**: https://ai.google.dev/docs
- **SDK Node.js**: https://github.com/google/generative-ai-js

---

## ✅ **Checklist de Configuração**

- [ ] API Key obtida do Google AI Studio
- [ ] Arquivo `.env.local` criado com a chave
- [ ] Dependências instaladas (`npm install`)
- [ ] Servidor reiniciado (`npm run dev`)
- [ ] Teste via API Route funcionando
- [ ] Chat integrado com Gemini

---

**Configuração completa! 🎉**

Agora o chat está pronto para usar o Google Gemini Pro!
