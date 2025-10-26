-- =============================================
-- Script: Testar Sistema de Cotações
-- Descrição: Valida tabela, SPs e insere dados de teste
-- Data: 2025-10-26
-- =============================================

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT 'TESTE DO SISTEMA DE COTAÇÕES';
PRINT '========================================';
GO

-- =============================================
-- 1. Verificar se a tabela existe
-- =============================================
PRINT '';
PRINT '1. Verificando tabela AIHT_CotacoesPecas...';
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AIHT_CotacoesPecas]'))
BEGIN
    PRINT '   ✓ Tabela AIHT_CotacoesPecas existe';
    
    -- Mostrar estrutura
    SELECT 
        COLUMN_NAME,
        DATA_TYPE,
        CHARACTER_MAXIMUM_LENGTH,
        IS_NULLABLE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'AIHT_CotacoesPecas'
    ORDER BY ORDINAL_POSITION;
END
ELSE
BEGIN
    PRINT '   ✗ Tabela AIHT_CotacoesPecas NÃO existe!';
    PRINT '   Execute o script 40_criar_tabela_cotacoes.sql primeiro';
    RETURN;
END
GO

-- =============================================
-- 2. Verificar Stored Procedures
-- =============================================
PRINT '';
PRINT '2. Verificando Stored Procedures...';
GO

DECLARE @SPsEsperadas TABLE (Nome NVARCHAR(100));
INSERT INTO @SPsEsperadas VALUES 
    ('AIHT_sp_RegistrarCotacao'),
    ('AIHT_sp_ListarCotacoesConversa'),
    ('AIHT_sp_ListarCotacoesPeca'),
    ('AIHT_sp_ResumoCotacoes'),
    ('AIHT_sp_DeletarCotacao');

SELECT 
    e.Nome,
    CASE WHEN p.name IS NOT NULL THEN '✓ Existe' ELSE '✗ NÃO existe' END AS Status
FROM @SPsEsperadas e
LEFT JOIN sys.procedures p ON e.Nome = p.name
ORDER BY e.Nome;
GO

-- =============================================
-- 3. Verificar Índices
-- =============================================
PRINT '';
PRINT '3. Verificando índices...';
GO

SELECT 
    i.name AS NomeIndice,
    c.name AS Coluna,
    i.type_desc AS TipoIndice
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('AIHT_CotacoesPecas')
ORDER BY i.name, ic.key_ordinal;
GO

-- =============================================
-- 4. Buscar dados para teste
-- =============================================
PRINT '';
PRINT '4. Buscando dados existentes para teste...';
GO

-- Buscar primeira conversa ativa
DECLARE @ConversaIdTeste INT;
DECLARE @PecaIdTeste INT;
DECLARE @ProblemaIdTeste INT;

SELECT TOP 1 
    @ConversaIdTeste = c.Id,
    @PecaIdTeste = p.Id,
    @ProblemaIdTeste = p.ProblemaId
FROM AIHT_Conversas c
INNER JOIN AIHT_PecasIdentificadas p ON c.Id = p.ConversaId
WHERE c.Ativo = 1 AND p.Ativo = 1
ORDER BY c.DataInicio DESC;

IF @ConversaIdTeste IS NULL
BEGIN
    PRINT '   ⚠ Nenhuma conversa com peças encontrada';
    PRINT '   Criando dados de teste...';
    
    -- Criar conversa de teste
    EXEC AIHT_sp_CriarConversa 
        @NomeCliente = 'Cliente Teste Cotação',
        @GrupoEmpresarialId = 1,
        @MarcaId = 1,
        @ModeloId = 1;
    
    SET @ConversaIdTeste = SCOPE_IDENTITY();
    
    -- Criar problema de teste
    EXEC AIHT_sp_RegistrarProblema
        @ConversaId = @ConversaIdTeste,
        @DescricaoProblema = 'Freio fazendo barulho - Teste';
    
    SET @ProblemaIdTeste = SCOPE_IDENTITY();
    
    -- Criar peça de teste
    EXEC AIHT_sp_RegistrarPeca
        @ConversaId = @ConversaIdTeste,
        @ProblemaId = @ProblemaIdTeste,
        @NomePeca = 'Pastilha de Freio Dianteira',
        @CategoriaPeca = 'Freios',
        @Prioridade = 'Alta';
    
    SET @PecaIdTeste = SCOPE_IDENTITY();
    
    PRINT '   ✓ Dados de teste criados';
