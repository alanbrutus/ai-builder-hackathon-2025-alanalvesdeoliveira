-- =============================================
-- Script: Verificar Sistema de Cotação
-- Descrição: Diagnóstico completo do sistema de cotação
-- =============================================

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT 'DIAGNÓSTICO DO SISTEMA DE COTAÇÃO';
PRINT '========================================';
PRINT '';

-- =============================================
-- 1. Verificar Tabelas
-- =============================================
PRINT '1. VERIFICANDO TABELAS...';
PRINT '----------------------------------------';

IF OBJECT_ID('AIHT_PalavrasCotacao', 'U') IS NOT NULL
    PRINT '✓ Tabela AIHT_PalavrasCotacao existe'
ELSE
    PRINT '✗ Tabela AIHT_PalavrasCotacao NÃO existe';

IF OBJECT_ID('AIHT_PecasIdentificadas', 'U') IS NOT NULL
    PRINT '✓ Tabela AIHT_PecasIdentificadas existe'
ELSE
    PRINT '✗ Tabela AIHT_PecasIdentificadas NÃO existe';

IF OBJECT_ID('AIHT_ProblemasIdentificados', 'U') IS NOT NULL
    PRINT '✓ Tabela AIHT_ProblemasIdentificados existe'
ELSE
    PRINT '✗ Tabela AIHT_ProblemasIdentificados NÃO existe';

IF OBJECT_ID('AIHT_Conversas', 'U') IS NOT NULL
    PRINT '✓ Tabela AIHT_Conversas existe'
ELSE
    PRINT '✗ Tabela AIHT_Conversas NÃO existe';

PRINT '';

-- =============================================
-- 2. Verificar Stored Procedures
-- =============================================
PRINT '2. VERIFICANDO STORED PROCEDURES...';
PRINT '----------------------------------------';

IF OBJECT_ID('AIHT_sp_VerificarIntencaoCotacao', 'P') IS NOT NULL
    PRINT '✓ AIHT_sp_VerificarIntencaoCotacao existe'
ELSE
    PRINT '✗ AIHT_sp_VerificarIntencaoCotacao NÃO existe';

IF OBJECT_ID('AIHT_sp_ListarPecasParaCotacao', 'P') IS NOT NULL
    PRINT '✓ AIHT_sp_ListarPecasParaCotacao existe'
ELSE
    PRINT '✗ AIHT_sp_ListarPecasParaCotacao NÃO existe';

IF OBJECT_ID('AIHT_sp_ResumoCotacao', 'P') IS NOT NULL
    PRINT '✓ AIHT_sp_ResumoCotacao existe'
ELSE
    PRINT '✗ AIHT_sp_ResumoCotacao NÃO existe';

IF OBJECT_ID('AIHT_sp_ListarPalavrasCotacao', 'P') IS NOT NULL
    PRINT '✓ AIHT_sp_ListarPalavrasCotacao existe'
ELSE
    PRINT '✗ AIHT_sp_ListarPalavrasCotacao NÃO existe';

IF OBJECT_ID('AIHT_sp_AdicionarPalavraCotacao', 'P') IS NOT NULL
    PRINT '✓ AIHT_sp_AdicionarPalavraCotacao existe'
ELSE
    PRINT '✗ AIHT_sp_AdicionarPalavraCotacao NÃO existe';

PRINT '';

-- =============================================
-- 3. Contar Palavras-Chave Cadastradas
-- =============================================
PRINT '3. PALAVRAS-CHAVE CADASTRADAS...';
PRINT '----------------------------------------';

IF OBJECT_ID('AIHT_PalavrasCotacao', 'U') IS NOT NULL
BEGIN
    DECLARE @TotalPalavras INT;
    DECLARE @PalavrasAtivas INT;
    
    SELECT @TotalPalavras = COUNT(*) FROM AIHT_PalavrasCotacao;
    SELECT @PalavrasAtivas = COUNT(*) FROM AIHT_PalavrasCotacao WHERE Ativo = 1;
    
    PRINT 'Total de palavras: ' + CAST(@TotalPalavras AS VARCHAR(10));
    PRINT 'Palavras ativas: ' + CAST(@PalavrasAtivas AS VARCHAR(10));
    
    PRINT '';
    PRINT 'Primeiras 10 palavras-chave:';
    SELECT TOP 10 
        Id,
        Palavra,
        Tipo,
        Ativo
    FROM AIHT_PalavrasCotacao
    ORDER BY Id;
END
ELSE
BEGIN
    PRINT '⚠ Tabela AIHT_PalavrasCotacao não existe!';
END

PRINT '';

-- =============================================
-- 4. Verificar Conversas com Peças
-- =============================================
PRINT '4. CONVERSAS COM PEÇAS IDENTIFICADAS...';
PRINT '----------------------------------------';

