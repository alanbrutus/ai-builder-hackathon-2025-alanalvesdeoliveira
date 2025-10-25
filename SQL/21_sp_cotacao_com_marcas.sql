-- =============================================
-- Script: Stored Procedures de Cotação com AIHT_Marcas
-- Descrição: Versão correta usando AIHT_Marcas
-- =============================================

USE AI_Builder_Hackthon;
GO

-- =============================================
-- SP: Listar Peças para Cotação (COM MARCAS)
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
        p.DataAtualizacao,
        prob.Id AS ProblemaId,
        prob.DescricaoProblema,
        c.NomeCliente,
        c.ModeloId,
        m.Nome AS ModeloVeiculo,
        m.MarcaId,
        marc.Nome AS MarcaVeiculo,
        marc.GrupoEmpresarialId,
        g.Nome AS GrupoEmpresarial
    FROM AIHT_PecasIdentificadas p
    INNER JOIN AIHT_ProblemasIdentificados prob ON p.ProblemaId = prob.Id
    INNER JOIN AIHT_Conversas c ON p.ConversaId = c.Id
    LEFT JOIN AIHT_Modelos m ON c.ModeloId = m.Id
    LEFT JOIN AIHT_Marcas marc ON m.MarcaId = marc.Id
    LEFT JOIN AIHT_GruposEmpresariais g ON marc.GrupoEmpresarialId = g.Id
    WHERE p.ConversaId = @ConversaId
    ORDER BY p.Prioridade DESC, p.DataIdentificacao DESC;
END;
GO

PRINT '✓ AIHT_sp_ListarPecasParaCotacao criada (com AIHT_Marcas)';
GO

-- =============================================
-- SP: Resumo da Conversa para Cotação (COM MARCAS)
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
        c.ModeloId,
        m.Nome AS ModeloVeiculo,
        marc.Nome AS MarcaVeiculo,
        g.Nome AS GrupoEmpresarial,
        COUNT(DISTINCT prob.Id) AS TotalProblemas,
        COUNT(DISTINCT p.Id) AS TotalPecas
    FROM AIHT_Conversas c
    LEFT JOIN AIHT_Modelos m ON c.ModeloId = m.Id
    LEFT JOIN AIHT_Marcas marc ON m.MarcaId = marc.Id
    LEFT JOIN AIHT_GruposEmpresariais g ON marc.GrupoEmpresarialId = g.Id
    LEFT JOIN AIHT_ProblemasIdentificados prob ON prob.ConversaId = c.Id
    LEFT JOIN AIHT_PecasIdentificadas p ON p.ConversaId = c.Id
    WHERE c.Id = @ConversaId
    GROUP BY c.Id, c.NomeCliente, c.DataInicio, c.ModeloId, m.Nome, marc.Nome, g.Nome;
    
    -- Problemas identificados
    SELECT 
        Id,
        DescricaoProblema,
        DataIdentificacao
    FROM AIHT_ProblemasIdentificados
    WHERE ConversaId = @ConversaId
    ORDER BY DataIdentificacao;
    
    -- Peças identificadas com informações completas
    SELECT 
        p.Id,
        p.NomePeca,
        p.CodigoPeca,
        p.CategoriaPeca,
        p.Prioridade,
        p.DataIdentificacao,
        prob.DescricaoProblema,
        m.Nome AS ModeloVeiculo,
        marc.Nome AS MarcaVeiculo,
        g.Nome AS GrupoEmpresarial
    FROM AIHT_PecasIdentificadas p
    INNER JOIN AIHT_ProblemasIdentificados prob ON p.ProblemaId = prob.Id
    INNER JOIN AIHT_Conversas c ON p.ConversaId = c.Id
    LEFT JOIN AIHT_Modelos m ON c.ModeloId = m.Id
    LEFT JOIN AIHT_Marcas marc ON m.MarcaId = marc.Id
    LEFT JOIN AIHT_GruposEmpresariais g ON marc.GrupoEmpresarialId = g.Id
    WHERE p.ConversaId = @ConversaId
    ORDER BY p.Prioridade DESC, p.DataIdentificacao;
END;
GO

PRINT '✓ AIHT_sp_ResumoCotacao criada (com AIHT_Marcas)';
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
PRINT 'Agora com informações completas de:';
PRINT '- Grupo Empresarial';
PRINT '- Marca (Fabricante)';
PRINT '- Modelo';
PRINT '========================================';
GO
