-- =============================================
-- Script: Verificar Estrutura Real do Banco
-- Descrição: Identifica as tabelas e colunas reais
-- =============================================

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT 'TODAS AS TABELAS AIHT_:';
PRINT '========================================';
GO

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE 'AIHT_%'
ORDER BY TABLE_NAME;
GO

PRINT '';
PRINT '========================================';
PRINT 'ESTRUTURA DA TABELA AIHT_Conversas:';
PRINT '========================================';
GO

SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'AIHT_Conversas'
ORDER BY ORDINAL_POSITION;
GO

PRINT '';
PRINT '========================================';
PRINT 'DADOS DE EXEMPLO:';
PRINT '========================================';
GO

-- Ver uma conversa de exemplo
IF EXISTS (SELECT 1 FROM AIHT_Conversas)
BEGIN
    PRINT 'Exemplo de Conversa:';
    SELECT TOP 1 * FROM AIHT_Conversas ORDER BY Id DESC;
END
GO

-- Ver stored procedures que já funcionam
PRINT '';
PRINT '========================================';
PRINT 'STORED PROCEDURES EXISTENTES:';
PRINT '========================================';
GO

SELECT 
    ROUTINE_NAME,
    CREATED,
    LAST_ALTERED
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE'
AND ROUTINE_NAME LIKE 'AIHT_%'
ORDER BY ROUTINE_NAME;
GO

-- Testar uma SP que funciona
PRINT '';
PRINT '========================================';
PRINT 'TESTANDO SP QUE FUNCIONA:';
PRINT '========================================';
GO

IF EXISTS (SELECT 1 FROM AIHT_Conversas)
BEGIN
    DECLARE @TesteId INT;
    SELECT TOP 1 @TesteId = Id FROM AIHT_Conversas ORDER BY Id DESC;
    
    PRINT 'Testando AIHT_sp_ListarPecasConversa:';
    EXEC AIHT_sp_ListarPecasConversa @ConversaId = @TesteId;
END
GO
