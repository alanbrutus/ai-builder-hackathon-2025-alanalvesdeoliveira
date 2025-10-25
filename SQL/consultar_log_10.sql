-- =============================================
-- Consultar Log ID 10 - Debug Detalhado
-- =============================================

USE AI_Builder_Hackthon;
GO

PRINT 'Consultando log ID 10...';
GO

-- Ver detalhes completos
SELECT 
    Id,
    ConversaId,
    MensagemCliente,
    Sucesso,
    MensagemErro,
    TempoResposta,
    DataChamada,
    LEN(PromptEnviado) AS TamanhoPrompt,
    LEN(RespostaIA) AS TamanhoResposta
FROM AIHT_LogChamadasIA
WHERE Id = 10;
GO

-- Ver prompt enviado
PRINT '';
PRINT '========================================';
PRINT 'PROMPT ENVIADO:';
PRINT '========================================';
SELECT PromptEnviado FROM AIHT_LogChamadasIA WHERE Id = 10;
GO

-- Ver resposta da IA
PRINT '';
PRINT '========================================';
PRINT 'RESPOSTA DA IA:';
PRINT '========================================';
SELECT RespostaIA FROM AIHT_LogChamadasIA WHERE Id = 10;
GO

-- Verificar se tem marcadores
PRINT '';
PRINT '========================================';
PRINT 'VERIFICANDO MARCADORES:';
PRINT '========================================';
GO

SELECT 
    Id,
    CASE 
        WHEN RespostaIA LIKE '%---PECAS_IDENTIFICADAS---%' THEN 'SIM'
        ELSE 'NÃO'
    END AS TemMarcadorInicio,
    CASE 
        WHEN RespostaIA LIKE '%---FIM_PECAS---%' THEN 'SIM'
        ELSE 'NÃO'
    END AS TemMarcadorFim,
    CHARINDEX('---PECAS_IDENTIFICADAS---', RespostaIA) AS PosicaoInicio,
    CHARINDEX('---FIM_PECAS---', RespostaIA) AS PosicaoFim,
    CASE 
        WHEN Sucesso = 1 THEN 'SUCESSO'
        ELSE 'ERRO: ' + ISNULL(MensagemErro, 'Sem mensagem de erro')
    END AS Status
FROM AIHT_LogChamadasIA
WHERE Id = 10;
GO

-- Ver últimos 5 logs para comparação
PRINT '';
PRINT '========================================';
PRINT 'ÚLTIMOS 5 LOGS:';
PRINT '========================================';
GO

SELECT TOP 5
    Id,
    ConversaId,
    LEFT(MensagemCliente, 50) + '...' AS Mensagem,
    Sucesso,
    MensagemErro,
    TempoResposta,
    DataChamada
FROM AIHT_LogChamadasIA
ORDER BY Id DESC;
GO
