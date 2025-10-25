# Scripts SQL - E-Commerce de Peças Automotivas

Esta pasta contém todos os scripts SQL necessários para criar e configurar o banco de dados do projeto.

## 📋 Ordem de Execução

Execute os scripts na seguinte ordem:

### 1. `01_create_tables.sql`
Cria todas as tabelas do banco de dados (com prefixo **AIHT_**):
- **AIHT_Marcas** - Marcas de veículos
- **AIHT_TiposVeiculo** - Tipos de veículos (Sedan, Hatchback, Pick-up, SUV)
- **AIHT_Modelos** - Modelos de veículos por marca
- **AIHT_CategoriasPecas** - Categorias e subcategorias de peças
- **AIHT_Pecas** - Catálogo de peças automotivas
- **AIHT_CompatibilidadePecas** - Relacionamento entre peças e modelos
- **AIHT_Clientes** - Cadastro de clientes
- **AIHT_Enderecos** - Endereços dos clientes
- **AIHT_Pedidos** - Pedidos realizados
- **AIHT_ItensPedido** - Itens de cada pedido
- **AIHT_Avaliacoes** - Avaliações de peças pelos clientes
- **AIHT_HistoricoPrecos** - Histórico de alterações de preços

### 2. `02_create_indexes.sql`
Cria índices para otimizar as consultas mais comuns:
- Índices em chaves estrangeiras
- Índices em campos de busca frequente
- Índices em campos de filtro

### 3. `03_seed_data.sql`
Insere dados iniciais no banco:
- Tipos de veículos (Sedan, Hatchback, Pick-up Pequena, Pick-up Média, SUV)
- Marcas principais (Chevrolet, Ford, VW, Fiat, Toyota, Honda, etc.)
- Modelos populares de cada marca
- Categorias e subcategorias de peças

### 4. `04_create_views.sql`
Cria views para facilitar consultas complexas (com prefixo **AIHT_vw_**):
- `AIHT_vw_CatalogoPecas` - Catálogo completo com categorias
- `AIHT_vw_CompatibilidadeVeiculos` - Compatibilidade de peças com veículos
- `AIHT_vw_ResumoPedidos` - Resumo de pedidos com informações do cliente
- `AIHT_vw_ItensPedidoDetalhado` - Detalhes dos itens de pedidos
- `AIHT_vw_AvaliacoesPecas` - Média de avaliações por peça
- `AIHT_vw_PecasMaisVendidas` - Ranking de peças mais vendidas
- `AIHT_vw_TopClientes` - Clientes com mais compras
- `AIHT_vw_EstoqueCritico` - Peças com estoque baixo ou zerado

### 5. `05_create_procedures.sql`
Cria stored procedures para operações comuns (com prefixo **AIHT_sp_**):
- `AIHT_sp_BuscarPecasPorVeiculo` - Busca peças compatíveis com um veículo
- `AIHT_sp_CriarPedido` - Cria um novo pedido
- `AIHT_sp_AdicionarItemPedido` - Adiciona item ao pedido e atualiza estoque
- `AIHT_sp_AtualizarStatusPedido` - Atualiza o status de um pedido
- `AIHT_sp_RegistrarAvaliacao` - Registra avaliação de uma peça
- `AIHT_sp_AtualizarPrecoPeca` - Atualiza preço e registra histórico
- `AIHT_sp_BuscarPecasPorTexto` - Busca textual em peças

### 6. `06_add_grupos_empresariais.sql` ⭐ **NOVO**
Adiciona hierarquia Grupo Empresarial → Fabricante → Modelo para seleção em cascata:
- **Tabela**: `AIHT_GruposEmpresariais` - Grupos empresariais (Stellantis, Volkswagen Group, General Motors, etc.)
- **Coluna**: `AIHT_Marcas.GrupoEmpresarialId` - Relaciona fabricante ao grupo empresarial
- **View**: `AIHT_vw_HierarquiaCompleta` - Visualização completa da hierarquia
- **15 Grupos Empresariais** cadastrados com 60+ fabricantes
- **Procedures**:
  - `AIHT_sp_ListarGruposEmpresariais` - Lista todos os grupos empresariais
  - `AIHT_sp_ListarFabricantesPorGrupo` - Lista fabricantes de um grupo específico
  - `AIHT_sp_ListarModelosPorFabricante` - Lista modelos de um fabricante específico
  - `AIHT_sp_BuscarHierarquiaPorModelo` - Retorna grupo e fabricante de um modelo
  - `AIHT_sp_BuscarModelosPorNome` - Autocomplete para busca de modelos

