# 🔄 Novo Fluxo de Cotação e Finalização

**Data:** 25/10/2025  
**Objetivo:** Implementar fluxo correto após diagnóstico  
**Desenvolvedor:** Alan Alves de Oliveira

---

## 🎯 Problema Anterior

Após o diagnóstico, quando o cliente respondia "Cotação", o sistema não estava gerando a cotação corretamente.

---

## ✅ Novo Fluxo Implementado

### **Fluxo Completo:**

```
1. Cliente descreve problema
   ↓
2. Sistema identifica problema e peças (API: /api/identificar-pecas)
   ↓
3. Sistema grava peças em AIHT_PecasIdentificadas
   ↓
4. IA pergunta: "Você gostaria de uma cotação?"
   ↓
5. Cliente responde
   ↓
6. Sistema verifica mensagem na tabela AIHT_PalavrasCotacao
   ↓
   ├─ SE CONTÉM palavra de cotação (ex: "Cotação", "quanto custa", "preço")
   │  ↓
   │  7a. Sistema busca prompt com contexto 'cotacao'
   │  ↓
   │  8a. Sistema monta prompt com:
   │      - {{fabricante_veiculo}}
   │      - {{modelo_veiculo}}
   │      - {{lista_pecas}} (busca de AIHT_PecasIdentificadas)
   │  ↓
   │  9a. Sistema envia para Gemini
   │  ↓
   │  10a. Exibe cotação com preços e links
   │
   └─ SE NÃO CONTÉM palavra de cotação (ex: "obrigado", "ok")
      ↓
      7b. Sistema busca prompt com contexto 'finalizacao'
      ↓
      8b. Sistema monta prompt com:
          - {{nome_cliente}}
          - {{fabricante_veiculo}}
          - {{modelo_veiculo}}
          - {{mensagem_cliente}}
          - {{diagnostico_anterior}}
      ↓
      9b. Sistema envia para Gemini
      ↓
      10b. Exibe mensagem de finalização educada
```

---

## 📝 Prompts Criados

### **1. Prompt de Identificação (identificacao_pecas)**

**Contexto:** `identificacao_pecas`  
**API:** `/api/identificar-pecas`  
**Quando:** Primeira mensagem do cliente descrevendo o problema

**Variáveis:**
- `{{nome_cliente}}`
- `{{fabricante_veiculo}}`
- `{{modelo_veiculo}}`
- `{{grupo_empresarial}}`
- `{{mensagem_cliente}}`

**Saída:** Diagnóstico + Lista de peças necessárias

---

### **2. Prompt de Cotação (cotacao)**

**Contexto:** `cotacao`  
**API:** `/api/gerar-cotacao`  
**Quando:** Cliente solicita cotação (palavra na tabela AIHT_PalavrasCotacao)

**Variáveis:**
- `{{fabricante_veiculo}}`
- `{{modelo_veiculo}}`
- `{{lista_pecas}}`

**Fonte dos dados:**
```sql
SELECT NomePeca, CodigoPeca, MarcaVeiculo, ModeloVeiculo
FROM AIHT_PecasIdentificadas
WHERE ConversaId = @ConversaId
```

**Saída:** Cotação detalhada com:
- Nome da peça
- Código
- Tipo (e-Commerce/Loja Física)
- Link/Endereço
- Preço estimado
- Condições de pagamento
- Observações

---

### **3. Prompt de Finalização (finalizacao)** ✨ **NOVO**

**Contexto:** `finalizacao`  
**API:** `/api/finalizar-atendimento`  
**Quando:** Cliente NÃO solicita cotação (sem palavra da tabela)

**Variáveis:**
- `{{nome_cliente}}`
- `{{fabricante_veiculo}}`
- `{{modelo_veiculo}}`
- `{{mensagem_cliente}}`
- `{{diagnostico_anterior}}`

**Saída:** Mensagem educada de finalização:
- Agradecimento
- Despedida
- Oferta de ajuda futura

---

## 🔍 Detecção de Intenção

### **Tabela: AIHT_PalavrasCotacao**

Palavras e expressões que indicam intenção de cotação:

| Palavra/Expressão | Tipo |
|-------------------|------|
| cotação | Palavra |
| cotacao | Palavra |
| preço | Palavra |
| preco | Palavra |
| valor | Palavra |
| quanto custa | Expressao |
| quanto é | Expressao |
| quanto sai | Expressao |
| qual o preço | Expressao |
| quero comprar | Expressao |
| onde comprar | Expressao |
| orçamento | Palavra |
| orcamento | Palavra |

### **Stored Procedure: AIHT_sp_VerificarIntencaoCotacao**

```sql
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Cotação';
-- Retorna: IntencaoCotacao = 1, PalavrasEncontradas = 'cotação'

EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'obrigado';
-- Retorna: IntencaoCotacao = 0, PalavrasEncontradas = NULL
```

---

## 🚀 Arquivos Criados/Modificados

### **1. SQL Scripts:**
- ✅ `SQL/31_corrigir_prompt_id_11.sql` - Corrige ID 11 como identificacao_pecas
- ✅ `SQL/32_criar_prompt_finalizacao.sql` - Cria prompt de finalização

### **2. API Routes:**
- ✅ `app/api/finalizar-atendimento/route.ts` - Nova API de finalização

### **3. Frontend:**
- ✅ `app/chat/page.tsx` - Fluxo ajustado com lógica correta

---

## 📊 Exemplos de Uso

### **Exemplo 1: Cliente Solicita Cotação**