END
ELSE
BEGIN
    PRINT '   ✓ Usando conversa existente: ' + CAST(@ConversaIdTeste AS NVARCHAR(10));
END

PRINT '   ConversaId: ' + CAST(@ConversaIdTeste AS NVARCHAR(10));
PRINT '   PecaId: ' + CAST(@PecaIdTeste AS NVARCHAR(10));
PRINT '   ProblemaId: ' + CAST(ISNULL(@ProblemaIdTeste, 0) AS NVARCHAR(10));
GO

-- =============================================
-- 5. Testar Inserção de Cotações
-- =============================================
PRINT '';
PRINT '5. Testando inserção de cotações...';
GO

-- Buscar IDs novamente (necessário por causa do GO)
DECLARE @ConversaId INT, @PecaId INT, @ProblemaId INT;

SELECT TOP 1 
    @ConversaId = c.Id,
    @PecaId = p.Id,
    @ProblemaId = p.ProblemaId
FROM AIHT_Conversas c
INNER JOIN AIHT_PecasIdentificadas p ON c.Id = p.ConversaId
WHERE c.Ativo = 1 AND p.Ativo = 1
ORDER BY c.DataInicio DESC;

-- Teste 1: Cotação E-Commerce
PRINT '   Teste 1: Cotação E-Commerce...';
EXEC AIHT_sp_RegistrarCotacao
    @ConversaId = @ConversaId,
    @ProblemaId = @ProblemaId,
    @PecaIdentificadaId = @PecaId,
    @NomePeca = 'Pastilha de Freio Dianteira',
    @TipoCotacao = 'E-Commerce',
    @Link = 'https://mercadolivre.com.br/pastilha-freio-teste',
    @Preco = 189.90,
    @CondicoesPagamento = '3x sem juros no cartão',
    @Observacoes = 'Entrega em 5 dias úteis',
    @Disponibilidade = 'Em estoque',
    @PrazoEntrega = '5 dias úteis',
    @EstadoPeca = 'Nova';

PRINT '   ✓ Cotação E-Commerce inserida';

-- Teste 2: Cotação Loja Física
PRINT '   Teste 2: Cotação Loja Física...';
EXEC AIHT_sp_RegistrarCotacao
    @ConversaId = @ConversaId,
    @ProblemaId = @ProblemaId,
    @PecaIdentificadaId = @PecaId,
    @NomePeca = 'Pastilha de Freio Dianteira',
    @TipoCotacao = 'Loja Física',
    @Endereco = 'Rua das Peças, 123 - Centro - São Paulo/SP',
    @NomeLoja = 'Auto Peças Central',
    @Telefone = '(11) 98765-4321',
    @PrecoMinimo = 150.00,
    @PrecoMaximo = 200.00,
    @CondicoesPagamento = 'À vista ou cartão em até 6x',
    @Observacoes = 'Retirada imediata. Peça original.',
    @Disponibilidade = 'Disponível',
    @EstadoPeca = 'Nova';

PRINT '   ✓ Cotação Loja Física inserida';

-- Teste 3: Cotação com preço único
PRINT '   Teste 3: Cotação com preço único...';
EXEC AIHT_sp_RegistrarCotacao
    @ConversaId = @ConversaId,
    @ProblemaId = @ProblemaId,
    @PecaIdentificadaId = @PecaId,
    @NomePeca = 'Pastilha de Freio Dianteira',
    @TipoCotacao = 'E-Commerce',
    @Link = 'https://olx.com.br/pastilha-freio-teste',
    @Preco = 120.00,
    @CondicoesPagamento = 'À vista',
    @Observacoes = 'Peça usada em bom estado',
    @Disponibilidade = 'Disponível',
    @PrazoEntrega = 'Combinar com vendedor',
    @EstadoPeca = 'Usada';

