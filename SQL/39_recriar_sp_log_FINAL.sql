/*
==============================================================================
Script: 39_recriar_sp_log_FINAL.sql
Descrição: Recriar SP AIHT_sp_RegistrarChamadaIA com todos os parâmetros corretos
Autor: Alan Alves de Oliveira
Data: 25/10/2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT '🔧 RECRIANDO SP AIHT_sp_RegistrarChamadaIA';
PRINT '========================================';
PRINT '';

-- Dropar SP se existir
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'AIHT_sp_RegistrarChamadaIA')
BEGIN
    PRINT '🗑️  Dropando SP antiga...';
    DROP PROCEDURE AIHT_sp_RegistrarChamadaIA;
    PRINT '✅ SP antiga removida';
    PRINT '';
END

PRINT '📝 Criando SP nova...';
PRINT '';
GO

CREATE PROCEDURE [dbo].[AIHT_sp_RegistrarChamadaIA]
    @ConversaId INT = NULL,
    @TipoChamada VARCHAR(50) = NULL,
    @MensagemCliente NVARCHAR(MAX) = 'Mensagem não informada',
    @PromptEnviado NVARCHAR(MAX) = 'Prompt não informado',
    @RespostaRecebida NVARCHAR(MAX) = NULL,
    @TempoResposta INT = NULL,
    @Sucesso BIT = 0,
    @MensagemErro NVARCHAR(MAX) = NULL,
    @ModeloIA NVARCHAR(100) = 'gemini-pro'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @LogId INT;
    
    INSERT INTO [dbo].[AIHT_LogChamadasIA] (
        ConversaId,
        TipoChamada,
        MensagemCliente,
        PromptEnviado,
        RespostaRecebida,
        TempoResposta,
        Sucesso,
        MensagemErro,
        ModeloIA
    )
    VALUES (
        @ConversaId,
        @TipoChamada,
        @MensagemCliente,
        @PromptEnviado,
        @RespostaRecebida,
        @TempoResposta,
        @Sucesso,
        @MensagemErro,
        @ModeloIA
    );
    
    SET @LogId = SCOPE_IDENTITY();
    
    SELECT 
        Id,
        ConversaId,
        TipoChamada,
        MensagemCliente,
        LEFT(PromptEnviado, 100) + '...' AS PromptPreview,
        Sucesso,
        TempoResposta,
        DataChamada
    FROM [dbo].[AIHT_LogChamadasIA]
    WHERE Id = @LogId;
END
GO

PRINT '✅ SP criada com sucesso!';
PRINT '';

-- Testar SP
PRINT '🧪 Testando SP...';
PRINT '';

EXEC AIHT_sp_RegistrarChamadaIA
    @ConversaId = 999,
    @TipoChamada = 'teste',
    @MensagemCliente = 'Teste de mensagem',
    @PromptEnviado = 'Teste de prompt',
    @RespostaRecebida = 'Teste de resposta',
    @TempoResposta = 1000,
    @Sucesso = 1,
    @MensagemErro = NULL,
    @ModeloIA = 'gemini-pro';

PRINT '';
PRINT '✅ Teste executado!';
PRINT '';

-- Mostrar parâmetros
PRINT '📋 Parâmetros da SP:';
PRINT '';

SELECT 
    ORDINAL_POSITION AS Ordem,
    PARAMETER_NAME AS Parametro,
    DATA_TYPE AS Tipo,
    PARAMETER_MODE AS Modo
FROM INFORMATION_SCHEMA.PARAMETERS
WHERE SPECIFIC_NAME = 'AIHT_sp_RegistrarChamadaIA'
ORDER BY ORDINAL_POSITION;

PRINT '';
PRINT '========================================';
PRINT '✅ SP RECRIADA COM SUCESSO!';
PRINT '========================================';
PRINT '';
PRINT '📝 Parâmetros (na ordem):';
PRINT '   1. @ConversaId';
PRINT '   2. @TipoChamada';
PRINT '   3. @MensagemCliente';
PRINT '   4. @PromptEnviado';
PRINT '   5. @RespostaRecebida';
PRINT '   6. @TempoResposta';
PRINT '   7. @Sucesso';
PRINT '   8. @MensagemErro';
PRINT '   9. @ModeloIA';
PRINT '';
GO
