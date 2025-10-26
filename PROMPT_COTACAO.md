# 📝 Prompt de Cotação - Configuração e Uso

**Data:** 25/10/2025  
**Desenvolvedor:** Alan Alves de Oliveira

---

## 🎯 Objetivo

Criar um prompt dinâmico na tabela `AIHT_Prompts` que será usado pela IA para gerar cotações detalhadas de peças automotivas, buscando informações em e-commerces e lojas físicas.

---

## 📋 Script SQL Criado

**Arquivo:** `SQL/25_inserir_prompt_cotacao.sql`

### **Funcionalidades:**
- ✅ Insere ou atualiza o prompt de cotação
- ✅ Contexto: `'cotacao'`
- ✅ Suporta variáveis dinâmicas
- ✅ Formato profissional com emojis

---

## 🔧 Como Executar

### **Passo 1: Executar o Script SQL**

```sql
-- No SQL Server Management Studio ou Azure Data Studio
USE AI_Builder_Hackthon;
GO

-- Executar o script
:r C:\TMP\ai-builder-hackathon-2025-alanalvesdeoliveira-1\SQL\25_inserir_prompt_cotacao.sql
```

**Ou copie e cole o conteúdo do arquivo diretamente.**

### **Passo 2: Verificar Inserção**

```sql
-- Verificar se o prompt foi inserido
SELECT 
    Id,
    Contexto,
    LEFT(TextoPrompt, 200) AS TextoPrompt_Preview,
    Ativo,
    DataCriacao
FROM AIHT_Prompts
WHERE Contexto = 'cotacao';
```

---

## 📝 Estrutura do Prompt

### **Variáveis Disponíveis:**

| Variável | Descrição | Fonte |
|----------|-----------|-------|
| `{{fabricante_veiculo}}` | Nome do fabricante | `AIHT_PecasIdentificadas` → `MarcaVeiculo` |
| `{{modelo_veiculo}}` | Nome do modelo | `AIHT_PecasIdentificadas` → `ModeloVeiculo` |
| `{{lista_pecas}}` | Lista formatada de peças | `AIHT_PecasIdentificadas` → `NomePeca` + `CodigoPeca` |

### **Formato da Lista de Peças:**

```
1. Pastilha de Freio - BRP123456
2. Disco de Freio - DFR789012
3. Fluido de Freio - FFR345678
```

---

## 🔄 Fluxo de Substituição de Variáveis

### **1. Buscar Prompt do Banco:**
```typescript
const promptResult = await pool
  .request()
  .input('Contexto', 'cotacao')
  .execute('AIHT_sp_ObterPromptPorContexto');
```

### **2. Buscar Peças da Conversa:**
```typescript
const pecasResult = await pool
  .request()
  .input('ConversaId', conversaId)
  .execute('AIHT_sp_ListarPecasParaCotacao');
```

### **3. Extrair Dados:**
```typescript
const fabricanteVeiculo = pecas[0]?.MarcaVeiculo || 'Veículo';
const modeloVeiculo = pecas[0]?.ModeloVeiculo || '';
const listaPecas = pecas.map((p, i) => 
  `${i + 1}. ${p.NomePeca} - ${p.CodigoPeca || 'Sem código'}`
).join('\n');
```

### **4. Substituir Variáveis:**
```typescript
const promptCotacao = promptTemplate
  .replace(/\{\{fabricante_veiculo\}\}/g, fabricanteVeiculo)
  .replace(/\{\{modelo_veiculo\}\}/g, modeloVeiculo)
  .replace(/\{\{lista_pecas\}\}/g, listaPecas);
```

---

## 📊 Exemplo de Prompt Processado

### **Antes (Template):**
```
Preciso que realize um processo de cotação para o {{fabricante_veiculo}} {{modelo_veiculo}} em e-Commerce e lojas presenciais para as peças relacionadas abaixo:

-- Início Peças
{{lista_pecas}}
-- Fim Peças
```

### **Depois (Processado):**
```
Preciso que realize um processo de cotação para o Jeep Compass em e-Commerce e lojas presenciais para as peças relacionadas abaixo:

-- Início Peças
1. Pastilha de Freio - BRP123456
2. Disco de Freio - DFR789012
3. Fluido de Freio - FFR345678
-- Fim Peças
```

---

