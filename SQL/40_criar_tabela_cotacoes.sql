-- =============================================
-- Script: Criar Tabela de Cotações de Peças
-- Descrição: Armazena cotações retornadas para cada peça identificada
-- Data: 2025-10-26
-- =============================================

USE AI_Builder_Hackthon;
GO

PRINT 'Criando tabela de cotações de peças...';
GO

-- =============================================
-- Tabela: AIHT_CotacoesPecas
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AIHT_CotacoesPecas]'))
BEGIN
    DROP TABLE [dbo].[AIHT_CotacoesPecas];
    PRINT 'Tabela antiga removida.';
END
GO

CREATE TABLE [dbo].[AIHT_CotacoesPecas] (
    [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ConversaId] INT NOT NULL,
    [ProblemaId] INT NULL,
    [PecaIdentificadaId] INT NOT NULL,
    [NomePeca] NVARCHAR(200) NOT NULL,
    
    -- Tipo de cotação
    [TipoCotacao] NVARCHAR(50) NOT NULL, -- 'E-Commerce' ou 'Loja Física'
    
    -- Informações de E-Commerce
    [Link] NVARCHAR(500) NULL,
    
    -- Informações de Loja Física
    [Endereco] NVARCHAR(500) NULL,
    [NomeLoja] NVARCHAR(200) NULL,
    [Telefone] NVARCHAR(50) NULL,
    
    -- Informações Comuns
    [Preco] DECIMAL(10,2) NULL,
    [PrecoMinimo] DECIMAL(10,2) NULL,
    [PrecoMaximo] DECIMAL(10,2) NULL,
    [CondicoesPagamento] NVARCHAR(500) NULL,
    
    -- Observações
    [Observacoes] NVARCHAR(MAX) NULL, -- Disponibilidade, prazo de entrega, peça nova/usada
    [Disponibilidade] NVARCHAR(100) NULL,
    [PrazoEntrega] NVARCHAR(100) NULL,
    [EstadoPeca] NVARCHAR(50) NULL, -- 'Nova', 'Usada', 'Recondicionada'
    
    -- Controle
    [DataCotacao] DATETIME NOT NULL DEFAULT GETDATE(),
    [Ativo] BIT NOT NULL DEFAULT 1,
    
    -- Foreign Keys
    CONSTRAINT [FK_Cotacoes_Conversa] FOREIGN KEY ([ConversaId]) 
        REFERENCES [dbo].[AIHT_Conversas]([Id]),
    CONSTRAINT [FK_Cotacoes_Problema] FOREIGN KEY ([ProblemaId]) 
        REFERENCES [dbo].[AIHT_ProblemasIdentificados]([Id]),
    CONSTRAINT [FK_Cotacoes_Peca] FOREIGN KEY ([PecaIdentificadaId]) 
        REFERENCES [dbo].[AIHT_PecasIdentificadas]([Id]),
    
    -- Constraints
    CONSTRAINT [CHK_TipoCotacao] CHECK ([TipoCotacao] IN ('E-Commerce', 'Loja Física')),
    CONSTRAINT [CHK_EstadoPeca] CHECK ([EstadoPeca] IS NULL OR [EstadoPeca] IN ('Nova', 'Usada', 'Recondicionada'))
);

PRINT '✓ Tabela AIHT_CotacoesPecas criada';
GO

-- Criar índices para melhor performance
CREATE INDEX [IX_CotacoesPecas_ConversaId] ON [dbo].[AIHT_CotacoesPecas]([ConversaId]);
CREATE INDEX [IX_CotacoesPecas_PecaId] ON [dbo].[AIHT_CotacoesPecas]([PecaIdentificadaId]);
CREATE INDEX [IX_CotacoesPecas_TipoCotacao] ON [dbo].[AIHT_CotacoesPecas]([TipoCotacao]);

PRINT '✓ Índices criados';
GO

