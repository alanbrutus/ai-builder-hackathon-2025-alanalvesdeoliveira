-- =============================================
-- Script: Diagnóstico de Tabelas
-- =============================================

-- Verificar banco de dados atual
SELECT DB_NAME() AS 'Banco Atual';
GO

-- Listar todas as tabelas que começam com AIHT_
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE 'AIHT_%'
ORDER BY TABLE_NAME;
GO

-- Verificar especificamente AIHT_Conversas
IF EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'AIHT_Conversas'
)
BEGIN
    PRINT '✓ Tabela AIHT_Conversas encontrada';
    
    -- Mostrar colunas
    SELECT 
        COLUMN_NAME,
        DATA_TYPE,
        IS_NULLABLE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'AIHT_Conversas'
    ORDER BY ORDINAL_POSITION;
END
ELSE
BEGIN
    PRINT '✗ Tabela AIHT_Conversas NÃO encontrada';
END
GO

-- Verificar schema
SELECT 
    s.name AS 'Schema',
    t.name AS 'Tabela',
    t.create_date AS 'Data Criação'
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.name LIKE 'AIHT_%'
ORDER BY t.name;
GO

-- Testar SELECT direto
BEGIN TRY
    SELECT TOP 1 * FROM dbo.AIHT_Conversas;
    PRINT '✓ SELECT funcionou!';
END TRY
BEGIN CATCH
    PRINT '✗ Erro no SELECT: ' + ERROR_MESSAGE();
END CATCH
GO
