-- =============================================
-- Script: Verificar Estrutura da Tabela AIHT_Prompts
-- =============================================

USE AI_Builder_Hackthon;
GO

PRINT 'Estrutura da tabela AIHT_Prompts:';
GO

-- Ver todas as colunas
SELECT 
    COLUMN_NAME AS 'Coluna',
    DATA_TYPE AS 'Tipo',
    CHARACTER_MAXIMUM_LENGTH AS 'Tamanho',
    IS_NULLABLE AS 'Permite NULL',
    COLUMN_DEFAULT AS 'Valor Padrão'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'AIHT_Prompts'
ORDER BY ORDINAL_POSITION;
GO

-- Ver dados existentes
PRINT '';
PRINT 'Prompts existentes:';
GO

SELECT 
    Id,
    Nome,
    Contexto,
    LEFT(ConteudoPrompt, 50) + '...' AS 'Preview',
    Versao,
    Ativo
FROM AIHT_Prompts;
GO
