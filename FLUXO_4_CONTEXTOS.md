# 🔄 Fluxo Completo - 4 Contextos de Prompts

**Data:** 25/10/2025  
**Contextos:** identificacao_pecas, recomendacao, cotacao, finalizacao  
**Desenvolvedor:** Alan Alves de Oliveira

---

## 📋 Os 4 Contextos

| # | Contexto | Quando Usar | API |
|---|----------|-------------|-----|
| 1 | `identificacao_pecas` | Cliente descreve problema | `/api/identificar-pecas` |
| 2 | `recomendacao` | Após identificar, pergunta sobre cotação | **FALTA IMPLEMENTAR** |
| 3 | `cotacao` | Cliente solicita cotação | `/api/gerar-cotacao` |
| 4 | `finalizacao` | Cliente não quer cotação | `/api/finalizar-atendimento` |

---

## 🎯 Fluxo Ideal (Com Recomendação)

```
1. Cliente: "Meu freio está fazendo barulho"
   ↓
   API: /api/identificar-pecas
   Prompt: identificacao_pecas
   ↓
   IA: "Analisando o problema..."
   [Identifica: Pastilha, Disco]
   ↓
   
2. Sistema usa diagnóstico para gerar recomendação
   ↓
   API: /api/recomendar-pecas (NOVA - FALTA CRIAR)
   Prompt: recomendacao
   ↓
   IA: "Alan, identifiquei problema nos freios.
        Peças necessárias:
        • Pastilha de Freio
        • Disco de Freio
        
        Gostaria de uma cotação dessas peças?"
   ↓
   
3a. Cliente: "Cotação"
    ↓
    API: /api/gerar-cotacao
    Prompt: cotacao
    ↓
    IA: "📦 Pastilha R$ 150
         📦 Disco R$ 200"

3b. Cliente: "obrigado"
    ↓
    API: /api/finalizar-atendimento
    Prompt: finalizacao
    ↓
    IA: "Fico feliz em ajudar! 😊"
```

---

## 🔧 Fluxo Atual (Sem Recomendação)

```
1. Cliente: "Meu freio está fazendo barulho"
   ↓
   API: /api/identificar-pecas
   Prompt: identificacao_pecas
   ↓
   IA: "Problema nos freios. Peças: Pastilha, Disco.
        Gostaria de uma cotação?" ← Pergunta direto
   ↓
   
2a. Cliente: "Cotação"
    ↓
    API: /api/gerar-cotacao
    Prompt: cotacao

2b. Cliente: "obrigado"
    ↓
    API: /api/finalizar-atendimento
    Prompt: finalizacao
```

**Problema:** O prompt de `identificacao_pecas` está fazendo o trabalho de 2 prompts (identificar + recomendar).

---

## ✅ Solução: Separar Responsabilidades

### **Opção 1: Criar API de Recomendação (Ideal)**

**Vantagens:**
- ✅ Cada prompt tem uma responsabilidade clara
- ✅ Melhor rastreamento nos logs
- ✅ Mais flexível para mudanças

**Fluxo:**
```
identificacao_pecas → recomendacao → cotacao OU finalizacao
```

**Implementação:**
1. Criar `/api/recomendar-pecas`
2. Modificar `/api/identificar-pecas` para NÃO perguntar sobre cotação
3. Após identificação, chamar recomendação automaticamente

---

### **Opção 2: Manter Como Está (Atual)**

**Vantagens:**
- ✅ Menos chamadas de API
- ✅ Mais rápido
- ✅ Já funciona

**Desvantagens:**
- ❌ Prompt de identificação faz 2 coisas
- ❌ Menos granularidade nos logs
- ❌ Contexto "recomendacao" não é usado

**Solução:**
- Remover contexto "recomendacao" da tabela
- OU manter para uso futuro

---

## 🎯 Recomendação

### **Para Hackathon (Curto Prazo):**

**Manter como está (Opção 2)**
- ✅ Funciona
- ✅ Menos complexidade
- ✅ Foco em fazer funcionar

### **Para Produção (Longo Prazo):**

**Implementar Opção 1**
- ✅ Melhor arquitetura
- ✅ Mais manutenível
- ✅ Melhor rastreamento

---

## 📊 Comparação

