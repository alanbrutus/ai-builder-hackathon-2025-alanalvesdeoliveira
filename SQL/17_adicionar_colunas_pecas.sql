-- =============================================
-- Script: Adicionar Colunas na Tabela de Peças
-- Descrição: Adiciona colunas CodigoPeca e DataAtualizacao
-- =============================================

USE AI_Builder_Hackthon;
GO

PRINT 'Verificando estrutura da tabela AIHT_PecasIdentificadas...';
GO

-- Ver estrutura atual
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'AIHT_PecasIdentificadas'
ORDER BY ORDINAL_POSITION;
GO

PRINT '';
PRINT 'Adicionando colunas faltantes...';
GO

-- Adicionar coluna CodigoPeca se não existir
IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'AIHT_PecasIdentificadas' 
    AND COLUMN_NAME = 'CodigoPeca'
)
BEGIN
    ALTER TABLE AIHT_PecasIdentificadas
    ADD CodigoPeca VARCHAR(50) NULL;
    
    PRINT '✓ Coluna CodigoPeca adicionada';
END
ELSE
BEGIN
    PRINT '  Coluna CodigoPeca já existe';
END
GO

-- Adicionar coluna DataAtualizacao se não existir
IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'AIHT_PecasIdentificadas' 
    AND COLUMN_NAME = 'DataAtualizacao'
)
BEGIN
    ALTER TABLE AIHT_PecasIdentificadas
    ADD DataAtualizacao DATETIME NULL;
    
    PRINT '✓ Coluna DataAtualizacao adicionada';
END
ELSE
BEGIN
    PRINT '  Coluna DataAtualizacao já existe';
END
GO

-- Atualizar DataAtualizacao para registros existentes
UPDATE AIHT_PecasIdentificadas
SET DataAtualizacao = DataIdentificacao
WHERE DataAtualizacao IS NULL;
GO

PRINT '';
PRINT 'Verificando estrutura atualizada...';
GO

-- Ver estrutura atualizada
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'AIHT_PecasIdentificadas'
ORDER BY ORDINAL_POSITION;
GO

PRINT '';
PRINT '========================================';
PRINT 'Colunas adicionadas com sucesso!';
PRINT 'Execute novamente: SQL/16_sp_pecas_para_cotacao.sql';
PRINT '========================================';
GO
