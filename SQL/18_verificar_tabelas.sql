-- =============================================
-- Script: Verificar Nomes das Tabelas
-- Descrição: Lista todas as tabelas AIHT_ para verificar nomes corretos
-- =============================================

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT 'TABELAS EXISTENTES NO BANCO:';
PRINT '========================================';
GO

SELECT 
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE 'AIHT_%'
ORDER BY TABLE_NAME;
GO

PRINT '';
PRINT '========================================';
PRINT 'COLUNAS DA TABELA AIHT_Conversas:';
PRINT '========================================';
GO

SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'AIHT_Conversas'
ORDER BY ORDINAL_POSITION;
GO

PRINT '';
PRINT '========================================';
PRINT 'VERIFICANDO RELACIONAMENTOS:';
PRINT '========================================';
GO

-- Ver se existe ModeloId na tabela Conversas
IF EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'AIHT_Conversas' 
    AND COLUMN_NAME = 'ModeloId'
)
BEGIN
    PRINT '✓ AIHT_Conversas tem ModeloId';
    
    -- Verificar se existe tabela de Modelos
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE '%Modelo%')
    BEGIN
        SELECT 'Tabela de Modelos encontrada: ' + TABLE_NAME
        FROM INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_NAME LIKE '%Modelo%';
    END
    ELSE
    BEGIN
        PRINT '❌ Nenhuma tabela de Modelos encontrada';
    END
END
ELSE
BEGIN
    PRINT '❌ AIHT_Conversas NÃO tem ModeloId';
END
GO

-- Ver se existe FabricanteId
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE '%Fabricante%')
BEGIN
    SELECT 'Tabela de Fabricantes encontrada: ' + TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME LIKE '%Fabricante%';
END
ELSE
BEGIN
    PRINT '❌ Nenhuma tabela de Fabricantes encontrada';
END
GO

-- Ver se existe GrupoEmpresarial
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE '%Grupo%')
BEGIN
    SELECT 'Tabela de Grupos encontrada: ' + TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME LIKE '%Grupo%';
END
ELSE
BEGIN
    PRINT '❌ Nenhuma tabela de Grupos encontrada';
END
GO
