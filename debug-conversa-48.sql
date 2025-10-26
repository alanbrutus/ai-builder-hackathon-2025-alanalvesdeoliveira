-- Debug da Conversa 48
USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT 'DEBUG CONVERSA 48';
PRINT '========================================';
PRINT '';

-- 1. Informações da conversa
PRINT '1. INFORMAÇÕES DA CONVERSA:';
SELECT 
    Id,
    NomeCliente,
    VeiculoModelo,
    VeiculoAno,
    DataCriacao,
    DataUltimaInteracao
FROM AIHT_Conversas
WHERE Id = 48;

-- 2. Peças identificadas
PRINT '';
PRINT '2. PEÇAS IDENTIFICADAS:';
SELECT 
    Id,
    NomePeca,
    CodigoPeca,
    DataIdentificacao
FROM AIHT_PecasIdentificadas
WHERE ConversaId = 48;

-- 3. Logs de chamadas IA
PRINT '';
PRINT '3. LOGS DE CHAMADAS IA:';
SELECT 
    Id,
    TipoChamada,
    PromptEnviado,
    CASE 
        WHEN LEN(RespostaRecebida) > 100 THEN LEFT(RespostaRecebida, 100) + '...'
        ELSE RespostaRecebida
    END AS RespostaRecebida_Preview,
    LEN(RespostaRecebida) AS TamanhoResposta,
    Sucesso,
    MensagemErro,
    DataChamada
FROM AIHT_LogChamadasIA
WHERE ConversaId = 48
ORDER BY DataChamada DESC;

-- 4. Verificar se o prompt tem as variáveis
PRINT '';
PRINT '4. VERIFICAR PROMPT COMPLETO:';
SELECT 
    Id,
    PromptEnviado
FROM AIHT_LogChamadasIA
WHERE ConversaId = 48
AND TipoChamada = 'gerar-cotacao'
ORDER BY DataChamada DESC;

-- 5. Verificar resposta completa
PRINT '';
PRINT '5. RESPOSTA COMPLETA:';
SELECT 
    Id,
    RespostaRecebida
FROM AIHT_LogChamadasIA
WHERE ConversaId = 48
AND TipoChamada = 'gerar-cotacao'
ORDER BY DataChamada DESC;

GO
