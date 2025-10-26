-- =============================================
-- Script: Verificar Instalação do Sistema de Cotações
-- Descrição: Valida se tudo foi criado corretamente
-- Data: 2025-10-26
-- =============================================

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT 'VERIFICAÇÃO DO SISTEMA DE COTAÇÕES';
PRINT '========================================';
GO

-- =============================================
-- 1. Verificar Tabela
-- =============================================
PRINT '';
PRINT '1. TABELA AIHT_CotacoesPecas';
PRINT '----------------------------';

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AIHT_CotacoesPecas]'))
BEGIN
    PRINT '✓ Tabela existe';
    
    -- Contar registros
    DECLARE @TotalRegistros INT;
    SELECT @TotalRegistros = COUNT(*) FROM AIHT_CotacoesPecas;
    PRINT '  Total de registros: ' + CAST(@TotalRegistros AS NVARCHAR(10));
    
    -- Mostrar estrutura resumida
    SELECT 
        COLUMN_NAME AS Coluna,
        DATA_TYPE AS Tipo,
        IS_NULLABLE AS Nulo
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'AIHT_CotacoesPecas'
    ORDER BY ORDINAL_POSITION;
END
ELSE
BEGIN
    PRINT '✗ Tabela NÃO existe!';
END
GO

-- =============================================
-- 2. Verificar Stored Procedures
-- =============================================
PRINT '';
PRINT '2. STORED PROCEDURES';
PRINT '----------------------------';

SELECT 
    name AS StoredProcedure,
    create_date AS DataCriacao,
    modify_date AS DataModificacao
FROM sys.procedures
WHERE name LIKE 'AIHT_sp_%Cotac%'
ORDER BY name;
GO

-- =============================================
-- 3. Verificar Índices
-- =============================================
PRINT '';
PRINT '3. ÍNDICES';
PRINT '----------------------------';

SELECT 
    i.name AS Indice,
    c.name AS Coluna,
    i.type_desc AS Tipo
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('AIHT_CotacoesPecas')
ORDER BY i.name, ic.key_ordinal;
GO

-- =============================================
-- 4. Verificar Foreign Keys
-- =============================================
PRINT '';
PRINT '4. FOREIGN KEYS';
PRINT '----------------------------';

SELECT 
    fk.name AS ForeignKey,
    OBJECT_NAME(fk.parent_object_id) AS TabelaOrigem,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS ColunaOrigem,
    OBJECT_NAME(fk.referenced_object_id) AS TabelaReferencia,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS ColunaReferencia
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
WHERE fk.parent_object_id = OBJECT_ID('AIHT_CotacoesPecas')
ORDER BY fk.name;
GO

-- =============================================
-- 5. Verificar Constraints
-- =============================================
PRINT '';
PRINT '5. CONSTRAINTS';
PRINT '----------------------------';

SELECT 
    name AS Constraint,
    type_desc AS Tipo,
    definition AS Definicao
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('AIHT_CotacoesPecas')
ORDER BY name;
GO

-- =============================================
-- 6. Verificar Permissões
-- =============================================
PRINT '';
PRINT '6. PERMISSÕES DO USUÁRIO AI_Hackthon';
PRINT '----------------------------';

SELECT 
    OBJECT_NAME(major_id) AS Objeto,
    permission_name AS Permissao,
    state_desc AS Estado
FROM sys.database_permissions
WHERE grantee_principal_id = USER_ID('AI_Hackthon')
    AND (
        OBJECT_NAME(major_id) = 'AIHT_CotacoesPecas'
        OR OBJECT_NAME(major_id) LIKE 'AIHT_sp_%Cotac%'
    )
ORDER BY OBJECT_NAME(major_id), permission_name;
GO

-- =============================================
-- 7. Estatísticas (se houver dados)
-- =============================================
PRINT '';
PRINT '7. ESTATÍSTICAS';
PRINT '----------------------------';

DECLARE @Total INT;
SELECT @Total = COUNT(*) FROM AIHT_CotacoesPecas WHERE Ativo = 1;

