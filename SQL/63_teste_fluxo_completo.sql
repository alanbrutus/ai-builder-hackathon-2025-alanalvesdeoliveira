/*
==============================================================================
Script: 63_teste_fluxo_completo.sql
Descrição: Testar fluxo completo de uma conversa
Autor: Alan Alves de Oliveira
Data: 26/10/2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT 'TESTE DE FLUXO COMPLETO';
PRINT '========================================';
PRINT '';

-- Pegar a última conversa criada
DECLARE @ConversaId INT;
SELECT TOP 1 @ConversaId = Id FROM AIHT_Conversas ORDER BY DataInicio DESC;

PRINT '1. ÚLTIMA CONVERSA:';
SELECT 
    c.Id,
    c.NomeCliente,
    m.Nome AS Modelo,
    marc.Nome AS Marca,
    c.DataInicio,
    c.Status
FROM AIHT_Conversas c
LEFT JOIN AIHT_Modelos m ON c.ModeloId = m.Id
LEFT JOIN AIHT_Marcas marc ON m.MarcaId = marc.Id
WHERE c.Id = @ConversaId;
PRINT '';

PRINT '2. PEÇAS IDENTIFICADAS:';
SELECT * FROM AIHT_PecasIdentificadas WHERE ConversaId = @ConversaId;
PRINT '';

PRINT '3. LOGS DE CHAMADAS:';
SELECT 
    Id,
    TipoChamada,
    MensagemCliente,
    Sucesso,
    LEFT(PromptEnviado, 50) AS PromptInicio,
    DataChamada
FROM AIHT_LogChamadasIA 
WHERE ConversaId = @ConversaId
ORDER BY DataChamada;
PRINT '';

PRINT '4. COTAÇÕES SALVAS:';
SELECT * FROM AIHT_CotacoesPecas WHERE ConversaId = @ConversaId;
PRINT '';

PRINT '5. TESTAR SP DE LISTAR PEÇAS:';
EXEC AIHT_sp_ListarPecasParaCotacao @ConversaId = @ConversaId;
PRINT '';

PRINT '6. VERIFICAR PROMPT DE COTAÇÃO:';
EXEC AIHT_sp_ObterPromptPorContexto @Contexto = 'cotacao';
PRINT '';

PRINT '========================================';
PRINT 'CHECKLIST DE VALIDAÇÃO';
PRINT '========================================';
PRINT '';

-- Checklist
DECLARE @TemPecas INT;
DECLARE @TemPrompt INT;
DECLARE @SPFunciona INT;

SELECT @TemPecas = COUNT(*) FROM AIHT_PecasIdentificadas WHERE ConversaId = @ConversaId;
SELECT @TemPrompt = COUNT(*) FROM AIHT_Prompts WHERE Contexto = 'cotacao' AND Ativo = 1;

-- Testar SP
BEGIN TRY
    EXEC AIHT_sp_ListarPecasParaCotacao @ConversaId = @ConversaId;
    SET @SPFunciona = 1;
END TRY
BEGIN CATCH
    SET @SPFunciona = 0;
END CATCH

PRINT 'Conversa ID: ' + CAST(@ConversaId AS VARCHAR);
PRINT '';
PRINT CASE WHEN @TemPecas > 0 THEN '✅' ELSE '❌' END + ' Tem peças identificadas: ' + CAST(@TemPecas AS VARCHAR);
PRINT CASE WHEN @TemPrompt > 0 THEN '✅' ELSE '❌' END + ' Tem prompt de cotação ativo';
PRINT CASE WHEN @SPFunciona = 1 THEN '✅' ELSE '❌' END + ' SP ListarPecasParaCotacao funciona';
PRINT '';

IF @TemPecas > 0 AND @TemPrompt > 0 AND @SPFunciona = 1
BEGIN
    PRINT '🎯 SISTEMA PRONTO PARA GERAR COTAÇÃO!';
END
ELSE
BEGIN
    PRINT '⚠️ SISTEMA COM PROBLEMAS:';
    IF @TemPecas = 0 PRINT '   - Nenhuma peça identificada';
    IF @TemPrompt = 0 PRINT '   - Prompt de cotação não encontrado';
    IF @SPFunciona = 0 PRINT '   - SP ListarPecasParaCotacao com erro';
END

PRINT '';

GO
