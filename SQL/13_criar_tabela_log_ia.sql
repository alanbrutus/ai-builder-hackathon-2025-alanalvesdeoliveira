-- =============================================
-- Script: Criar Tabela de Log de Chamadas à IA
-- Descrição: Rastreia todas as chamadas ao modelo de IA
-- =============================================

USE AI_Builder_Hackthon;
GO

PRINT 'Criando tabela de log...';
GO

-- =============================================
-- Tabela: AIHT_LogChamadasIA
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AIHT_LogChamadasIA]'))
BEGIN
    DROP TABLE [dbo].[AIHT_LogChamadasIA];
    PRINT 'Tabela antiga removida.';
END
GO

CREATE TABLE [dbo].[AIHT_LogChamadasIA] (
    [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ConversaId] INT NULL,
    [MensagemCliente] NVARCHAR(MAX) NOT NULL,
    [PromptEnviado] NVARCHAR(MAX) NOT NULL,
    [RespostaIA] NVARCHAR(MAX) NULL,
    [Sucesso] BIT NOT NULL DEFAULT 0,
    [MensagemErro] NVARCHAR(MAX) NULL,
    [TempoResposta] INT NULL, -- em milissegundos
    [DataChamada] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModeloIA] NVARCHAR(100) NULL DEFAULT 'gemini-pro',
    CONSTRAINT [FK_LogIA_Conversa] FOREIGN KEY ([ConversaId]) 
        REFERENCES [dbo].[AIHT_Conversas]([Id])
);

PRINT '✓ Tabela AIHT_LogChamadasIA criada';
GO

-- Criar índices para melhor performance
CREATE INDEX IX_LogIA_ConversaId ON AIHT_LogChamadasIA(ConversaId);
CREATE INDEX IX_LogIA_DataChamada ON AIHT_LogChamadasIA(DataChamada DESC);
CREATE INDEX IX_LogIA_Sucesso ON AIHT_LogChamadasIA(Sucesso);

PRINT '✓ Índices criados';
GO

-- =============================================
-- Stored Procedure: Registrar Chamada à IA
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[AIHT_sp_RegistrarChamadaIA]
    @ConversaId INT = NULL,
    @MensagemCliente NVARCHAR(MAX),
    @PromptEnviado NVARCHAR(MAX),
    @RespostaIA NVARCHAR(MAX) = NULL,
    @Sucesso BIT,
    @MensagemErro NVARCHAR(MAX) = NULL,
    @TempoResposta INT = NULL,
    @ModeloIA NVARCHAR(100) = 'gemini-pro'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @LogId INT;
    
    INSERT INTO [dbo].[AIHT_LogChamadasIA] (
        ConversaId,
        MensagemCliente,
        PromptEnviado,
        RespostaIA,
        Sucesso,
        MensagemErro,
        TempoResposta,
        ModeloIA
    )
    VALUES (
        @ConversaId,
        @MensagemCliente,
        @PromptEnviado,
        @RespostaIA,
        @Sucesso,
        @MensagemErro,
        @TempoResposta,
        @ModeloIA
    );
    
    SET @LogId = SCOPE_IDENTITY();
    
    SELECT 
        Id,
        ConversaId,
        LEFT(MensagemCliente, 100) + '...' AS MensagemPreview,
        LEFT(PromptEnviado, 100) + '...' AS PromptPreview,
        Sucesso,
        DataChamada
    FROM [dbo].[AIHT_LogChamadasIA]
    WHERE Id = @LogId;
END
GO

PRINT '✓ AIHT_sp_RegistrarChamadaIA criada';
GO

-- =============================================
-- Stored Procedure: Consultar Logs
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[AIHT_sp_ConsultarLogsIA]
    @ConversaId INT = NULL,
    @UltimosN INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP (@UltimosN)
        Id,
        ConversaId,
        LEFT(MensagemCliente, 100) + '...' AS MensagemPreview,
        LEFT(PromptEnviado, 200) + '...' AS PromptPreview,
        LEFT(RespostaIA, 200) + '...' AS RespostaPreview,
        Sucesso,
        MensagemErro,
        TempoResposta,
        DataChamada,
        ModeloIA
    FROM [dbo].[AIHT_LogChamadasIA]
    WHERE (@ConversaId IS NULL OR ConversaId = @ConversaId)
    ORDER BY DataChamada DESC;
END
GO

PRINT '✓ AIHT_sp_ConsultarLogsIA criada';
GO

-- =============================================
-- Stored Procedure: Ver Detalhes do Log
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[AIHT_sp_VerDetalhesLogIA]
    @LogId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        Id,
        ConversaId,
        MensagemCliente,
        PromptEnviado,
        RespostaIA,
        Sucesso,
        MensagemErro,
        TempoResposta,
        DataChamada,
        ModeloIA,
        LEN(PromptEnviado) AS TamanhoPrompt,
        LEN(RespostaIA) AS TamanhoResposta
    FROM [dbo].[AIHT_LogChamadasIA]
    WHERE Id = @LogId;
END
GO

PRINT '✓ AIHT_sp_VerDetalhesLogIA criada';
GO

-- =============================================
-- Conceder permissões
-- =============================================
GRANT SELECT, INSERT ON dbo.AIHT_LogChamadasIA TO AI_Hackthon;
GRANT EXECUTE ON dbo.AIHT_sp_RegistrarChamadaIA TO AI_Hackthon;
GRANT EXECUTE ON dbo.AIHT_sp_ConsultarLogsIA TO AI_Hackthon;
GRANT EXECUTE ON dbo.AIHT_sp_VerDetalhesLogIA TO AI_Hackthon;

PRINT '✓ Permissões concedidas';
GO

PRINT '';
PRINT '========================================';
PRINT 'SUCESSO! Tabela de log criada!';
PRINT '';
PRINT 'Para consultar logs:';
PRINT '  EXEC AIHT_sp_ConsultarLogsIA';
PRINT '';
PRINT 'Para ver detalhes:';
PRINT '  EXEC AIHT_sp_VerDetalhesLogIA @LogId = 1';
PRINT '========================================';
GO