IF OBJECT_ID('AIHT_Conversas', 'U') IS NOT NULL 
   AND OBJECT_ID('AIHT_PecasIdentificadas', 'U') IS NOT NULL
BEGIN
    DECLARE @TotalConversas INT;
    DECLARE @ConversasComPecas INT;
    DECLARE @TotalPecas INT;
    
    SELECT @TotalConversas = COUNT(*) FROM AIHT_Conversas;
    SELECT @ConversasComPecas = COUNT(DISTINCT ConversaId) FROM AIHT_PecasIdentificadas;
    SELECT @TotalPecas = COUNT(*) FROM AIHT_PecasIdentificadas;
    
    PRINT 'Total de conversas: ' + CAST(@TotalConversas AS VARCHAR(10));
    PRINT 'Conversas com peças: ' + CAST(@ConversasComPecas AS VARCHAR(10));
    PRINT 'Total de peças identificadas: ' + CAST(@TotalPecas AS VARCHAR(10));
    
    IF @ConversasComPecas > 0
    BEGIN
        PRINT '';
        PRINT 'Últimas 5 conversas com peças:';
        SELECT TOP 5
            c.Id AS ConversaId,
            c.NomeCliente,
            COUNT(p.Id) AS QtdPecas,
            MAX(p.DataIdentificacao) AS UltimaIdentificacao
        FROM AIHT_Conversas c
        INNER JOIN AIHT_PecasIdentificadas p ON p.ConversaId = c.Id
        GROUP BY c.Id, c.NomeCliente
        ORDER BY MAX(p.DataIdentificacao) DESC;
    END
END
ELSE
BEGIN
    PRINT '⚠ Tabelas necessárias não existem!';
END

PRINT '';

-- =============================================
-- 5. Testar Detecção de Intenção
-- =============================================
PRINT '5. TESTANDO DETECÇÃO DE INTENÇÃO...';
PRINT '----------------------------------------';

IF OBJECT_ID('AIHT_sp_VerificarIntencaoCotacao', 'P') IS NOT NULL
BEGIN
    PRINT 'Teste 1: "Quanto custa essas peças?"';
    EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Quanto custa essas peças?';
    
    PRINT '';
    PRINT 'Teste 2: "Quero fazer uma cotação"';
    EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Quero fazer uma cotação';
    
    PRINT '';
    PRINT 'Teste 3: "Obrigado pela ajuda" (sem intenção)';
    EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Obrigado pela ajuda';
END
ELSE
BEGIN
    PRINT '⚠ Stored Procedure AIHT_sp_VerificarIntencaoCotacao não existe!';
END

PRINT '';

-- =============================================
-- 6. Testar Listagem de Peças
-- =============================================
PRINT '6. TESTANDO LISTAGEM DE PEÇAS PARA COTAÇÃO...';
PRINT '----------------------------------------';

IF OBJECT_ID('AIHT_sp_ListarPecasParaCotacao', 'P') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM AIHT_PecasIdentificadas)
    BEGIN
        DECLARE @TesteConversaId INT;
        SELECT TOP 1 @TesteConversaId = ConversaId 
        FROM AIHT_PecasIdentificadas 
        ORDER BY DataIdentificacao DESC;
        
        PRINT 'Testando com ConversaId: ' + CAST(@TesteConversaId AS VARCHAR(10));
        EXEC AIHT_sp_ListarPecasParaCotacao @ConversaId = @TesteConversaId;
    END
    ELSE
    BEGIN
        PRINT '⚠ Nenhuma peça identificada no sistema ainda.';
    END
END
ELSE
BEGIN
    PRINT '⚠ Stored Procedure AIHT_sp_ListarPecasParaCotacao não existe!';
END

PRINT '';

-- =============================================
-- 7. Status Geral
-- =============================================
PRINT '========================================';
PRINT 'STATUS GERAL DO SISTEMA';
PRINT '========================================';

DECLARE @StatusGeral VARCHAR(50) = 'COMPLETO';

IF OBJECT_ID('AIHT_PalavrasCotacao', 'U') IS NULL
    SET @StatusGeral = 'INCOMPLETO';
IF OBJECT_ID('AIHT_sp_VerificarIntencaoCotacao', 'P') IS NULL
    SET @StatusGeral = 'INCOMPLETO';
IF OBJECT_ID('AIHT_sp_ListarPecasParaCotacao', 'P') IS NULL
    SET @StatusGeral = 'INCOMPLETO';
IF OBJECT_ID('AIHT_sp_ResumoCotacao', 'P') IS NULL
    SET @StatusGeral = 'INCOMPLETO';

IF @StatusGeral = 'COMPLETO'
    PRINT '✓ Sistema de Cotação está COMPLETO e pronto para uso!'
ELSE
    PRINT '⚠ Sistema de Cotação está INCOMPLETO - execute os scripts necessários';

PRINT '';
PRINT '========================================';
PRINT 'FIM DO DIAGNÓSTICO';
PRINT '========================================';
GO
