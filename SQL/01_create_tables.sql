-- =============================================
-- Script de Criação das Tabelas
-- AI Builder Hackathon 2025
-- E-Commerce de Peças Automotivas Multimarcas
-- =============================================

USE AI_Builder_Hackthon;
GO

-- Tabela de Marcas de Veículos
CREATE TABLE AIHT_Marcas (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nome NVARCHAR(100) NOT NULL,
    Pais NVARCHAR(50),
    Ativo BIT DEFAULT 1,
    DataCriacao DATETIME DEFAULT GETDATE(),
    DataAtualizacao DATETIME DEFAULT GETDATE()
);
GO

-- Tabela de Tipos de Veículos
CREATE TABLE AIHT_TiposVeiculo (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nome NVARCHAR(50) NOT NULL, -- Sedan, Hatchback, Pick-up, SUV
    Descricao NVARCHAR(255),
    Ativo BIT DEFAULT 1,
    DataCriacao DATETIME DEFAULT GETDATE()
);
GO

-- Tabela de Modelos de Veículos
CREATE TABLE AIHT_Modelos (
    Id INT PRIMARY KEY IDENTITY(1,1),
    MarcaId INT NOT NULL,
    TipoVeiculoId INT NOT NULL,
    Nome NVARCHAR(100) NOT NULL,
    AnoInicio INT NOT NULL,
    AnoFim INT,
    Ativo BIT DEFAULT 1,
    DataCriacao DATETIME DEFAULT GETDATE(),
    DataAtualizacao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (MarcaId) REFERENCES AIHT_Marcas(Id),
    FOREIGN KEY (TipoVeiculoId) REFERENCES AIHT_TiposVeiculo(Id)
);
GO

-- Tabela de Categorias de Peças
CREATE TABLE AIHT_CategoriasPecas (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nome NVARCHAR(100) NOT NULL,
    Descricao NVARCHAR(255),
    CategoriaPaiId INT NULL,
    Ativo BIT DEFAULT 1,
    DataCriacao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CategoriaPaiId) REFERENCES AIHT_CategoriasPecas(Id)
);
GO

-- Tabela de Peças
CREATE TABLE AIHT_Pecas (
    Id INT PRIMARY KEY IDENTITY(1,1),
    CodigoOriginal NVARCHAR(50) NOT NULL,
    Nome NVARCHAR(200) NOT NULL,
    Descricao NVARCHAR(MAX),
    CategoriaId INT NOT NULL,
    Fabricante NVARCHAR(100),
    Preco DECIMAL(10,2) NOT NULL,
    EstoqueAtual INT DEFAULT 0,
    EstoqueMinimo INT DEFAULT 5,
    ImagemUrl NVARCHAR(500),
    Peso DECIMAL(8,3), -- em kg
    Dimensoes NVARCHAR(50), -- formato: LxAxP em cm
    Garantia INT, -- em meses
    Ativo BIT DEFAULT 1,
    DataCriacao DATETIME DEFAULT GETDATE(),
    DataAtualizacao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CategoriaId) REFERENCES AIHT_CategoriasPecas(Id)
);
GO

-- Tabela de Compatibilidade (Peças x Modelos)
CREATE TABLE AIHT_CompatibilidadePecas (
    Id INT PRIMARY KEY IDENTITY(1,1),
    PecaId INT NOT NULL,
    ModeloId INT NOT NULL,
    AnoInicio INT NOT NULL,
    AnoFim INT,
    Observacoes NVARCHAR(500),
    DataCriacao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (PecaId) REFERENCES AIHT_Pecas(Id),
    FOREIGN KEY (ModeloId) REFERENCES AIHT_Modelos(Id),
    UNIQUE(PecaId, ModeloId, AnoInicio)
);
GO

-- Tabela de Clientes
CREATE TABLE AIHT_Clientes (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nome NVARCHAR(200) NOT NULL,
    Email NVARCHAR(150) NOT NULL UNIQUE,
    Telefone NVARCHAR(20),
    CPF NVARCHAR(14) UNIQUE,
    CNPJ NVARCHAR(18) UNIQUE,
    TipoPessoa CHAR(1) NOT NULL, -- F=Física, J=Jurídica
    Ativo BIT DEFAULT 1,
    DataCriacao DATETIME DEFAULT GETDATE(),
    DataAtualizacao DATETIME DEFAULT GETDATE()
);
GO

