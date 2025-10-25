-- =============================================
-- Script: Criar Stored Procedure para Obter Prompt
-- =============================================

USE AI_Builder_Hackthon;
GO

-- =============================================
-- Stored Procedure: Obter Prompt por Contexto
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[AIHT_sp_ObterPromptPorContexto]
    @Contexto NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        Id,
        Contexto,
        ConteudoPrompt,
        Descricao,
        Versao,
        Ativo,
        DataCriacao,
        DataAtualizacao
    FROM [dbo].[AIHT_Prompts]
    WHERE Contexto = @Contexto
        AND Ativo = 1
    ORDER BY Versao DESC;
END
GO

PRINT '✓ AIHT_sp_ObterPromptPorContexto criada';
GO

-- Conceder permissão
GRANT EXECUTE ON dbo.AIHT_sp_ObterPromptPorContexto TO AI_Hackthon;
PRINT '✓ Permissão concedida';
GO

-- Testar
PRINT 'Testando stored procedure...';
GO

EXEC dbo.AIHT_sp_ObterPromptPorContexto @Contexto = 'identificacao_pecas';
GO

PRINT '========================================';
PRINT 'Stored procedure criada e testada!';
PRINT '========================================';
GO
