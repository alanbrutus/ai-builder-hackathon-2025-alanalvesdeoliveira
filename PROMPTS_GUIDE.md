# 📝 Guia do Sistema de Prompts da IA

## 🎯 **Visão Geral**

O sistema de prompts permite armazenar e gerenciar os prompts da IA no banco de dados, possibilitando alterações sem necessidade de redeploy da aplicação.

---

## 🗄️ **Estrutura do Banco de Dados**

### **Tabela: AIHT_Prompts**

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `Id` | INT | Identificador único |
| `Nome` | NVARCHAR(100) | Nome do prompt |
| `Descricao` | NVARCHAR(500) | Descrição do propósito |
| `Contexto` | NVARCHAR(50) | Contexto de uso (atendimento, recomendacao, finalizacao) |
| `ConteudoPrompt` | NVARCHAR(MAX) | Conteúdo do prompt com variáveis |
| `Variaveis` | NVARCHAR(500) | JSON com lista de variáveis |
| `Ativo` | BIT | Se o prompt está ativo |
| `Versao` | INT | Versão do prompt |
| `DataCriacao` | DATETIME | Data de criação |
| `DataAtualizacao` | DATETIME | Data da última atualização |

---

## 📋 **Prompts Padrão**

### **1. Atendimento Inicial** (`atendimento`)

**Quando usar:** Após coleta de nome, grupo, fabricante e modelo

**Variáveis:**
- `{{nome_cliente}}`
- `{{grupo_empresarial}}`
- `{{fabricante_veiculo}}`
- `{{modelo_veiculo}}`

**Exemplo:**
```
Olá {{nome_cliente}}, tudo bem? Sou seu assistente virtual especializado em peças automotivas. 
Vejo que você tem um {{fabricante_veiculo}} {{modelo_veiculo}} do grupo {{grupo_empresarial}}. 
Pode me contar qual é o problema ou o que você está precisando para o veículo hoje?
```

---

### **2. Recomendação de Peças** (`recomendacao`)

**Quando usar:** Após cliente relatar o problema

**Variáveis:**
- `{{nome_cliente}}`
- `{{fabricante_veiculo}}`
- `{{modelo_veiculo}}`
- `{{problema_cliente}}`
- `{{categoria_interesse}}`

---

### **3. Finalização** (`finalizacao`)

**Quando usar:** Ao finalizar o atendimento

**Variáveis:**
- `{{nome_cliente}}`
- `{{fabricante_veiculo}}`
- `{{modelo_veiculo}}`
- `{{pecas_recomendadas}}`

---

## 🔌 **APIs Disponíveis**

### **1. Buscar Prompt por Contexto**

```http
GET /api/prompts/[contexto]
```

**Exemplo:**
```bash
GET /api/prompts/atendimento
```

**Resposta:**
```json
{
  "success": true,
  "data": {
    "Id": 1,
    "Nome": "Atendimento Inicial",
    "Contexto": "atendimento",
    "ConteudoPrompt": "Olá {{nome_cliente}}...",
    "Variaveis": "[\"nome_cliente\", \"grupo_empresarial\", ...]",
    "Versao": 1
  }
}
```

---

### **2. Listar Todos os Prompts**

```http
GET /api/prompts
```

**Resposta:**
```json
{
  "success": true,
  "data": [
    {
      "Id": 1,
      "Nome": "Atendimento Inicial",
      "Contexto": "atendimento",
      ...
    }
  ]
}
```

---

### **3. Atualizar Prompt**

```http
PUT /api/prompts
```

**Body:**
```json
{
  "id": 1,
  "conteudoPrompt": "Novo conteúdo do prompt...",
  "atualizadoPor": "Admin"
}
```

---

### **4. Criar Novo Prompt**

```http
POST /api/prompts
```

**Body:**
```json
{
  "nome": "Novo Prompt",
  "descricao": "Descrição do prompt",
  "contexto": "atendimento",
  "conteudoPrompt": "Conteúdo com {{variaveis}}",
  "variaveis": "[\"variavel1\", \"variavel2\"]",
  "criadoPor": "Admin"
}
```

---

## 💻 **Uso no Código**

### **Importar a função utilitária:**

```typescript
import { getProcessedPrompt } from '@/lib/prompt-utils';
```

### **Buscar e processar prompt:**