-- Tabela de Endereços
CREATE TABLE AIHT_Enderecos (
    Id INT PRIMARY KEY IDENTITY(1,1),
    ClienteId INT NOT NULL,
    TipoEndereco NVARCHAR(20) NOT NULL, -- Entrega, Cobrança, Principal
    CEP NVARCHAR(10) NOT NULL,
    Logradouro NVARCHAR(200) NOT NULL,
    Numero NVARCHAR(20) NOT NULL,
    Complemento NVARCHAR(100),
    Bairro NVARCHAR(100) NOT NULL,
    Cidade NVARCHAR(100) NOT NULL,
    Estado CHAR(2) NOT NULL,
    Pais NVARCHAR(50) DEFAULT 'Brasil',
    Principal BIT DEFAULT 0,
    DataCriacao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ClienteId) REFERENCES AIHT_Clientes(Id)
);
GO

-- Tabela de Pedidos
CREATE TABLE AIHT_Pedidos (
    Id INT PRIMARY KEY IDENTITY(1,1),
    ClienteId INT NOT NULL,
    NumPedido NVARCHAR(20) NOT NULL UNIQUE,
    Status NVARCHAR(30) NOT NULL, -- Pendente, Confirmado, Separação, Enviado, Entregue, Cancelado
    ValorSubtotal DECIMAL(10,2) NOT NULL,
    ValorFrete DECIMAL(10,2) DEFAULT 0,
    ValorDesconto DECIMAL(10,2) DEFAULT 0,
    ValorTotal DECIMAL(10,2) NOT NULL,
    EnderecoEntregaId INT NOT NULL,
    FormaPagamento NVARCHAR(50),
    Observacoes NVARCHAR(MAX),
    DataPedido DATETIME DEFAULT GETDATE(),
    DataAtualizacao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ClienteId) REFERENCES AIHT_Clientes(Id),
    FOREIGN KEY (EnderecoEntregaId) REFERENCES AIHT_Enderecos(Id)
);
GO

-- Tabela de Itens do Pedido
CREATE TABLE AIHT_ItensPedido (
    Id INT PRIMARY KEY IDENTITY(1,1),
    PedidoId INT NOT NULL,
    PecaId INT NOT NULL,
    Quantidade INT NOT NULL,
    PrecoUnitario DECIMAL(10,2) NOT NULL,
    PrecoTotal DECIMAL(10,2) NOT NULL,
    Desconto DECIMAL(10,2) DEFAULT 0,
    DataCriacao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (PedidoId) REFERENCES AIHT_Pedidos(Id),
    FOREIGN KEY (PecaId) REFERENCES AIHT_Pecas(Id)
);
GO

-- Tabela de Avaliações
CREATE TABLE AIHT_Avaliacoes (
    Id INT PRIMARY KEY IDENTITY(1,1),
    PecaId INT NOT NULL,
    ClienteId INT NOT NULL,
    Nota INT NOT NULL CHECK (Nota >= 1 AND Nota <= 5),
    Comentario NVARCHAR(MAX),
    DataAvaliacao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (PecaId) REFERENCES AIHT_Pecas(Id),
    FOREIGN KEY (ClienteId) REFERENCES AIHT_Clientes(Id)
);
GO

-- Tabela de Histórico de Preços
CREATE TABLE AIHT_HistoricoPrecos (
    Id INT PRIMARY KEY IDENTITY(1,1),
    PecaId INT NOT NULL,
    PrecoAnterior DECIMAL(10,2) NOT NULL,
    PrecoNovo DECIMAL(10,2) NOT NULL,
    DataAlteracao DATETIME DEFAULT GETDATE(),
    UsuarioAlteracao NVARCHAR(100),
    FOREIGN KEY (PecaId) REFERENCES AIHT_Pecas(Id)
);
GO

PRINT 'Tabelas criadas com sucesso!';
GO