**Exemplo**: Stellantis → Jeep → Compass

## 🔧 Como Executar

### Usando SQL Server Management Studio (SSMS)

1. Conecte-se ao servidor: `.\ALYASQLEXPRESS`
2. Abra cada script na ordem indicada
3. Execute cada script pressionando F5 ou clicando em "Execute"

### Usando sqlcmd (Linha de Comando)

```bash
sqlcmd -S .\ALYASQLEXPRESS -U AI_Hackthon -P 41@H4ckth0n -i 01_create_tables.sql
sqlcmd -S .\ALYASQLEXPRESS -U AI_Hackthon -P 41@H4ckth0n -i 02_create_indexes.sql
sqlcmd -S .\ALYASQLEXPRESS -U AI_Hackthon -P 41@H4ckth0n -i 03_seed_data.sql
sqlcmd -S .\ALYASQLEXPRESS -U AI_Hackthon -P 41@H4ckth0n -i 04_create_views.sql
sqlcmd -S .\ALYASQLEXPRESS -U AI_Hackthon -P 41@H4ckth0n -i 05_create_procedures.sql
sqlcmd -S .\ALYASQLEXPRESS -U AI_Hackthon -P 41@H4ckth0n -i 06_add_grupos_empresariais.sql
```

## 📊 Estrutura do Banco de Dados

### Hierarquia de Veículos (Seleção em Cascata)

```
AIHT_GruposEmpresariais (Grupo Empresarial)
    └── AIHT_Marcas (Fabricante) [GrupoEmpresarialId]
            └── AIHT_Modelos (Modelo) [MarcaId]
```

**Exemplo de fluxo:**
1. Cliente seleciona **Grupo Empresarial**: "Stellantis"
2. Sistema mostra **Fabricantes** daquele grupo: Jeep, Fiat, Peugeot, Citroën, etc. (15 marcas)
3. Cliente seleciona **Fabricante**: "Jeep"
4. Sistema mostra **Modelos**: Compass, Renegade, Commander, Wrangler, etc.

**OU** cliente busca diretamente por modelo e o sistema retorna: Stellantis > Jeep > Compass

### Relacionamentos Principais

```
AIHT_GruposEmpresariais (1) ──→ (N) AIHT_Marcas
AIHT_Marcas (1) ──→ (N) AIHT_Modelos
AIHT_TiposVeiculo (1) ──→ (N) AIHT_Modelos
AIHT_CategoriasPecas (1) ──→ (N) AIHT_Pecas
AIHT_Pecas (N) ←──→ (N) AIHT_Modelos (através de AIHT_CompatibilidadePecas)
AIHT_Clientes (1) ──→ (N) AIHT_Pedidos
AIHT_Clientes (1) ──→ (N) AIHT_Enderecos
AIHT_Pedidos (1) ──→ (N) AIHT_ItensPedido
AIHT_Pecas (1) ──→ (N) AIHT_ItensPedido
AIHT_Pecas (1) ──→ (N) AIHT_Avaliacoes
AIHT_Clientes (1) ──→ (N) AIHT_Avaliacoes
```

## 🎯 Tipos de Veículos Suportados

- ✅ Sedans
- ✅ Hatchbacks
- ✅ Pick-ups (pequenas e médias)
- ✅ SUVs
- ❌ Veículos de carga
- ❌ Motocicletas
- ❌ Ciclomotores

## 📝 Observações

- **Todas as entidades usam o prefixo `AIHT_`** (AI Hackathon)
- Todos os scripts incluem tratamento de erros
- As tabelas possuem campos de auditoria (DataCriacao, DataAtualizacao)
- Os índices foram criados para otimizar as consultas mais comuns
- As stored procedures incluem validações de negócio
- O campo `Ativo` permite soft delete em várias tabelas

## 🔐 Credenciais do Banco

- **Servidor**: `.\ALYASQLEXPRESS`
- **Database**: `AI_Builder_Hackthon`
- **Usuário**: `AI_Hackthon`
- **Senha**: `41@H4ckth0n`
