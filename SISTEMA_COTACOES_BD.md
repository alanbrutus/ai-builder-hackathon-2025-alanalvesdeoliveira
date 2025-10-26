# 📊 Sistema de Gravação de Cotações no Banco de Dados

## 🎯 Objetivo

Implementar a gravação persistente das cotações de peças retornadas pela IA, permitindo histórico completo e análise de preços ao longo do tempo.

## 🗄️ Estrutura do Banco de Dados

### Tabela: `AIHT_CotacoesPecas`

Armazena todas as cotações retornadas para cada peça identificada.

#### Campos Principais:

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `Id` | INT | Identificador único da cotação |
| `ConversaId` | INT | FK para AIHT_Conversas |
| `ProblemaId` | INT | FK para AIHT_ProblemasIdentificados (opcional) |
| `PecaIdentificadaId` | INT | FK para AIHT_PecasIdentificadas |
| `NomePeca` | NVARCHAR(200) | Nome da peça cotada |

#### Tipo de Cotação:

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `TipoCotacao` | NVARCHAR(50) | 'E-Commerce' ou 'Loja Física' |

#### Informações de E-Commerce:

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `Link` | NVARCHAR(500) | URL do produto no e-commerce |

#### Informações de Loja Física:

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `Endereco` | NVARCHAR(500) | Endereço completo da loja |
| `NomeLoja` | NVARCHAR(200) | Nome da loja física |
| `Telefone` | NVARCHAR(50) | Telefone de contato |

#### Informações de Preço:

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `Preco` | DECIMAL(10,2) | Preço único |
| `PrecoMinimo` | DECIMAL(10,2) | Preço mínimo (faixa) |
| `PrecoMaximo` | DECIMAL(10,2) | Preço máximo (faixa) |
| `CondicoesPagamento` | NVARCHAR(500) | Condições de pagamento |

#### Observações:

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `Observacoes` | NVARCHAR(MAX) | Observações gerais |
| `Disponibilidade` | NVARCHAR(100) | Status de disponibilidade |
| `PrazoEntrega` | NVARCHAR(100) | Prazo de entrega estimado |
| `EstadoPeca` | NVARCHAR(50) | 'Nova', 'Usada' ou 'Recondicionada' |

#### Controle:

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `DataCotacao` | DATETIME | Data/hora da cotação |
| `Ativo` | BIT | Flag de ativo (soft delete) |

## 📝 Stored Procedures

### 1. `AIHT_sp_RegistrarCotacao`

Registra uma nova cotação no banco de dados.

**Parâmetros:**
```sql
@ConversaId INT,
@ProblemaId INT = NULL,
@PecaIdentificadaId INT,
@NomePeca NVARCHAR(200),
@TipoCotacao NVARCHAR(50),
@Link NVARCHAR(500) = NULL,
@Endereco NVARCHAR(500) = NULL,
@NomeLoja NVARCHAR(200) = NULL,
@Telefone NVARCHAR(50) = NULL,
@Preco DECIMAL(10,2) = NULL,
@PrecoMinimo DECIMAL(10,2) = NULL,
@PrecoMaximo DECIMAL(10,2) = NULL,
@CondicoesPagamento NVARCHAR(500) = NULL,
@Observacoes NVARCHAR(MAX) = NULL,
@Disponibilidade NVARCHAR(100) = NULL,
@PrazoEntrega NVARCHAR(100) = NULL,
@EstadoPeca NVARCHAR(50) = NULL
```

**Retorno:** Registro da cotação criada

### 2. `AIHT_sp_ListarCotacoesConversa`

Lista todas as cotações de uma conversa.

**Parâmetros:**
```sql
@ConversaId INT
```

**Retorno:** Lista de cotações com informações completas

### 3. `AIHT_sp_ListarCotacoesPeca`

Lista todas as cotações de uma peça específica, ordenadas por preço.

**Parâmetros:**
```sql
@PecaIdentificadaId INT
```

**Retorno:** Lista de cotações ordenadas por preço crescente

### 4. `AIHT_sp_ResumoCotacoes`

Retorna resumo estatístico das cotações de uma conversa.

**Parâmetros:**
```sql
@ConversaId INT
```

**Retorno:** 
- Recordset 1: Resumo geral (total, e-commerce vs loja física, preços)
- Recordset 2: Resumo por peça

### 5. `AIHT_sp_DeletarCotacao`

Remove uma cotação (soft delete).

**Parâmetros:**
```sql
@CotacaoId INT
```

**Retorno:** Número de linhas afetadas

## 🔌 APIs Implementadas

### 1. `POST /api/salvar-cotacao`

Salva uma ou mais cotações no banco de dados.

**Request Body:**
```typescript
{
  cotacoes: [
    {
      conversaId: number;
      problemaId?: number;
      pecaIdentificadaId: number;
      nomePeca: string;
      tipoCotacao: 'E-Commerce' | 'Loja Física';
      link?: string;
      endereco?: string;
      nomeLoja?: string;
      telefone?: string;
      preco?: number;
      precoMinimo?: number;
      precoMaximo?: number;
      condicoesPagamento?: string;
      observacoes?: string;
      disponibilidade?: string;
      prazoEntrega?: string;
      estadoPeca?: 'Nova' | 'Usada' | 'Recondicionada';
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "totalSolicitadas": 5,
  "totalSalvas": 5,
  "cotacoes": [...]
}
```

### 2. `GET /api/cotacoes/[conversaId]`

Lista todas as cotações de uma conversa.