-- =============================================
-- Stored Procedure: Registrar Cotação
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[AIHT_sp_RegistrarCotacao]
    @ConversaId INT,
    @ProblemaId INT = NULL,
    @PecaIdentificadaId INT,
    @NomePeca NVARCHAR(200),
    @TipoCotacao NVARCHAR(50),
    @Link NVARCHAR(500) = NULL,
    @Endereco NVARCHAR(500) = NULL,
    @NomeLoja NVARCHAR(200) = NULL,
    @Telefone NVARCHAR(50) = NULL,
    @Preco DECIMAL(10,2) = NULL,
    @PrecoMinimo DECIMAL(10,2) = NULL,
    @PrecoMaximo DECIMAL(10,2) = NULL,
    @CondicoesPagamento NVARCHAR(500) = NULL,
    @Observacoes NVARCHAR(MAX) = NULL,
    @Disponibilidade NVARCHAR(100) = NULL,
    @PrazoEntrega NVARCHAR(100) = NULL,
    @EstadoPeca NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CotacaoId INT;
    
    -- Validar tipo de cotação
    IF @TipoCotacao NOT IN ('E-Commerce', 'Loja Física')
    BEGIN
        RAISERROR('Tipo de cotação inválido. Use "E-Commerce" ou "Loja Física"', 16, 1);
        RETURN;
    END
    
    -- Validar se a peça existe
    IF NOT EXISTS (SELECT 1 FROM [dbo].[AIHT_PecasIdentificadas] WHERE Id = @PecaIdentificadaId)
    BEGIN
        RAISERROR('Peça identificada não encontrada', 16, 1);
        RETURN;
    END
    
    -- Inserir cotação
    INSERT INTO [dbo].[AIHT_CotacoesPecas] (
        ConversaId,
        ProblemaId,
        PecaIdentificadaId,
        NomePeca,
        TipoCotacao,
        Link,
        Endereco,
        NomeLoja,
        Telefone,
        Preco,
        PrecoMinimo,
        PrecoMaximo,
        CondicoesPagamento,
        Observacoes,
        Disponibilidade,
        PrazoEntrega,
        EstadoPeca
    )
    VALUES (
        @ConversaId,
        @ProblemaId,
        @PecaIdentificadaId,
        @NomePeca,
        @TipoCotacao,
        @Link,
        @Endereco,
        @NomeLoja,
        @Telefone,
        @Preco,
        @PrecoMinimo,
        @PrecoMaximo,
        @CondicoesPagamento,
        @Observacoes,
        @Disponibilidade,
        @PrazoEntrega,
        @EstadoPeca
    );
    
    SET @CotacaoId = SCOPE_IDENTITY();
    
    -- Atualizar última interação da conversa
    UPDATE [dbo].[AIHT_Conversas]
    SET DataUltimaInteracao = GETDATE()
    WHERE Id = @ConversaId;
    
    -- Retornar cotação criada
    SELECT 
        Id,
        ConversaId,
        ProblemaId,
        PecaIdentificadaId,
        NomePeca,
        TipoCotacao,
        Link,
        Endereco,
        NomeLoja,
        Telefone,
        Preco,
        PrecoMinimo,
        PrecoMaximo,
        CondicoesPagamento,
        Observacoes,
        Disponibilidade,
        PrazoEntrega,
        EstadoPeca,
        DataCotacao
    FROM [dbo].[AIHT_CotacoesPecas]
    WHERE Id = @CotacaoId;
END
GO

PRINT '✓ AIHT_sp_RegistrarCotacao criada';
GO

-- =============================================
-- Stored Procedure: Listar Cotações por Conversa
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[AIHT_sp_ListarCotacoesConversa]
    @ConversaId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        c.Id,
        c.ConversaId,
        c.ProblemaId,
        prob.DescricaoProblema,
        c.PecaIdentificadaId,
        c.NomePeca,
        peca.CategoriaPeca,
        peca.Prioridade,
        c.TipoCotacao,
        c.Link,
        c.Endereco,
        c.NomeLoja,
        c.Telefone,
        c.Preco,
        c.PrecoMinimo,
        c.PrecoMaximo,
        c.CondicoesPagamento,
        c.Observacoes,
        c.Disponibilidade,
        c.PrazoEntrega,
        c.EstadoPeca,
        c.DataCotacao
    FROM [dbo].[AIHT_CotacoesPecas] c
    LEFT JOIN [dbo].[AIHT_ProblemasIdentificados] prob ON c.ProblemaId = prob.Id
    LEFT JOIN [dbo].[AIHT_PecasIdentificadas] peca ON c.PecaIdentificadaId = peca.Id
    WHERE c.ConversaId = @ConversaId 
        AND c.Ativo = 1
    ORDER BY c.DataCotacao DESC, c.NomePeca;
END
GO

PRINT '✓ AIHT_sp_ListarCotacoesConversa criada';
GO

