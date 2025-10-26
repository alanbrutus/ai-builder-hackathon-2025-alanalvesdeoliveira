-- =============================================
-- Script: Debug de Cotações
-- Descrição: Verificar estado das cotações e transações
-- Data: 2025-10-26
-- =============================================

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT 'DEBUG DE COTAÇÕES';
PRINT '========================================';
GO

-- 1. Verificar últimas conversas
PRINT '';
PRINT '1. ÚLTIMAS CONVERSAS';
PRINT '----------------------------';

SELECT TOP 5
    Id,
    NomeCliente,
    DataInicio,
    DataUltimaInteracao,
    Ativo
FROM AIHT_Conversas
ORDER BY DataUltimaInteracao DESC;
GO

-- 2. Verificar peças identificadas nas últimas conversas
PRINT '';
PRINT '2. PEÇAS IDENTIFICADAS (ÚLTIMAS 5 CONVERSAS)';
PRINT '----------------------------';

SELECT TOP 20
    c.Id AS ConversaId,
    c.NomeCliente,
    p.Id AS PecaId,
    p.NomePeca,
    p.DataIdentificacao
FROM AIHT_Conversas c
INNER JOIN AIHT_PecasIdentificadas p ON p.ConversaId = c.Id
ORDER BY c.DataUltimaInteracao DESC, p.DataIdentificacao DESC;
GO

-- 3. Verificar cotações existentes
PRINT '';
PRINT '3. COTAÇÕES EXISTENTES';
PRINT '----------------------------';

SELECT 
    COUNT(*) AS TotalCotacoes,
    MIN(DataCotacao) AS PrimeiraCotacao,
    MAX(DataCotacao) AS UltimaCotacao
FROM AIHT_CotacoesPecas;
GO

-- 4. Cotações por conversa
PRINT '';
PRINT '4. COTAÇÕES POR CONVERSA';
PRINT '----------------------------';

SELECT 
    c.Id AS ConversaId,
    c.NomeCliente,
    COUNT(cot.Id) AS TotalCotacoes,
    MAX(cot.DataCotacao) AS UltimaCotacao
FROM AIHT_Conversas c
LEFT JOIN AIHT_CotacoesPecas cot ON cot.ConversaId = c.Id
GROUP BY c.Id, c.NomeCliente
HAVING COUNT(cot.Id) > 0
ORDER BY MAX(cot.DataCotacao) DESC;
GO

-- 5. Últimas 10 cotações salvas
PRINT '';
PRINT '5. ÚLTIMAS 10 COTAÇÕES SALVAS';
PRINT '----------------------------';

SELECT TOP 10
    Id,
    ConversaId,
    NomePeca,
    TipoCotacao,
    CASE 
        WHEN Preco IS NOT NULL THEN 'R$ ' + CAST(Preco AS NVARCHAR(20))
        WHEN PrecoMinimo IS NOT NULL THEN 'R$ ' + CAST(PrecoMinimo AS NVARCHAR(20)) + ' - R$ ' + CAST(PrecoMaximo AS NVARCHAR(20))
        ELSE 'Sem preço'
    END AS Preco,
    DataCotacao
FROM AIHT_CotacoesPecas
ORDER BY DataCotacao DESC;
GO

-- 6. Verificar transações abertas
PRINT '';
PRINT '6. TRANSAÇÕES ABERTAS';
PRINT '----------------------------';

SELECT 
    session_id,
    transaction_id,
    name,
    transaction_begin_time,
    transaction_type,
    transaction_state
FROM sys.dm_tran_active_transactions t
INNER JOIN sys.dm_tran_session_transactions st ON t.transaction_id = st.transaction_id
INNER JOIN sys.dm_exec_sessions s ON st.session_id = s.session_id;
GO

-- 7. Verificar locks na tabela de cotações
PRINT '';
PRINT '7. LOCKS NA TABELA DE COTAÇÕES';
PRINT '----------------------------';

SELECT 
    request_session_id,
    resource_type,
    resource_database_id,
    resource_description,
    request_mode,
    request_status
FROM sys.dm_tran_locks
WHERE resource_database_id = DB_ID('AI_Builder_Hackthon')
    AND resource_description LIKE '%AIHT_CotacoesPecas%';
GO

-- 8. Teste de inserção manual
PRINT '';
PRINT '8. TESTE DE INSERÇÃO MANUAL';
PRINT '----------------------------';

-- Pegar uma peça existente para teste
DECLARE @TestePecaId INT;
DECLARE @TesteConversaId INT;

SELECT TOP 1 
    @TestePecaId = Id,
    @TesteConversaId = ConversaId
FROM AIHT_PecasIdentificadas
ORDER BY DataIdentificacao DESC;

IF @TestePecaId IS NOT NULL
BEGIN
    PRINT 'Tentando inserir cotação de teste...';
    
    BEGIN TRY
        EXEC AIHT_sp_RegistrarCotacao
            @ConversaId = @TesteConversaId,
            @ProblemaId = NULL,
            @PecaIdentificadaId = @TestePecaId,
            @NomePeca = 'TESTE - Peça de Teste',
            @TipoCotacao = 'E-Commerce',
            @Link = 'https://teste.com',
            @Preco = 99.99;
        
        PRINT '✓ Cotação de teste inserida com sucesso!';
        
        -- Deletar cotação de teste
        DELETE FROM AIHT_CotacoesPecas 
        WHERE NomePeca = 'TESTE - Peça de Teste';
        
        PRINT '✓ Cotação de teste removida';
    END TRY
    BEGIN CATCH
        PRINT '✗ Erro ao inserir cotação de teste:';
        PRINT ERROR_MESSAGE();
    END CATCH
END
ELSE
BEGIN
    PRINT '✗ Nenhuma peça encontrada para teste';
END
GO

PRINT '';
PRINT '========================================';
PRINT 'DEBUG CONCLUÍDO';
PRINT '========================================';
GO
