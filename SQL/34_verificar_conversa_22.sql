/*
==============================================================================
Script: 34_verificar_conversa_22.sql
Descrição: Verificar dados completos da conversa ID 22
Autor: Alan Alves de Oliveira
Data: 25/10/2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT '🔍 ANÁLISE DA CONVERSA ID 22';
PRINT '========================================';
PRINT '';

-- 1. Dados da conversa
PRINT '1️⃣ DADOS DA CONVERSA:';
PRINT '----------------------------------------';
SELECT 
    Id,
    NomeCliente,
    GrupoEmpresarialId,
    FabricanteVeiculoId,
    ModeloVeiculoId,
    DataInicio,
    DataFim,
    Status
FROM AIHT_Conversas
WHERE Id = 22;

PRINT '';

-- 2. Mensagens da conversa
PRINT '2️⃣ MENSAGENS TROCADAS:';
PRINT '----------------------------------------';
SELECT 
    Id,
    ConversaId,
    Remetente,
    LEFT(Mensagem, 100) AS Mensagem_Preview,
    DataEnvio
FROM AIHT_Mensagens
WHERE ConversaId = 22
ORDER BY DataEnvio;

PRINT '';

-- 3. Peças identificadas
PRINT '3️⃣ PEÇAS IDENTIFICADAS:';
PRINT '----------------------------------------';
SELECT 
    Id,
    ConversaId,
    NomePeca,
    CodigoPeca,
    Categoria,
    Prioridade,
    MarcaVeiculo,
    ModeloVeiculo,
    DataIdentificacao
FROM AIHT_PecasIdentificadas
WHERE ConversaId = 22
ORDER BY DataIdentificacao;

PRINT '';

-- 4. Chamadas de IA
PRINT '4️⃣ CHAMADAS DE IA:';
PRINT '----------------------------------------';
SELECT 
    Id,
    ConversaId,
    TipoChamada,
    LEFT(PromptEnviado, 100) AS Prompt_Preview,
    LEFT(RespostaRecebida, 100) AS Resposta_Preview,
    TempoResposta,
    Sucesso,
    DataChamada
FROM AIHT_ChamadasIA
WHERE ConversaId = 22
ORDER BY DataChamada;

PRINT '';

-- 5. Última mensagem do cliente
PRINT '5️⃣ ÚLTIMA MENSAGEM DO CLIENTE:';
PRINT '----------------------------------------';
SELECT TOP 1
    Id,
    Mensagem,
    DataEnvio
FROM AIHT_Mensagens
WHERE ConversaId = 22
AND Remetente = 'Cliente'
ORDER BY DataEnvio DESC;

PRINT '';

-- 6. Testar detecção na última mensagem
PRINT '6️⃣ TESTE DE DETECÇÃO NA ÚLTIMA MENSAGEM:';
PRINT '----------------------------------------';

DECLARE @UltimaMensagem NVARCHAR(MAX);

SELECT TOP 1 @UltimaMensagem = Mensagem
FROM AIHT_Mensagens
WHERE ConversaId = 22
AND Remetente = 'Cliente'
ORDER BY DataEnvio DESC;

PRINT 'Mensagem: ' + ISNULL(@UltimaMensagem, 'Nenhuma mensagem encontrada');
PRINT '';

IF @UltimaMensagem IS NOT NULL
BEGIN
    PRINT 'Testando detecção de cotação:';
    EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = @UltimaMensagem;
END

PRINT '';

-- 7. Verificar se há peças para cotação
PRINT '7️⃣ PEÇAS DISPONÍVEIS PARA COTAÇÃO:';
PRINT '----------------------------------------';
EXEC AIHT_sp_ListarPecasParaCotacao @ConversaId = 22;

PRINT '';

-- 8. Histórico completo da conversa
PRINT '8️⃣ HISTÓRICO COMPLETO (CRONOLÓGICO):';
PRINT '----------------------------------------';
SELECT 
    M.Id AS MensagemId,
    M.Remetente,
    M.Mensagem,
    M.DataEnvio,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM AIHT_ChamadasIA 
            WHERE ConversaId = 22 
            AND DataChamada >= M.DataEnvio 
            AND DataChamada <= DATEADD(SECOND, 5, M.DataEnvio)
        ) THEN '✅ Teve chamada IA'
        ELSE ''
    END AS Status_IA
FROM AIHT_Mensagens M
WHERE M.ConversaId = 22
ORDER BY M.DataEnvio;

PRINT '';

-- 9. Análise de fluxo
PRINT '9️⃣ ANÁLISE DE FLUXO:';
PRINT '----------------------------------------';

DECLARE @TotalMensagens INT;
DECLARE @MensagensCliente INT;
DECLARE @MensagensAssistente INT;
DECLARE @TotalPecas INT;
DECLARE @TotalChamadas INT;

SELECT @TotalMensagens = COUNT(*) FROM AIHT_Mensagens WHERE ConversaId = 22;
SELECT @MensagensCliente = COUNT(*) FROM AIHT_Mensagens WHERE ConversaId = 22 AND Remetente = 'Cliente';
SELECT @MensagensAssistente = COUNT(*) FROM AIHT_Mensagens WHERE ConversaId = 22 AND Remetente = 'Assistente';
SELECT @TotalPecas = COUNT(*) FROM AIHT_PecasIdentificadas WHERE ConversaId = 22;
SELECT @TotalChamadas = COUNT(*) FROM AIHT_ChamadasIA WHERE ConversaId = 22;

PRINT 'Total de mensagens: ' + CAST(@TotalMensagens AS VARCHAR);
PRINT 'Mensagens do cliente: ' + CAST(@MensagensCliente AS VARCHAR);
PRINT 'Mensagens do assistente: ' + CAST(@MensagensAssistente AS VARCHAR);
PRINT 'Peças identificadas: ' + CAST(@TotalPecas AS VARCHAR);
PRINT 'Chamadas de IA: ' + CAST(@TotalChamadas AS VARCHAR);

PRINT '';

-- 10. Verificar tipo de chamadas
PRINT '🔟 TIPOS DE CHAMADAS DE IA:';
PRINT '----------------------------------------';
SELECT 
    TipoChamada,
    COUNT(*) AS Quantidade,
    AVG(TempoResposta) AS TempoMedio_ms,
    SUM(CASE WHEN Sucesso = 1 THEN 1 ELSE 0 END) AS Sucessos,
    SUM(CASE WHEN Sucesso = 0 THEN 1 ELSE 0 END) AS Falhas
FROM AIHT_ChamadasIA
WHERE ConversaId = 22
GROUP BY TipoChamada;

PRINT '';
PRINT '========================================';
PRINT '✅ ANÁLISE CONCLUÍDA';
PRINT '========================================';
PRINT '';

-- 11. Diagnóstico final
PRINT '📋 DIAGNÓSTICO:';
PRINT '----------------------------------------';

IF @TotalPecas = 0
BEGIN
    PRINT '⚠️  PROBLEMA: Nenhuma peça foi identificada!';
    PRINT '   Solução: Verificar se a identificação funcionou corretamente.';
END
ELSE
BEGIN
    PRINT '✅ Peças identificadas: ' + CAST(@TotalPecas AS VARCHAR);
END

IF @UltimaMensagem IS NOT NULL
BEGIN
    DECLARE @IntencaoTeste BIT;
    
    SELECT @IntencaoTeste = IntencaoCotacao
    FROM (
        SELECT TOP 1 * FROM (
            SELECT 1 AS IntencaoCotacao
            WHERE EXISTS (
                SELECT 1 
                FROM AIHT_PalavrasCotacao 
                WHERE Ativo = 1 
                AND UPPER(@UltimaMensagem) LIKE '%' + UPPER(Palavra) + '%'
            )
            UNION ALL
            SELECT 0
        ) x
    ) resultado;
    
    IF @IntencaoTeste = 1
    BEGIN
        PRINT '✅ Última mensagem TEM intenção de cotação';
        PRINT '   Deveria ter gerado cotação!';
    END
    ELSE
    BEGIN
        PRINT '❌ Última mensagem NÃO tem intenção de cotação';
        PRINT '   Deveria ter finalizado atendimento.';
    END
END

PRINT '';
PRINT '🔧 PRÓXIMOS PASSOS:';
PRINT '   1. Verificar se a última mensagem deveria gerar cotação';
PRINT '   2. Verificar logs do servidor Next.js';
PRINT '   3. Verificar console do navegador';
PRINT '';
