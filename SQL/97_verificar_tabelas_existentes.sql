-- =============================================
-- Script: Verificar Tabelas Existentes
-- =============================================

USE AI_Builder_Hackthon;
GO

PRINT 'Listando TODAS as tabelas do banco:';
GO

SELECT 
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO

PRINT '';
PRINT 'Verificando tabelas específicas:';
GO

-- Verificar GruposEmpresariais
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'AIHT_GruposEmpresariais')
    PRINT '✓ AIHT_GruposEmpresariais existe'
ELSE
    PRINT '✗ AIHT_GruposEmpresariais NÃO existe';

-- Verificar Fabricantes
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'AIHT_Fabricantes')
    PRINT '✓ AIHT_Fabricantes existe'
ELSE
    PRINT '✗ AIHT_Fabricantes NÃO existe';

-- Verificar Modelos
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'AIHT_Modelos')
    PRINT '✓ AIHT_Modelos existe'
ELSE
    PRINT '✗ AIHT_Modelos NÃO existe';
GO
