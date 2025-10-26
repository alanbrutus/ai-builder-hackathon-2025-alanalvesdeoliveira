# 🔧 Correção - Detecção de Cotação

**Data:** 25/10/2025  
**Problema:** Palavra "Cotação" não estava sendo detectada  
**Desenvolvedor:** Alan Alves de Oliveira

---

## 🐛 Problema Identificado

### **Situação:**
1. Usuário envia mensagem: "Cotação"
2. IA responde normalmente
3. Sistema NÃO gera cotação automaticamente

### **Causa Raiz:**
O sistema estava verificando apenas a **mensagem do cliente**, mas não verificava a **resposta da IA** para detectar palavras-chave de cotação.

---

## ✅ Correções Aplicadas

### **1. Fluxo Duplo de Verificação**

**Arquivo:** `app/chat/page.tsx`

Agora o sistema verifica em **DOIS momentos**:

#### **Verificação 1: Mensagem do Cliente**
```typescript
// Verifica se o cliente digitou palavra de cotação
const cotacaoResponse = await fetch('/api/gerar-cotacao', {
  method: 'POST',
  body: JSON.stringify({
    conversaId: conversaId,
    mensagemCliente: text // ← Mensagem do cliente
  })
});
```

#### **Verificação 2: Resposta da IA**
```typescript
// Se não detectou na mensagem do cliente, verifica na resposta da IA
if (!cotacaoData.intencaoCotacao) {
  const cotacaoRespostaResponse = await fetch('/api/gerar-cotacao', {
    method: 'POST',
    body: JSON.stringify({
      conversaId: conversaId,
      mensagemCliente: resposta // ← Resposta da IA
    })
  });
}
```

### **2. Palavras-Chave Garantidas**

**Arquivo:** `SQL/26_verificar_palavras_cotacao.sql`

Script que garante que as palavras essenciais estejam cadastradas:

```sql
-- Palavras essenciais
'cotação'
'cotacao' (sem acento)
'preço'
'preco'
'valor'
'quanto custa'
'quanto é'
'quero comprar'
'onde comprar'
'orçamento'
'orcamento'
```

---

## 🔄 Novo Fluxo Completo

### **Cenário 1: Cliente digita "Cotação"**

```
1. Cliente: "Cotação"
   ↓
2. Sistema verifica mensagem "Cotação" na tabela AIHT_PalavrasCotacao
   ↓
3. ✅ DETECTADO! (palavra existe na tabela)
   ↓
4. Sistema busca peças identificadas (AIHT_PecasIdentificadas)
   ↓
5. Sistema busca prompt de cotação (AIHT_Prompts WHERE Contexto = 'cotacao')
   ↓
6. Sistema substitui variáveis:
   - {{fabricante_veiculo}} → "Jeep"
   - {{modelo_veiculo}} → "Compass"
   - {{lista_pecas}} → "1. Pastilha de Freio - BRP123..."
   ↓
7. Sistema envia prompt para IA (Gemini)
   ↓
8. IA retorna cotação formatada
   ↓
9. Sistema exibe cotação no chat
```

### **Cenário 2: Cliente pergunta sobre problema**

```
1. Cliente: "Meu freio está fazendo barulho"
   ↓
2. Sistema verifica mensagem na tabela AIHT_PalavrasCotacao
   ↓
3. ❌ NÃO DETECTADO (não tem palavra de cotação)
   ↓
4. Sistema envia para IA identificar problema
   ↓
5. IA responde: "Detectei problema no freio. Peças: Pastilha, Disco..."
   ↓
6. Sistema verifica RESPOSTA DA IA na tabela AIHT_PalavrasCotacao
   ↓
7. ❌ NÃO DETECTADO (resposta não tem palavra de cotação)
   ↓
8. Sistema exibe apenas a resposta da IA
   ↓
9. Cliente: "Quanto custa?"
   ↓
10. Sistema verifica mensagem "Quanto custa?" na tabela
    ↓
11. ✅ DETECTADO! (expressão existe na tabela)
    ↓
12. Sistema gera cotação (passos 4-9 do Cenário 1)
```

---

## 🚀 Como Aplicar as Correções

### **Passo 1: Executar Script SQL**

```sql
-- No SQL Server Management Studio
USE AI_Builder_Hackthon;
GO

-- Executar o script completo:
-- SQL/26_verificar_palavras_cotacao.sql
```

### **Passo 2: Verificar Palavras Cadastradas**

```sql
SELECT 
    Id,
    Palavra,
    Tipo,
    Ativo
FROM AIHT_PalavrasCotacao
WHERE UPPER(Palavra) IN ('COTAÇÃO', 'COTACAO', 'PREÇO', 'PRECO')
ORDER BY Palavra;
```

**Resultado esperado:**
```
Id  Palavra    Tipo      Ativo
1   cotacao    Palavra   1
2   cotação    Palavra   1
3   preco      Palavra   1
4   preço      Palavra   1
```

### **Passo 3: Testar Detecção**

```sql
-- Testar com "Cotação"
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Cotação';

-- Resultado esperado:
-- IntencaoCotacao: 1
-- PalavrasEncontradas: cotação

-- Testar com "quanto custa"
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'quanto custa?';

-- Resultado esperado:
-- IntencaoCotacao: 1
-- PalavrasEncontradas: quanto custa
```

