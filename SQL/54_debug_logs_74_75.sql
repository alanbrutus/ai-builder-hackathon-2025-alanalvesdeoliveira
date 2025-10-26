/*
==============================================================================
Script: 54_debug_logs_74_75.sql
Descrição: Debug dos logs 74 e 75 da conversa 53
Autor: Alan Alves de Oliveira
Data: 26/10/2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT 'DEBUG LOGS 74 E 75 - CONVERSA 53';
PRINT '========================================';
PRINT '';

-- 1. Log 74 (Primeira mensagem)
PRINT '1. LOG 74 (PRIMEIRA MENSAGEM):';
PRINT '';
SELECT 
    Id,
    ConversaId,
    TipoChamada,
    MensagemCliente,
    Sucesso,
    DataChamada
FROM AIHT_LogChamadasIA
WHERE Id = 74;
PRINT '';

PRINT 'Mensagem do Cliente (Log 74):';
SELECT MensagemCliente FROM AIHT_LogChamadasIA WHERE Id = 74;
PRINT '';

-- 2. Log 75 (Solicitação de cotação)
PRINT '2. LOG 75 (SOLICITAÇÃO DE COTAÇÃO):';
PRINT '';
SELECT 
    Id,
    ConversaId,
    TipoChamada,
    MensagemCliente,
    Sucesso,
    DataChamada
FROM AIHT_LogChamadasIA
WHERE Id = 75;
PRINT '';

PRINT 'Mensagem do Cliente (Log 75):';
SELECT MensagemCliente FROM AIHT_LogChamadasIA WHERE Id = 75;
PRINT '';

-- 3. Testar detecção da mensagem do Log 75
PRINT '========================================';
PRINT '3. TESTAR DETECÇÃO DA MENSAGEM LOG 75';
PRINT '========================================';
PRINT '';

DECLARE @MensagemLog75 NVARCHAR(MAX);
SELECT @MensagemLog75 = MensagemCliente FROM AIHT_LogChamadasIA WHERE Id = 75;

PRINT 'Mensagem a testar: "' + ISNULL(@MensagemLog75, 'NULL') + '"';
PRINT 'Tamanho: ' + CAST(LEN(@MensagemLog75) AS VARCHAR) + ' caracteres';
PRINT '';

IF @MensagemLog75 IS NOT NULL
BEGIN
    PRINT 'Executando SP de verificação:';
    EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = @MensagemLog75;
END
ELSE
BEGIN
    PRINT '❌ Mensagem é NULL!';
END
PRINT '';

-- 4. Verificar se há resposta no Log 75
PRINT '4. VERIFICAR RESPOSTA DO LOG 75:';
SELECT 
    Id,
    CASE 
        WHEN RespostaRecebida IS NULL THEN '❌ NULL'
        WHEN LEN(RespostaRecebida) = 0 THEN '❌ VAZIO'
        WHEN LEN(RespostaRecebida) > 100 THEN '✅ TEM RESPOSTA (' + CAST(LEN(RespostaRecebida) AS VARCHAR) + ' caracteres)'
        ELSE '✅ TEM RESPOSTA (' + CAST(LEN(RespostaRecebida) AS VARCHAR) + ' caracteres)'
    END AS StatusResposta,
    Sucesso,
    MensagemErro
FROM AIHT_LogChamadasIA
WHERE Id = 75;
PRINT '';

-- 5. Verificar peças identificadas
PRINT '5. PEÇAS IDENTIFICADAS (Conversa 53):';
SELECT 
    Id,
    NomePeca,
    CodigoPeca,
    DataIdentificacao
FROM AIHT_PecasIdentificadas
WHERE ConversaId = 53
ORDER BY DataIdentificacao;
PRINT '';

-- 6. Verificar cotações salvas
PRINT '6. COTAÇÕES SALVAS (Conversa 53):';
SELECT 
    COUNT(*) AS TotalCotacoes
FROM AIHT_CotacoesPecas
WHERE ConversaId = 53;

SELECT 
    Id,
    NomePeca,
    TipoCotacao,
    Preco,
    PrecoMinimo,
    PrecoMaximo,
    DataCotacao
FROM AIHT_CotacoesPecas
WHERE ConversaId = 53
ORDER BY DataCotacao;
PRINT '';

-- 7. Testar palavras comuns
PRINT '========================================';
PRINT '7. TESTES RÁPIDOS';
PRINT '========================================';
PRINT '';

PRINT 'Teste: "cotação"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'cotação';
PRINT '';

PRINT 'Teste: "cotacao"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'cotacao';
PRINT '';

PRINT 'Teste: "SIM"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'SIM';
PRINT '';

PRINT '========================================';
PRINT 'FIM DO DEBUG';
PRINT '========================================';

GO