**Response:**
```json
{
  "success": true,
  "conversaId": 123,
  "total": 10,
  "cotacoes": [...]
}
```

### 3. `GET /api/cotacoes/peca/[pecaId]`

Lista todas as cotações de uma peça específica.

**Response:**
```json
{
  "success": true,
  "pecaId": 456,
  "total": 3,
  "cotacoes": [...]
}
```

### 4. `GET /api/cotacoes/resumo/[conversaId]`

Retorna resumo estatístico das cotações.

**Response:**
```json
{
  "success": true,
  "conversaId": 123,
  "resumoGeral": {
    "TotalCotacoes": 10,
    "TotalPecas": 3,
    "CotacoesECommerce": 7,
    "CotacoesLojaFisica": 3,
    "MenorPreco": 150.00,
    "MaiorPreco": 850.00,
    "PrecoMedio": 425.50
  },
  "resumoPorPeca": [
    {
      "PecaIdentificadaId": 1,
      "NomePeca": "Pastilha de Freio",
      "QuantidadeCotacoes": 4,
      "MenorPreco": 150.00,
      "MaiorPreco": 280.00
    }
  ]
}
```

## 🔄 Fluxo de Integração

### Fluxo Atual (Geração de Cotação):

1. Cliente solicita cotação
2. Sistema detecta intenção via `AIHT_sp_VerificarIntencaoCotacao`
3. Busca peças via `AIHT_sp_ListarPecasParaCotacao`
4. Envia para Gemini Pro
5. Retorna cotação formatada
6. Registra log via `AIHT_sp_RegistrarChamadaIA`

### Novo Fluxo (Com Gravação):

1. Cliente solicita cotação
2. Sistema detecta intenção
3. Busca peças
4. Envia para Gemini Pro
5. **Parseia resposta da IA**
6. **Salva cada cotação via `POST /api/salvar-cotacao`**
7. Retorna cotação formatada
8. Registra log

## 📋 Exemplo de Uso

### Salvando Cotações:

```typescript
// Após receber resposta da IA com cotações
const cotacoes = [
  {
    conversaId: 123,
    problemaId: 45,
    pecaIdentificadaId: 67,
    nomePeca: "Pastilha de Freio Dianteira",
    tipoCotacao: "E-Commerce",
    link: "https://mercadolivre.com.br/pastilha-freio-xyz",
    preco: 189.90,
    condicoesPagamento: "3x sem juros",
    observacoes: "Entrega em 5 dias úteis",
    disponibilidade: "Em estoque",
    prazoEntrega: "5 dias úteis",
    estadoPeca: "Nova"
  },
  {
    conversaId: 123,
    problemaId: 45,
    pecaIdentificadaId: 67,
    nomePeca: "Pastilha de Freio Dianteira",
    tipoCotacao: "Loja Física",
    endereco: "Rua das Peças, 123 - Centro",
    nomeLoja: "Auto Peças Central",
    telefone: "(11) 98765-4321",
    precoMinimo: 150.00,
    precoMaximo: 200.00,
    condicoesPagamento: "À vista ou cartão",
    observacoes: "Retirada imediata",
    disponibilidade: "Disponível",
    estadoPeca: "Nova"
  }
];

const response = await fetch('/api/salvar-cotacao', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ cotacoes })
});
```

### Consultando Cotações:

```typescript
// Listar todas as cotações de uma conversa
const response = await fetch('/api/cotacoes/123');
const data = await response.json();

// Listar cotações de uma peça específica
const response2 = await fetch('/api/cotacoes/peca/67');
const data2 = await response2.json();

// Obter resumo
const response3 = await fetch('/api/cotacoes/resumo/123');
const data3 = await response3.json();
```

## 🎯 Próximos Passos

1. ✅ Criar tabela `AIHT_CotacoesPecas`
2. ✅ Criar stored procedures
3. ✅ Criar APIs REST
4. ⏳ Integrar com `/api/gerar-cotacao`
5. ⏳ Parsear resposta da IA para extrair cotações
6. ⏳ Atualizar interface para exibir cotações salvas
7. ⏳ Adicionar funcionalidade de comparação de preços

## 📊 Benefícios

- **Histórico Completo**: Todas as cotações ficam registradas
- **Análise de Preços**: Comparação de preços ao longo do tempo
- **Rastreabilidade**: Saber quando e onde cada cotação foi obtida
- **Relatórios**: Gerar relatórios de cotações por período
- **Melhores Ofertas**: Identificar automaticamente as melhores ofertas
- **Tendências**: Analisar tendências de preços de peças

## 🔧 Instalação

Execute o script SQL:

```bash
# No SQL Server Management Studio ou Azure Data Studio
# Execute o arquivo:
SQL/40_criar_tabela_cotacoes.sql
```

## ✅ Validação

Após executar o script, valide:

```sql
-- Verificar se a tabela foi criada
SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'AIHT_CotacoesPecas';

-- Verificar stored procedures
SELECT name FROM sys.procedures 
WHERE name LIKE 'AIHT_sp_%Cotac%';

-- Testar inserção
EXEC AIHT_sp_RegistrarCotacao 
  @ConversaId = 1,
  @PecaIdentificadaId = 1,
  @NomePeca = 'Teste',
  @TipoCotacao = 'E-Commerce',
  @Link = 'https://teste.com',
  @Preco = 100.00;
```

---

**Data de Criação**: 26/10/2025  
**Versão**: 1.0  
**Autor**: Alan Alves de Oliveira
