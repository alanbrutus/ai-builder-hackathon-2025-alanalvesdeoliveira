/*
==============================================================================
Script: 31_corrigir_prompt_id_11.sql
Descrição: Corrige o prompt ID 11 que foi sobrescrito incorretamente
Problema: ID 11 era identificacao_pecas mas foi alterado para cotacao
Solução: Restaurar ID 11 como identificacao_pecas e criar novo para cotacao
Autor: Alan Alves de Oliveira
Data: 25/10/2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '🔍 Verificando situação atual...';
PRINT '';

-- Ver estado atual do ID 11
SELECT 
    Id,
    Nome,
    Contexto,
    LEFT(ConteudoPrompt, 100) AS Preview,
    Ativo,
    Versao
FROM AIHT_Prompts
WHERE Id = 11;

PRINT '';
PRINT '🔧 Corrigindo prompt ID 11...';
PRINT '';

-- Restaurar ID 11 como identificacao_pecas
UPDATE AIHT_Prompts
SET 
    Nome = 'Prompt de Identificação de Problemas',
    Descricao = 'Prompt utilizado para identificar problemas automotivos e sugerir peças necessárias',
    Contexto = 'identificacao_pecas',
    ConteudoPrompt = 'Você é um especialista em diagnóstico automotivo com mais de 20 anos de experiência.

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
    Variaveis = '{{nome_cliente}}, {{fabricante_veiculo}}, {{modelo_veiculo}}, {{grupo_empresarial}}, {{mensagem_cliente}}',
    Ativo = 1,
    Versao = ISNULL(Versao, 0) + 1,
    DataAtualizacao = GETDATE(),
    AtualizadoPor = 'Sistema - Correção de Contexto'
WHERE Id = 11;

PRINT '✅ Prompt ID 11 restaurado como identificacao_pecas!';
PRINT '';

-- Verificar se já existe prompt de cotação (diferente do ID 11)
IF NOT EXISTS (SELECT 1 FROM AIHT_Prompts WHERE Contexto = 'cotacao' AND Id <> 11 AND Ativo = 1)
BEGIN
    PRINT '📝 Criando novo prompt de cotação...';
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
        'Prompt de Cotação de Peças',
        'Prompt utilizado para gerar cotações detalhadas de peças automotivas em e-commerce e lojas físicas',
        'cotacao',
        'Preciso que realize um processo de cotação para o {{fabricante_veiculo}} {{modelo_veiculo}} em e-Commerce e lojas presenciais para as peças relacionadas abaixo:

-- Início Peças
{{lista_pecas}}
-- Fim Peças

Para cada peça identificada, retorne as seguintes informações:

📦 **Nome da Peça:** [Nome completo da peça]
🔢 **Código:** [Código da peça]
🏪 **Tipo:** [e-Commerce ou Loja Física]
🔗 **Link/Endereço:** [URL do e-commerce ou endereço completo da loja física]
💰 **Preço:** [Faixa de preço estimada]
💳 **Condições de Pagamento:** [Formas de pagamento disponíveis]
⭐ **Observações:** [Disponibilidade, prazo de entrega, etc]

---

**IMPORTANTE:**
- Pesquise em múltiplos e-commerces: Mercado Livre, OLX, Shopee, Amazon
- Para lojas físicas, indique endereços reais na região (se possível)
- Forneça faixas de preço realistas baseadas no mercado atual
- Indique se a peça é original, paralela ou genérica
- Mencione prazos de entrega estimados
- Sugira as melhores opções custo-benefício

**FORMATO DE RESPOSTA:**
Use emojis e formatação clara para facilitar a leitura. Organize as informações de forma estruturada e profissional.',
        '{{fabricante_veiculo}}, {{modelo_veiculo}}, {{lista_pecas}}',
        1,
        1,
        GETDATE(),
        'Sistema'
    );
    
    PRINT '✅ Novo prompt de cotação criado!';
END
ELSE
BEGIN
    PRINT '✅ Prompt de cotação já existe (ID diferente de 11)';
END

PRINT '';
PRINT '========================================';
PRINT '📋 SITUAÇÃO FINAL DOS PROMPTS';
PRINT '========================================';
PRINT '';

SELECT 
    Id,
    Nome,
    Contexto,
    LEFT(ConteudoPrompt, 100) AS Preview,
    Variaveis,
    Ativo,
    Versao,
    DataAtualizacao,
    AtualizadoPor
FROM AIHT_Prompts
ORDER BY 
    CASE Contexto
        WHEN 'identificacao_pecas' THEN 1
        WHEN 'cotacao' THEN 2
        ELSE 3
    END,
    Id;

PRINT '';
PRINT '========================================';
PRINT '✅ CORREÇÃO CONCLUÍDA!';
PRINT '========================================';
PRINT '';
PRINT '📊 RESUMO:';
PRINT '   - ID 11: identificacao_pecas (RESTAURADO)';
PRINT '   - Novo ID: cotacao (CRIADO se não existia)';
PRINT '';
PRINT '🔧 CONTEXTOS CORRETOS:';
PRINT '   - identificacao_pecas: Para identificar problemas e peças';
PRINT '   - cotacao: Para gerar cotações de peças';
PRINT '';
PRINT '🚀 APIs:';
PRINT '   - /api/identificar-pecas → contexto ''identificacao_pecas''';
PRINT '   - /api/gerar-cotacao → contexto ''cotacao''';
PRINT '';