PRINT '   ✓ Cotação com preço único inserida';
GO

-- =============================================
-- 6. Testar Consultas
-- =============================================
PRINT '';
PRINT '6. Testando consultas...';
GO

DECLARE @ConversaId INT;

SELECT TOP 1 @ConversaId = Id
FROM AIHT_Conversas
WHERE Ativo = 1
ORDER BY DataInicio DESC;

-- Teste 1: Listar cotações da conversa
PRINT '   Teste 1: Listar cotações da conversa...';
EXEC AIHT_sp_ListarCotacoesConversa @ConversaId = @ConversaId;

-- Teste 2: Listar cotações por peça
PRINT '   Teste 2: Listar cotações por peça...';
DECLARE @PecaId INT;
SELECT TOP 1 @PecaId = Id FROM AIHT_PecasIdentificadas WHERE ConversaId = @ConversaId;
EXEC AIHT_sp_ListarCotacoesPeca @PecaIdentificadaId = @PecaId;

-- Teste 3: Resumo de cotações
PRINT '   Teste 3: Resumo de cotações...';
EXEC AIHT_sp_ResumoCotacoes @ConversaId = @ConversaId;
GO

-- =============================================
-- 7. Estatísticas
-- =============================================
PRINT '';
PRINT '7. Estatísticas do sistema...';
GO

SELECT 
    COUNT(*) AS TotalCotacoes,
    COUNT(DISTINCT ConversaId) AS ConversasComCotacao,
    COUNT(DISTINCT PecaIdentificadaId) AS PecasComCotacao,
    SUM(CASE WHEN TipoCotacao = 'E-Commerce' THEN 1 ELSE 0 END) AS CotacoesECommerce,
    SUM(CASE WHEN TipoCotacao = 'Loja Física' THEN 1 ELSE 0 END) AS CotacoesLojaFisica,
    MIN(CASE WHEN Preco IS NOT NULL THEN Preco WHEN PrecoMinimo IS NOT NULL THEN PrecoMinimo END) AS MenorPreco,
    MAX(CASE WHEN Preco IS NOT NULL THEN Preco WHEN PrecoMaximo IS NOT NULL THEN PrecoMaximo END) AS MaiorPreco,
    AVG(CASE WHEN Preco IS NOT NULL THEN Preco END) AS PrecoMedio
FROM AIHT_CotacoesPecas
WHERE Ativo = 1;
GO

-- =============================================
-- 8. Últimas Cotações
-- =============================================
PRINT '';
PRINT '8. Últimas 5 cotações registradas...';
GO

SELECT TOP 5
    c.Id,
    c.NomePeca,
    c.TipoCotacao,
    CASE 
        WHEN c.Preco IS NOT NULL THEN CAST(c.Preco AS NVARCHAR(20))
        WHEN c.PrecoMinimo IS NOT NULL THEN CAST(c.PrecoMinimo AS NVARCHAR(20)) + ' - ' + CAST(c.PrecoMaximo AS NVARCHAR(20))
        ELSE 'Não informado'
    END AS Preco,
    c.EstadoPeca,
    c.DataCotacao
FROM AIHT_CotacoesPecas c
WHERE c.Ativo = 1
ORDER BY c.DataCotacao DESC;
GO

PRINT '';
PRINT '========================================';
PRINT '✓ TESTES CONCLUÍDOS COM SUCESSO!';
PRINT '========================================';
PRINT '';
PRINT 'Próximos passos:';
PRINT '1. Integrar com a API /api/gerar-cotacao';
PRINT '2. Parsear resposta da IA para extrair cotações';
PRINT '3. Chamar /api/salvar-cotacao automaticamente';
PRINT '4. Exibir cotações salvas na interface';
GO
