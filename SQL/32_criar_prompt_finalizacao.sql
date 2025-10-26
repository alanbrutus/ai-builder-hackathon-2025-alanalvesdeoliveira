/*
==============================================================================
Script: 32_criar_prompt_finalizacao.sql
Descrição: Cria o prompt de finalização para quando não há intenção de cotação
Autor: Alan Alves de Oliveira
Data: 25/10/2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '🔍 Verificando prompt de finalização...';
PRINT '';

-- Verificar se existe prompt de finalização
IF NOT EXISTS (SELECT 1 FROM AIHT_Prompts WHERE Contexto = 'finalizacao' AND Ativo = 1)
BEGIN
    PRINT '📝 Criando prompt de finalização...';
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
        'Prompt de Finalização de Atendimento',
        'Prompt utilizado para finalizar o atendimento quando o cliente não solicita cotação',
        'finalizacao',
        'Você é um assistente virtual especializado em atendimento automotivo.

**CONTEXTO:**
- Cliente: {{nome_cliente}}
- Veículo: {{fabricante_veiculo}} {{modelo_veiculo}}
- Última mensagem do cliente: {{mensagem_cliente}}

**DIAGNÓSTICO ANTERIOR:**
{{diagnostico_anterior}}

---

**SUA TAREFA:**

O cliente enviou uma mensagem após receber o diagnóstico do problema. Responda de forma educada e profissional:

1. **Se o cliente agradeceu ou se despediu:**
   - Agradeça pela preferência
   - Deseje boa sorte com o reparo
   - Ofereça ajuda futura se necessário

2. **Se o cliente fez uma pergunta adicional:**
   - Responda de forma clara e objetiva
   - Mantenha o foco no problema diagnosticado
   - Seja prestativo

3. **Se o cliente expressou dúvida:**
   - Esclareça de forma didática
   - Reforce as informações importantes
   - Sugira próximos passos

**FORMATO DE RESPOSTA:**

Use um tom amigável e profissional. Seja breve mas completo. Use emojis moderadamente para tornar a conversa mais agradável.

**EXEMPLOS:**

Se cliente disse "obrigado":
"Fico feliz em ajudar, {{nome_cliente}}! 😊 Qualquer dúvida sobre o seu {{fabricante_veiculo}} {{modelo_veiculo}}, estou à disposição. Boa sorte com o reparo! 🔧"

Se cliente fez pergunta:
"Claro, {{nome_cliente}}! [Resposta clara à pergunta]. Se precisar de mais alguma informação, é só perguntar! 👍"

---

**INSTRUÇÕES:**
- Seja educado e prestativo
- Mantenha tom profissional mas amigável
- Não force vendas ou cotações
- Ofereça ajuda futura de forma natural',
        '{{nome_cliente}}, {{fabricante_veiculo}}, {{modelo_veiculo}}, {{mensagem_cliente}}, {{diagnostico_anterior}}',
        1,
        1,
        GETDATE(),
        'Sistema'
    );
    
    PRINT '✅ Prompt de finalização criado!';
END
ELSE
BEGIN
    PRINT '✅ Prompt de finalização já existe!';
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
        WHEN 'cotacao' THEN 2
        WHEN 'finalizacao' THEN 3
        ELSE 4
    END,
    Id;

PRINT '';
PRINT '✅ Script concluído!';
PRINT '';
PRINT '🔧 CONTEXTOS DISPONÍVEIS:';
PRINT '   1. identificacao_pecas: Identifica problemas e peças';
PRINT '   2. cotacao: Gera cotação de peças';
PRINT '   3. finalizacao: Finaliza atendimento sem cotação';
PRINT '';