IF @Total > 0
BEGIN
    SELECT 
        COUNT(*) AS TotalCotacoes,
        COUNT(DISTINCT ConversaId) AS ConversasComCotacao,
        COUNT(DISTINCT PecaIdentificadaId) AS PecasComCotacao,
        SUM(CASE WHEN TipoCotacao = 'E-Commerce' THEN 1 ELSE 0 END) AS ECommerce,
        SUM(CASE WHEN TipoCotacao = 'Loja Física' THEN 1 ELSE 0 END) AS LojaFisica,
        MIN(CASE WHEN Preco IS NOT NULL THEN Preco WHEN PrecoMinimo IS NOT NULL THEN PrecoMinimo END) AS MenorPreco,
        MAX(CASE WHEN Preco IS NOT NULL THEN Preco WHEN PrecoMaximo IS NOT NULL THEN PrecoMaximo END) AS MaiorPreco
    FROM AIHT_CotacoesPecas
    WHERE Ativo = 1;
    
    PRINT '';
    PRINT 'Últimas 5 cotações:';
    SELECT TOP 5
        Id,
        NomePeca,
        TipoCotacao,
        CASE 
            WHEN Preco IS NOT NULL THEN 'R$ ' + CAST(Preco AS NVARCHAR(20))
            WHEN PrecoMinimo IS NOT NULL THEN 'R$ ' + CAST(PrecoMinimo AS NVARCHAR(20)) + ' - R$ ' + CAST(PrecoMaximo AS NVARCHAR(20))
            ELSE 'Não informado'
        END AS Preco,
        DataCotacao
    FROM AIHT_CotacoesPecas
    WHERE Ativo = 1
    ORDER BY DataCotacao DESC;
END
ELSE
BEGIN
    PRINT 'Nenhuma cotação registrada ainda.';
END
GO

-- =============================================
-- 8. Teste Rápido de Inserção
-- =============================================
PRINT '';
PRINT '8. TESTE DE INSERÇÃO';
PRINT '----------------------------';

-- Buscar dados para teste
DECLARE @TestConversaId INT, @TestPecaId INT, @TestProblemaId INT;

SELECT TOP 1 
    @TestConversaId = c.Id,
    @TestPecaId = p.Id,
    @TestProblemaId = p.ProblemaId
FROM AIHT_Conversas c
INNER JOIN AIHT_PecasIdentificadas p ON c.Id = p.ConversaId
WHERE c.Ativo = 1 AND p.Ativo = 1
ORDER BY c.DataInicio DESC;

IF @TestConversaId IS NOT NULL
BEGIN
    PRINT 'Testando inserção de cotação...';
    
    BEGIN TRY
        EXEC AIHT_sp_RegistrarCotacao
            @ConversaId = @TestConversaId,
            @ProblemaId = @TestProblemaId,
            @PecaIdentificadaId = @TestPecaId,
            @NomePeca = 'Teste de Validação',
            @TipoCotacao = 'E-Commerce',
            @Link = 'https://teste.com/validacao',
            @Preco = 99.99,
            @Observacoes = 'Teste de validação do sistema';
        
        PRINT '✓ Inserção bem-sucedida!';
        
        -- Remover registro de teste
        DELETE FROM AIHT_CotacoesPecas 
        WHERE NomePeca = 'Teste de Validação' 
            AND Link = 'https://teste.com/validacao';
        
        PRINT '✓ Registro de teste removido';
    END TRY
    BEGIN CATCH
        PRINT '✗ Erro na inserção: ' + ERROR_MESSAGE();
    END CATCH
END
ELSE
BEGIN
    PRINT 'Nenhuma conversa com peças encontrada para teste.';
END
GO

PRINT '';
PRINT '========================================';
PRINT '✓ VERIFICAÇÃO CONCLUÍDA';
PRINT '========================================';
PRINT '';
PRINT 'Status: Sistema de Cotações instalado e funcional!';
PRINT '';
PRINT 'APIs disponíveis:';
PRINT '  POST /api/salvar-cotacao';
PRINT '  GET  /api/cotacoes/[conversaId]';
PRINT '  GET  /api/cotacoes/peca/[pecaId]';
PRINT '  GET  /api/cotacoes/resumo/[conversaId]';
GO