```
Cliente: "Meu freio está fazendo barulho"
IA: [Diagnóstico] "Detectei problema nos freios. Peças: Pastilha, Disco.
     Alan, você gostaria de uma cotação para as peças necessárias?"

Cliente: "Cotação"
Sistema: Verifica "Cotação" em AIHT_PalavrasCotacao
         ✅ ENCONTROU!
         Chama /api/gerar-cotacao
         Busca prompt contexto 'cotacao'
         Monta lista de peças
         Envia para Gemini

IA: [Cotação]
    📦 Pastilha de Freio
    💰 R$ 150 - R$ 250
    🔗 Mercado Livre: [link]
    
    📦 Disco de Freio
    💰 R$ 200 - R$ 350
    🔗 OLX: [link]
```

### **Exemplo 2: Cliente Não Solicita Cotação**

```
Cliente: "Meu freio está fazendo barulho"
IA: [Diagnóstico] "Detectei problema nos freios. Peças: Pastilha, Disco.
     Alan, você gostaria de uma cotação para as peças necessárias?"

Cliente: "obrigado"
Sistema: Verifica "obrigado" em AIHT_PalavrasCotacao
         ❌ NÃO ENCONTROU!
         Chama /api/finalizar-atendimento
         Busca prompt contexto 'finalizacao'
         Envia para Gemini

IA: [Finalização]
    "Fico feliz em ajudar, Alan! 😊 Qualquer dúvida sobre o seu 
     Jeep Compass, estou à disposição. Boa sorte com o reparo! 🔧"
```

### **Exemplo 3: Cliente Faz Pergunta Adicional**

```
Cliente: "Meu freio está fazendo barulho"
IA: [Diagnóstico] "Detectei problema nos freios..."

Cliente: "É urgente trocar?"
Sistema: Verifica "É urgente trocar?" em AIHT_PalavrasCotacao
         ❌ NÃO ENCONTROU!
         Chama /api/finalizar-atendimento
         Busca prompt contexto 'finalizacao'

IA: [Finalização]
    "Sim, Alan! Problemas nos freios devem ser tratados com urgência
     por questões de segurança. Recomendo levar seu Jeep Compass
     a um mecânico o quanto antes. Se precisar de mais informações,
     estou aqui! 👍"
```

---

## 🔧 Como Aplicar

### **Passo 1: Executar Scripts SQL**

```sql
USE AI_Builder_Hackthon;
GO

-- 1. Corrigir prompt ID 11
-- SQL/31_corrigir_prompt_id_11.sql

-- 2. Criar prompt de finalização
-- SQL/32_criar_prompt_finalizacao.sql
```

### **Passo 2: Verificar Prompts**

```sql
SELECT Id, Nome, Contexto, Ativo
FROM AIHT_Prompts
WHERE Contexto IN ('identificacao_pecas', 'cotacao', 'finalizacao')
ORDER BY 
    CASE Contexto
        WHEN 'identificacao_pecas' THEN 1
        WHEN 'cotacao' THEN 2
        WHEN 'finalizacao' THEN 3
    END;
```

**Resultado esperado:**
```
Id: 11  | Nome: Prompt de Identificação | Contexto: identificacao_pecas
Id: [X] | Nome: Prompt de Cotação       | Contexto: cotacao
Id: [Y] | Nome: Prompt de Finalização   | Contexto: finalizacao
```

### **Passo 3: Reiniciar Aplicação**

```bash
# Ctrl+C no terminal
npm run dev
```

### **Passo 4: Testar Fluxo Completo**

**Teste A: Com Cotação**
1. Acesse: `http://192.168.15.35:3000/chat`
2. Digite: "Meu freio está fazendo barulho"
3. Aguarde diagnóstico
4. Digite: **"Cotação"**
5. ✅ Deve gerar cotação com preços

**Teste B: Sem Cotação**
1. Acesse: `http://192.168.15.35:3000/chat`
2. Digite: "Meu freio está fazendo barulho"
3. Aguarde diagnóstico
4. Digite: **"obrigado"**
5. ✅ Deve finalizar educadamente

---

## 📋 Checklist de Validação

- [ ] Script 31 executado (corrige ID 11)
- [ ] Script 32 executado (cria prompt finalização)
- [ ] Prompt ID 11 = `identificacao_pecas`
- [ ] Prompt novo = `cotacao`
- [ ] Prompt novo = `finalizacao`
- [ ] API `/api/finalizar-atendimento` criada
- [ ] Arquivo `app/chat/page.tsx` atualizado
- [ ] Aplicação reiniciada
- [ ] Teste com "Cotação" funciona
- [ ] Teste com "obrigado" funciona
- [ ] Logs aparecem no console

---

## 🔍 Logs para Debug

### **Console do Navegador:**

**Com cotação:**
```
🔍 Verificando próximo passo após diagnóstico...
   Mensagem do cliente: Cotação
💰 Intenção de cotação detectada!
   Palavras encontradas: cotação
📦 3 peças encontradas para cotação
✅ Cotação gerada com sucesso
```

**Sem cotação:**
```
🔍 Verificando próximo passo após diagnóstico...
   Mensagem do cliente: obrigado
🏁 Sem intenção de cotação. Finalizando atendimento...
✅ Atendimento finalizado
```

---

## 🎯 Resultado Final

### **Fluxo Correto:**

1. ✅ Cliente descreve problema
2. ✅ Sistema identifica e grava peças
3. ✅ IA pergunta sobre cotação
4. ✅ Sistema verifica palavra na mensagem
5. ✅ **SE TEM palavra:** Gera cotação (contexto 'cotacao')
6. ✅ **SE NÃO TEM palavra:** Finaliza educadamente (contexto 'finalizacao')

---

**Novo fluxo implementado! Execute os scripts e teste! 🚀**

**Desenvolvido por Alan Alves de Oliveira - AI Builder Hackathon 2025**