-- =============================================
-- Stored Procedure: Listar Cotações por Peça
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[AIHT_sp_ListarCotacoesPeca]
    @PecaIdentificadaId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        c.Id,
        c.ConversaId,
        c.ProblemaId,
        c.PecaIdentificadaId,
        c.NomePeca,
        c.TipoCotacao,
        c.Link,
        c.Endereco,
        c.NomeLoja,
        c.Telefone,
        c.Preco,
        c.PrecoMinimo,
        c.PrecoMaximo,
        c.CondicoesPagamento,
        c.Observacoes,
        c.Disponibilidade,
        c.PrazoEntrega,
        c.EstadoPeca,
        c.DataCotacao
    FROM [dbo].[AIHT_CotacoesPecas] c
    WHERE c.PecaIdentificadaId = @PecaIdentificadaId 
        AND c.Ativo = 1
    ORDER BY 
        CASE 
            WHEN c.Preco IS NOT NULL THEN c.Preco
            WHEN c.PrecoMinimo IS NOT NULL THEN c.PrecoMinimo
            ELSE 999999
        END ASC;
END
GO

PRINT '✓ AIHT_sp_ListarCotacoesPeca criada';
GO

-- =============================================
-- Stored Procedure: Resumo de Cotações
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[AIHT_sp_ResumoCotacoes]
    @ConversaId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Resumo geral
    SELECT 
        COUNT(*) AS TotalCotacoes,
        COUNT(DISTINCT PecaIdentificadaId) AS TotalPecas,
        SUM(CASE WHEN TipoCotacao = 'E-Commerce' THEN 1 ELSE 0 END) AS CotacoesECommerce,
        SUM(CASE WHEN TipoCotacao = 'Loja Física' THEN 1 ELSE 0 END) AS CotacoesLojaFisica,
        MIN(CASE WHEN Preco IS NOT NULL THEN Preco WHEN PrecoMinimo IS NOT NULL THEN PrecoMinimo END) AS MenorPreco,
        MAX(CASE WHEN Preco IS NOT NULL THEN Preco WHEN PrecoMaximo IS NOT NULL THEN PrecoMaximo END) AS MaiorPreco,
        AVG(CASE WHEN Preco IS NOT NULL THEN Preco END) AS PrecoMedio
    FROM [dbo].[AIHT_CotacoesPecas]
    WHERE ConversaId = @ConversaId AND Ativo = 1;
    
    -- Cotações por peça
    SELECT 
        c.PecaIdentificadaId,
        c.NomePeca,
        COUNT(*) AS QuantidadeCotacoes,
        MIN(CASE WHEN c.Preco IS NOT NULL THEN c.Preco WHEN c.PrecoMinimo IS NOT NULL THEN c.PrecoMinimo END) AS MenorPreco,
        MAX(CASE WHEN c.Preco IS NOT NULL THEN c.Preco WHEN c.PrecoMaximo IS NOT NULL THEN c.PrecoMaximo END) AS MaiorPreco
    FROM [dbo].[AIHT_CotacoesPecas] c
    WHERE c.ConversaId = @ConversaId AND c.Ativo = 1
    GROUP BY c.PecaIdentificadaId, c.NomePeca
    ORDER BY c.NomePeca;
END
GO

PRINT '✓ AIHT_sp_ResumoCotacoes criada';
GO

-- =============================================
-- Stored Procedure: Deletar Cotação (Soft Delete)
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[AIHT_sp_DeletarCotacao]
    @CotacaoId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE [dbo].[AIHT_CotacoesPecas]
    SET Ativo = 0
    WHERE Id = @CotacaoId;
    
    SELECT @@ROWCOUNT AS LinhasAfetadas;
END
GO

PRINT '✓ AIHT_sp_DeletarCotacao criada';
GO

-- =============================================
-- Permissões
-- =============================================
GRANT SELECT, INSERT, UPDATE ON dbo.AIHT_CotacoesPecas TO AI_Hackthon;
GRANT EXECUTE ON dbo.AIHT_sp_RegistrarCotacao TO AI_Hackthon;
GRANT EXECUTE ON dbo.AIHT_sp_ListarCotacoesConversa TO AI_Hackthon;
GRANT EXECUTE ON dbo.AIHT_sp_ListarCotacoesPeca TO AI_Hackthon;
GRANT EXECUTE ON dbo.AIHT_sp_ResumoCotacoes TO AI_Hackthon;
GRANT EXECUTE ON dbo.AIHT_sp_DeletarCotacao TO AI_Hackthon;

PRINT '✓ Permissões concedidas';
GO

PRINT '========================================';
PRINT 'SUCESSO! Tabela de cotações criada!';
PRINT '========================================';
GO
