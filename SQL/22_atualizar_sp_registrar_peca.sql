-- =============================================
-- Script: Atualizar SP Registrar Peça com Código
-- Descrição: Adiciona parâmetro CodigoPeca na SP
-- =============================================

USE AI_Builder_Hackthon;
GO

-- =============================================
-- SP: Registrar Peça (ATUALIZADA COM CÓDIGO)
-- =============================================
IF OBJECT_ID('AIHT_sp_RegistrarPeca', 'P') IS NOT NULL
    DROP PROCEDURE AIHT_sp_RegistrarPeca;
GO

CREATE PROCEDURE AIHT_sp_RegistrarPeca
    @ConversaId INT,
    @ProblemaId INT,
    @NomePeca VARCHAR(200),
    @CodigoPeca VARCHAR(50) = NULL,
    @CategoriaPeca VARCHAR(100) = NULL,
    @Prioridade VARCHAR(50) = 'Média'
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO AIHT_PecasIdentificadas (
        ConversaId,
        ProblemaId,
        NomePeca,
        CodigoPeca,
        CategoriaPeca,
        Prioridade,
        DataIdentificacao,
        DataAtualizacao
    )
    VALUES (
        @ConversaId,
        @ProblemaId,
        @NomePeca,
        @CodigoPeca,
        @CategoriaPeca,
        @Prioridade,
        GETDATE(),
        GETDATE()
    );
    
    SELECT 
        Id,
        ConversaId,
        ProblemaId,
        NomePeca,
        CodigoPeca,
        CategoriaPeca,
        Prioridade,
        DataIdentificacao
    FROM AIHT_PecasIdentificadas
    WHERE Id = SCOPE_IDENTITY();
END;
GO

PRINT '✓ AIHT_sp_RegistrarPeca atualizada com parâmetro CodigoPeca';
GO

-- =============================================
-- Teste
-- =============================================
PRINT '';
PRINT '========================================';
PRINT 'Testando SP atualizada...';
PRINT '========================================';
GO

-- Verificar se existem conversas e problemas
IF EXISTS (SELECT 1 FROM AIHT_Conversas) AND EXISTS (SELECT 1 FROM AIHT_ProblemasIdentificados)
BEGIN
    DECLARE @TesteConversaId INT;
    DECLARE @TesteProblemaId INT;
    
    SELECT TOP 1 @TesteConversaId = Id FROM AIHT_Conversas ORDER BY Id DESC;
    SELECT TOP 1 @TesteProblemaId = Id FROM AIHT_ProblemasIdentificados ORDER BY Id DESC;
    
    PRINT 'Testando com ConversaId: ' + CAST(@TesteConversaId AS VARCHAR(10));
    PRINT 'Testando com ProblemaId: ' + CAST(@TesteProblemaId AS VARCHAR(10));
    PRINT '';
    
    -- Testar inserção com código
    PRINT 'Inserindo peça COM código:';
    EXEC AIHT_sp_RegistrarPeca 
        @ConversaId = @TesteConversaId,
        @ProblemaId = @TesteProblemaId,
        @NomePeca = 'Pastilhas de Freio Dianteiras (TESTE)',
        @CodigoPeca = '7098038',
        @CategoriaPeca = 'Freios',
        @Prioridade = 'Alta';
    
    PRINT '';
    PRINT 'Inserindo peça SEM código:';
    EXEC AIHT_sp_RegistrarPeca 
        @ConversaId = @TesteConversaId,
        @ProblemaId = @TesteProblemaId,
        @NomePeca = 'Filtro de Ar (TESTE)',
        @CategoriaPeca = 'Filtros',
        @Prioridade = 'Baixa';
END
ELSE
BEGIN
    PRINT 'Nenhuma conversa ou problema encontrado para teste.';
END
GO

PRINT '';
PRINT '========================================';
PRINT 'SP atualizada com sucesso!';
PRINT 'Agora aceita o parâmetro @CodigoPeca';
PRINT '========================================';
GO
