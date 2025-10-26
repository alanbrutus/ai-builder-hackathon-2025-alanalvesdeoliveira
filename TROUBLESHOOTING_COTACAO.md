# 🔧 Troubleshooting - Detecção de Cotação

**Data:** 25/10/2025  
**Problema:** Palavra "Cotação" não está sendo detectada  
**Desenvolvedor:** Alan Alves de Oliveira

---

## 🐛 Problema Relatado

Quando o usuário digita "Cotação", o sistema não está buscando o prompt correto de cotação. Em vez disso, está chamando o prompt de finalização.

---

## 🔍 Diagnóstico Passo a Passo

### **Passo 1: Verificar se as palavras estão cadastradas**

```sql
USE AI_Builder_Hackthon;
GO

SELECT * FROM AIHT_PalavrasCotacao WHERE Ativo = 1;
```

**Resultado esperado:**
```
Id | Palavra        | Tipo      | Ativo
---+----------------+-----------+------
1  | cotação        | Palavra   | 1
2  | cotacao        | Palavra   | 1
3  | preço          | Palavra   | 1
4  | preco          | Palavra   | 1
5  | quanto custa   | Expressao | 1
...
```

**❌ Se estiver vazio:**
```sql
-- Executar: SQL/26_verificar_palavras_cotacao.sql
```

---

### **Passo 2: Testar a Stored Procedure**

```sql
-- Teste direto
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Cotação';
```

**Resultado esperado:**
```
IntencaoCotacao | PalavrasEncontradas
----------------+--------------------
1               | cotação
```

**❌ Se retornar 0 ou NULL:**
```sql
-- Recriar a SP: SQL/28_corrigir_sp_verificar_cotacao.sql
```

---

### **Passo 3: Verificar se a SP existe**

```sql
SELECT 
    name,
    create_date,
    modify_date
FROM sys.procedures
WHERE name = 'AIHT_sp_VerificarIntencaoCotacao';
```

**❌ Se não existir:**
```sql
-- Executar: SQL/28_corrigir_sp_verificar_cotacao.sql
```

---

### **Passo 4: Testar API diretamente**

Abra o console do navegador e execute:

```javascript
// Teste da API de cotação
fetch('/api/gerar-cotacao', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    conversaId: 1, // Use um ID de conversa válido
    mensagemCliente: 'Cotação'
  })
})
.then(res => res.json())
.then(data => console.log('Resposta:', data));
```

**Resultado esperado:**
```json
{
  "success": true,
  "intencaoCotacao": true,
  "palavrasEncontradas": "cotação",
  "cotacao": "[Cotação gerada...]"
}
```

**❌ Se `intencaoCotacao: false`:**
- A SP não está detectando a palavra
- Verificar passos 1 e 2

---

### **Passo 5: Verificar logs do servidor**

No terminal onde o servidor está rodando, procure por:

```
🔍 Verificando intenção de cotação...
   Intenção detectada: SIM  ← Deve ser SIM
   Palavras encontradas: cotação
```

**❌ Se aparecer "NÃO":**
- A SP está retornando 0
- Voltar ao Passo 2

---

## 🔧 Soluções

### **Solução 1: Executar Scripts SQL na Ordem**

```sql
USE AI_Builder_Hackthon;
GO

-- 1. Verificar e inserir palavras
-- SQL/26_verificar_palavras_cotacao.sql

-- 2. Corrigir/criar a SP
-- SQL/28_corrigir_sp_verificar_cotacao.sql

-- 3. Testar
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Cotação';
-- Deve retornar: IntencaoCotacao = 1
```

---

### **Solução 2: Script de Diagnóstico Completo**

```sql
-- Executar: SQL/33_diagnostico_cotacao.sql
-- Este script faz todos os testes automaticamente
```

---

### **Solução 3: Verificar Collation**

```sql
-- Ver collation do banco
SELECT 
    name,
    collation_name
FROM sys.databases
WHERE name = 'AI_Builder_Hackthon';

-- Ver collation da coluna
SELECT 
    COLUMN_NAME,
    COLLATION_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'AIHT_PalavrasCotacao'
AND COLUMN_NAME = 'Palavra';
```

**Collation deve ser:** `SQL_Latin1_General_CP1_CI_AS`
- `CI` = Case Insensitive (ignora maiúsculas/minúsculas)
- `AS` = Accent Sensitive (diferencia acentos)

**❌ Se for diferente:**
```sql
ALTER TABLE AIHT_PalavrasCotacao
ALTER COLUMN Palavra NVARCHAR(100) 
COLLATE SQL_Latin1_General_CP1_CI_AS;
```

---

### **Solução 4: Recriar Tabela e SP do Zero**

```sql
-- 1. Limpar tudo
DROP PROCEDURE IF EXISTS AIHT_sp_VerificarIntencaoCotacao;
DELETE FROM AIHT_PalavrasCotacao;

-- 2. Recriar
-- Executar: SQL/26_verificar_palavras_cotacao.sql
-- Executar: SQL/28_corrigir_sp_verificar_cotacao.sql

-- 3. Testar
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Cotação';
```

