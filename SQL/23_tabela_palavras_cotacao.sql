-- =============================================
-- Script: Tabela de Palavras-Chave para Cotação
-- Descrição: Identifica quando o cliente quer cotação
-- =============================================

USE AI_Builder_Hackthon;
GO

-- =============================================
-- Tabela: Palavras-Chave de Cotação
-- =============================================
IF OBJECT_ID('AIHT_PalavrasCotacao', 'U') IS NOT NULL
    DROP TABLE AIHT_PalavrasCotacao;
GO

CREATE TABLE AIHT_PalavrasCotacao (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Palavra VARCHAR(100) NOT NULL,
    Tipo VARCHAR(50) NOT NULL, -- 'Palavra' ou 'Expressao'
    Ativo BIT NOT NULL DEFAULT 1,
    DataCriacao DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_Palavra UNIQUE (Palavra)
);
GO

PRINT '✓ Tabela AIHT_PalavrasCotacao criada';
GO

-- =============================================
-- Inserir Palavras-Chave Padrão
-- =============================================
INSERT INTO AIHT_PalavrasCotacao (Palavra, Tipo) VALUES
-- Palavras simples
('cotação', 'Palavra'),
('cotacao', 'Palavra'),
('preço', 'Palavra'),
('preco', 'Palavra'),
('valor', 'Palavra'),
('quanto custa', 'Expressao'),
('quanto sai', 'Expressao'),
('quanto fica', 'Expressao'),
('qual o preço', 'Expressao'),
('qual o valor', 'Expressao'),
('quero comprar', 'Expressao'),
('quero cotar', 'Expressao'),
('pode cotar', 'Expressao'),
('pode orçar', 'Expressao'),
('fazer orçamento', 'Expressao'),
('fazer cotação', 'Expressao'),
('fazer cotacao', 'Expressao'),
('preciso comprar', 'Expressao'),
('onde comprar', 'Expressao'),
('onde encontrar', 'Expressao'),
('tem disponível', 'Expressao'),
('tem disponivel', 'Expressao'),
('tem em estoque', 'Expressao'),
('link', 'Palavra'),
('site', 'Palavra'),
('loja', 'Palavra'),
('comprar', 'Palavra'),
('orçamento', 'Expressao'),
('orcamento', 'Expressao');
GO

PRINT '✓ Palavras-chave padrão inseridas';
GO

-- =============================================
-- SP: Verificar Intenção de Cotação
-- =============================================
IF OBJECT_ID('AIHT_sp_VerificarIntencaoCotacao', 'P') IS NOT NULL
    DROP PROCEDURE AIHT_sp_VerificarIntencaoCotacao;
GO

CREATE PROCEDURE AIHT_sp_VerificarIntencaoCotacao
    @Mensagem NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @MensagemLower NVARCHAR(MAX) = LOWER(@Mensagem);
    DECLARE @IntencaoCotacao BIT = 0;
    DECLARE @PalavrasEncontradas VARCHAR(MAX) = '';
    
    -- Verificar se alguma palavra-chave está presente
    SELECT 
        @IntencaoCotacao = 1,
        @PalavrasEncontradas = STRING_AGG(Palavra, ', ')
    FROM AIHT_PalavrasCotacao
    WHERE Ativo = 1
    AND @MensagemLower LIKE '%' + LOWER(Palavra) + '%';
    
    SELECT 
        @IntencaoCotacao AS IntencaoCotacao,
        @PalavrasEncontradas AS PalavrasEncontradas;
END;
GO

PRINT '✓ AIHT_sp_VerificarIntencaoCotacao criada';
GO

-- =============================================
-- SP: Listar Palavras-Chave Ativas
-- =============================================
IF OBJECT_ID('AIHT_sp_ListarPalavrasCotacao', 'P') IS NOT NULL
    DROP PROCEDURE AIHT_sp_ListarPalavrasCotacao;
GO

CREATE PROCEDURE AIHT_sp_ListarPalavrasCotacao
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        Id,
        Palavra,
        Tipo,
        Ativo,
        DataCriacao
    FROM AIHT_PalavrasCotacao
    ORDER BY Tipo, Palavra;
END;
GO

PRINT '✓ AIHT_sp_ListarPalavrasCotacao criada';
GO

-- =============================================
-- SP: Adicionar Palavra-Chave
-- =============================================
IF OBJECT_ID('AIHT_sp_AdicionarPalavraCotacao', 'P') IS NOT NULL
    DROP PROCEDURE AIHT_sp_AdicionarPalavraCotacao;
GO

CREATE PROCEDURE AIHT_sp_AdicionarPalavraCotacao
    @Palavra VARCHAR(100),
    @Tipo VARCHAR(50) = 'Palavra'
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM AIHT_PalavrasCotacao WHERE Palavra = @Palavra)
    BEGIN
        INSERT INTO AIHT_PalavrasCotacao (Palavra, Tipo)
        VALUES (@Palavra, @Tipo);
        
        SELECT 
            Id,
            Palavra,
            Tipo,
            Ativo
        FROM AIHT_PalavrasCotacao
        WHERE Id = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        SELECT 
            Id,
            Palavra,
            Tipo,
            Ativo
        FROM AIHT_PalavrasCotacao
        WHERE Palavra = @Palavra;
    END
END;
GO

PRINT '✓ AIHT_sp_AdicionarPalavraCotacao criada';
GO

-- =============================================
-- Testes
-- =============================================
PRINT '';
PRINT '========================================';
PRINT 'Testando Sistema de Detecção...';
PRINT '========================================';
GO

-- Teste 1: Mensagem com intenção de cotação
PRINT '';
PRINT 'Teste 1: "Quanto custa essas peças?"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Quanto custa essas peças?';
GO

-- Teste 2: Mensagem sem intenção de cotação
PRINT '';
PRINT 'Teste 2: "Obrigado pela ajuda"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Obrigado pela ajuda';
GO

-- Teste 3: Mensagem com múltiplas palavras-chave
PRINT '';
PRINT 'Teste 3: "Quero comprar, qual o preço?"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Quero comprar, qual o preço?';
GO

-- Listar todas as palavras-chave
PRINT '';
PRINT 'Palavras-chave cadastradas:';
EXEC AIHT_sp_ListarPalavrasCotacao;
GO

PRINT '';
PRINT '========================================';
PRINT 'Sistema de Detecção criado com sucesso!';
PRINT '========================================';
GO
