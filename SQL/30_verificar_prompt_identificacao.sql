/*
==============================================================================
Script: 30_verificar_prompt_identificacao.sql
Descrição: Verifica e insere o prompt de identificação de problemas
Autor: Alan Alves de Oliveira
Data: 25/10/2025
Erro: "Prompt de identificação não encontrado"
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '🔍 Verificando prompts cadastrados...';
PRINT '';

-- Listar todos os prompts
SELECT 
    Id,
    Nome,
    Contexto,
    LEFT(ConteudoPrompt, 100) AS ConteudoPrompt_Preview,
    Ativo,
    Versao,
    DataCriacao
FROM AIHT_Prompts
ORDER BY Id;

PRINT '';
PRINT '🔍 Verificando prompt de identificação (contexto = ''identificacao_pecas'')...';
PRINT '';

-- Verificar se existe prompt de identificação
IF NOT EXISTS (SELECT 1 FROM AIHT_Prompts WHERE Contexto = 'identificacao_pecas' AND Ativo = 1)
BEGIN
    PRINT '❌ Prompt de identificação NÃO encontrado!';
    PRINT '📝 Inserindo prompt de identificação...';
    PRINT '';
    
    INSERT INTO AIHT_Prompts (
        Nome,
        Descricao,
        Contexto,
        ConteudoPrompt,
        Variaveis,
        Ativo,
        Versao,
        DataCriacao,
        CriadoPor
    )
    VALUES (
        'Prompt de Identificação de Problemas',
        'Prompt utilizado para identificar problemas automotivos e sugerir peças necessárias',
        'identificacao_pecas',
        'Você é um especialista em diagnóstico automotivo com mais de 20 anos de experiência.

**CONTEXTO DO CLIENTE:**
- Nome: {{nome_cliente}}
- Veículo: {{fabricante_veiculo}} {{modelo_veiculo}}
- Grupo Empresarial: {{grupo_empresarial}}

**PROBLEMA RELATADO:**
{{mensagem_cliente}}

---

**SUA TAREFA:**

1. **ANÁLISE DO PROBLEMA:**
   - Analise cuidadosamente o problema descrito
   - Identifique os sintomas principais
   - Considere as causas mais prováveis

2. **DIAGNÓSTICO:**
   - Explique de forma clara e didática o que pode estar causando o problema
   - Use linguagem acessível, evitando jargões técnicos excessivos
   - Seja específico sobre o sistema afetado (freios, suspensão, motor, etc.)

3. **PEÇAS NECESSÁRIAS:**
   - Liste TODAS as peças que podem ser necessárias para resolver o problema
   - Para CADA peça, forneça:
     * Nome completo e específico da peça
     * Código da peça (se aplicável ao modelo)
     * Categoria (ex: Freios, Suspensão, Motor, Elétrica, Carroceria)
     * Prioridade (Alta, Média, Baixa)
   
4. **RECOMENDAÇÕES:**
   - Sugira a ordem de verificação/substituição
   - Indique se é necessário diagnóstico profissional
   - Mencione cuidados importantes

**FORMATO DE RESPOSTA:**

🔍 **DIAGNÓSTICO:**
[Explicação clara do problema]

🔧 **PEÇAS NECESSÁRIAS:**

1. **[Nome da Peça]**
   - Código: [Código ou "Verificar com fabricante"]
   - Categoria: [Categoria]
   - Prioridade: [Alta/Média/Baixa]
   - Motivo: [Por que essa peça pode ser necessária]

[Repetir para cada peça]

💡 **RECOMENDAÇÕES:**
- [Recomendação 1]
- [Recomendação 2]
- [Recomendação 3]

⚠️ **IMPORTANTE:**
[Avisos ou cuidados especiais]

---

**INSTRUÇÕES IMPORTANTES:**
- Seja específico e preciso
- Liste TODAS as peças que podem estar relacionadas ao problema
- Use emojis para melhor visualização
- Mantenha tom profissional mas acessível
- Se não tiver certeza, mencione que é necessário diagnóstico presencial',
        '{{nome_cliente}}, {{fabricante_veiculo}}, {{modelo_veiculo}}, {{grupo_empresarial}}, {{mensagem_cliente}}',
        1,
        1,
        GETDATE(),
        'Sistema'
    );
    
    PRINT '✅ Prompt de identificação inserido com sucesso!';
END
ELSE
BEGIN
    PRINT '✅ Prompt de identificação JÁ existe!';
    
    -- Mostrar o prompt existente
    SELECT 
        Id,
        Nome,
        Contexto,
        LEFT(ConteudoPrompt, 200) AS ConteudoPrompt_Preview,
        Variaveis,
        Ativo,
        Versao
    FROM AIHT_Prompts
    WHERE Contexto = 'identificacao_pecas';
END

PRINT '';
PRINT '========================================';
PRINT '📋 RESUMO DOS PROMPTS';
PRINT '========================================';
PRINT '';

SELECT 
    Id,
    Nome,
    Contexto,
    Ativo,
    Versao,
    DataCriacao
FROM AIHT_Prompts
ORDER BY 
    CASE Contexto
        WHEN 'identificacao_pecas' THEN 1
        WHEN 'cotacao' THEN 2
        ELSE 3
    END,
    Id;

PRINT '';
PRINT '✅ Verificação concluída!';
PRINT '';
PRINT '🔧 CONTEXTOS ESPERADOS:';
PRINT '   - identificacao_pecas: Para identificar problemas e peças';
PRINT '   - cotacao: Para gerar cotações de peças';
PRINT '';
PRINT '🚀 API que usa cada prompt:';
PRINT '   - /api/identificar-pecas → contexto ''identificacao_pecas''';
PRINT '   - /api/gerar-cotacao → contexto ''cotacao''';
PRINT '';
