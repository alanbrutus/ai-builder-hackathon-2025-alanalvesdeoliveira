/*
==============================================================================
Script: 64_verificar_logs_para_reprocessar.sql
Descrição: Verificar logs que precisam ser reprocessados
Autor: Alan Alves de Oliveira
Data: 26/10/2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT 'LOGS PARA REPROCESSAR';
PRINT '========================================';
PRINT '';

-- 1. Logs com palavras de cotação
PRINT '1. LOGS COM PALAVRAS DE COTAÇÃO:';
SELECT 
    l.Id,
    l.ConversaId,
    l.MensagemCliente,
    UPPER(LTRIM(RTRIM(l.MensagemCliente))) AS MensagemNormalizada,
    LEFT(l.PromptEnviado, 30) AS PromptInicio,
    l.DataChamada
FROM [AI_Builder_Hackthon].[dbo].[AIHT_LogChamadasIA] l
WHERE UPPER(LTRIM(RTRIM(l.MensagemCliente))) IN (
    SELECT [Palavra] 
    FROM [AI_Builder_Hackthon].[dbo].[AIHT_PalavrasCotacao] 
    WHERE Ativo = 1
)
ORDER BY l.DataChamada DESC;
PRINT '';

-- 2. Logs que foram finalizados
PRINT '2. LOGS COM PROMPT DE FINALIZAÇÃO:';
SELECT 
    l.Id,
    l.ConversaId,
    l.MensagemCliente,
    LEFT(l.PromptEnviado, 50) AS PromptInicio,
    l.DataChamada
FROM [AI_Builder_Hackthon].[dbo].[AIHT_LogChamadasIA] l
WHERE l.PromptEnviado LIKE 'Você está finalizando%'
ORDER BY l.DataChamada DESC;
PRINT '';

-- 3. Intersecção (logs que devem ser reprocessados)
PRINT '3. LOGS PARA REPROCESSAR (palavras de cotação + finalização):';
SELECT 
    l.Id,
    l.ConversaId,
    l.MensagemCliente,
    LEFT(l.PromptEnviado, 50) AS PromptInicio,
    l.DataChamada
FROM [AI_Builder_Hackthon].[dbo].[AIHT_LogChamadasIA] l
WHERE UPPER(LTRIM(RTRIM(l.MensagemCliente))) IN (
    SELECT [Palavra] 
    FROM [AI_Builder_Hackthon].[dbo].[AIHT_PalavrasCotacao] 
    WHERE Ativo = 1
)
AND l.PromptEnviado LIKE 'Você está finalizando%'
ORDER BY l.DataChamada DESC;
PRINT '';

-- 4. Total
PRINT '4. TOTAIS:';
SELECT 
    (SELECT COUNT(*) FROM [AI_Builder_Hackthon].[dbo].[AIHT_LogChamadasIA] 
     WHERE UPPER(LTRIM(RTRIM(MensagemCliente))) IN (
         SELECT [Palavra] FROM [AI_Builder_Hackthon].[dbo].[AIHT_PalavrasCotacao] WHERE Ativo = 1
     )) AS TotalComPalavrasCotacao,
    (SELECT COUNT(*) FROM [AI_Builder_Hackthon].[dbo].[AIHT_LogChamadasIA] 
     WHERE PromptEnviado LIKE 'Você está finalizando%') AS TotalFinalizados,
    (SELECT COUNT(*) FROM [AI_Builder_Hackthon].[dbo].[AIHT_LogChamadasIA] 
     WHERE UPPER(LTRIM(RTRIM(MensagemCliente))) IN (
         SELECT [Palavra] FROM [AI_Builder_Hackthon].[dbo].[AIHT_PalavrasCotacao] WHERE Ativo = 1
     )
     AND PromptEnviado LIKE 'Você está finalizando%') AS TotalParaReprocessar;
PRINT '';

-- 5. Palavras ativas
PRINT '5. PALAVRAS DE COTAÇÃO ATIVAS:';
SELECT Palavra FROM [AI_Builder_Hackthon].[dbo].[AIHT_PalavrasCotacao] WHERE Ativo = 1 ORDER BY Palavra;
PRINT '';

GO
