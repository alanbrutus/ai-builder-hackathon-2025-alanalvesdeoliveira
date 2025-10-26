/*
==============================================================================
Script: 57_aplicar_todas_correcoes.sql
Descrição: Aplicar TODAS as correções necessárias
Autor: Alan Alves de Oliveira
Data: 26/10/2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT 'APLICANDO TODAS AS CORREÇÕES';
PRINT '========================================';
PRINT '';

-- =============================================
-- 1. DESATIVAR PALAVRA "S"
-- =============================================
PRINT '1. Desativando palavra "S"...';
UPDATE AIHT_PalavrasCotacao
SET Ativo = 0
WHERE UPPER(LTRIM(RTRIM(Palavra))) = 'S';
PRINT '   ✅ Concluído!';
PRINT '';

-- =============================================
-- 2. PADRONIZAR PALAVRAS PARA UPPER
-- =============================================
PRINT '2. Padronizando palavras para UPPER...';
UPDATE AIHT_PalavrasCotacao
SET Palavra = UPPER(LTRIM(RTRIM(Palavra)))
WHERE Ativo = 1;
PRINT '   ✅ Concluído!';
PRINT '';

-- =============================================
-- 3. CORRIGIR SP DE VERIFICAÇÃO DE COTAÇÃO
-- =============================================
PRINT '3. Corrigindo SP de Verificação de Cotação...';

IF OBJECT_ID('AIHT_sp_VerificarIntencaoCotacao', 'P') IS NOT NULL
    DROP PROCEDURE AIHT_sp_VerificarIntencaoCotacao;
GO

CREATE PROCEDURE AIHT_sp_VerificarIntencaoCotacao
    @Mensagem NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Converter mensagem para maiúsculas E remover espaços
    DECLARE @MensagemUpper NVARCHAR(MAX) = UPPER(LTRIM(RTRIM(@Mensagem)));
    DECLARE @IntencaoCotacao BIT = 0;
    DECLARE @PalavrasEncontradas VARCHAR(MAX) = '';
    
    -- Verificar se QUALQUER palavra-chave está presente na mensagem
    IF EXISTS (
        SELECT 1 
        FROM AIHT_PalavrasCotacao
        WHERE Ativo = 1
        AND @MensagemUpper LIKE '%' + UPPER(LTRIM(RTRIM(Palavra))) + '%'
    )
    BEGIN
        SET @IntencaoCotacao = 1;
        
        -- Listar todas as palavras encontradas
        SELECT @PalavrasEncontradas = STRING_AGG(Palavra, ', ')
        FROM AIHT_PalavrasCotacao
        WHERE Ativo = 1
        AND @MensagemUpper LIKE '%' + UPPER(LTRIM(RTRIM(Palavra))) + '%';
    END
    
    -- Retornar resultado
    SELECT 
        @IntencaoCotacao AS IntencaoCotacao,
        @PalavrasEncontradas AS PalavrasEncontradas;
END;
GO

PRINT '   ✅ SP AIHT_sp_VerificarIntencaoCotacao corrigida!';
PRINT '';

-- =============================================
-- 4. CORRIGIR SP DE LISTAR PEÇAS
-- =============================================
PRINT '4. Corrigindo SP de Listar Peças para Cotação...';

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
    LEFT JOIN AIHT_ProblemasIdentificados prob ON p.ProblemaId = prob.Id  -- LEFT JOIN
    LEFT JOIN AIHT_Modelos m ON c.ModeloId = m.Id
    LEFT JOIN AIHT_Marcas marc ON m.MarcaId = marc.Id
    LEFT JOIN AIHT_GruposEmpresariais g ON marc.GrupoEmpresarialId = g.Id
    WHERE p.ConversaId = @ConversaId
    ORDER BY p.Prioridade DESC, p.DataIdentificacao DESC;
END;
GO

PRINT '   ✅ SP AIHT_sp_ListarPecasParaCotacao corrigida!';
PRINT '';

-- =============================================
-- TESTES DE VALIDAÇÃO
-- =============================================
PRINT '========================================';
PRINT 'TESTES DE VALIDAÇÃO';
PRINT '========================================';
PRINT '';

PRINT 'Teste 1: "SIM"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'SIM';
PRINT '';

PRINT 'Teste 2: "cotacao"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'cotacao';
PRINT '';

PRINT 'Teste 3: "Meu carro está com problema" (NÃO deve detectar)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Meu carro está com problema';
PRINT '';

PRINT 'Teste 4: Listar peças da conversa 53';
EXEC AIHT_sp_ListarPecasParaCotacao @ConversaId = 53;
PRINT '';

-- =============================================
-- RESUMO
-- =============================================
PRINT '========================================';
PRINT '✅ TODAS AS CORREÇÕES APLICADAS!';
PRINT '========================================';
PRINT '';
PRINT 'Correções aplicadas:';
PRINT '  1. ✅ Palavra "S" desativada';
PRINT '  2. ✅ Palavras padronizadas para UPPER';
PRINT '  3. ✅ SP VerificarIntencaoCotacao com TRIM';
PRINT '  4. ✅ SP ListarPecasParaCotacao com LEFT JOIN';
PRINT '';
PRINT 'Total de palavras ativas:';
SELECT COUNT(*) AS TotalPalavrasAtivas FROM AIHT_PalavrasCotacao WHERE Ativo = 1;
PRINT '';
PRINT '🎯 SISTEMA PRONTO PARA USO!';
PRINT '';

GO
