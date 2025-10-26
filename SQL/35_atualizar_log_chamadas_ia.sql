/*
==============================================================================
Script: 35_atualizar_log_chamadas_ia.sql
Descrição: Atualiza tabela e SP de logs para novo formato
Problema: APIs usando parâmetros diferentes da SP antiga
Solução: Adicionar coluna TipoChamada e atualizar SP
Autor: Alan Alves de Oliveira
Data: 25/10/2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT '🔧 ATUALIZANDO SISTEMA DE LOGS';
PRINT '========================================';
PRINT '';

-- =============================================
-- 1. Adicionar coluna TipoChamada se não existir
-- =============================================
PRINT '1️⃣ Verificando coluna TipoChamada...';

IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'AIHT_LogChamadasIA' 
    AND COLUMN_NAME = 'TipoChamada'
)
BEGIN
    PRINT '   Adicionando coluna TipoChamada...';
    ALTER TABLE AIHT_LogChamadasIA
    ADD TipoChamada VARCHAR(50) NULL;
    
    PRINT '   ✅ Coluna TipoChamada adicionada';
END
ELSE
BEGIN
    PRINT '   ✅ Coluna TipoChamada já existe';
END

PRINT '';

-- =============================================
-- 2. Renomear coluna RespostaIA para RespostaRecebida
-- =============================================
PRINT '2️⃣ Verificando coluna RespostaRecebida...';

IF EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'AIHT_LogChamadasIA' 
    AND COLUMN_NAME = 'RespostaIA'
)
AND NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'AIHT_LogChamadasIA' 
    AND COLUMN_NAME = 'RespostaRecebida'
)
BEGIN
    PRINT '   Renomeando RespostaIA para RespostaRecebida...';
    EXEC sp_rename 'AIHT_LogChamadasIA.RespostaIA', 'RespostaRecebida', 'COLUMN';
    PRINT '   ✅ Coluna renomeada';
END
ELSE IF EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'AIHT_LogChamadasIA' 
    AND COLUMN_NAME = 'RespostaRecebida'
)
BEGIN
    PRINT '   ✅ Coluna RespostaRecebida já existe';
END
ELSE
BEGIN
    PRINT '   ⚠️  Criando coluna RespostaRecebida...';
    ALTER TABLE AIHT_LogChamadasIA
    ADD RespostaRecebida NVARCHAR(MAX) NULL;
    PRINT '   ✅ Coluna RespostaRecebida criada';
END

PRINT '';

-- =============================================
-- 3. Atualizar Stored Procedure
-- =============================================
PRINT '3️⃣ Atualizando Stored Procedure...';
GO

CREATE OR ALTER PROCEDURE [dbo].[AIHT_sp_RegistrarChamadaIA]
    @ConversaId INT = NULL,
    @TipoChamada VARCHAR(50) = NULL,
    @MensagemCliente NVARCHAR(MAX) = 'Mensagem não informada',
    @PromptEnviado NVARCHAR(MAX),
    @RespostaRecebida NVARCHAR(MAX) = NULL,
    @TempoResposta INT = NULL,
    @Sucesso BIT,
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
        LEFT(PromptEnviado, 100) + '...' AS PromptPreview,
        Sucesso,
        TempoResposta,
        DataChamada
    FROM [dbo].[AIHT_LogChamadasIA]
    WHERE Id = @LogId;
END
GO

PRINT '   ✅ AIHT_sp_RegistrarChamadaIA atualizada';
PRINT '';

-- =============================================
-- 4. Criar índice para TipoChamada
-- =============================================
PRINT '4️⃣ Criando índice para TipoChamada...';

IF NOT EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE name = 'IX_LogIA_TipoChamada' 
    AND object_id = OBJECT_ID('AIHT_LogChamadasIA')
)
BEGIN
    CREATE INDEX IX_LogIA_TipoChamada ON AIHT_LogChamadasIA(TipoChamada);
    PRINT '   ✅ Índice criado';
END
ELSE
BEGIN
    PRINT '   ✅ Índice já existe';
END

PRINT '';

-- =============================================
-- 5. Atualizar SP de Consulta
-- =============================================
PRINT '5️⃣ Atualizando SP de Consulta...';
GO

CREATE OR ALTER PROCEDURE [dbo].[AIHT_sp_ConsultarLogsIA]
    @ConversaId INT = NULL,
    @TipoChamada VARCHAR(50) = NULL,
    @UltimosN INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP (@UltimosN)
        Id,
        ConversaId,
        TipoChamada,
        LEFT(PromptEnviado, 200) + '...' AS PromptPreview,
        LEFT(RespostaRecebida, 200) + '...' AS RespostaPreview,
        Sucesso,
        MensagemErro,
        TempoResposta,
        DataChamada,
        ModeloIA
    FROM [dbo].[AIHT_LogChamadasIA]
    WHERE (@ConversaId IS NULL OR ConversaId = @ConversaId)
    AND (@TipoChamada IS NULL OR TipoChamada = @TipoChamada)
    ORDER BY DataChamada DESC;
END
GO

PRINT '   ✅ AIHT_sp_ConsultarLogsIA atualizada';
PRINT '';

-- =============================================
-- 6. Atualizar SP de Detalhes
-- =============================================
PRINT '6️⃣ Atualizando SP de Detalhes...';
GO

CREATE OR ALTER PROCEDURE [dbo].[AIHT_sp_VerDetalhesLogIA]
    @LogId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        Id,
        ConversaId,
        TipoChamada,
        PromptEnviado,
        RespostaRecebida,
        Sucesso,
        MensagemErro,
        TempoResposta,
        DataChamada,
        ModeloIA,
        LEN(PromptEnviado) AS TamanhoPrompt,
        LEN(RespostaRecebida) AS TamanhoResposta
    FROM [dbo].[AIHT_LogChamadasIA]
    WHERE Id = @LogId;
END
GO

PRINT '   ✅ AIHT_sp_VerDetalhesLogIA atualizada';
PRINT '';

-- =============================================
-- 7. Verificar estrutura final
-- =============================================
PRINT '7️⃣ Verificando estrutura final...';
PRINT '';

SELECT 
    COLUMN_NAME AS Coluna,
    DATA_TYPE AS Tipo,
    IS_NULLABLE AS Nullable,
    CHARACTER_MAXIMUM_LENGTH AS Tamanho
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'AIHT_LogChamadasIA'
ORDER BY ORDINAL_POSITION;

PRINT '';
PRINT '========================================';
PRINT '✅ ATUALIZAÇÃO CONCLUÍDA!';
PRINT '========================================';
PRINT '';
PRINT '📋 MUDANÇAS APLICADAS:';
PRINT '   1. Coluna TipoChamada adicionada';
PRINT '   2. Coluna RespostaIA → RespostaRecebida';
PRINT '   3. SP AIHT_sp_RegistrarChamadaIA atualizada';
PRINT '   4. Índice para TipoChamada criado';
PRINT '   5. SPs de consulta atualizadas';
PRINT '';
PRINT '🔧 PARÂMETROS DA SP:';
PRINT '   @ConversaId INT';
PRINT '   @TipoChamada VARCHAR(50) - identificacao_pecas, cotacao, finalizacao';
PRINT '   @PromptEnviado NVARCHAR(MAX)';
PRINT '   @RespostaRecebida NVARCHAR(MAX)';
PRINT '   @TempoResposta INT';
PRINT '   @Sucesso BIT';
PRINT '   @MensagemErro NVARCHAR(MAX)';
PRINT '   @ModeloIA NVARCHAR(100)';
PRINT '';
PRINT '📊 EXEMPLOS DE USO:';
PRINT '';
PRINT '-- Consultar todos os logs:';
PRINT 'EXEC AIHT_sp_ConsultarLogsIA;';
PRINT '';
PRINT '-- Consultar logs de uma conversa:';
PRINT 'EXEC AIHT_sp_ConsultarLogsIA @ConversaId = 22;';
PRINT '';
PRINT '-- Consultar logs de cotação:';
PRINT 'EXEC AIHT_sp_ConsultarLogsIA @TipoChamada = ''cotacao'';';
PRINT '';
PRINT '-- Ver detalhes de um log:';
PRINT 'EXEC AIHT_sp_VerDetalhesLogIA @LogId = 1;';
PRINT '';
PRINT '========================================';
GO
