-- =============================================
-- Script: Criar Tabelas de Conversas SEM Foreign Keys
-- Descrição: Versão simplificada sem restrições de FK
-- =============================================

USE AI_Builder_Hackthon;
GO

PRINT 'Criando tabelas SEM foreign keys...';
GO

-- =============================================
-- Tabela: AIHT_Conversas (SEM FK)
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AIHT_Conversas]'))
BEGIN
    DROP TABLE [dbo].[AIHT_Conversas];
    PRINT 'Tabela AIHT_Conversas antiga removida.';
END
GO

CREATE TABLE [dbo].[AIHT_Conversas] (
    [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [NomeCliente] NVARCHAR(200) NOT NULL,
    [GrupoEmpresarialId] INT NOT NULL,
    [FabricanteId] INT NOT NULL,
    [ModeloId] INT NOT NULL,
    [DataInicio] DATETIME NOT NULL DEFAULT GETDATE(),
    [DataUltimaInteracao] DATETIME NOT NULL DEFAULT GETDATE(),
    [Status] NVARCHAR(50) NOT NULL DEFAULT 'Ativa',
    [Ativo] BIT NOT NULL DEFAULT 1
);

PRINT '✓ Tabela AIHT_Conversas criada (SEM foreign keys)';
GO

-- =============================================
-- Tabela: AIHT_ProblemasIdentificados
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AIHT_ProblemasIdentificados]'))
BEGIN
    DROP TABLE [dbo].[AIHT_ProblemasIdentificados];
    PRINT 'Tabela AIHT_ProblemasIdentificados antiga removida.';
END
GO

CREATE TABLE [dbo].[AIHT_ProblemasIdentificados] (
    [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ConversaId] INT NOT NULL,
    [DescricaoProblema] NVARCHAR(MAX) NOT NULL,
    [DataIdentificacao] DATETIME NOT NULL DEFAULT GETDATE(),
    [Ativo] BIT NOT NULL DEFAULT 1,
    CONSTRAINT [FK_Problemas_Conversa] FOREIGN KEY ([ConversaId]) 
        REFERENCES [dbo].[AIHT_Conversas]([Id])
);

PRINT '✓ Tabela AIHT_ProblemasIdentificados criada';
GO

-- =============================================
-- Tabela: AIHT_PecasIdentificadas
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AIHT_PecasIdentificadas]'))
BEGIN
    DROP TABLE [dbo].[AIHT_PecasIdentificadas];
    PRINT 'Tabela AIHT_PecasIdentificadas antiga removida.';
END
GO

CREATE TABLE [dbo].[AIHT_PecasIdentificadas] (
    [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ConversaId] INT NOT NULL,
    [ProblemaId] INT NULL,
    [NomePeca] NVARCHAR(200) NOT NULL,
    [CategoriaPeca] NVARCHAR(100) NULL,
    [Prioridade] NVARCHAR(50) NULL,
    [DataIdentificacao] DATETIME NOT NULL DEFAULT GETDATE(),
    [Ativo] BIT NOT NULL DEFAULT 1,
    CONSTRAINT [FK_Pecas_Conversa] FOREIGN KEY ([ConversaId]) 
        REFERENCES [dbo].[AIHT_Conversas]([Id]),
    CONSTRAINT [FK_Pecas_Problema] FOREIGN KEY ([ProblemaId]) 
        REFERENCES [dbo].[AIHT_ProblemasIdentificados]([Id])
);

PRINT '✓ Tabela AIHT_PecasIdentificadas criada';
GO

-- =============================================
-- Inserir prompt de identificação
-- =============================================
IF NOT EXISTS (SELECT 1 FROM AIHT_Prompts WHERE Contexto = 'identificacao_pecas')
BEGIN
    INSERT INTO AIHT_Prompts (
        Contexto,
        ConteudoPrompt,
        Descricao,
        Versao,
        Ativo
    )
    VALUES (
        'identificacao_pecas',
        'Preciso que a partir dessa conversa identifique o que é um relato de problema automotivo para o {{grupo_empresarial}}, {{fabricante_veiculo}}, {{modelo_veiculo}} e peças mencionadas ou que podem ser causadoras deste problema e me retorne isso em uma lista no formato:
Problema;Peça

Exemplo de resposta esperada:
Barulho ao frear;Pastilha de freio
Barulho ao frear;Disco de freio

Caso não identifique um relato de problema retorne perguntando qual o problema ou a peça desejada.

IMPORTANTE: Retorne APENAS a lista no formato especificado (Problema;Peça) ou a pergunta. Não adicione explicações extras.',
        'Prompt para identificar problemas e peças a partir da conversa do cliente',
        1,
        1
    );
    
    PRINT '✓ Prompt de identificação de peças inserido';
END
ELSE
BEGIN
    PRINT 'Prompt de identificação de peças já existe';
END
GO

-- =============================================
-- Conceder permissões
-- =============================================
GRANT SELECT, INSERT, UPDATE ON dbo.AIHT_Conversas TO AI_Hackthon;
GRANT SELECT, INSERT ON dbo.AIHT_ProblemasIdentificados TO AI_Hackthon;
GRANT SELECT, INSERT ON dbo.AIHT_PecasIdentificadas TO AI_Hackthon;

PRINT '✓ Permissões concedidas';
GO

-- =============================================
-- Verificar criação
-- =============================================
PRINT '';
PRINT 'Verificando tabelas criadas:';
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'AIHT_Conversas')
    PRINT '✓ AIHT_Conversas criada';
ELSE
    PRINT '✗ ERRO: AIHT_Conversas NÃO foi criada';

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'AIHT_ProblemasIdentificados')
    PRINT '✓ AIHT_ProblemasIdentificados criada';
ELSE
    PRINT '✗ ERRO: AIHT_ProblemasIdentificados NÃO foi criada';

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'AIHT_PecasIdentificadas')
    PRINT '✓ AIHT_PecasIdentificadas criada';
ELSE
    PRINT '✗ ERRO: AIHT_PecasIdentificadas NÃO foi criada';
GO

PRINT '';
PRINT '========================================';
PRINT 'Tabelas criadas com sucesso!';
PRINT 'Execute agora: SQL/07_stored_procedures_conversas.sql';
PRINT '========================================';
GO