---

## 🧪 Testes de Validação

### **Teste A: Palavra exata**
```sql
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Cotação';
-- Esperado: IntencaoCotacao = 1
```

### **Teste B: Palavra em frase**
```sql
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Preciso de uma cotação';
-- Esperado: IntencaoCotacao = 1
```

### **Teste C: Maiúsculas**
```sql
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'COTAÇÃO';
-- Esperado: IntencaoCotacao = 1
```

### **Teste D: Sem acento**
```sql
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'cotacao';
-- Esperado: IntencaoCotacao = 1
```

### **Teste E: Outras palavras**
```sql
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'preço';
-- Esperado: IntencaoCotacao = 1

EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'quanto custa';
-- Esperado: IntencaoCotacao = 1
```

### **Teste F: Sem palavra-chave (controle)**
```sql
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'obrigado';
-- Esperado: IntencaoCotacao = 0
```

---

## 📋 Checklist de Validação

Execute na ordem:

- [ ] **1.** Verificar tabela `AIHT_PalavrasCotacao` tem palavras
- [ ] **2.** Verificar SP `AIHT_sp_VerificarIntencaoCotacao` existe
- [ ] **3.** Testar SP com "Cotação" retorna 1
- [ ] **4.** Testar SP com "obrigado" retorna 0
- [ ] **5.** Verificar collation é CI (Case Insensitive)
- [ ] **6.** Reiniciar aplicação Next.js
- [ ] **7.** Testar no navegador com console aberto
- [ ] **8.** Verificar logs do servidor
- [ ] **9.** Confirmar que API retorna `intencaoCotacao: true`
- [ ] **10.** Confirmar que cotação é gerada

---

## 🎯 Fluxo Correto

```
1. Usuário digita: "Cotação"
   ↓
2. Frontend chama: /api/gerar-cotacao
   ↓
3. API executa: AIHT_sp_VerificarIntencaoCotacao
   ↓
4. SP verifica: UPPER('Cotação') LIKE '%COTAÇÃO%'
   ↓
5. SP retorna: IntencaoCotacao = 1, PalavrasEncontradas = 'cotação'
   ↓
6. API busca: Prompt com contexto 'cotacao'
   ↓
7. API monta: Prompt com variáveis substituídas
   ↓
8. API envia: Para Gemini
   ↓
9. API retorna: { success: true, intencaoCotacao: true, cotacao: "..." }
   ↓
10. Frontend exibe: Cotação com preços
```

---

## 🚨 Problemas Comuns

### **Problema 1: SP retorna 0**
**Causa:** Tabela `AIHT_PalavrasCotacao` vazia  
**Solução:** Executar `SQL/26_verificar_palavras_cotacao.sql`

### **Problema 2: SP não existe**
**Causa:** Script não foi executado  
**Solução:** Executar `SQL/28_corrigir_sp_verificar_cotacao.sql`

### **Problema 3: Collation errada**
**Causa:** Banco com collation case-sensitive  
**Solução:** Alterar collation da coluna (ver Solução 3)

### **Problema 4: Cache do Next.js**
**Causa:** Código antigo em cache  
**Solução:** 
```bash
# Limpar cache
rm -rf .next
npm run dev
```

### **Problema 5: Conexão com banco**
**Causa:** String de conexão incorreta  
**Solução:** Verificar `.env.local`

---

## 📞 Comandos Rápidos

### **Diagnóstico Rápido:**
```sql
-- Executar este bloco completo
USE AI_Builder_Hackthon;
GO

PRINT '1. Palavras cadastradas:';
SELECT COUNT(*) FROM AIHT_PalavrasCotacao WHERE Ativo = 1;

PRINT '2. SP existe:';
SELECT COUNT(*) FROM sys.procedures WHERE name = 'AIHT_sp_VerificarIntencaoCotacao';

PRINT '3. Teste:';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Cotação';
```

### **Correção Rápida:**
```sql
-- Se algo estiver errado, executar:
-- SQL/26_verificar_palavras_cotacao.sql
-- SQL/28_corrigir_sp_verificar_cotacao.sql
```

---

## ✅ Validação Final

Após executar as correções:

1. ✅ Abra o chat: `http://192.168.15.35:3000/chat`
2. ✅ Descreva um problema
3. ✅ Aguarde o diagnóstico
4. ✅ Digite: **"Cotação"**
5. ✅ Console deve mostrar:
   ```
   🔍 Verificando próximo passo após diagnóstico...
      Mensagem do cliente: Cotação
   💰 Intenção de cotação detectada!
      Palavras encontradas: cotação
   📦 X peças encontradas para cotação
   ✅ Cotação gerada com sucesso
   ```
6. ✅ Cotação deve ser exibida no chat

---

**Execute o diagnóstico e aplique as correções necessárias! 🚀**

**Desenvolvido por Alan Alves de Oliveira - AI Builder Hackathon 2025**
