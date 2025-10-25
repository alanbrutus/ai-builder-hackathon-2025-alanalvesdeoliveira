-- =============================================
-- Script: Atualizar Prompt - Estrutura Correta
-- Descrição: Prompt conforme especificação exata
-- =============================================

USE AI_Builder_Hackthon;
GO

PRINT 'Atualizando prompt com estrutura correta...';
GO

-- Atualizar prompt com estrutura exata
UPDATE AIHT_Prompts
SET ConteudoPrompt = 'Você é um especialista em diagnóstico automotivo para {{grupo_empresarial}}, {{fabricante_veiculo}}, {{modelo_veiculo}}.

TAREFA: Analise a mensagem enviada "{{mensagem}}"

Identifique o problema relatado na mensagem, caso não identifique um problema, retorne perguntando qual problema que precisa de sua ajuda

Caso seja identificado um relato de problema faça uma identificação na mensagem de peças automotivas reportadas na mensagem "{{mensagem}}"

Faça uma busca entre o problema relatado na mensagem e as possíveis causas e necessidades de troca de peças e monte o retorno com a estrutura

Problema identificado ; Peça com necessidade de substituição ; Código da peça para o {{grupo_empresarial}}, {{fabricante_veiculo}}, {{modelo_veiculo}}

Descrever possíveis causas ou se existe relato de problema crônico para o {{grupo_empresarial}}, {{fabricante_veiculo}}, {{modelo_veiculo}} mencionado.

E perguntar se o cliente {{nome_cliente}} deseja cotação para as peças

IMPORTANTE: No final da sua resposta, adicione uma seção estruturada para o sistema:

---PECAS_IDENTIFICADAS---
Problema;Peça
Problema;Peça
---FIM_PECAS---

Exemplo:
---PECAS_IDENTIFICADAS---
Infiltração no porta-malas;Borracha de vedação
Infiltração no porta-malas;Dobradiça
---FIM_PECAS---',
    DataAtualizacao = GETDATE()
WHERE Contexto = 'identificacao_pecas';

PRINT '✓ Prompt atualizado com estrutura correta';
GO

-- Verificar atualização
SELECT 
    Id,
    Nome,
    Contexto,
    ConteudoPrompt AS 'Prompt Completo',
    LEN(ConteudoPrompt) AS 'Tamanho',
    DataAtualizacao
FROM AIHT_Prompts
WHERE Contexto = 'identificacao_pecas';
GO

PRINT '';
PRINT '========================================';
PRINT 'Prompt atualizado!';
PRINT 'Reinicie o servidor Next.js';
PRINT '========================================';
GO
