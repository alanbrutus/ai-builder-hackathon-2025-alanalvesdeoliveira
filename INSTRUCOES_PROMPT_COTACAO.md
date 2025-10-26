# 📝 Instruções - Prompt de Cotação

**Data:** 25/10/2025  
**Desenvolvedor:** Alan Alves de Oliveira

---

## ✅ Correções Aplicadas

### **1. Estrutura da Tabela Corrigida**

A tabela `AIHT_Prompts` possui a seguinte estrutura:

```sql
[Id] INT IDENTITY(1,1) PRIMARY KEY
[Nome] VARCHAR
[Descricao] VARCHAR
[Contexto] VARCHAR
[ConteudoPrompt] NVARCHAR(MAX)  -- ⚠️ Campo correto!
[Variaveis] VARCHAR
[Ativo] BIT
[Versao] INT
[DataCriacao] DATETIME
[DataAtualizacao] DATETIME
[CriadoPor] VARCHAR
[AtualizadoPor] VARCHAR
```

### **2. Script SQL Atualizado**

**Arquivo:** `SQL/25_inserir_prompt_cotacao.sql`

O script agora usa os campos corretos:
- ✅ `Nome` - Nome do prompt
- ✅ `Descricao` - Descrição do propósito
- ✅ `Contexto` - 'cotacao'
- ✅ `ConteudoPrompt` - Texto do prompt com variáveis
- ✅ `Variaveis` - Lista de variáveis disponíveis
- ✅ `Versao` - Controle de versão automático
- ✅ `CriadoPor` / `AtualizadoPor` - Auditoria

### **3. API Atualizada**

**Arquivo:** `app/api/gerar-cotacao/route.ts`

Mudança aplicada:
```typescript
// ANTES (errado)
let promptTemplate = promptResult.recordset[0]?.TextoPrompt;

// DEPOIS (correto)
let promptTemplate = promptResult.recordset[0]?.ConteudoPrompt;
```

---

## 🚀 Como Executar

### **Passo 1: Executar o Script SQL**

Abra o SQL Server Management Studio ou Azure Data Studio e execute:

```sql
USE AI_Builder_Hackthon;
GO

-- Copie e cole o conteúdo completo do arquivo:
-- SQL/25_inserir_prompt_cotacao.sql
```

### **Passo 2: Verificar Inserção**

```sql
SELECT 
    Id,
    Nome,
    Descricao,
    Contexto,
    LEFT(ConteudoPrompt, 200) AS Preview,
    Variaveis,
    Ativo,
    Versao,
    DataCriacao,
    CriadoPor
FROM AIHT_Prompts
WHERE Contexto = 'cotacao';
```

**Resultado Esperado:**
```
Id: 1 (ou outro número)
Nome: Prompt de Cotação de Peças
Descricao: Prompt utilizado para gerar cotações...
Contexto: cotacao
Preview: Preciso que realize um processo de cotação...
Variaveis: {{fabricante_veiculo}}, {{modelo_veiculo}}, {{lista_pecas}}
Ativo: 1
Versao: 1
```

### **Passo 3: Reiniciar a Aplicação**

```bash
# No terminal onde o servidor está rodando
# Pressione Ctrl+C para parar

# Inicie novamente
npm run dev
```

### **Passo 4: Testar no Chat**

1. Acesse: `http://192.168.15.35:3000/chat`
2. Preencha os dados:
   - Nome: Seu nome
   - Grupo: Stellantis
   - Fabricante: Jeep
   - Modelo: Compass
3. Clique em "Iniciar Chat"
4. Digite: "Meu freio está fazendo barulho"
5. Aguarde a IA identificar as peças
6. Digite: "Quanto custa essas peças?"
7. Observe a cotação gerada!

---

## 📊 Dados do Prompt

### **Campos Inseridos:**

| Campo | Valor |
|-------|-------|
| **Nome** | Prompt de Cotação de Peças |
| **Descrição** | Prompt utilizado para gerar cotações detalhadas de peças automotivas em e-commerce e lojas físicas |
| **Contexto** | cotacao |
| **Variáveis** | {{fabricante_veiculo}}, {{modelo_veiculo}}, {{lista_pecas}} |
| **Ativo** | 1 (Sim) |
| **Versão** | 1 (incrementa automaticamente em updates) |
| **CriadoPor** | Sistema |

### **Conteúdo do Prompt:**

```
Preciso que realize um processo de cotação para o {{fabricante_veiculo}} {{modelo_veiculo}} 
em e-Commerce e lojas presenciais para as peças relacionadas abaixo:

-- Início Peças
{{lista_pecas}}
-- Fim Peças

Para cada peça identificada, retorne as seguintes informações:

📦 **Nome da Peça:** [Nome completo da peça]
🔢 **Código:** [Código da peça]
🏪 **Tipo:** [e-Commerce ou Loja Física]
🔗 **Link/Endereço:** [URL do e-commerce ou endereço completo da loja física]
💰 **Preço:** [Faixa de preço estimada]
💳 **Condições de Pagamento:** [Formas de pagamento disponíveis]
⭐ **Observações:** [Disponibilidade, prazo de entrega, etc]

---

**IMPORTANTE:**
- Pesquise em múltiplos e-commerces: Mercado Livre, OLX, Shopee, Amazon
- Para lojas físicas, indique endereços reais na região (se possível)
- Forneça faixas de preço realistas baseadas no mercado atual
- Indique se a peça é original, paralela ou genérica
- Mencione prazos de entrega estimados
- Sugira as melhores opções custo-benefício

**FORMATO DE RESPOSTA:**
Use emojis e formatação clara para facilitar a leitura. 
Organize as informações de forma estruturada e profissional.
```