## 🎯 Formato de Resposta Esperado da IA

Para cada peça, a IA deve retornar:

```
📦 **Nome da Peça:** Pastilha de Freio
🔢 **Código:** BRP123456
🏪 **Tipo:** e-Commerce
🔗 **Link:** https://mercadolivre.com.br/pastilha-freio-jeep-compass
💰 **Preço:** R$ 150,00 - R$ 250,00
💳 **Condições:** Até 12x sem juros
⭐ **Observações:** Original Bosch, entrega em 3-5 dias úteis
```

---

## 🧪 Como Testar

### **1. Executar o Script SQL:**
```bash
# No terminal SQL
sqlcmd -S .\ALYASQLEXPRESS -d AI_Builder_Hackthon -U AI_Hackthon -P "41@H4ckth0n" -i SQL/25_inserir_prompt_cotacao.sql
```

### **2. Reiniciar a Aplicação:**
```bash
# Parar o servidor (Ctrl+C)
# Iniciar novamente
npm run dev
```

### **3. Testar no Chat:**

1. Acesse: `http://192.168.15.35:3000/chat`
2. Preencha os dados do veículo (Jeep Compass, por exemplo)
3. Inicie o chat
4. Digite: "Meu freio está fazendo barulho"
5. Aguarde a IA identificar as peças
6. Digite: "Quanto custa essas peças?"
7. Observe a cotação gerada com o novo formato

---

## ✅ Checklist de Validação

- [ ] Script SQL executado sem erros
- [ ] Prompt inserido na tabela `AIHT_Prompts`
- [ ] Contexto = `'cotacao'`
- [ ] Prompt está ativo (`Ativo = 1`)
- [ ] API `/api/gerar-cotacao` atualizada
- [ ] Variáveis sendo substituídas corretamente
- [ ] Teste no chat funcionando
- [ ] Resposta da IA no formato esperado

---

## 🔍 Troubleshooting

### **Erro: "Prompt não encontrado"**
```sql
-- Verificar se existe
SELECT * FROM AIHT_Prompts WHERE Contexto = 'cotacao';

-- Se não existir, executar novamente o script
```

### **Variáveis não substituídas:**
```typescript
// Verificar logs no console
console.log('Fabricante:', fabricanteVeiculo);
console.log('Modelo:', modeloVeiculo);
console.log('Lista:', listaPecas);
```

### **Resposta da IA não formatada:**
- Verifique se o prompt tem as instruções de formatação
- Confirme que está usando o contexto `'cotacao'`
- Teste com o prompt padrão primeiro

---

## 📈 Melhorias Futuras

### **Curto Prazo:**
- [ ] Adicionar variável `{{nome_cliente}}`
- [ ] Incluir `{{regiao}}` para lojas físicas
- [ ] Adicionar `{{urgencia}}` (normal/urgente)

### **Médio Prazo:**
- [ ] Múltiplos prompts por região
- [ ] Personalização por tipo de veículo
- [ ] Histórico de cotações

### **Longo Prazo:**
- [ ] Integração real com APIs de e-commerce
- [ ] Preços em tempo real
- [ ] Comparador automático

---

## 📝 Arquivos Relacionados

- `SQL/25_inserir_prompt_cotacao.sql` - Script de inserção
- `app/api/gerar-cotacao/route.ts` - API atualizada
- `SQL/23_tabela_palavras_cotacao.sql` - Palavras-chave
- `SQL/24_atualizar_sp_verificar_cotacao.sql` - SP de detecção

---

## 🎓 Conceitos Aplicados

### **1. Prompts Dinâmicos:**
Armazenar prompts no banco permite:
- ✅ Edição sem redeploy
- ✅ Versionamento
- ✅ A/B testing
- ✅ Personalização por contexto

### **2. Substituição de Variáveis:**
Usar `{{variavel}}` permite:
- ✅ Reutilização de prompts
- ✅ Personalização automática
- ✅ Manutenção simplificada
- ✅ Testes mais fáceis

### **3. Separação de Responsabilidades:**
- **Banco de Dados:** Armazena template
- **API:** Busca dados e substitui variáveis
- **IA:** Processa prompt final

---

**Prompt de cotação configurado e pronto para uso!** 🚀

**Desenvolvido por Alan Alves de Oliveira - AI Builder Hackathon 2025**
