/*
==============================================================================
Script: 56_corrigir_sp_listar_pecas.sql
Descrição: Corrigir SP para listar peças mesmo sem ProblemaId
Autor: Alan Alves de Oliveira
Data: 26/10/2025
Problema: INNER JOIN com ProblemaId impede listar peças sem problema associado
Solução: Mudar para LEFT JOIN
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '🔧 Corrigindo AIHT_sp_ListarPecasParaCotacao...';
GO

-- =============================================
-- SP: Listar Peças para Cotação (CORRIGIDA)
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
        p.Id,
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
    INNER JOIN AIHT_Conversas c ON p.ConversaId = c.Id
    LEFT JOIN AIHT_ProblemasIdentificados prob ON p.ProblemaId = prob.Id  -- MUDADO PARA LEFT JOIN
    LEFT JOIN AIHT_Modelos m ON c.ModeloId = m.Id
    LEFT JOIN AIHT_Marcas marc ON m.MarcaId = marc.Id
    LEFT JOIN AIHT_GruposEmpresariais g ON marc.GrupoEmpresarialId = g.Id
    WHERE p.ConversaId = @ConversaId
    ORDER BY p.Prioridade DESC, p.DataIdentificacao DESC;
END;
GO

PRINT '✅ AIHT_sp_ListarPecasParaCotacao corrigida!';
PRINT '';
GO

-- =============================================
-- Teste com Conversa 53
-- =============================================
PRINT '========================================';
PRINT 'TESTE COM CONVERSA 53';
PRINT '========================================';
PRINT '';

PRINT 'Executando SP para Conversa 53:';
EXEC AIHT_sp_ListarPecasParaCotacao @ConversaId = 53;
PRINT '';

PRINT 'Total de peças retornadas:';
SELECT COUNT(*) AS TotalPecas
FROM AIHT_PecasIdentificadas
WHERE ConversaId = 53;
PRINT '';

PRINT '========================================';
PRINT '✅ CORREÇÃO APLICADA!';
PRINT '========================================';
PRINT '';
PRINT '💡 MUDANÇA:';
PRINT '   ANTES: INNER JOIN AIHT_ProblemasIdentificados';
PRINT '   DEPOIS: LEFT JOIN AIHT_ProblemasIdentificados';
PRINT '';
PRINT '🎯 RESULTADO:';
PRINT '   Agora lista peças MESMO SEM ProblemaId associado!';
PRINT '';

GO
