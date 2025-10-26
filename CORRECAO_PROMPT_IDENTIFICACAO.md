# 🔧 Correção - Prompt de Identificação Não Encontrado

**Data:** 25/10/2025  
**Erro:** "Prompt de identificação não encontrado"  
**Mensagem do usuário:** "Meu carro está apresentando barulho na tampa da caçamba..."  
**Desenvolvedor:** Alan Alves de Oliveira

---

## 🐛 Problema Identificado

### **Erro Apresentado:**
```
Desculpe, ocorreu um erro: Prompt de identificação não encontrado. Tente novamente.
```

### **Causa Raiz:**
A API `/api/identificar-pecas` busca um prompt com contexto `'identificacao_pecas'`, mas o prompt não estava cadastrado no banco de dados.

### **Código da API:**
```typescript
// app/api/identificar-pecas/route.ts (linha 27)
const promptResult = await pool
  .request()
  .input('Contexto', 'identificacao_pecas')  // ← Busca este contexto
  .execute('AIHT_sp_ObterPromptPorContexto');

if (!promptResult.recordset || promptResult.recordset.length === 0) {
  return NextResponse.json({
    success: false,
    error: 'Prompt de identificação não encontrado'  // ← Erro retornado
  }, { status: 500 });
}
```

---

## ✅ Solução Implementada

### **Script SQL Criado:**
**Arquivo:** `SQL/30_verificar_prompt_identificacao.sql`

O script:
1. ✅ Verifica se existe prompt com contexto `'identificacao_pecas'`
2. ✅ Se NÃO existir, insere o prompt completo
3. ✅ Se JÁ existir, apenas mostra os dados
4. ✅ Lista todos os prompts cadastrados

### **Prompt Inserido:**

```sql
INSERT INTO AIHT_Prompts (
    Nome,
    Descricao,
    Contexto,
    ConteudoPrompt,
    Variaveis,
    Ativo,
    Versao,
    DataCriacao,
    CriadoPor
)
VALUES (
    'Prompt de Identificação de Problemas',
    'Prompt utilizado para identificar problemas automotivos e sugerir peças necessárias',
    'identificacao_pecas',  -- ← Contexto correto
    '[Prompt completo...]',
    '{{nome_cliente}}, {{fabricante_veiculo}}, {{modelo_veiculo}}, {{grupo_empresarial}}, {{mensagem_cliente}}',
    1,
    1,
    GETDATE(),
    'Sistema'
);
```

### **Variáveis do Prompt:**

| Variável | Fonte | Exemplo |
|----------|-------|---------|
| `{{nome_cliente}}` | Formulário do chat | "João Silva" |
| `{{fabricante_veiculo}}` | Seleção do usuário | "Chevrolet" |
| `{{modelo_veiculo}}` | Seleção do usuário | "S10" |
| `{{grupo_empresarial}}` | Seleção do usuário | "General Motors" |
| `{{mensagem_cliente}}` | Mensagem digitada | "Meu carro está apresentando barulho..." |

---

## 📝 Conteúdo do Prompt

O prompt inserido instrui a IA a:

### **1. Analisar o Problema:**
- Identificar sintomas principais
- Considerar causas prováveis
- Analisar o sistema afetado

### **2. Fazer Diagnóstico:**
- Explicar de forma clara
- Usar linguagem acessível
- Ser específico sobre o sistema

### **3. Listar Peças Necessárias:**
Para cada peça:
- Nome completo
- Código da peça
- Categoria (Freios, Suspensão, Motor, etc.)
- Prioridade (Alta, Média, Baixa)
- Motivo da necessidade

### **4. Dar Recomendações:**
- Ordem de verificação
- Necessidade de diagnóstico profissional
- Cuidados importantes

### **Formato de Resposta:**
```
🔍 **DIAGNÓSTICO:**
[Explicação clara do problema]

🔧 **PEÇAS NECESSÁRIAS:**

1. **[Nome da Peça]**
   - Código: [Código]
   - Categoria: [Categoria]
   - Prioridade: [Alta/Média/Baixa]
   - Motivo: [Explicação]

💡 **RECOMENDAÇÕES:**
- [Recomendação 1]
- [Recomendação 2]

⚠️ **IMPORTANTE:**
[Avisos especiais]
```

---

## 🚀 Como Aplicar a Correção

### **Passo 1: Executar Script SQL**

```sql
-- No SQL Server Management Studio
USE AI_Builder_Hackthon;
GO

-- Executar o script completo:
-- SQL/30_verificar_prompt_identificacao.sql
```

### **Passo 2: Verificar Inserção**

```sql
-- Verificar se o prompt foi inserido
SELECT 
    Id,
    Nome,
    Contexto,
    LEFT(ConteudoPrompt, 100) AS Preview,
    Ativo,
    Versao
FROM AIHT_Prompts
WHERE Contexto = 'identificacao_pecas';
```

**Resultado esperado:**
```
Id: [número]
Nome: Prompt de Identificação de Problemas
Contexto: identificacao_pecas
Preview: Você é um especialista em diagnóstico automotivo...
Ativo: 1
Versao: 1
```

### **Passo 3: Reiniciar Aplicação**

