-- Verificação rápida do estado das cotações
USE AI_Builder_Hackthon;
GO

PRINT 'VERIFICAÇÃO RÁPIDA';
PRINT '==================';

-- 1. Total de conversas
DECLARE @TotalConversas INT = (SELECT COUNT(*) FROM AIHT_Conversas);
PRINT 'Total de conversas: ' + CAST(@TotalConversas AS NVARCHAR(10));

-- 2. Total de peças identificadas
DECLARE @TotalPecas INT = (SELECT COUNT(*) FROM AIHT_PecasIdentificadas);
PRINT 'Total de peças identificadas: ' + CAST(@TotalPecas AS NVARCHAR(10));

-- 3. Total de cotações
DECLARE @TotalCotacoes INT = (SELECT COUNT(*) FROM AIHT_CotacoesPecas);
PRINT 'Total de cotações: ' + CAST(@TotalCotacoes AS NVARCHAR(10));

-- 4. Últimas 5 conversas
PRINT '';
PRINT 'ÚLTIMAS 5 CONVERSAS:';
SELECT TOP 5 
    Id, 
    NomeCliente, 
    CONVERT(VARCHAR(20), DataUltimaInteracao, 120) AS UltimaInteracao
FROM AIHT_Conversas 
ORDER BY DataUltimaInteracao DESC;

-- 5. Peças das últimas conversas
PRINT '';
PRINT 'PEÇAS DAS ÚLTIMAS CONVERSAS:';
SELECT TOP 10
    p.ConversaId,
    p.Id AS PecaId,
    p.NomePeca,
    CONVERT(VARCHAR(20), p.DataIdentificacao, 120) AS DataIdentificacao
FROM AIHT_PecasIdentificadas p
ORDER BY p.DataIdentificacao DESC;

-- 6. Verificar se stored procedure existe
PRINT '';
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'AIHT_sp_RegistrarCotacao')
    PRINT '✓ Stored procedure AIHT_sp_RegistrarCotacao existe'
ELSE
    PRINT '✗ Stored procedure AIHT_sp_RegistrarCotacao NÃO existe';

-- 7. Teste de inserção
PRINT '';
PRINT 'TESTE DE INSERÇÃO:';

DECLARE @TestePecaId INT;
DECLARE @TesteConversaId INT;

SELECT TOP 1 
    @TestePecaId = Id,
    @TesteConversaId = ConversaId
FROM AIHT_PecasIdentificadas
ORDER BY DataIdentificacao DESC;

IF @TestePecaId IS NOT NULL
BEGIN
    BEGIN TRY
        PRINT 'Tentando inserir cotação de teste...';
        
        EXEC AIHT_sp_RegistrarCotacao
            @ConversaId = @TesteConversaId,
            @ProblemaId = NULL,
            @PecaIdentificadaId = @TestePecaId,
            @NomePeca = 'TESTE - Peça de Teste',
            @TipoCotacao = 'E-Commerce',
            @Link = 'https://teste.com',
            @Preco = 99.99;
        
        PRINT '✓ Cotação de teste inserida com sucesso!';
        
        -- Verificar se foi inserida
        IF EXISTS (SELECT 1 FROM AIHT_CotacoesPecas WHERE NomePeca = 'TESTE - Peça de Teste')
        BEGIN
            PRINT '✓ Cotação de teste encontrada na tabela';
            
            -- Deletar cotação de teste
            DELETE FROM AIHT_CotacoesPecas WHERE NomePeca = 'TESTE - Peça de Teste';
            PRINT '✓ Cotação de teste removida';
        END
        ELSE
        BEGIN
            PRINT '✗ Cotação de teste NÃO foi encontrada na tabela!';
            PRINT '  PROBLEMA: Stored procedure executou mas não inseriu dados';
        END
    END TRY
    BEGIN CATCH
        PRINT '✗ Erro ao inserir cotação de teste:';
        PRINT '  ' + ERROR_MESSAGE();
    END CATCH
END
ELSE
BEGIN
    PRINT '✗ Nenhuma peça encontrada para teste';
END

GO
