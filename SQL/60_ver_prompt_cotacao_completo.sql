/*
==============================================================================
Script: 60_ver_prompt_cotacao_completo.sql
Descrição: Ver conteúdo completo do prompt de cotação
Autor: Alan Alves de Oliveira
Data: 26/10/2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT 'PROMPT DE COTAÇÃO - CONTEÚDO COMPLETO';
PRINT '========================================';
PRINT '';

-- Ver conteúdo completo
SELECT ConteudoPrompt 
FROM AIHT_Prompts 
WHERE Contexto = 'cotacao';

PRINT '';
PRINT '========================================';
PRINT 'INFORMAÇÕES DO PROMPT';
PRINT '========================================';
PRINT '';

SELECT 
    Id,
    Contexto,
    Nome,
    LEN(ConteudoPrompt) AS TamanhoCaracteres,
    Ativo,
    DataCriacao,
    DataAtualizacao
FROM AIHT_Prompts
WHERE Contexto = 'cotacao';

GO