### **Passo 4: Reiniciar Aplicação**

```bash
# No terminal onde o servidor está rodando
# Pressione Ctrl+C

# Inicie novamente
npm run dev
```

### **Passo 5: Testar no Chat**

1. Acesse: `http://192.168.15.35:3000/chat`
2. Preencha dados do veículo
3. Inicie o chat
4. Digite: "Meu freio está fazendo barulho"
5. Aguarde a IA identificar as peças
6. Digite: **"Cotação"**
7. ✅ Sistema deve gerar cotação automaticamente!

---

## 🧪 Casos de Teste

### **Teste 1: Palavra "Cotação"**
```
Entrada: "Cotação"
Esperado: ✅ Cotação gerada
```

### **Teste 2: Palavra "cotacao" (sem acento)**
```
Entrada: "cotacao"
Esperado: ✅ Cotação gerada
```

### **Teste 3: Expressão "quanto custa"**
```
Entrada: "quanto custa?"
Esperado: ✅ Cotação gerada
```

### **Teste 4: Palavra "preço"**
```
Entrada: "qual o preço?"
Esperado: ✅ Cotação gerada
```

### **Teste 5: Palavra "comprar"**
```
Entrada: "quero comprar"
Esperado: ✅ Cotação gerada
```

### **Teste 6: Sem palavra-chave**
```
Entrada: "Meu freio está ruim"
Esperado: ❌ Apenas identificação, SEM cotação
```

---

## 📊 Logs para Debug

### **Console do Navegador:**
```javascript
🔍 Verificando intenção de cotação...
   Mensagem do cliente: Cotação

💰 Intenção de cotação detectada na mensagem do cliente!
   Palavras encontradas: cotação

📦 3 peças encontradas para cotação
📝 Prompt montado com variáveis substituídas
🤖 Enviando para Gemini...
✅ Cotação gerada com sucesso
```

### **Console do Servidor (Terminal):**
```
🔍 Verificando intenção de cotação...
   Intenção detectada: SIM
   Palavras encontradas: cotação

📦 3 peças encontradas para cotação
📝 Prompt montado com variáveis substituídas
🤖 Enviando para Gemini...
✅ Cotação gerada com sucesso
```

---

## 🔍 Troubleshooting

### **Problema: "Cotação" não detectada**

#### **Verificar 1: Palavra cadastrada?**
```sql
SELECT * FROM AIHT_PalavrasCotacao 
WHERE UPPER(Palavra) = 'COTAÇÃO';
```

Se retornar vazio:
```sql
INSERT INTO AIHT_PalavrasCotacao (Palavra, Tipo, Ativo, DataCriacao)
VALUES ('cotação', 'Palavra', 1, GETDATE());
```

#### **Verificar 2: SP funciona?**
```sql
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Cotação';
```

Deve retornar:
```
IntencaoCotacao: 1
PalavrasEncontradas: cotação
```

#### **Verificar 3: Há peças identificadas?**
```sql
SELECT * FROM AIHT_PecasIdentificadas 
WHERE ConversaId = [SEU_CONVERSA_ID];
```

Se retornar vazio, primeiro identifique um problema antes de solicitar cotação.

#### **Verificar 4: Prompt existe?**
```sql
SELECT * FROM AIHT_Prompts 
WHERE Contexto = 'cotacao' AND Ativo = 1;
```

Se retornar vazio, execute:
```sql
-- SQL/25_inserir_prompt_cotacao.sql
```

---

## ✅ Checklist de Validação

- [ ] Script SQL `26_verificar_palavras_cotacao.sql` executado
- [ ] Palavra "cotação" cadastrada na tabela
- [ ] Palavra "cotacao" (sem acento) cadastrada
- [ ] SP `AIHT_sp_VerificarIntencaoCotacao` funciona
- [ ] Arquivo `app/chat/page.tsx` atualizado
- [ ] Verificação dupla implementada (cliente + IA)
- [ ] Aplicação reiniciada
- [ ] Teste com "Cotação" funcionando
- [ ] Teste com "quanto custa" funcionando
- [ ] Logs aparecendo no console

---

## 📁 Arquivos Modificados

1. ✅ `app/chat/page.tsx` - Verificação dupla implementada
2. ✅ `SQL/26_verificar_palavras_cotacao.sql` - Script de verificação criado
3. ✅ `CORRECAO_DETECCAO_COTACAO.md` - Este documento

---

## 🎯 Resultado Esperado

Após as correções:

1. ✅ Palavra "Cotação" detectada
2. ✅ Palavra "cotacao" detectada
3. ✅ Expressões como "quanto custa" detectadas
4. ✅ Sistema verifica mensagem do cliente
5. ✅ Sistema verifica resposta da IA
6. ✅ Cotação gerada automaticamente
7. ✅ Prompt do contexto 'cotacao' utilizado
8. ✅ Variáveis substituídas corretamente

---

**Correção aplicada! Execute os scripts e teste! 🚀**

**Desenvolvido por Alan Alves de Oliveira - AI Builder Hackathon 2025**
