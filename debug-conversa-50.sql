-- Debug da Conversa 50
USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT 'DEBUG CONVERSA 50';
PRINT '========================================';
PRINT '';

-- 1. Informações da conversa
PRINT '1. INFORMAÇÕES DA CONVERSA:';
SELECT 
    Id,
    NomeCliente,
    VeiculoMarca,
    VeiculoModelo,
    VeiculoAno,
    DataCriacao,
    DataUltimaInteracao
FROM AIHT_Conversas
WHERE Id = 50;

-- 2. Peças identificadas
PRINT '';
PRINT '2. PEÇAS IDENTIFICADAS:';
SELECT 
    Id,
    NomePeca,
    CodigoPeca,
    DataIdentificacao
FROM AIHT_PecasIdentificadas
WHERE ConversaId = 50;

-- 3. Logs de chamadas IA
PRINT '';
PRINT '3. LOGS DE CHAMADAS IA:';
SELECT 
    Id,
    TipoChamada,
    MensagemCliente,
    CASE 
        WHEN LEN(PromptEnviado) > 100 THEN LEFT(PromptEnviado, 100) + '...'
        ELSE PromptEnviado
    END AS PromptEnviado_Preview,
    CASE 
        WHEN LEN(RespostaRecebida) > 100 THEN LEFT(RespostaRecebida, 100) + '...'
        ELSE RespostaRecebida
    END AS RespostaRecebida_Preview,
    Sucesso,
    MensagemErro,
    DataChamada
FROM AIHT_LogChamadasIA
WHERE ConversaId = 50
ORDER BY DataChamada DESC;

-- 4. Testar detecção de "SIM"
PRINT '';
PRINT '4. TESTE DE DETECÇÃO "SIM":';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'SIM';

-- 5. Testar com espaços
PRINT '';
PRINT '5. TESTE COM ESPAÇOS:';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = '  SIM  ';

-- 6. Verificar palavra SIM na tabela
PRINT '';
PRINT '6. PALAVRA SIM NA TABELA:';
SELECT * FROM AIHT_PalavrasCotacao WHERE UPPER(Palavra) = 'SIM';

GO
