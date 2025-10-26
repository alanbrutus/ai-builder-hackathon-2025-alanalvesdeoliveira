/*
==============================================================================
Script: 37_criar_prompt_recomendacao.sql
Descrição: Cria o prompt de recomendação (após diagnóstico, antes da cotação)
Autor: Alan Alves de Oliveira
Data: 25/10/2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT '🔧 CRIANDO PROMPT DE RECOMENDAÇÃO';
PRINT '========================================';
PRINT '';

-- Verificar se existe prompt de recomendação
IF NOT EXISTS (SELECT 1 FROM AIHT_Prompts WHERE Contexto = 'recomendacao' AND Ativo = 1)
BEGIN
    PRINT '📝 Criando prompt de recomendação...';
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
        'Prompt de Recomendação de Peças',
        'Prompt utilizado para recomendar peças após diagnóstico e perguntar sobre cotação',
        'recomendacao',
        'Você é um assistente virtual especializado em peças automotivas.

**CONTEXTO:**
- Cliente: {{nome_cliente}}
- Veículo: {{fabricante_veiculo}} {{modelo_veiculo}}
- Grupo Empresarial: {{grupo_empresarial}}

**DIAGNÓSTICO REALIZADO:**
{{diagnostico}}

**PEÇAS IDENTIFICADAS:**
{{lista_pecas}}

---

**SUA TAREFA:**

Com base no diagnóstico acima, você deve:

1. **Resumir o problema** de forma clara e objetiva
2. **Confirmar as peças necessárias** para resolver o problema
3. **Explicar brevemente** por que cada peça é necessária
4. **Perguntar se o cliente deseja uma cotação** dessas peças

**FORMATO DE RESPOSTA:**

Use um tom profissional mas amigável. Seja claro e direto.

**EXEMPLO:**

"{{nome_cliente}}, com base na análise do seu {{fabricante_veiculo}} {{modelo_veiculo}}, identifiquei o seguinte:

🔍 **Problema Detectado:**
[Resumo do problema]

🔧 **Peças Necessárias:**
• [Peça 1] - [Breve explicação]
• [Peça 2] - [Breve explicação]

💡 **Recomendação:**
[Orientação sobre urgência, segurança, etc]

💰 **Próximo Passo:**
Gostaria que eu realizasse uma cotação dessas peças em e-commerces e lojas físicas da região?"

---

**INSTRUÇÕES:**
- Seja claro e objetivo
- Use emojis moderadamente
- Destaque a importância da manutenção
- Sempre pergunte sobre a cotação no final
- Mantenha tom profissional mas acessível',
        '{{nome_cliente}}, {{fabricante_veiculo}}, {{modelo_veiculo}}, {{grupo_empresarial}}, {{diagnostico}}, {{lista_pecas}}',
        1,
        1,
        GETDATE(),
        'Sistema'
    );
    
    PRINT '✅ Prompt de recomendação criado!';
END
ELSE
BEGIN
    PRINT '✅ Prompt de recomendação já existe!';
END

PRINT '';
PRINT '========================================';
PRINT '📋 TODOS OS PROMPTS CADASTRADOS';
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
        WHEN 'recomendacao' THEN 2
        WHEN 'cotacao' THEN 3
        WHEN 'finalizacao' THEN 4
        ELSE 5
    END,
    Id;

PRINT '';
PRINT '✅ Script concluído!';
PRINT '';
PRINT '🔧 CONTEXTOS DISPONÍVEIS:';
PRINT '   1. identificacao_pecas: Identifica problemas e peças';
PRINT '   2. recomendacao: Recomenda peças e pergunta sobre cotação';
PRINT '   3. cotacao: Gera cotação de peças';
PRINT '   4. finalizacao: Finaliza atendimento sem cotação';
PRINT '';
PRINT '📊 FLUXO COMPLETO:';
PRINT '   Cliente descreve problema';
PRINT '   → identificacao_pecas (identifica)';
PRINT '   → recomendacao (pergunta se quer cotação)';
PRINT '   → Cliente responde';
PRINT '      ├─ "Cotação" → cotacao (gera cotação)';
PRINT '      └─ "Obrigado" → finalizacao (finaliza)';
PRINT '';
