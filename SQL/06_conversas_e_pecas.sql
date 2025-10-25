-- =============================================
-- Script: Criar Tabelas de Conversas e Peças Identificadas
-- Descrição: Sistema para rastrear conversas e peças mencionadas
-- =============================================

USE AI_Builder_Hackthon;
GO

-- =============================================
-- Tabela: AIHT_Conversas
-- Descrição: Armazena as conversas dos clientes
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AIHT_Conversas]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AIHT_Conversas] (
        [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [NomeCliente] NVARCHAR(200) NOT NULL,
        [GrupoEmpresarialId] INT NOT NULL,
        [FabricanteId] INT NOT NULL,
        [ModeloId] INT NOT NULL,
        [DataInicio] DATETIME NOT NULL DEFAULT GETDATE(),
        [DataUltimaInteracao] DATETIME NOT NULL DEFAULT GETDATE(),
        [Status] NVARCHAR(50) NOT NULL DEFAULT 'Ativa', -- Ativa, Finalizada, Abandonada
        [Ativo] BIT NOT NULL DEFAULT 1,
        CONSTRAINT [FK_Conversas_GrupoEmpresarial] FOREIGN KEY ([GrupoEmpresarialId]) 
            REFERENCES [dbo].[AIHT_GruposEmpresariais]([Id]),
        CONSTRAINT [FK_Conversas_Fabricante] FOREIGN KEY ([FabricanteId]) 
            REFERENCES [dbo].[AIHT_Fabricantes]([Id]),
        CONSTRAINT [FK_Conversas_Modelo] FOREIGN KEY ([ModeloId]) 
            REFERENCES [dbo].[AIHT_Modelos]([Id])
    );
    
    PRINT 'Tabela AIHT_Conversas criada com sucesso!';
END
ELSE
BEGIN
    PRINT 'Tabela AIHT_Conversas já existe.';
END
GO

-- =============================================
-- Tabela: AIHT_ProblemasIdentificados
-- Descrição: Armazena problemas identificados nas conversas
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AIHT_ProblemasIdentificados]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AIHT_ProblemasIdentificados] (
        [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [ConversaId] INT NOT NULL,
        [DescricaoProblema] NVARCHAR(MAX) NOT NULL,
        [DataIdentificacao] DATETIME NOT NULL DEFAULT GETDATE(),
        [Ativo] BIT NOT NULL DEFAULT 1,
        CONSTRAINT [FK_Problemas_Conversa] FOREIGN KEY ([ConversaId]) 
            REFERENCES [dbo].[AIHT_Conversas]([Id])
    );
    
    PRINT 'Tabela AIHT_ProblemasIdentificados criada com sucesso!';
END
ELSE
BEGIN
    PRINT 'Tabela AIHT_ProblemasIdentificados já existe.';
END
GO

-- =============================================
-- Tabela: AIHT_PecasIdentificadas
-- Descrição: Armazena peças identificadas para cada problema
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AIHT_PecasIdentificadas]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AIHT_PecasIdentificadas] (
        [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [ConversaId] INT NOT NULL,
        [ProblemaId] INT NULL,
        [NomePeca] NVARCHAR(200) NOT NULL,
        [CategoriaPeca] NVARCHAR(100) NULL, -- Freios, Motor, Suspensão, etc
        [Prioridade] NVARCHAR(50) NULL, -- Alta, Média, Baixa
        [DataIdentificacao] DATETIME NOT NULL DEFAULT GETDATE(),
        [Ativo] BIT NOT NULL DEFAULT 1,
        CONSTRAINT [FK_Pecas_Conversa] FOREIGN KEY ([ConversaId]) 
            REFERENCES [dbo].[AIHT_Conversas]([Id]),
        CONSTRAINT [FK_Pecas_Problema] FOREIGN KEY ([ProblemaId]) 
            REFERENCES [dbo].[AIHT_ProblemasIdentificados]([Id])
    );
    
    PRINT 'Tabela AIHT_PecasIdentificadas criada com sucesso!';
END
ELSE
BEGIN
    PRINT 'Tabela AIHT_PecasIdentificadas já existe.';
END
GO

-- =============================================
-- Inserir novo prompt para identificação de problemas e peças
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
    
    PRINT 'Prompt de identificação de peças inserido com sucesso!';
END
ELSE
BEGIN
    PRINT 'Prompt de identificação de peças já existe.';
END
GO

-- =============================================
-- Stored Procedure: Criar Nova Conversa
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[AIHT_sp_CriarConversa]
    @NomeCliente NVARCHAR(200),
    @GrupoEmpresarialId INT,
    @FabricanteId INT,
    @ModeloId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ConversaId INT;
    
    INSERT INTO AIHT_Conversas (
        NomeCliente,
        GrupoEmpresarialId,
        FabricanteId,
        ModeloId,
        Status
    )
    VALUES (
        @NomeCliente,
        @GrupoEmpresarialId,
        @FabricanteId,
        @ModeloId,
        'Ativa'
    );
    
    SET @ConversaId = SCOPE_IDENTITY();
    
    SELECT 
        Id,
        NomeCliente,
        GrupoEmpresarialId,
        FabricanteId,
        ModeloId,
        DataInicio,
        Status
    FROM AIHT_Conversas
    WHERE Id = @ConversaId;
END
GO

-- =============================================
-- Stored Procedure: Registrar Problema Identificado
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[AIHT_sp_RegistrarProblema]
    @ConversaId INT,
    @DescricaoProblema NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ProblemaId INT;
    
    INSERT INTO AIHT_ProblemasIdentificados (
        ConversaId,
        DescricaoProblema
    )
    VALUES (
        @ConversaId,
        @DescricaoProblema
    );
    
    SET @ProblemaId = SCOPE_IDENTITY();
    
    -- Atualizar data da última interação
    UPDATE AIHT_Conversas
    SET DataUltimaInteracao = GETDATE()
    WHERE Id = @ConversaId;
    
    SELECT 
        Id,
        ConversaId,
        DescricaoProblema,
        DataIdentificacao
    FROM AIHT_ProblemasIdentificados
    WHERE Id = @ProblemaId;
END
GO

-- =============================================
-- Stored Procedure: Registrar Peça Identificada
-- =============================================
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
    
    INSERT INTO AIHT_PecasIdentificadas (
        ConversaId,
        ProblemaId,
        NomePeca,
        CategoriaPeca,
        Prioridade
    )
    VALUES (
        @ConversaId,
        @ProblemaId,
        @NomePeca,
        @CategoriaPeca,
        @Prioridade
    );
    
    SET @PecaId = SCOPE_IDENTITY();
    
    -- Atualizar data da última interação
    UPDATE AIHT_Conversas
    SET DataUltimaInteracao = GETDATE()
    WHERE Id = @ConversaId;
    
    SELECT 
        Id,
        ConversaId,
        ProblemaId,
        NomePeca,
        CategoriaPeca,
        Prioridade,
        DataIdentificacao
    FROM AIHT_PecasIdentificadas
    WHERE Id = @PecaId;
END
GO

-- =============================================
-- Stored Procedure: Listar Peças da Conversa
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[AIHT_sp_ListarPecasConversa]
    @ConversaId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        p.Id,
        p.ConversaId,
        p.ProblemaId,
        prob.DescricaoProblema,
        p.NomePeca,
        p.CategoriaPeca,
        p.Prioridade,
        p.DataIdentificacao
    FROM AIHT_PecasIdentificadas p
    LEFT JOIN AIHT_ProblemasIdentificados prob ON p.ProblemaId = prob.Id
    WHERE p.ConversaId = @ConversaId
        AND p.Ativo = 1
    ORDER BY p.DataIdentificacao DESC;
END
GO

-- =============================================
-- Conceder permissões ao usuário AI_Hackthon
-- =============================================
GRANT EXECUTE ON dbo.AIHT_sp_CriarConversa TO AI_Hackthon;
GRANT EXECUTE ON dbo.AIHT_sp_RegistrarProblema TO AI_Hackthon;
GRANT EXECUTE ON dbo.AIHT_sp_RegistrarPeca TO AI_Hackthon;
GRANT EXECUTE ON dbo.AIHT_sp_ListarPecasConversa TO AI_Hackthon;

GRANT SELECT ON dbo.AIHT_Conversas TO AI_Hackthon;
GRANT INSERT ON dbo.AIHT_Conversas TO AI_Hackthon;
GRANT UPDATE ON dbo.AIHT_Conversas TO AI_Hackthon;

GRANT SELECT ON dbo.AIHT_ProblemasIdentificados TO AI_Hackthon;
GRANT INSERT ON dbo.AIHT_ProblemasIdentificados TO AI_Hackthon;

GRANT SELECT ON dbo.AIHT_PecasIdentificadas TO AI_Hackthon;
GRANT INSERT ON dbo.AIHT_PecasIdentificadas TO AI_Hackthon;

PRINT 'Permissões concedidas com sucesso!';
GO

PRINT '========================================';
PRINT 'Script executado com sucesso!';
PRINT 'Tabelas criadas:';
PRINT '  - AIHT_Conversas';
PRINT '  - AIHT_ProblemasIdentificados';
PRINT '  - AIHT_PecasIdentificadas';
PRINT 'Stored Procedures criadas:';
PRINT '  - AIHT_sp_CriarConversa';
PRINT '  - AIHT_sp_RegistrarProblema';
PRINT '  - AIHT_sp_RegistrarPeca';
PRINT '  - AIHT_sp_ListarPecasConversa';
PRINT 'Prompt inserido: identificacao_pecas';
PRINT '========================================';
GO
