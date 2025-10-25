-- =============================================
-- Script: 07_create_prompts_table.sql
-- Descrição: Cria estrutura para armazenamento de prompts da IA
-- Data: 2025-10-25
-- =============================================

USE AI_Builder_Hackthon;
GO

-- =============================================
-- 1. CRIAR TABELA DE PROMPTS
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'AIHT_Prompts') AND type in (N'U'))
BEGIN
    CREATE TABLE AIHT_Prompts (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Nome NVARCHAR(100) NOT NULL,
        Descricao NVARCHAR(500),
        Contexto NVARCHAR(50) NOT NULL, -- 'inicial', 'atendimento', 'recomendacao', 'finalizacao'
        ConteudoPrompt NVARCHAR(MAX) NOT NULL,
        Variaveis NVARCHAR(500), -- JSON com lista de variáveis esperadas
        Ativo BIT NOT NULL DEFAULT 1,
        Versao INT NOT NULL DEFAULT 1,
        DataCriacao DATETIME NOT NULL DEFAULT GETDATE(),
        DataAtualizacao DATETIME NOT NULL DEFAULT GETDATE(),
        CriadoPor NVARCHAR(100) DEFAULT 'Sistema',
        AtualizadoPor NVARCHAR(100) DEFAULT 'Sistema'
    );
    PRINT 'Tabela AIHT_Prompts criada com sucesso.';
END
ELSE
BEGIN
    PRINT 'Tabela AIHT_Prompts já existe.';
END
GO

-- =============================================
-- 2. CRIAR ÍNDICES
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'AIHT_IX_Prompts_Contexto_Ativo')
BEGIN
    CREATE INDEX AIHT_IX_Prompts_Contexto_Ativo 
    ON AIHT_Prompts(Contexto, Ativo);
    PRINT 'Índice AIHT_IX_Prompts_Contexto_Ativo criado.';
END
GO

-- =============================================
-- 3. INSERIR PROMPTS PADRÃO
-- =============================================

-- Prompt de Atendimento Inicial
IF NOT EXISTS (SELECT * FROM AIHT_Prompts WHERE Contexto = 'atendimento' AND Nome = 'Atendimento Inicial')
BEGIN
    INSERT INTO AIHT_Prompts (Nome, Descricao, Contexto, ConteudoPrompt, Variaveis, Versao)
    VALUES (
        'Atendimento Inicial',
        'Prompt usado após coleta de dados iniciais do cliente',
        'atendimento',
        'Você é um assistente virtual especializado em peças automotivas. Seu objetivo é entender o problema do cliente com o veículo e sugerir peças compatíveis, além de buscar preços e opções de compra online.

Inicie a conversa de forma amigável e personalizada, utilizando os dados abaixo:

- Nome do cliente: {{nome_cliente}}
- Grupo Empresarial: {{grupo_empresarial}}
- Fabricante do veículo: {{fabricante_veiculo}}
- Modelo do veículo: {{modelo_veiculo}}

Comece perguntando qual é o problema ou necessidade com o veículo. Use linguagem simples e clara. Após entender o problema, sugira possíveis peças relacionadas e, se possível, realize uma busca online por preços e disponibilidade.

Seja proativo, mas não insista. Sempre pergunte se o cliente deseja que você realize a busca ou deseja mais informações sobre a peça.

Exemplo de início da conversa:

"Olá {{nome_cliente}}, tudo bem? Sou seu assistente virtual especializado em peças automotivas. Vejo que você tem um {{fabricante_veiculo}} {{modelo_veiculo}} do grupo {{grupo_empresarial}}. Pode me contar qual é o problema ou o que você está precisando para o veículo hoje?"',
        '["nome_cliente", "grupo_empresarial", "fabricante_veiculo", "modelo_veiculo"]',
        1
    );
    PRINT 'Prompt de Atendimento Inicial inserido.';
END
GO

-- Prompt de Recomendação de Peças
IF NOT EXISTS (SELECT * FROM AIHT_Prompts WHERE Contexto = 'recomendacao' AND Nome = 'Recomendação de Peças')
BEGIN
    INSERT INTO AIHT_Prompts (Nome, Descricao, Contexto, ConteudoPrompt, Variaveis, Versao)
    VALUES (
        'Recomendação de Peças',
        'Prompt usado para recomendar peças específicas',
        'recomendacao',
        'Com base no problema relatado pelo cliente {{nome_cliente}} para o veículo {{fabricante_veiculo}} {{modelo_veiculo}}, você deve:

1. Analisar o problema descrito
2. Sugerir as peças mais adequadas
3. Explicar de forma simples por que essas peças são necessárias
4. Informar sobre compatibilidade
5. Mencionar se há opções de qualidade original ou alternativas

Problema relatado: {{problema_cliente}}
Categoria de interesse: {{categoria_interesse}}

Seja técnico quando necessário, mas sempre explique em termos que o cliente possa entender.',
        '["nome_cliente", "fabricante_veiculo", "modelo_veiculo", "problema_cliente", "categoria_interesse"]',
        1
    );
    PRINT 'Prompt de Recomendação de Peças inserido.';
END
GO