```bash
# No terminal onde o servidor está rodando
# Pressione Ctrl+C

# Inicie novamente
npm run dev
```

### **Passo 4: Testar no Chat**

1. Acesse: `http://192.168.15.35:3000/chat`
2. Preencha os dados do veículo
3. Inicie o chat
4. Digite: **"Meu carro está apresentando barulho na tampa da caçamba..."**
5. ✅ Sistema deve identificar o problema e sugerir peças!

---

## 🔍 Fluxo Corrigido

```
1. Usuário digita mensagem no chat
   ↓
2. Frontend chama /api/identificar-pecas
   ↓
3. API busca prompt: contexto = 'identificacao_pecas'
   ↓
4. ✅ PROMPT ENCONTRADO!
   ↓
5. API substitui variáveis:
   - {{nome_cliente}} → "João"
   - {{fabricante_veiculo}} → "Chevrolet"
   - {{modelo_veiculo}} → "S10"
   - {{grupo_empresarial}} → "GM"
   - {{mensagem_cliente}} → "Meu carro está..."
   ↓
6. API envia prompt para Gemini
   ↓
7. Gemini analisa e retorna diagnóstico
   ↓
8. API registra peças identificadas no banco
   ↓
9. Frontend exibe resposta ao usuário
```

---

## 📊 Contextos de Prompts

| Contexto | Usado Por | Propósito |
|----------|-----------|-----------|
| `identificacao_pecas` | `/api/identificar-pecas` | Identificar problemas e sugerir peças |
| `cotacao` | `/api/gerar-cotacao` | Gerar cotação com preços e links |

---

## 🧪 Testes de Validação

### **Teste 1: Problema de Freio**
```
Mensagem: "Meu freio está fazendo barulho"
Esperado: ✅ Identifica pastilhas, discos, fluido
```

### **Teste 2: Problema de Suspensão**
```
Mensagem: "Carro batendo em buracos"
Esperado: ✅ Identifica amortecedores, molas, buchas
```

### **Teste 3: Problema de Motor**
```
Mensagem: "Motor falhando"
Esperado: ✅ Identifica velas, bobinas, filtros
```

### **Teste 4: Problema da Caçamba (Caso do Usuário)**
```
Mensagem: "Barulho na tampa da caçamba ao passar em buracos"
Esperado: ✅ Identifica dobradiças, travas, borrachas
```

---

## ✅ Checklist de Validação

- [ ] Script SQL executado sem erros
- [ ] Prompt inserido na tabela `AIHT_Prompts`
- [ ] Contexto = `'identificacao_pecas'`
- [ ] Campo `ConteudoPrompt` preenchido
- [ ] Campo `Variaveis` lista as 5 variáveis
- [ ] Campo `Ativo` = 1
- [ ] Aplicação reiniciada
- [ ] Teste no chat funcionando
- [ ] Peças sendo identificadas corretamente
- [ ] Resposta formatada conforme esperado

---

## 🔧 Troubleshooting

### **Problema: Ainda retorna "Prompt não encontrado"**

**Verificar 1: Prompt existe?**
```sql
SELECT * FROM AIHT_Prompts 
WHERE Contexto = 'identificacao_pecas' AND Ativo = 1;
```

Se retornar vazio:
```sql
-- Executar novamente o script
-- SQL/30_verificar_prompt_identificacao.sql
```

**Verificar 2: SP funciona?**
```sql
EXEC AIHT_sp_ObterPromptPorContexto @Contexto = 'identificacao_pecas';
```

Deve retornar o prompt completo.

**Verificar 3: Aplicação reiniciada?**
```bash
# Ctrl+C no terminal
npm run dev
```

### **Problema: Prompt encontrado mas não substitui variáveis**

**Verificar código da API:**
```typescript
// Deve ter estas linhas:
promptProcessado = promptProcessado.replace(/\{\{grupo_empresarial\}\}/g, grupoEmpresarial);
promptProcessado = promptProcessado.replace(/\{\{fabricante_veiculo\}\}/g, fabricanteVeiculo);
promptProcessado = promptProcessado.replace(/\{\{modelo_veiculo\}\}/g, modeloVeiculo);
promptProcessado = promptProcessado.replace(/\{\{mensagem\}\}/g, mensagem);
promptProcessado = promptProcessado.replace(/\{\{nome_cliente\}\}/g, nomeCliente);
```

---

## 📁 Arquivos Relacionados

1. ✅ `SQL/30_verificar_prompt_identificacao.sql` - Script de correção
2. ✅ `app/api/identificar-pecas/route.ts` - API que usa o prompt
3. ✅ `CORRECAO_PROMPT_IDENTIFICACAO.md` - Este documento

---

## 🎯 Resultado Final

Após executar o script:

```
Mensagem: "Meu carro está apresentando barulho na tampa da caçamba..."
    ↓
Prompt encontrado: ✅
    ↓
Variáveis substituídas: ✅
    ↓
Enviado para Gemini: ✅
    ↓
Resposta recebida: ✅
    ↓
Peças identificadas: ✅
    ↓
Exibido no chat: ✅
```

---

**Correção aplicada! Execute o script SQL e teste! 🚀**

**Desenvolvido por Alan Alves de Oliveira - AI Builder Hackathon 2025**
