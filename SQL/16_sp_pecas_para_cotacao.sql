-- =============================================
-- Script: Stored Procedures para Cotação de Peças
-- Descrição: Procedures para gerenciar peças identificadas e cotações
-- =============================================

USE AI_Builder_Hackthon;
GO

-- =============================================
-- SP: Listar Peças para Cotação
-- Descrição: Lista todas as peças identificadas em uma conversa
--            com informações para solicitar cotação
-- =============================================
IF OBJECT_ID('AIHT_sp_ListarPecasParaCotacao', 'P') IS NOT NULL
    DROP PROCEDURE AIHT_sp_ListarPecasParaCotacao;
GO

CREATE PROCEDURE AIHT_sp_ListarPecasParaCotacao
    @ConversaId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        p.Id AS PecaId,
        p.NomePeca,
        p.CodigoPeca,
        p.CategoriaPeca,
        p.Prioridade,
        p.DataIdentificacao,
        prob.Id AS ProblemaId,
        prob.DescricaoProblema,
        c.NomeCliente,
        m.Nome AS ModeloVeiculo,
        f.Nome AS FabricanteVeiculo,
        g.Nome AS GrupoEmpresarial
    FROM AIHT_PecasIdentificadas p
    INNER JOIN AIHT_ProblemasIdentificados prob ON p.ProblemaId = prob.Id
    INNER JOIN AIHT_Conversas c ON p.ConversaId = c.Id
    LEFT JOIN AIHT_Modelos m ON c.ModeloId = m.Id
    LEFT JOIN AIHT_Fabricantes f ON m.FabricanteId = f.Id
    LEFT JOIN AIHT_GruposEmpresariais g ON f.GrupoEmpresarialId = g.Id
    WHERE p.ConversaId = @ConversaId
    ORDER BY p.Prioridade DESC, p.DataIdentificacao DESC;
END;
GO

PRINT '✓ AIHT_sp_ListarPecasParaCotacao criada';
GO

-- =============================================
-- SP: Atualizar Código da Peça
-- Descrição: Atualiza o código de uma peça identificada
-- =============================================
IF OBJECT_ID('AIHT_sp_AtualizarCodigoPeca', 'P') IS NOT NULL
    DROP PROCEDURE AIHT_sp_AtualizarCodigoPeca;
GO

CREATE PROCEDURE AIHT_sp_AtualizarCodigoPeca
    @PecaId INT,
    @CodigoPeca VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE AIHT_PecasIdentificadas
    SET CodigoPeca = @CodigoPeca,
        DataAtualizacao = GETDATE()
    WHERE Id = @PecaId;
    
    SELECT 
        Id,
        NomePeca,
        CodigoPeca,
        DataAtualizacao
    FROM AIHT_PecasIdentificadas
    WHERE Id = @PecaId;
END;
GO

PRINT '✓ AIHT_sp_AtualizarCodigoPeca criada';
GO

-- =============================================
-- SP: Resumo da Conversa para Cotação
-- Descrição: Retorna resumo completo para gerar cotação
-- =============================================
IF OBJECT_ID('AIHT_sp_ResumoCotacao', 'P') IS NOT NULL
    DROP PROCEDURE AIHT_sp_ResumoCotacao;
GO

CREATE PROCEDURE AIHT_sp_ResumoCotacao
    @ConversaId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Informações da conversa
    SELECT 
        c.Id AS ConversaId,
        c.NomeCliente,
        c.DataInicio,
        g.Nome AS GrupoEmpresarial,
        f.Nome AS Fabricante,
        m.Nome AS Modelo,
        COUNT(DISTINCT prob.Id) AS TotalProblemas,
        COUNT(DISTINCT p.Id) AS TotalPecas
    FROM AIHT_Conversas c
    LEFT JOIN AIHT_Modelos m ON c.ModeloId = m.Id
    LEFT JOIN AIHT_Fabricantes f ON m.FabricanteId = f.Id
    LEFT JOIN AIHT_GruposEmpresariais g ON f.GrupoEmpresarialId = g.Id
    LEFT JOIN AIHT_ProblemasIdentificados prob ON prob.ConversaId = c.Id
    LEFT JOIN AIHT_PecasIdentificadas p ON p.ConversaId = c.Id
    WHERE c.Id = @ConversaId
    GROUP BY c.Id, c.NomeCliente, c.DataInicio, g.Nome, f.Nome, m.Nome;
    
    -- Problemas identificados
    SELECT 
        Id,
        DescricaoProblema,
        DataIdentificacao
    FROM AIHT_ProblemasIdentificados
    WHERE ConversaId = @ConversaId
    ORDER BY DataIdentificacao;
    
    -- Peças identificadas
    SELECT 
        p.Id,
        p.NomePeca,
        p.CodigoPeca,
        p.CategoriaPeca,
        p.Prioridade,
        prob.DescricaoProblema
    FROM AIHT_PecasIdentificadas p
    INNER JOIN AIHT_ProblemasIdentificados prob ON p.ProblemaId = prob.Id
    WHERE p.ConversaId = @ConversaId
    ORDER BY p.Prioridade DESC, p.DataIdentificacao;
END;
GO

PRINT '✓ AIHT_sp_ResumoCotacao criada';
GO

-- =============================================
-- Testes
-- =============================================
PRINT '';
PRINT '========================================';
PRINT 'Testando Stored Procedures...';
PRINT '========================================';
GO

-- Verificar se existem conversas
IF EXISTS (SELECT 1 FROM AIHT_Conversas)
BEGIN
    DECLARE @TesteConversaId INT;
    SELECT TOP 1 @TesteConversaId = Id FROM AIHT_Conversas ORDER BY Id DESC;
    
    PRINT 'Testando com ConversaId: ' + CAST(@TesteConversaId AS VARCHAR(10));
    
    -- Testar listagem de peças para cotação
    PRINT '';
    PRINT 'Peças para Cotação:';
    EXEC AIHT_sp_ListarPecasParaCotacao @ConversaId = @TesteConversaId;
    
    -- Testar resumo de cotação
    PRINT '';
    PRINT 'Resumo para Cotação:';
    EXEC AIHT_sp_ResumoCotacao @ConversaId = @TesteConversaId;
END
ELSE
BEGIN
    PRINT 'Nenhuma conversa encontrada para teste.';
END
GO

PRINT '';
PRINT '========================================';
PRINT 'Stored Procedures criadas com sucesso!';
PRINT '========================================';
GO
