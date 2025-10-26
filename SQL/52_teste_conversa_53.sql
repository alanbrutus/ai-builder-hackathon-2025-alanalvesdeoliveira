/*
==============================================================================
Script: 52_teste_conversa_53.sql
Descrição: Teste completo da conversa 53
Autor: Alan Alves de Oliveira
Data: 26/10/2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT 'TESTE COMPLETO - CONVERSA 53';
PRINT '========================================';
PRINT '';

-- 1. Informações da conversa
PRINT '1. INFORMAÇÕES DA CONVERSA:';
SELECT 
    Id,
    NomeCliente,
    MarcaId,
    ModeloId,
    DataInicio,
    DataUltimaInteracao,
    Status
FROM AIHT_Conversas
WHERE Id = 53;
PRINT '';

-- 2. Peças identificadas
PRINT '2. PEÇAS IDENTIFICADAS:';
SELECT 
    Id,
    NomePeca,
    CodigoPeca,
    DataIdentificacao
FROM AIHT_PecasIdentificadas
WHERE ConversaId = 53
ORDER BY DataIdentificacao;
PRINT '';

-- 3. Logs de chamadas IA
PRINT '3. LOGS DE CHAMADAS IA:';
SELECT 
    Id,
    TipoChamada,
    MensagemCliente,
    CASE 
        WHEN LEN(PromptEnviado) > 150 THEN LEFT(PromptEnviado, 150) + '...'
        ELSE PromptEnviado
    END AS PromptEnviado_Preview,
    CASE 
        WHEN LEN(RespostaRecebida) > 150 THEN LEFT(RespostaRecebida, 150) + '...'
        ELSE RespostaRecebida
    END AS RespostaRecebida_Preview,
    Sucesso,
    MensagemErro,
    DataChamada
FROM AIHT_LogChamadasIA
WHERE ConversaId = 53
ORDER BY DataChamada;
PRINT '';

-- 4. Cotações salvas
PRINT '4. COTAÇÕES SALVAS:';
SELECT 
    Id,
    NomePeca,
    TipoCotacao,
    Preco,
    PrecoMinimo,
    PrecoMaximo,
    Link,
    DataCotacao
FROM AIHT_CotacoesPecas
WHERE ConversaId = 53
ORDER BY DataCotacao;
PRINT '';

-- 5. Testar mensagens da conversa 53
PRINT '========================================';
PRINT '5. TESTAR MENSAGENS DA CONVERSA';
PRINT '========================================';
PRINT '';

-- Buscar mensagens do cliente nos logs
DECLARE @Mensagem1 NVARCHAR(MAX);
DECLARE @Mensagem2 NVARCHAR(MAX);
DECLARE @Mensagem3 NVARCHAR(MAX);

SELECT TOP 1 @Mensagem1 = MensagemCliente 
FROM AIHT_LogChamadasIA 
WHERE ConversaId = 53 
ORDER BY DataChamada;

SELECT @Mensagem2 = MensagemCliente 
FROM (
    SELECT MensagemCliente, ROW_NUMBER() OVER (ORDER BY DataChamada) AS RowNum
    FROM AIHT_LogChamadasIA 
    WHERE ConversaId = 53
) AS T
WHERE RowNum = 2;

SELECT @Mensagem3 = MensagemCliente 
FROM (
    SELECT MensagemCliente, ROW_NUMBER() OVER (ORDER BY DataChamada) AS RowNum
    FROM AIHT_LogChamadasIA 
    WHERE ConversaId = 53
) AS T
WHERE RowNum = 3;

IF @Mensagem1 IS NOT NULL
BEGIN
    PRINT '📝 Mensagem 1: "' + ISNULL(@Mensagem1, 'NULL') + '"';
    EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = @Mensagem1;
    PRINT '';
END

IF @Mensagem2 IS NOT NULL
BEGIN
    PRINT '📝 Mensagem 2: "' + ISNULL(@Mensagem2, 'NULL') + '"';
    EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = @Mensagem2;
    PRINT '';
END

IF @Mensagem3 IS NOT NULL
BEGIN
    PRINT '📝 Mensagem 3: "' + ISNULL(@Mensagem3, 'NULL') + '"';
    EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = @Mensagem3;
    PRINT '';
END

-- 6. Testar palavras comuns
PRINT '========================================';
PRINT '6. TESTES COM PALAVRAS COMUNS';
PRINT '========================================';
PRINT '';

PRINT '📝 Teste: "SIM"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'SIM';
PRINT '';

PRINT '📝 Teste: "cotação"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'cotação';
PRINT '';

PRINT '📝 Teste: "cotacao"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'cotacao';
PRINT '';

PRINT '📝 Teste: "quero"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'quero';
PRINT '';

PRINT '📝 Teste: "quanto custa"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'quanto custa';
PRINT '';

-- 7. Verificar palavra "S"
PRINT '========================================';
PRINT '7. STATUS DA PALAVRA "S"';
PRINT '========================================';
PRINT '';

SELECT Id, Palavra, Tipo, Ativo 
FROM AIHT_PalavrasCotacao 
WHERE UPPER(Palavra) = 'S';
PRINT '';

-- 8. Contar palavras ativas
PRINT '8. TOTAL DE PALAVRAS ATIVAS:';
SELECT COUNT(*) AS TotalPalavrasAtivas 
FROM AIHT_PalavrasCotacao 
WHERE Ativo = 1;
PRINT '';

PRINT '========================================';
PRINT 'FIM DO TESTE - CONVERSA 53';
PRINT '========================================';

GO