-- Prompt de Finalização
IF NOT EXISTS (SELECT * FROM AIHT_Prompts WHERE Contexto = 'finalizacao' AND Nome = 'Finalização de Atendimento')
BEGIN
    INSERT INTO AIHT_Prompts (Nome, Descricao, Contexto, ConteudoPrompt, Variaveis, Versao)
    VALUES (
        'Finalização de Atendimento',
        'Prompt usado para finalizar o atendimento',
        'finalizacao',
        'Você está finalizando o atendimento com {{nome_cliente}}. 

Resumo do atendimento:
- Veículo: {{fabricante_veiculo}} {{modelo_veiculo}}
- Peças recomendadas: {{pecas_recomendadas}}

Agradeça o cliente de forma cordial, pergunte se há mais alguma dúvida, e ofereça assistência futura. Seja breve e profissional.',
        '["nome_cliente", "fabricante_veiculo", "modelo_veiculo", "pecas_recomendadas"]',
        1
    );
    PRINT 'Prompt de Finalização inserido.';
END
GO

-- =============================================
-- 4. STORED PROCEDURES
-- =============================================

-- Procedure para buscar prompt ativo por contexto
IF OBJECT_ID('AIHT_sp_BuscarPromptPorContexto', 'P') IS NOT NULL
    DROP PROCEDURE AIHT_sp_BuscarPromptPorContexto;
GO

CREATE PROCEDURE AIHT_sp_BuscarPromptPorContexto
    @Contexto NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP 1
        Id,
        Nome,
        Descricao,
        Contexto,
        ConteudoPrompt,
        Variaveis,
        Versao,
        DataAtualizacao
    FROM AIHT_Prompts
    WHERE Contexto = @Contexto
        AND Ativo = 1
    ORDER BY Versao DESC, DataAtualizacao DESC;
END
GO

PRINT 'Procedure AIHT_sp_BuscarPromptPorContexto criada.';
GO

-- Procedure para listar todos os prompts
IF OBJECT_ID('AIHT_sp_ListarPrompts', 'P') IS NOT NULL
    DROP PROCEDURE AIHT_sp_ListarPrompts;
GO

CREATE PROCEDURE AIHT_sp_ListarPrompts
    @ApenasAtivos BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        Id,
        Nome,
        Descricao,
        Contexto,
        ConteudoPrompt,
        Variaveis,
        Ativo,
        Versao,
        DataCriacao,
        DataAtualizacao,
        CriadoPor,
        AtualizadoPor
    FROM AIHT_Prompts
    WHERE (@ApenasAtivos = 0 OR Ativo = 1)
    ORDER BY Contexto, Versao DESC;
END
GO

PRINT 'Procedure AIHT_sp_ListarPrompts criada.';
GO

-- Procedure para atualizar prompt
IF OBJECT_ID('AIHT_sp_AtualizarPrompt', 'P') IS NOT NULL
    DROP PROCEDURE AIHT_sp_AtualizarPrompt;
GO

CREATE PROCEDURE AIHT_sp_AtualizarPrompt
    @Id INT,
    @ConteudoPrompt NVARCHAR(MAX),
    @AtualizadoPor NVARCHAR(100) = 'Sistema'
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE AIHT_Prompts
    SET ConteudoPrompt = @ConteudoPrompt,
        Versao = Versao + 1,
        DataAtualizacao = GETDATE(),
        AtualizadoPor = @AtualizadoPor
    WHERE Id = @Id;
    
    SELECT @@ROWCOUNT AS LinhasAfetadas;
END
GO

PRINT 'Procedure AIHT_sp_AtualizarPrompt criada.';
GO

-- Procedure para criar novo prompt
IF OBJECT_ID('AIHT_sp_CriarPrompt', 'P') IS NOT NULL
    DROP PROCEDURE AIHT_sp_CriarPrompt;
GO

CREATE PROCEDURE AIHT_sp_CriarPrompt
    @Nome NVARCHAR(100),
    @Descricao NVARCHAR(500),
    @Contexto NVARCHAR(50),
    @ConteudoPrompt NVARCHAR(MAX),
    @Variaveis NVARCHAR(500),
    @CriadoPor NVARCHAR(100) = 'Sistema'
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO AIHT_Prompts (Nome, Descricao, Contexto, ConteudoPrompt, Variaveis, CriadoPor, AtualizadoPor)
    VALUES (@Nome, @Descricao, @Contexto, @ConteudoPrompt, @Variaveis, @CriadoPor, @CriadoPor);
    
    SELECT SCOPE_IDENTITY() AS NovoId;
END
GO

PRINT 'Procedure AIHT_sp_CriarPrompt criada.';
GO

-- =============================================
-- RESUMO
-- =============================================
PRINT '';
PRINT '=============================================';
PRINT 'Estrutura de Prompts criada com sucesso!';
PRINT '=============================================';
PRINT 'Tabela criada:';
PRINT '  - AIHT_Prompts';
PRINT '';
PRINT 'Prompts padrão inseridos:';
PRINT '  - Atendimento Inicial';
PRINT '  - Recomendação de Peças';
PRINT '  - Finalização de Atendimento';
PRINT '';
PRINT 'Procedures disponíveis:';
PRINT '  - AIHT_sp_BuscarPromptPorContexto';
PRINT '  - AIHT_sp_ListarPrompts';
PRINT '  - AIHT_sp_AtualizarPrompt';
PRINT '  - AIHT_sp_CriarPrompt';
PRINT '=============================================';
GO
