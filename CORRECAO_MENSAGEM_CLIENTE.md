# ✅ Correção Final - MensagemCliente NULL

**Data:** 25/10/2025  
**Problema:** Cannot insert NULL into column 'MensagemCliente'  
**Causa:** SP não tinha parâmetro MensagemCliente  
**Desenvolvedor:** Alan Alves de Oliveira

---

## 🎯 Problema Encontrado

### **Erro:**
```
Cannot insert the value NULL into column 'MensagemCliente', 
table 'AIHT_LogChamadasIA'; column does not allow nulls.
```

### **Causa:**
A tabela `AIHT_LogChamadasIA` tem a coluna `MensagemCliente NOT NULL`, mas a stored procedure `AIHT_sp_RegistrarChamadaIA` **não tinha esse parâmetro**!

---

## 📊 Análise

### **Tabela (Criada em SQL/13):**
```sql
CREATE TABLE AIHT_LogChamadasIA (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ConversaId INT NULL,
    MensagemCliente NVARCHAR(MAX) NOT NULL,  ← Coluna existe e é NOT NULL
    PromptEnviado NVARCHAR(MAX) NULL,
    ...
);
```

### **SP Antiga (ERRADA):**
```sql
CREATE PROCEDURE AIHT_sp_RegistrarChamadaIA
    @ConversaId INT = NULL,
    @TipoChamada VARCHAR(50) = NULL,
    -- ❌ FALTAVA: @MensagemCliente
    @PromptEnviado NVARCHAR(MAX),
    ...
AS
BEGIN
    INSERT INTO AIHT_LogChamadasIA (
        ConversaId,
        TipoChamada,
        -- ❌ FALTAVA: MensagemCliente
        PromptEnviado,
        ...
    )
    VALUES (
        @ConversaId,
        @TipoChamada,
        -- ❌ FALTAVA: @MensagemCliente
        @PromptEnviado,
        ...
    );
END
```

---

## ✅ Correção Aplicada

### **1. SQL - Atualizar SP:**

**Arquivo:** `SQL/35_atualizar_log_chamadas_ia.sql`

```sql
CREATE OR ALTER PROCEDURE AIHT_sp_RegistrarChamadaIA
    @ConversaId INT = NULL,
    @TipoChamada VARCHAR(50) = NULL,
    @MensagemCliente NVARCHAR(MAX) = 'Mensagem não informada',  ← ADICIONADO
    @PromptEnviado NVARCHAR(MAX),
    @RespostaRecebida NVARCHAR(MAX) = NULL,
    @TempoResposta INT = NULL,
    @Sucesso BIT,
    @MensagemErro NVARCHAR(MAX) = NULL,
    @ModeloIA NVARCHAR(100) = 'gemini-pro'
AS
BEGIN
    INSERT INTO AIHT_LogChamadasIA (
        ConversaId,
        TipoChamada,
        MensagemCliente,  ← ADICIONADO
        PromptEnviado,
        RespostaRecebida,
        TempoResposta,
        Sucesso,
        MensagemErro,
        ModeloIA
    )
    VALUES (
        @ConversaId,
        @TipoChamada,
        @MensagemCliente,  ← ADICIONADO
        @PromptEnviado,
        @RespostaRecebida,
        @TempoResposta,
        @Sucesso,
        @MensagemErro,
        @ModeloIA
    );
END
```

### **2. APIs - Adicionar Parâmetro:**

**Todas as 3 APIs foram atualizadas:**

#### **A. `/api/identificar-pecas/route.ts`**
```typescript
await pool
  .request()
  .input('ConversaId', conversaId)
  .input('TipoChamada', 'identificacao_pecas')
  .input('MensagemCliente', mensagem || 'Mensagem não informada')  ← ADICIONADO
  .input('PromptEnviado', promptProcessado || 'Prompt não disponível')
  .input('RespostaRecebida', ...)
  .execute('AIHT_sp_RegistrarChamadaIA');
```

#### **B. `/api/gerar-cotacao/route.ts`**
```typescript
await pool
  .request()
  .input('ConversaId', conversaId)
  .input('TipoChamada', 'cotacao')
  .input('MensagemCliente', mensagemCliente || 'Mensagem não informada')  ← ADICIONADO
  .input('PromptEnviado', promptCotacao || 'Prompt não disponível')
  .input('RespostaRecebida', ...)
  .execute('AIHT_sp_RegistrarChamadaIA');
```

#### **C. `/api/finalizar-atendimento/route.ts`**
```typescript
await pool
  .request()
  .input('ConversaId', conversaId)
  .input('TipoChamada', 'finalizacao')
  .input('MensagemCliente', mensagemCliente || 'Mensagem não informada')  ← ADICIONADO
  .input('PromptEnviado', promptProcessado || 'Prompt não disponível')
  .input('RespostaRecebida', ...)
  .execute('AIHT_sp_RegistrarChamadaIA');
```

---

## 🚀 Como Aplicar

### **Passo 1: Executar SQL**
```sql
-- No SQL Server Management Studio
-- Executar: SQL/35_atualizar_log_chamadas_ia.sql
```

### **Passo 2: Reiniciar Aplicação**
```bash
# Ctrl+C
npm run dev
```

### **Passo 3: Testar**
1. Acesse: `http://192.168.15.35:3000/chat`
2. Digite problema
3. ✅ Deve gravar log com MensagemCliente

---

## 📋 Verificar Logs

```sql
SELECT TOP 5
    Id,
    ConversaId,
    TipoChamada,
    MensagemCliente,  ← Agora deve ter valor
    LEFT(PromptEnviado, 50) AS Prompt,
    Sucesso,
    DataChamada
FROM AIHT_LogChamadasIA
ORDER BY DataChamada DESC;
```

**Resultado esperado:**
```
Id | TipoChamada          | MensagemCliente                    | Sucesso
---+----------------------+------------------------------------+---------
1  | identificacao_pecas  | Meu carro está com barulho...      | 1
2  | cotacao              | Cotação                            | 1
3  | finalizacao          | obrigado                           | 1
```

---

## ✅ Checklist

- [x] SP atualizada com parâmetro @MensagemCliente
- [x] SP atualizada com INSERT de MensagemCliente
- [x] API identificar-pecas atualizada
- [x] API gerar-cotacao atualizada
- [x] API finalizar-atendimento atualizada
- [ ] **SQL executado** ← FAZER AGORA
- [ ] **Aplicação reiniciada**
- [ ] **Teste realizado**
- [ ] **Logs verificados**

---

## 🎯 Resumo

| Componente | Status | Observação |
|------------|--------|------------|
| Tabela AIHT_LogChamadasIA | ✅ | Tem coluna MensagemCliente NOT NULL |
| SP AIHT_sp_RegistrarChamadaIA | ✅ | Agora tem parâmetro @MensagemCliente |
| API identificar-pecas | ✅ | Passa MensagemCliente |
| API gerar-cotacao | ✅ | Passa MensagemCliente |
| API finalizar-atendimento | ✅ | Passa MensagemCliente |

---

**AGORA DEVE FUNCIONAR! Execute o SQL e reinicie! 🎉**

**Desenvolvido por Alan Alves de Oliveira - AI Builder Hackathon 2025**
