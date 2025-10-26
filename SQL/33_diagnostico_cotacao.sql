/*
==============================================================================
Script: 33_diagnostico_cotacao.sql
Descrição: Diagnóstico completo do sistema de detecção de cotação
Problema: Palavra "Cotação" não está sendo detectada
Autor: Alan Alves de Oliveira
Data: 25/10/2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT '🔍 DIAGNÓSTICO DO SISTEMA DE COTAÇÃO';
PRINT '========================================';
PRINT '';

-- 1. Verificar palavras cadastradas
PRINT '1️⃣ PALAVRAS CADASTRADAS NA TABELA:';
PRINT '----------------------------------------';
SELECT 
    Id,
    Palavra,
    Tipo,
    Ativo,
    DataCriacao
FROM AIHT_PalavrasCotacao
ORDER BY Palavra;

PRINT '';
PRINT '----------------------------------------';
PRINT '';

-- 2. Testar detecção com diferentes variações
PRINT '2️⃣ TESTANDO DETECÇÃO:';
PRINT '----------------------------------------';

-- Teste 1: "Cotação" (com acento)
DECLARE @Teste1 NVARCHAR(MAX) = 'Cotação';
DECLARE @IntencaoTeste1 BIT;
DECLARE @PalavrasTeste1 NVARCHAR(MAX);

EXEC AIHT_sp_VerificarIntencaoCotacao 
    @Mensagem = @Teste1;

SELECT 
    @Teste1 AS Mensagem,
    IntencaoCotacao,
    PalavrasEncontradas
FROM (
    SELECT TOP 1 * FROM (
        SELECT 1 AS IntencaoCotacao, 'cotação' AS PalavrasEncontradas
        WHERE EXISTS (
            SELECT 1 
            FROM AIHT_PalavrasCotacao 
            WHERE Ativo = 1 
            AND UPPER(@Teste1) LIKE '%' + UPPER(Palavra) + '%'
        )
        UNION ALL
        SELECT 0, NULL
    ) x
) resultado;

PRINT '';

-- Teste 2: "cotacao" (sem acento)
DECLARE @Teste2 NVARCHAR(MAX) = 'cotacao';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = @Teste2;

PRINT '';

-- Teste 3: "COTAÇÃO" (maiúscula)
DECLARE @Teste3 NVARCHAR(MAX) = 'COTAÇÃO';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = @Teste3;

PRINT '';

-- Teste 4: "preço"
DECLARE @Teste4 NVARCHAR(MAX) = 'preço';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = @Teste4;

PRINT '';

-- Teste 5: "quanto custa"
DECLARE @Teste5 NVARCHAR(MAX) = 'quanto custa';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = @Teste5;

PRINT '';

-- Teste 6: "obrigado" (não deve detectar)
DECLARE @Teste6 NVARCHAR(MAX) = 'obrigado';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = @Teste6;

PRINT '';
PRINT '----------------------------------------';
PRINT '';

-- 3. Verificar stored procedure
PRINT '3️⃣ VERIFICANDO STORED PROCEDURE:';
PRINT '----------------------------------------';

SELECT 
    OBJECT_NAME(object_id) AS NomeSP,
    create_date AS DataCriacao,
    modify_date AS DataModificacao
FROM sys.procedures
WHERE name = 'AIHT_sp_VerificarIntencaoCotacao';

PRINT '';
PRINT '----------------------------------------';
PRINT '';

-- 4. Teste manual de UPPER
PRINT '4️⃣ TESTE MANUAL DE UPPER:';
PRINT '----------------------------------------';

SELECT 
    'Cotação' AS Original,
    UPPER('Cotação') AS Upper_Result,
    CASE 
        WHEN UPPER('Cotação') LIKE '%COTAÇÃO%' THEN 'Match com acento'
        WHEN UPPER('Cotação') LIKE '%COTACAO%' THEN 'Match sem acento'
        ELSE 'Sem match'
    END AS Teste_Match;

SELECT 
    Palavra AS Palavra_Tabela,
    UPPER(Palavra) AS Upper_Palavra,
    CASE 
        WHEN UPPER('Cotação') LIKE '%' + UPPER(Palavra) + '%' THEN '✅ MATCH'
        ELSE '❌ NO MATCH'
    END AS Resultado
FROM AIHT_PalavrasCotacao
WHERE Ativo = 1
ORDER BY Palavra;

PRINT '';
PRINT '----------------------------------------';
PRINT '';

-- 5. Verificar collation do banco
PRINT '5️⃣ VERIFICANDO COLLATION:';
PRINT '----------------------------------------';

SELECT 
    name AS Database_Name,
    collation_name AS Collation
FROM sys.databases
WHERE name = 'AI_Builder_Hackthon';

SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    COLLATION_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'AIHT_PalavrasCotacao'
AND COLUMN_NAME = 'Palavra';

PRINT '';
PRINT '========================================';
PRINT '✅ DIAGNÓSTICO CONCLUÍDO';
PRINT '========================================';
PRINT '';
PRINT '📋 PRÓXIMOS PASSOS:';
PRINT '   1. Verificar se as palavras estão cadastradas';
PRINT '   2. Verificar se a SP retorna IntencaoCotacao = 1';
PRINT '   3. Verificar collation (deve ser case-insensitive)';
PRINT '   4. Testar manualmente: EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = ''Cotação''';
PRINT '';