```typescript
const variables = {
  nome_cliente: 'João Silva',
  grupo_empresarial: 'Stellantis',
  fabricante_veiculo: 'Jeep',
  modelo_veiculo: 'Compass'
};

const result = await getProcessedPrompt('atendimento', variables);

if (result.success) {
  console.log(result.prompt);
  // Usar result.prompt para enviar à IA
} else {
  console.error(result.error);
}
```

### **Substituir variáveis manualmente:**

```typescript
import { replaceVariables } from '@/lib/prompt-utils';

const template = "Olá {{nome_cliente}}, você tem um {{modelo_veiculo}}.";
const variables = {
  nome_cliente: 'João',
  modelo_veiculo: 'Compass'
};

const result = replaceVariables(template, variables);
// Resultado: "Olá João, você tem um Compass."
```

---

## 🗃️ **Stored Procedures**

### **1. Buscar Prompt por Contexto**

```sql
EXEC AIHT_sp_BuscarPromptPorContexto @Contexto = 'atendimento';
```

### **2. Listar Todos os Prompts**

```sql
EXEC AIHT_sp_ListarPrompts @ApenasAtivos = 1;
```

### **3. Atualizar Prompt**

```sql
EXEC AIHT_sp_AtualizarPrompt 
    @Id = 1,
    @ConteudoPrompt = 'Novo conteúdo...',
    @AtualizadoPor = 'Admin';
```

### **4. Criar Novo Prompt**

```sql
EXEC AIHT_sp_CriarPrompt
    @Nome = 'Novo Prompt',
    @Descricao = 'Descrição',
    @Contexto = 'atendimento',
    @ConteudoPrompt = 'Conteúdo com {{variaveis}}',
    @Variaveis = '["variavel1", "variavel2"]',
    @CriadoPor = 'Admin';
```

---

## 🔧 **Como Alterar um Prompt**

### **Opção 1: Via SQL Server Management Studio**

```sql
-- 1. Visualizar prompt atual
SELECT * FROM AIHT_Prompts WHERE Contexto = 'atendimento';

-- 2. Atualizar conteúdo
UPDATE AIHT_Prompts
SET ConteudoPrompt = 'Novo conteúdo do prompt...',
    Versao = Versao + 1,
    DataAtualizacao = GETDATE(),
    AtualizadoPor = 'Seu Nome'
WHERE Id = 1;
```

### **Opção 2: Via API (Postman/Insomnia)**

```bash
curl -X PUT http://localhost:3000/api/prompts \
  -H "Content-Type: application/json" \
  -d '{
    "id": 1,
    "conteudoPrompt": "Novo conteúdo...",
    "atualizadoPor": "Admin"
  }'
```

### **Opção 3: Via Interface Web (Futuro)**

Criar uma página de administração em `/admin/prompts` para gerenciar os prompts visualmente.

---

## 📊 **Versionamento**

Cada atualização de prompt incrementa automaticamente o campo `Versao`, permitindo:
- Rastreamento de mudanças
- Rollback se necessário
- Auditoria de alterações

---

## ⚠️ **Boas Práticas**

1. **Sempre teste o prompt** antes de ativar em produção
2. **Documente as variáveis** necessárias no campo `Variaveis`
3. **Use nomes descritivos** para os prompts
4. **Mantenha backup** dos prompts importantes
5. **Versione as mudanças** usando o campo `Versao`

---

## 🚀 **Instalação**

Execute o script SQL:

```bash
sqlcmd -S .\ALYASQLEXPRESS -U sa -P Aly@2025 -i SQL/07_create_prompts_table.sql
```

Ou execute no SQL Server Management Studio.

---

## 📝 **Exemplo Completo de Uso no Chat**

```typescript
// No componente de chat, após coletar os dados
const handleModeloSelecionado = async (modelo: string) => {
  // Buscar e processar prompt
  const result = await getProcessedPrompt('atendimento', {
    nome_cliente: name,
    grupo_empresarial: grupoNome,
    fabricante_veiculo: fabricanteNome,
    modelo_veiculo: modelo
  });

  if (result.success) {
    // Enviar prompt processado para a IA
    const aiResponse = await sendToAI(result.prompt);
    addAssistant(aiResponse);
  }
};
```

---

**Sistema de prompts pronto para uso! 🎉**
