/*
==============================================================================
Script: 62_identificar_logs_incorretos.sql
Descrição: Identificar logs que foram finalizados mas tinham intenção de cotação
Autor: Alan Alves de Oliveira
Data: 26/10/2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT 'LOGS FINALIZADOS INCORRETAMENTE';
PRINT '========================================';
PRINT '';

-- 1. Identificar logs com problema
PRINT '1. LOGS COM PALAVRAS DE COTAÇÃO MAS FORAM FINALIZADOS:';
SELECT 
    l.Id,
    l.ConversaId,
    l.MensagemCliente,
    l.TipoChamada,
    LEFT(l.PromptEnviado, 50) AS PromptInicio,
    l.DataChamada,
    p.Palavra AS PalavraEncontrada
FROM [AI_Builder_Hackthon].[dbo].[AIHT_LogChamadasIA] l
INNER JOIN [AI_Builder_Hackthon].[dbo].[AIHT_PalavrasCotacao] p 
    ON UPPER(LTRIM(RTRIM(l.MensagemCliente))) = p.Palavra
WHERE p.Ativo = 1
AND l.PromptEnviado LIKE 'Você está finalizando%'
ORDER BY l.DataChamada DESC;

PRINT '';

-- 2. Contar total
PRINT '2. TOTAL DE LOGS INCORRETOS:';
SELECT COUNT(*) AS TotalLogsIncorretos
FROM [AI_Builder_Hackthon].[dbo].[AIHT_LogChamadasIA] l
INNER JOIN [AI_Builder_Hackthon].[dbo].[AIHT_PalavrasCotacao] p 
    ON UPPER(LTRIM(RTRIM(l.MensagemCliente))) = p.Palavra
WHERE p.Ativo = 1
AND l.PromptEnviado LIKE 'Você está finalizando%';

PRINT '';

-- 3. Agrupar por palavra
PRINT '3. LOGS INCORRETOS POR PALAVRA:';
SELECT 
    p.Palavra,
    COUNT(*) AS Quantidade
FROM [AI_Builder_Hackthon].[dbo].[AIHT_LogChamadasIA] l
INNER JOIN [AI_Builder_Hackthon].[dbo].[AIHT_PalavrasCotacao] p 
    ON UPPER(LTRIM(RTRIM(l.MensagemCliente))) = p.Palavra
WHERE p.Ativo = 1
AND l.PromptEnviado LIKE 'Você está finalizando%'
GROUP BY p.Palavra
ORDER BY COUNT(*) DESC;

PRINT '';

-- 4. Verificar conversas afetadas
PRINT '4. CONVERSAS AFETADAS:';
SELECT DISTINCT
    l.ConversaId,
    c.NomeCliente,
    COUNT(l.Id) AS TotalLogsIncorretos
FROM [AI_Builder_Hackthon].[dbo].[AIHT_LogChamadasIA] l
INNER JOIN [AI_Builder_Hackthon].[dbo].[AIHT_PalavrasCotacao] p 
    ON UPPER(LTRIM(RTRIM(l.MensagemCliente))) = p.Palavra
INNER JOIN [AI_Builder_Hackthon].[dbo].[AIHT_Conversas] c ON l.ConversaId = c.Id
WHERE p.Ativo = 1
AND l.PromptEnviado LIKE 'Você está finalizando%'
GROUP BY l.ConversaId, c.NomeCliente
ORDER BY COUNT(l.Id) DESC;

PRINT '';
PRINT '========================================';
PRINT 'ANÁLISE CONCLUÍDA';
PRINT '========================================';
PRINT '';
PRINT '💡 CAUSA DO PROBLEMA:';
PRINT '   O fluxo antigo não verificava intenção de cotação';
PRINT '   antes de finalizar o atendimento.';
PRINT '';
PRINT '✅ SOLUÇÃO IMPLEMENTADA:';
PRINT '   Agora o sistema gera cotação automaticamente';
PRINT '   após identificar as peças.';
PRINT '';

GO
