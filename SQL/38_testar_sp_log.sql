/*
==============================================================================
Script: 38_testar_sp_log.sql
Descrição: Testar a SP AIHT_sp_RegistrarChamadaIA
Autor: Alan Alves de Oliveira
Data: 25/10/2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT '🧪 TESTANDO SP AIHT_sp_RegistrarChamadaIA';
PRINT '========================================';
PRINT '';

-- Verificar parâmetros da SP
PRINT '1️⃣ Parâmetros da SP:';
PRINT '----------------------------------------';

SELECT 
    PARAMETER_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    PARAMETER_MODE,
    ORDINAL_POSITION
FROM INFORMATION_SCHEMA.PARAMETERS
WHERE SPECIFIC_NAME = 'AIHT_sp_RegistrarChamadaIA'
ORDER BY ORDINAL_POSITION;

PRINT '';
PRINT '2️⃣ Testando chamada da SP:';
PRINT '----------------------------------------';

-- Teste 1: Com todos os parâmetros
BEGIN TRY
    EXEC AIHT_sp_RegistrarChamadaIA
        @ConversaId = 1,
        @TipoChamada = 'teste',
        @MensagemCliente = 'Mensagem de teste',
        @PromptEnviado = 'Prompt de teste',
        @RespostaRecebida = 'Resposta de teste',
        @TempoResposta = 1000,
        @Sucesso = 1,
        @MensagemErro = NULL,
        @ModeloIA = 'gemini-pro';
    
    PRINT '✅ Teste 1: Sucesso com todos os parâmetros';
END TRY
BEGIN CATCH
    PRINT '❌ Teste 1: Erro - ' + ERROR_MESSAGE();
END CATCH

PRINT '';

-- Teste 2: Com parâmetros mínimos
BEGIN TRY
    EXEC AIHT_sp_RegistrarChamadaIA
        @PromptEnviado = 'Prompt mínimo',
        @Sucesso = 1;
    
    PRINT '✅ Teste 2: Sucesso com parâmetros mínimos';
END TRY
BEGIN CATCH
    PRINT '❌ Teste 2: Erro - ' + ERROR_MESSAGE();
END CATCH

PRINT '';
PRINT '========================================';
PRINT '✅ TESTES CONCLUÍDOS';
PRINT '========================================';
GO