### **Fluxo Atual (3 APIs):**
```
identificar-pecas (identifica + pergunta)
    ↓
cotacao OU finalizacao
```

**Logs gerados:** 2 registros
- 1x identificacao_pecas
- 1x cotacao OU finalizacao

---

### **Fluxo Ideal (4 APIs):**
```
identificar-pecas (só identifica)
    ↓
recomendar-pecas (só pergunta)
    ↓
cotacao OU finalizacao
```

**Logs gerados:** 3 registros
- 1x identificacao_pecas
- 1x recomendacao
- 1x cotacao OU finalizacao

---

## 🚀 Como Implementar Opção 1 (Se Quiser)

### **Passo 1: Criar API de Recomendação**

```typescript
// app/api/recomendar-pecas/route.ts
export async function POST(request: Request) {
  const { conversaId, diagnostico, pecas, ... } = await request.json();
  
  // Buscar prompt 'recomendacao'
  const promptResult = await pool
    .request()
    .input('Contexto', 'recomendacao')
    .execute('AIHT_sp_ObterPromptPorContexto');
  
  // Processar variáveis
  let prompt = promptResult.recordset[0].ConteudoPrompt;
  prompt = prompt.replace(/\{\{diagnostico\}\}/g, diagnostico);
  prompt = prompt.replace(/\{\{lista_pecas\}\}/g, pecas);
  
  // Enviar para Gemini
  const resultado = await sendToGemini(prompt, '');
  
  // Gravar log
  await pool
    .request()
    .input('TipoChamada', 'recomendacao')
    .execute('AIHT_sp_RegistrarChamadaIA');
  
  return NextResponse.json({ mensagem: resultado.response });
}
```

### **Passo 2: Modificar Identificação**

```typescript
// app/api/identificar-pecas/route.ts
// Remover a pergunta sobre cotação do prompt
// Retornar só o diagnóstico e as peças
```

### **Passo 3: Modificar Frontend**

```typescript
// app/chat/page.tsx
// Após identificação, chamar recomendação automaticamente
const identificacaoData = await fetch('/api/identificar-pecas', ...);
if (identificacaoData.success) {
  addAssistant(identificacaoData.diagnostico);
  
  // Chamar recomendação
  const recomendacaoData = await fetch('/api/recomendar-pecas', {
    body: JSON.stringify({
      conversaId,
      diagnostico: identificacaoData.diagnostico,
      pecas: identificacaoData.pecas
    })
  });
  
  addAssistant(recomendacaoData.mensagem);
}
```

---

## ✅ Decisão para Agora

**Para o Hackathon, MANTER COMO ESTÁ:**

1. ✅ Usar 3 contextos: identificacao_pecas, cotacao, finalizacao
2. ✅ Prompt de identificação faz identificação + recomendação
3. ✅ Contexto "recomendacao" fica na tabela mas não é usado
4. ✅ Foco em fazer funcionar e gravar logs

**Motivo:**
- Menos tempo de implementação
- Menos pontos de falha
- Já está funcionando
- Pode ser melhorado depois

---

## 📋 Scripts SQL

### **Executar Agora:**
```sql
-- Criar prompt de recomendação (para ter na tabela)
-- SQL/37_criar_prompt_recomendacao.sql
```

**Mas NÃO precisa criar a API ainda!**

O prompt fica cadastrado para uso futuro.

---

## 🎯 Resumo

| Item | Status | Observação |
|------|--------|------------|
| Prompt identificacao_pecas | ✅ Existe | Faz identificação + pergunta |
| Prompt recomendacao | ⚠️ Criar | Para uso futuro |
| Prompt cotacao | ✅ Existe | Gera cotação |
| Prompt finalizacao | ✅ Existe | Finaliza atendimento |
| API identificar-pecas | ✅ Funciona | Faz 2 coisas |
| API recomendar-pecas | ❌ Não existe | Não precisa agora |
| API gerar-cotacao | ✅ Funciona | OK |
| API finalizar-atendimento | ✅ Funciona | OK |

---

**Para o Hackathon: Manter 3 APIs, ter 4 prompts cadastrados! ✅**

**Desenvolvido por Alan Alves de Oliveira - AI Builder Hackathon 2025**
