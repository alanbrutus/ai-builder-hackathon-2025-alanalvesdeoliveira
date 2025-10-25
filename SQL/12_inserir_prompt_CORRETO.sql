-- =============================================
-- Script: Inserir Prompt de Identificação - CORRETO
-- Descrição: Com coluna Nome incluída
-- =============================================

USE AI_Builder_Hackthon;
GO

PRINT 'Inserindo prompt de identificação...';
GO

-- Deletar prompt antigo se existir
DELETE FROM AIHT_Prompts WHERE Contexto = 'identificacao_pecas';
GO

-- Inserir prompt de identificação COM NOME
INSERT INTO AIHT_Prompts (
    Nome,
    Contexto,
    ConteudoPrompt,
    Descricao,
    Versao,
    Ativo
)
VALUES (
    'Identificação de Peças Automotivas',
    'identificacao_pecas',
    'Você é um especialista em diagnóstico automotivo para {{grupo_empresarial}} {{fabricante_veiculo}} {{modelo_veiculo}}.

TAREFA: Analise a mensagem do cliente e forneça uma resposta completa E estruturada.

FORMATO DA RESPOSTA:

1. ANÁLISE (resposta ao cliente):
- Cumprimente o cliente
- Analise o problema relatado
- Explique as possíveis causas
- Detalhe cada peça mencionada ou necessária
- Dê recomendações técnicas

2. EXTRAÇÃO (para sistema - OBRIGATÓRIO no final):
Após sua análise completa, adicione uma seção especial no formato:

---PECAS_IDENTIFICADAS---
Problema;Peça
Problema;Peça
---FIM_PECAS---

EXEMPLO DE RESPOSTA COMPLETA:

Olá! Vejo que seu Jeep Compass está com problema de partida.

O diagnóstico do mecânico está correto. Quando o motor de arranque gira mas o carro não liga, as causas mais comuns são:

🔋 **Bateria:**
- Bateria fraca ou descarregada
- Terminais oxidados ou soltos
- Recomendação: Teste de carga (deve ter 12,6V)

⚙️ **Motor de Arranque:**
- Bendix desgastado
- Bobinas queimadas
- Escovas gastas
- Recomendação: Teste de corrente de partida

💡 **Próximos Passos:**
1. Teste a bateria primeiro (mais comum e mais barato)
2. Se bateria OK, verificar motor de arranque
3. Verificar também fusíveis e relés

---PECAS_IDENTIFICADAS---
Não dá partida;Bateria
Não dá partida;Motor de Arranque
Não dá partida;Terminais de bateria
---FIM_PECAS---

IMPORTANTE:
- SEMPRE inclua a seção ---PECAS_IDENTIFICADAS--- no final
- Se não houver problema/peças, retorne apenas uma pergunta amigável
- Use emojis para tornar a resposta mais visual
- Seja técnico mas acessível',
    'Prompt para identificar problemas e peças a partir da conversa do cliente',
    1,
    1
);

PRINT '✓ Prompt de identificação inserido';
GO

-- Verificar inserção
IF EXISTS (SELECT 1 FROM AIHT_Prompts WHERE Contexto = 'identificacao_pecas')
BEGIN
    PRINT '✓ Prompt encontrado na tabela';
    
    SELECT 
        Id,
        Nome,
        Contexto,
        LEFT(ConteudoPrompt, 100) + '...' AS 'Preview',
        LEN(ConteudoPrompt) AS 'Tamanho',
        Versao,
        Ativo
    FROM AIHT_Prompts
    WHERE Contexto = 'identificacao_pecas';
END
ELSE
BEGIN
    PRINT '✗ ERRO: Prompt não foi inserido!';
END
GO

-- =============================================
-- Stored Procedure: Obter Prompt por Contexto
-- =============================================
PRINT '';
PRINT 'Criando stored procedure...';
GO

CREATE OR ALTER PROCEDURE [dbo].[AIHT_sp_ObterPromptPorContexto]
    @Contexto NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        Id,
        Nome,
        Contexto,
        ConteudoPrompt,
        Descricao,
        Versao,
        Ativo,
        DataCriacao,
        DataAtualizacao
    FROM [dbo].[AIHT_Prompts]
    WHERE Contexto = @Contexto
        AND Ativo = 1
    ORDER BY Versao DESC;
END
GO

PRINT '✓ AIHT_sp_ObterPromptPorContexto criada';
GO

-- Conceder permissão
GRANT EXECUTE ON dbo.AIHT_sp_ObterPromptPorContexto TO AI_Hackthon;
PRINT '✓ Permissão concedida';
GO

-- Testar stored procedure
PRINT '';
PRINT 'Testando stored procedure...';
GO

EXEC dbo.AIHT_sp_ObterPromptPorContexto @Contexto = 'identificacao_pecas';
GO

PRINT '';
PRINT '========================================';
PRINT 'SUCESSO! Prompt e SP criados!';
PRINT 'Agora teste no chat!';
PRINT '========================================';
GO