---

## 🔄 Fluxo de Substituição

### **1. Cliente solicita cotação:**
```
Cliente: "Quanto custa essas peças?"
```

### **2. API detecta intenção:**
```typescript
// AIHT_sp_VerificarIntencaoCotacao
IntencaoCotacao: true
PalavrasEncontradas: "quanto custa"
```

### **3. API busca peças:**
```typescript
// AIHT_sp_ListarPecasParaCotacao
ConversaId: 123
Resultado: [
  { NomePeca: "Pastilha de Freio", CodigoPeca: "BRP123", MarcaVeiculo: "Jeep", ModeloVeiculo: "Compass" },
  { NomePeca: "Disco de Freio", CodigoPeca: "DFR456", MarcaVeiculo: "Jeep", ModeloVeiculo: "Compass" }
]
```

### **4. API busca prompt:**
```typescript
// AIHT_sp_ObterPromptPorContexto
Contexto: 'cotacao'
Resultado: { ConteudoPrompt: "Preciso que realize..." }
```

### **5. API substitui variáveis:**
```typescript
fabricanteVeiculo = "Jeep"
modeloVeiculo = "Compass"
listaPecas = "1. Pastilha de Freio - BRP123\n2. Disco de Freio - DFR456"

promptFinal = promptTemplate
  .replace(/\{\{fabricante_veiculo\}\}/g, "Jeep")
  .replace(/\{\{modelo_veiculo\}\}/g, "Compass")
  .replace(/\{\{lista_pecas\}\}/g, listaPecas)
```

### **6. Prompt final enviado à IA:**
```
Preciso que realize um processo de cotação para o Jeep Compass 
em e-Commerce e lojas presenciais para as peças relacionadas abaixo:

-- Início Peças
1. Pastilha de Freio - BRP123
2. Disco de Freio - DFR456
-- Fim Peças

[... resto das instruções ...]
```

### **7. IA retorna cotação:**
```
📦 **Nome da Peça:** Pastilha de Freio
🔢 **Código:** BRP123
🏪 **Tipo:** e-Commerce
🔗 **Link:** https://mercadolivre.com.br/...
💰 **Preço:** R$ 150,00 - R$ 250,00
💳 **Condições:** Até 12x sem juros
⭐ **Observações:** Original Bosch, entrega em 3-5 dias
```

---

## ✅ Checklist Final

- [ ] Script SQL executado sem erros
- [ ] Prompt inserido na tabela `AIHT_Prompts`
- [ ] Campo `ConteudoPrompt` preenchido corretamente
- [ ] Campo `Variaveis` lista as 3 variáveis
- [ ] Campo `Ativo` = 1
- [ ] Campo `Versao` = 1
- [ ] API usando `ConteudoPrompt` (não `TextoPrompt`)
- [ ] Aplicação reiniciada
- [ ] Teste no chat funcionando
- [ ] Variáveis sendo substituídas corretamente
- [ ] Resposta da IA formatada conforme esperado

---

## 🔍 Troubleshooting

### **Erro: "Prompt não encontrado"**
```sql
-- Verificar se existe
SELECT * FROM AIHT_Prompts WHERE Contexto = 'cotacao';

-- Se retornar vazio, executar novamente o script
```

### **Erro: "Invalid column name 'ConteudoPrompt'"**
```sql
-- Verificar estrutura da tabela
EXEC sp_columns 'AIHT_Prompts';

-- Confirmar que existe a coluna ConteudoPrompt
```

### **Variáveis não substituídas (aparecem {{...}} na resposta)**
```typescript
// Verificar logs no console do servidor
console.log('Fabricante:', fabricanteVeiculo);
console.log('Modelo:', modeloVeiculo);
console.log('Lista:', listaPecas);
console.log('Prompt final:', promptCotacao);
```

### **Resposta da IA sem formatação**
- Verifique se o prompt foi inserido completamente
- Confirme que as instruções de formatação estão no `ConteudoPrompt`
- Teste com uma conversa que tenha peças identificadas

---

## 📁 Arquivos Envolvidos

1. ✅ `SQL/25_inserir_prompt_cotacao.sql` - Script de inserção (ATUALIZADO)
2. ✅ `app/api/gerar-cotacao/route.ts` - API de cotação (ATUALIZADO)
3. ✅ `PROMPT_COTACAO.md` - Documentação detalhada
4. ✅ `INSTRUCOES_PROMPT_COTACAO.md` - Este arquivo

---

**Tudo pronto! Execute o script SQL e teste a cotação! 🚀**

**Desenvolvido por Alan Alves de Oliveira - AI Builder Hackathon 2025**
