-- =============================================
-- Script: Criar Tabelas de Conversas - VERSÃO CORRIGIDA
-- Descrição: Usando AIHT_Marcas (nome correto)
-- =============================================

USE AI_Builder_Hackthon;
GO

PRINT 'Criando tabelas com nomes corretos...';
GO

-- =============================================
-- Tabela: AIHT_Conversas
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AIHT_Conversas]'))
BEGIN
    DROP TABLE [dbo].[AIHT_PecasIdentificadas];
    DROP TABLE [dbo].[AIHT_ProblemasIdentificados];
    DROP TABLE [dbo].[AIHT_Conversas];
    PRINT 'Tabelas antigas removidas.';
END
GO

CREATE TABLE [dbo].[AIHT_Conversas] (
    [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [NomeCliente] NVARCHAR(200) NOT NULL,
    [GrupoEmpresarialId] INT NOT NULL,
    [MarcaId] INT NOT NULL,  -- CORRIGIDO: era FabricanteId
    [ModeloId] INT NOT NULL,
    [DataInicio] DATETIME NOT NULL DEFAULT GETDATE(),
    [DataUltimaInteracao] DATETIME NOT NULL DEFAULT GETDATE(),
    [Status] NVARCHAR(50) NOT NULL DEFAULT 'Ativa',
    [Ativo] BIT NOT NULL DEFAULT 1,
    CONSTRAINT [FK_Conversas_GrupoEmpresarial] FOREIGN KEY ([GrupoEmpresarialId]) 
        REFERENCES [dbo].[AIHT_GruposEmpresariais]([Id]),
    CONSTRAINT [FK_Conversas_Marca] FOREIGN KEY ([MarcaId]) 
        REFERENCES [dbo].[AIHT_Marcas]([Id]),  -- CORRIGIDO
    CONSTRAINT [FK_Conversas_Modelo] FOREIGN KEY ([ModeloId]) 
        REFERENCES [dbo].[AIHT_Modelos]([Id])
);

PRINT '✓ Tabela AIHT_Conversas criada';
GO

-- =============================================
-- Tabela: AIHT_ProblemasIdentificados
-- =============================================
CREATE TABLE [dbo].[AIHT_ProblemasIdentificados] (
    [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ConversaId] INT NOT NULL,
    [DescricaoProblema] NVARCHAR(MAX) NOT NULL,
    [DataIdentificacao] DATETIME NOT NULL DEFAULT GETDATE(),
    [Ativo] BIT NOT NULL DEFAULT 1,
    CONSTRAINT [FK_Problemas_Conversa] FOREIGN KEY ([ConversaId]) 
        REFERENCES [dbo].[AIHT_Conversas]([Id])
);

PRINT '✓ Tabela AIHT_ProblemasIdentificados criada';
GO

-- =============================================
-- Tabela: AIHT_PecasIdentificadas
-- =============================================
CREATE TABLE [dbo].[AIHT_PecasIdentificadas] (
    [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ConversaId] INT NOT NULL,
    [ProblemaId] INT NULL,
    [NomePeca] NVARCHAR(200) NOT NULL,
    [CategoriaPeca] NVARCHAR(100) NULL,
    [Prioridade] NVARCHAR(50) NULL,
    [DataIdentificacao] DATETIME NOT NULL DEFAULT GETDATE(),
    [Ativo] BIT NOT NULL DEFAULT 1,
    CONSTRAINT [FK_Pecas_Conversa] FOREIGN KEY ([ConversaId]) 
        REFERENCES [dbo].[AIHT_Conversas]([Id]),
    CONSTRAINT [FK_Pecas_Problema] FOREIGN KEY ([ProblemaId]) 
        REFERENCES [dbo].[AIHT_ProblemasIdentificados]([Id])
);

PRINT '✓ Tabela AIHT_PecasIdentificadas criada';
GO

-- =============================================
-- Inserir prompt de identificação
-- =============================================
IF NOT EXISTS (SELECT 1 FROM AIHT_Prompts WHERE Contexto = 'identificacao_pecas')
BEGIN
    INSERT INTO AIHT_Prompts (
        Contexto,
        ConteudoPrompt,
        Descricao,
        Versao,
        Ativo
    )
    VALUES (
        'identificacao_pecas',
        'Preciso que a partir dessa conversa identifique o que é um relato de problema automotivo para o {{grupo_empresarial}}, {{fabricante_veiculo}}, {{modelo_veiculo}} e peças mencionadas ou que podem ser causadoras deste problema e me retorne isso em uma lista no formato:
Problema;Peça

Exemplo de resposta esperada:
Barulho ao frear;Pastilha de freio
Barulho ao frear;Disco de freio

Caso não identifique um relato de problema retorne perguntando qual o problema ou a peça desejada.

IMPORTANTE: Retorne APENAS a lista no formato especificado (Problema;Peça) ou a pergunta. Não adicione explicações extras.',
        'Prompt para identificar problemas e peças a partir da conversa do cliente',
        1,
        1
    );
    
    PRINT '✓ Prompt de identificação inserido';
END
ELSE
BEGIN
    PRINT 'Prompt já existe';
END
GO

-- =============================================
-- Stored Procedure: Criar Conversa
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[AIHT_sp_CriarConversa]
    @NomeCliente NVARCHAR(200),
    @GrupoEmpresarialId INT,
    @MarcaId INT,  -- CORRIGIDO
    @ModeloId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ConversaId INT;
    
    INSERT INTO [dbo].[AIHT_Conversas] (
        NomeCliente,
        GrupoEmpresarialId,
        MarcaId,  -- CORRIGIDO
        ModeloId,
        Status
    )
    VALUES (
        @NomeCliente,
        @GrupoEmpresarialId,
        @MarcaId,  -- CORRIGIDO
        @ModeloId,
        'Ativa'
    );
    
    SET @ConversaId = SCOPE_IDENTITY();
    
    SELECT 
        Id,
        NomeCliente,
        GrupoEmpresarialId,
        MarcaId,  -- CORRIGIDO
        ModeloId,
        DataInicio,
        Status
    FROM [dbo].[AIHT_Conversas]
    WHERE Id = @ConversaId;
END
GO

PRINT '✓ AIHT_sp_CriarConversa criada';
GO

-- =============================================
-- Outras Stored Procedures
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[AIHT_sp_RegistrarProblema]
    @ConversaId INT,
    @DescricaoProblema NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ProblemaId INT;
    
    INSERT INTO [dbo].[AIHT_ProblemasIdentificados] (ConversaId, DescricaoProblema)
    VALUES (@ConversaId, @DescricaoProblema);
    
    SET @ProblemaId = SCOPE_IDENTITY();
    
    UPDATE [dbo].[AIHT_Conversas]
    SET DataUltimaInteracao = GETDATE()
    WHERE Id = @ConversaId;
    
    SELECT Id, ConversaId, DescricaoProblema, DataIdentificacao
    FROM [dbo].[AIHT_ProblemasIdentificados]
    WHERE Id = @ProblemaId;
END
GO

PRINT '✓ AIHT_sp_RegistrarProblema criada';
GO

CREATE OR ALTER PROCEDURE [dbo].[AIHT_sp_RegistrarPeca]
    @ConversaId INT,
    @ProblemaId INT = NULL,
    @NomePeca NVARCHAR(200),
    @CategoriaPeca NVARCHAR(100) = NULL,
    @Prioridade NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @PecaId INT;
    
    INSERT INTO [dbo].[AIHT_PecasIdentificadas] (ConversaId, ProblemaId, NomePeca, CategoriaPeca, Prioridade)
    VALUES (@ConversaId, @ProblemaId, @NomePeca, @CategoriaPeca, @Prioridade);
    
    SET @PecaId = SCOPE_IDENTITY();
    
    UPDATE [dbo].[AIHT_Conversas]
    SET DataUltimaInteracao = GETDATE()
    WHERE Id = @ConversaId;
    
    SELECT Id, ConversaId, ProblemaId, NomePeca, CategoriaPeca, Prioridade, DataIdentificacao
    FROM [dbo].[AIHT_PecasIdentificadas]
    WHERE Id = @PecaId;
END
GO

PRINT '✓ AIHT_sp_RegistrarPeca criada';
GO

CREATE OR ALTER PROCEDURE [dbo].[AIHT_sp_ListarPecasConversa]
    @ConversaId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        p.Id, p.ConversaId, p.ProblemaId, prob.DescricaoProblema,
        p.NomePeca, p.CategoriaPeca, p.Prioridade, p.DataIdentificacao
    FROM [dbo].[AIHT_PecasIdentificadas] p
    LEFT JOIN [dbo].[AIHT_ProblemasIdentificados] prob ON p.ProblemaId = prob.Id
    WHERE p.ConversaId = @ConversaId AND p.Ativo = 1
    ORDER BY p.DataIdentificacao DESC;
END
GO

PRINT '✓ AIHT_sp_ListarPecasConversa criada';
GO

-- =============================================
-- Permissões
-- =============================================
GRANT SELECT, INSERT, UPDATE ON dbo.AIHT_Conversas TO AI_Hackthon;
GRANT SELECT, INSERT ON dbo.AIHT_ProblemasIdentificados TO AI_Hackthon;
GRANT SELECT, INSERT ON dbo.AIHT_PecasIdentificadas TO AI_Hackthon;
GRANT EXECUTE ON dbo.AIHT_sp_CriarConversa TO AI_Hackthon;
GRANT EXECUTE ON dbo.AIHT_sp_RegistrarProblema TO AI_Hackthon;
GRANT EXECUTE ON dbo.AIHT_sp_RegistrarPeca TO AI_Hackthon;
GRANT EXECUTE ON dbo.AIHT_sp_ListarPecasConversa TO AI_Hackthon;

PRINT '✓ Permissões concedidas';
GO

PRINT '========================================';
PRINT 'SUCESSO! Tudo criado corretamente!';
PRINT '========================================';
GO
