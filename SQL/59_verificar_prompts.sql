/*
==============================================================================
Script: 59_verificar_prompts.sql
Descrição: Verificar prompts cadastrados no banco
Autor: Alan Alves de Oliveira
Data: 26/10/2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT 'VERIFICAR PROMPTS CADASTRADOS';
PRINT '========================================';
PRINT '';

-- 1. Listar todos os prompts
PRINT '1. TODOS OS PROMPTS:';
SELECT 
    Id,
    Contexto,
    Nome,
    LEFT(ConteudoPrompt, 100) AS ConteudoPrompt_Preview,
    LEN(ConteudoPrompt) AS TamanhoPrompt,
    Ativo,
    DataCriacao
FROM AIHT_Prompts
ORDER BY Contexto;
PRINT '';

-- 2. Prompt de cotação
PRINT '2. PROMPT DE COTAÇÃO (Contexto = ''cotacao''):';
SELECT 
    Id,
    Contexto,
    Nome,
    ConteudoPrompt,
    Ativo
FROM AIHT_Prompts
WHERE Contexto = 'cotacao';
PRINT '';

-- 3. Testar SP
PRINT '3. TESTAR SP AIHT_sp_ObterPromptPorContexto:';
EXEC AIHT_sp_ObterPromptPorContexto @Contexto = 'cotacao';
PRINT '';

-- 4. Verificar se tem variáveis no prompt
PRINT '4. VERIFICAR VARIÁVEIS NO PROMPT:';
SELECT 
    Id,
    Contexto,
    CASE 
        WHEN ConteudoPrompt LIKE '%{{fabricante_veiculo}}%' THEN 'SIM'
        ELSE 'NÃO'
    END AS TemFabricante,
    CASE 
        WHEN ConteudoPrompt LIKE '%{{modelo_veiculo}}%' THEN 'SIM'
        ELSE 'NÃO'
    END AS TemModelo,
    CASE 
        WHEN ConteudoPrompt LIKE '%{{lista_pecas}}%' THEN 'SIM'
        ELSE 'NÃO'
    END AS TemListaPecas
FROM AIHT_Prompts
WHERE Contexto = 'cotacao';
PRINT '';

PRINT '========================================';
PRINT 'FIM DA VERIFICAÇÃO';
PRINT '========================================';

GO
