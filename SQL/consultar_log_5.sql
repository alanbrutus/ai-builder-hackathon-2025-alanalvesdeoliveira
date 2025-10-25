-- =============================================
-- Consultar Log ID 5 - Debug
-- =============================================

USE AI_Builder_Hackthon;
GO

PRINT 'Consultando log ID 5...';
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
WHERE Id = 5;
GO

-- Ver prompt enviado
PRINT '';
PRINT 'PROMPT ENVIADO:';
PRINT '================';
SELECT PromptEnviado FROM AIHT_LogChamadasIA WHERE Id = 5;
GO

-- Ver resposta da IA
PRINT '';
PRINT 'RESPOSTA DA IA:';
PRINT '================';
SELECT RespostaIA FROM AIHT_LogChamadasIA WHERE Id = 5;
GO

-- Verificar se tem marcadores
PRINT '';
PRINT 'VERIFICANDO MARCADORES:';
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
    CHARINDEX('---FIM_PECAS---', RespostaIA) AS PosicaoFim
FROM AIHT_LogChamadasIA
WHERE Id = 5;
GO
