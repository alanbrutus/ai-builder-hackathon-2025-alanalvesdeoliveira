/*
==============================================================================
Script: 36_verificar_prompts.sql
Descrição: Verificar se todos os prompts estão cadastrados corretamente
Autor: Alan Alves de Oliveira
Data: 25/10/2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT '🔍 VERIFICANDO PROMPTS CADASTRADOS';
PRINT '========================================';
PRINT '';

-- 1. Listar todos os prompts
PRINT '1️⃣ PROMPTS CADASTRADOS:';
PRINT '----------------------------------------';

SELECT 
    Id,
    Nome,
    Contexto,
    Ativo,
    LEN(ConteudoPrompt) AS TamanhoPrompt,
    Variaveis,
    Versao,
    DataCriacao,
    DataAtualizacao
FROM AIHT_Prompts
ORDER BY 
    CASE Contexto
        WHEN 'identificacao_pecas' THEN 1
        WHEN 'cotacao' THEN 2
        WHEN 'finalizacao' THEN 3
        ELSE 4
    END,
    Id;

PRINT '';

-- 2. Verificar prompt de identificação
PRINT '2️⃣ PROMPT DE IDENTIFICAÇÃO:';
PRINT '----------------------------------------';

IF EXISTS (SELECT 1 FROM AIHT_Prompts WHERE Contexto = 'identificacao_pecas' AND Ativo = 1)
BEGIN
    SELECT 
        Id,
        Nome,
        Contexto,
        LEFT(ConteudoPrompt, 100) AS Preview,
        Variaveis
    FROM AIHT_Prompts
    WHERE Contexto = 'identificacao_pecas' AND Ativo = 1;
    PRINT '✅ Prompt de identificação encontrado';
END
ELSE
BEGIN
    PRINT '❌ Prompt de identificação NÃO encontrado!';
END

PRINT '';

-- 3. Verificar prompt de cotação
PRINT '3️⃣ PROMPT DE COTAÇÃO:';
PRINT '----------------------------------------';

IF EXISTS (SELECT 1 FROM AIHT_Prompts WHERE Contexto = 'cotacao' AND Ativo = 1)
BEGIN
    SELECT 
        Id,
        Nome,
        Contexto,
        LEFT(ConteudoPrompt, 100) AS Preview,
        Variaveis
    FROM AIHT_Prompts
    WHERE Contexto = 'cotacao' AND Ativo = 1;
    PRINT '✅ Prompt de cotação encontrado';
END
ELSE
BEGIN
    PRINT '❌ Prompt de cotação NÃO encontrado!';
END

PRINT '';

-- 4. Verificar prompt de finalização
PRINT '4️⃣ PROMPT DE FINALIZAÇÃO:';
PRINT '----------------------------------------';

IF EXISTS (SELECT 1 FROM AIHT_Prompts WHERE Contexto = 'finalizacao' AND Ativo = 1)
BEGIN
    SELECT 
        Id,
        Nome,
        Contexto,
        LEFT(ConteudoPrompt, 100) AS Preview,
        Variaveis
    FROM AIHT_Prompts
    WHERE Contexto = 'finalizacao' AND Ativo = 1;
    PRINT '✅ Prompt de finalização encontrado';
END
ELSE
BEGIN
    PRINT '❌ Prompt de finalização NÃO encontrado!';
    PRINT '';
    PRINT '🔧 SOLUÇÃO: Execute o script SQL/32_criar_prompt_finalizacao.sql';
END

PRINT '';

-- 5. Testar SP de obter prompt
PRINT '5️⃣ TESTANDO SP AIHT_sp_ObterPromptPorContexto:';
PRINT '----------------------------------------';

PRINT 'Teste 1: Buscar identificacao_pecas';
EXEC AIHT_sp_ObterPromptPorContexto @Contexto = 'identificacao_pecas';

PRINT '';
PRINT 'Teste 2: Buscar cotacao';
EXEC AIHT_sp_ObterPromptPorContexto @Contexto = 'cotacao';

PRINT '';
PRINT 'Teste 3: Buscar finalizacao';
EXEC AIHT_sp_ObterPromptPorContexto @Contexto = 'finalizacao';

PRINT '';

-- 6. Verificar se SP existe
PRINT '6️⃣ VERIFICANDO SP:';
PRINT '----------------------------------------';

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'AIHT_sp_ObterPromptPorContexto')
BEGIN
    SELECT 
        name AS NomeSP,
        create_date AS DataCriacao,
        modify_date AS DataModificacao
    FROM sys.procedures
    WHERE name = 'AIHT_sp_ObterPromptPorContexto';
    PRINT '✅ SP AIHT_sp_ObterPromptPorContexto existe';
END
ELSE
BEGIN
    PRINT '❌ SP AIHT_sp_ObterPromptPorContexto NÃO existe!';
END

PRINT '';

-- 7. Verificar conteúdo completo do prompt de finalização
PRINT '7️⃣ CONTEÚDO COMPLETO DO PROMPT DE FINALIZAÇÃO:';
PRINT '----------------------------------------';

IF EXISTS (SELECT 1 FROM AIHT_Prompts WHERE Contexto = 'finalizacao' AND Ativo = 1)
BEGIN
    SELECT 
        Id,
        Nome,
        Contexto,
        ConteudoPrompt,
        Variaveis,
        Ativo
    FROM AIHT_Prompts
    WHERE Contexto = 'finalizacao' AND Ativo = 1;
END
ELSE
BEGIN
    PRINT '❌ Prompt de finalização não encontrado!';
END

PRINT '';
PRINT '========================================';
PRINT '✅ VERIFICAÇÃO CONCLUÍDA';
PRINT '========================================';
PRINT '';

-- 8. Resumo
PRINT '📋 RESUMO:';
PRINT '----------------------------------------';

DECLARE @TotalPrompts INT;
DECLARE @PromptsAtivos INT;
DECLARE @TemIdentificacao BIT;
DECLARE @TemCotacao BIT;
DECLARE @TemFinalizacao BIT;

SELECT @TotalPrompts = COUNT(*) FROM AIHT_Prompts;
SELECT @PromptsAtivos = COUNT(*) FROM AIHT_Prompts WHERE Ativo = 1;
SELECT @TemIdentificacao = CASE WHEN EXISTS(SELECT 1 FROM AIHT_Prompts WHERE Contexto = 'identificacao_pecas' AND Ativo = 1) THEN 1 ELSE 0 END;
SELECT @TemCotacao = CASE WHEN EXISTS(SELECT 1 FROM AIHT_Prompts WHERE Contexto = 'cotacao' AND Ativo = 1) THEN 1 ELSE 0 END;
SELECT @TemFinalizacao = CASE WHEN EXISTS(SELECT 1 FROM AIHT_Prompts WHERE Contexto = 'finalizacao' AND Ativo = 1) THEN 1 ELSE 0 END;

PRINT 'Total de prompts: ' + CAST(@TotalPrompts AS VARCHAR);
PRINT 'Prompts ativos: ' + CAST(@PromptsAtivos AS VARCHAR);
PRINT '';
PRINT 'Prompt identificacao_pecas: ' + CASE WHEN @TemIdentificacao = 1 THEN '✅ OK' ELSE '❌ FALTANDO' END;
PRINT 'Prompt cotacao: ' + CASE WHEN @TemCotacao = 1 THEN '✅ OK' ELSE '❌ FALTANDO' END;
PRINT 'Prompt finalizacao: ' + CASE WHEN @TemFinalizacao = 1 THEN '✅ OK' ELSE '❌ FALTANDO' END;

PRINT '';

IF @TemIdentificacao = 1 AND @TemCotacao = 1 AND @TemFinalizacao = 1
BEGIN
    PRINT '✅ TODOS OS PROMPTS NECESSÁRIOS ESTÃO CADASTRADOS!';
END
ELSE
BEGIN
    PRINT '⚠️  FALTAM PROMPTS! Execute os scripts necessários:';
    IF @TemIdentificacao = 0 PRINT '   - SQL/30_verificar_prompt_identificacao.sql';
    IF @TemCotacao = 0 PRINT '   - SQL/25_inserir_prompt_cotacao.sql';
    IF @TemFinalizacao = 0 PRINT '   - SQL/32_criar_prompt_finalizacao.sql';
END

PRINT '';
PRINT '========================================';
GO
