# 🔍 Diagnóstico - Por que não está buscando o prompt?

**Data:** 25/10/2025  
**Problema:** API não encontra prompt de finalização  
**Desenvolvedor:** Alan Alves de Oliveira

---

## 🎯 Sua Pergunta

> "Porque nessa abordagem inicial não está buscando o prompt na tabela AIHT_Prompts corretamente?"

---

## 🔍 Possíveis Causas

### **1. Prompt de Finalização Não Foi Criado**

**Causa mais provável:** O script `SQL/32_criar_prompt_finalizacao.sql` não foi executado.

**Como verificar:**
```sql
SELECT * FROM AIHT_Prompts WHERE Contexto = 'finalizacao';
```

**Resultado esperado:**
- ✅ Deve retornar 1 registro
- ❌ Se retornar 0, o prompt não existe

**Solução:**
```sql
-- Executar: SQL/32_criar_prompt_finalizacao.sql
```

---

### **2. Prompt Está Inativo**

**Causa:** Prompt existe mas `Ativo = 0`

**Como verificar:**
```sql
SELECT Id, Contexto, Ativo FROM AIHT_Prompts WHERE Contexto = 'finalizacao';
```

**Resultado esperado:**
```
Id | Contexto    | Ativo
---+-------------+------
X  | finalizacao | 1     ← Deve ser 1
```

**Solução:**
```sql
UPDATE AIHT_Prompts 
SET Ativo = 1 
WHERE Contexto = 'finalizacao';
```

---

### **3. Contexto com Grafia Diferente**

**Causa:** Contexto cadastrado diferente (ex: 'Finalizacao', 'FINALIZACAO')

**Como verificar:**
```sql
SELECT Contexto FROM AIHT_Prompts;
```

**Deve ter:**
- `identificacao_pecas` (tudo minúsculo, com underline)
- `cotacao` (tudo minúsculo, sem acento)
- `finalizacao` (tudo minúsculo)

**Se estiver diferente:**
```sql
UPDATE AIHT_Prompts 
SET Contexto = 'finalizacao' 
WHERE Contexto LIKE '%finaliza%';
```

---

### **4. ConteudoPrompt é NULL**

**Causa:** Prompt existe mas `ConteudoPrompt` está vazio

**Como verificar:**
```sql
SELECT 
    Id, 
    Contexto, 
    ConteudoPrompt,
    LEN(ConteudoPrompt) AS Tamanho
FROM AIHT_Prompts 
WHERE Contexto = 'finalizacao';
```

**Resultado esperado:**
```
Id | Contexto    | Tamanho
---+-------------+--------
X  | finalizacao | 1500+  ← Deve ter conteúdo
```

**Se Tamanho = NULL ou 0:**
```sql
-- Executar novamente: SQL/32_criar_prompt_finalizacao.sql
```

---

### **5. Stored Procedure Não Existe**

**Causa:** SP `AIHT_sp_ObterPromptPorContexto` não foi criada

**Como verificar:**
```sql
SELECT name FROM sys.procedures WHERE name = 'AIHT_sp_ObterPromptPorContexto';
```

**Se não retornar nada:**
```sql
-- Executar: SQL/09_criar_sp_obter_prompt.sql
```

---

## 🧪 Script de Diagnóstico Completo

**Execute:** `SQL/36_verificar_prompts.sql`

Este script vai:
1. ✅ Listar todos os prompts
2. ✅ Verificar se identificacao_pecas existe
3. ✅ Verificar se cotacao existe
4. ✅ Verificar se finalizacao existe
5. ✅ Testar a SP com cada contexto
6. ✅ Mostrar conteúdo completo
7. ✅ Dar resumo e soluções

---

## 📊 Como a SP Funciona

### **Stored Procedure: `AIHT_sp_ObterPromptPorContexto`**

```sql
CREATE OR ALTER PROCEDURE AIHT_sp_ObterPromptPorContexto
    @Contexto NVARCHAR(100)
AS
BEGIN
    SELECT 
        Id,
        Contexto,
        ConteudoPrompt,  ← Este campo é retornado
        Descricao,
        Versao,
        Ativo,
        DataCriacao,
        DataAtualizacao
    FROM AIHT_Prompts
    WHERE Contexto = @Contexto  ← Busca exata
        AND Ativo = 1           ← Só ativos
    ORDER BY Versao DESC;       ← Versão mais recente
END
```

### **Como a API usa:**

```typescript
const promptResult = await pool
  .request()
  .input('Contexto', 'finalizacao')  ← Passa o contexto
  .execute('AIHT_sp_ObterPromptPorContexto');

// Verifica se encontrou
if (!promptResult.recordset || promptResult.recordset.length === 0) {
  // ❌ Não encontrou
  console.warn('Prompt não encontrado');
} else {
  // ✅ Encontrou
  const prompt = promptResult.recordset[0].ConteudoPrompt;
}
```

---

## ✅ Checklist de Verificação

Execute na ordem:

### **1. Verificar se prompts existem:**
```sql
-- Execute: SQL/36_verificar_prompts.sql
```

### **2. Se faltarem prompts, executar:**
```sql
-- Se falta identificacao_pecas:
-- SQL/30_verificar_prompt_identificacao.sql

-- Se falta cotacao:
-- SQL/25_inserir_prompt_cotacao.sql

-- Se falta finalizacao:
-- SQL/32_criar_prompt_finalizacao.sql
```

### **3. Verificar SP:**
```sql
SELECT name FROM sys.procedures WHERE name = 'AIHT_sp_ObterPromptPorContexto';
```

### **4. Testar SP manualmente:**
```sql
EXEC AIHT_sp_ObterPromptPorContexto @Contexto = 'finalizacao';
-- Deve retornar 1 registro com ConteudoPrompt preenchido
```

### **5. Reiniciar aplicação:**
```bash
# Ctrl+C
npm run dev
```

---

## 🎯 Solução Mais Provável

**99% de chance:** O script `SQL/32_criar_prompt_finalizacao.sql` **não foi executado**.

### **Como resolver:**

1. **Executar o script:**
```sql
-- No SQL Server Management Studio
-- Abrir e executar: SQL/32_criar_prompt_finalizacao.sql
```

2. **Verificar:**
```sql
SELECT * FROM AIHT_Prompts WHERE Contexto = 'finalizacao';
-- Deve retornar 1 registro
```

3. **Testar SP:**
```sql
EXEC AIHT_sp_ObterPromptPorContexto @Contexto = 'finalizacao';
-- Deve retornar o prompt completo
```

4. **Reiniciar app:**
```bash
npm run dev
```

---

## 📋 Resumo

| Problema | Causa | Solução |
|----------|-------|---------|
| Prompt não encontrado | Script 32 não executado | Executar SQL/32 |
| Prompt inativo | Ativo = 0 | UPDATE Ativo = 1 |
| Contexto diferente | Grafia errada | UPDATE Contexto |
| ConteudoPrompt NULL | Inserção falhou | Re-executar script |
| SP não existe | Script 09 não executado | Executar SQL/09 |

---

## 🚀 Ação Imediata

**Execute agora:**

```sql
-- 1. Verificar diagnóstico
-- SQL/36_verificar_prompts.sql

-- 2. Se não tiver prompt de finalização
-- SQL/32_criar_prompt_finalizacao.sql

-- 3. Testar
EXEC AIHT_sp_ObterPromptPorContexto @Contexto = 'finalizacao';
```

---

**Execute o diagnóstico para identificar o problema exato! 🔍**

**Desenvolvido por Alan Alves de Oliveira - AI Builder Hackathon 2025**
