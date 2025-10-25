-- =============================================
-- Script: Stored Procedures para Conversas
-- Descrição: Recriar stored procedures com schema explícito
-- =============================================

USE AI_Builder_Hackthon;
GO

PRINT 'Recriando Stored Procedures...';
GO

-- =============================================
-- Stored Procedure: Criar Nova Conversa
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'AIHT_sp_CriarConversa')
    DROP PROCEDURE dbo.AIHT_sp_CriarConversa;
GO

CREATE PROCEDURE [dbo].[AIHT_sp_CriarConversa]
    @NomeCliente NVARCHAR(200),
    @GrupoEmpresarialId INT,
    @FabricanteId INT,
    @ModeloId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ConversaId INT;
    
    INSERT INTO [dbo].[AIHT_Conversas] (
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
    FROM [dbo].[AIHT_Conversas]
    WHERE Id = @ConversaId;
END
GO

PRINT '✓ AIHT_sp_CriarConversa criada';
GO

-- =============================================
-- Stored Procedure: Registrar Problema Identificado
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'AIHT_sp_RegistrarProblema')
    DROP PROCEDURE dbo.AIHT_sp_RegistrarProblema;
GO

CREATE PROCEDURE [dbo].[AIHT_sp_RegistrarProblema]
    @ConversaId INT,
    @DescricaoProblema NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ProblemaId INT;
    
    INSERT INTO [dbo].[AIHT_ProblemasIdentificados] (
        ConversaId,
        DescricaoProblema
    )
    VALUES (
        @ConversaId,
        @DescricaoProblema
    );
    
    SET @ProblemaId = SCOPE_IDENTITY();
    
    -- Atualizar data da última interação
    UPDATE [dbo].[AIHT_Conversas]
    SET DataUltimaInteracao = GETDATE()
    WHERE Id = @ConversaId;
    
    SELECT 
        Id,
        ConversaId,
        DescricaoProblema,
        DataIdentificacao
    FROM [dbo].[AIHT_ProblemasIdentificados]
    WHERE Id = @ProblemaId;
END
GO

PRINT '✓ AIHT_sp_RegistrarProblema criada';
GO

-- =============================================
-- Stored Procedure: Registrar Peça Identificada
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'AIHT_sp_RegistrarPeca')
    DROP PROCEDURE dbo.AIHT_sp_RegistrarPeca;
GO

CREATE PROCEDURE [dbo].[AIHT_sp_RegistrarPeca]
    @ConversaId INT,
    @ProblemaId INT = NULL,
    @NomePeca NVARCHAR(200),
    @CategoriaPeca NVARCHAR(100) = NULL,
    @Prioridade NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @PecaId INT;
    
    INSERT INTO [dbo].[AIHT_PecasIdentificadas] (
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
    UPDATE [dbo].[AIHT_Conversas]
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
    FROM [dbo].[AIHT_PecasIdentificadas]
    WHERE Id = @PecaId;
END
GO

PRINT '✓ AIHT_sp_RegistrarPeca criada';
GO

-- =============================================
-- Stored Procedure: Listar Peças da Conversa
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'AIHT_sp_ListarPecasConversa')
    DROP PROCEDURE dbo.AIHT_sp_ListarPecasConversa;
GO

CREATE PROCEDURE [dbo].[AIHT_sp_ListarPecasConversa]
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
    FROM [dbo].[AIHT_PecasIdentificadas] p
    LEFT JOIN [dbo].[AIHT_ProblemasIdentificados] prob ON p.ProblemaId = prob.Id
    WHERE p.ConversaId = @ConversaId
        AND p.Ativo = 1
    ORDER BY p.DataIdentificacao DESC;
END
GO

PRINT '✓ AIHT_sp_ListarPecasConversa criada';
GO

-- =============================================
-- Conceder permissões ao usuário AI_Hackthon
-- =============================================
GRANT EXECUTE ON dbo.AIHT_sp_CriarConversa TO AI_Hackthon;
GRANT EXECUTE ON dbo.AIHT_sp_RegistrarProblema TO AI_Hackthon;
GRANT EXECUTE ON dbo.AIHT_sp_RegistrarPeca TO AI_Hackthon;
GRANT EXECUTE ON dbo.AIHT_sp_ListarPecasConversa TO AI_Hackthon;

PRINT '✓ Permissões concedidas';
GO

-- =============================================
-- Testar stored procedure
-- =============================================
PRINT 'Testando AIHT_sp_CriarConversa...';
GO

BEGIN TRY
    DECLARE @TestResult TABLE (
        Id INT,
        NomeCliente NVARCHAR(200),
        GrupoEmpresarialId INT,
        FabricanteId INT,
        ModeloId INT,
        DataInicio DATETIME,
        Status NVARCHAR(50)
    );
    
    INSERT INTO @TestResult
    EXEC dbo.AIHT_sp_CriarConversa 
        @NomeCliente = 'Teste Sistema',
        @GrupoEmpresarialId = 1,
        @FabricanteId = 1,
        @ModeloId = 1;
    
    IF EXISTS (SELECT 1 FROM @TestResult)
    BEGIN
        PRINT '✓ Teste PASSOU! Stored procedure funcionando corretamente!';
        SELECT * FROM @TestResult;
    END
    ELSE
    BEGIN
        PRINT '✗ Teste FALHOU! Nenhum resultado retornado.';
    END
END TRY
BEGIN CATCH
    PRINT '✗ ERRO no teste: ' + ERROR_MESSAGE();
END CATCH
GO

PRINT '========================================';
PRINT 'Stored Procedures recriadas com sucesso!';
PRINT '========================================';
GO
