/*
==============================================================================
Script: 29_corrigir_prompt_id_11.sql
Descrição: Corrige o prompt ID 11 para usar variáveis com {{variavel}}
Autor: Alan Alves de Oliveira
Data: 25/10/2025
Problema: Prompt não tem variáveis mapeadas com {{ }}
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '🔍 Verificando prompt ID 11...';
PRINT '';

-- Verificar conteúdo atual
SELECT 
    Id,
    Nome,
    Contexto,
    LEFT(ConteudoPrompt, 200) AS ConteudoPrompt_Preview,
    Variaveis,
    Ativo,
    Versao
FROM AIHT_Prompts
WHERE Id = 11;

PRINT '';
PRINT '🔧 Atualizando prompt ID 11 com variáveis corretas...';
PRINT '';

-- Atualizar o prompt com as variáveis corretas
UPDATE AIHT_Prompts
SET 
    Nome = 'Prompt de Cotação de Peças',
    Descricao = 'Prompt utilizado para gerar cotações detalhadas de peças automotivas em e-commerce e lojas físicas',
    Contexto = 'cotacao',
    ConteudoPrompt = 'Preciso que realize um processo de cotação para o {{fabricante_veiculo}} {{modelo_veiculo}} em e-Commerce e lojas presenciais para as peças relacionadas abaixo:

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
    Variaveis = '{{fabricante_veiculo}}, {{modelo_veiculo}}, {{lista_pecas}}',
    Ativo = 1,
    Versao = ISNULL(Versao, 0) + 1,
    DataAtualizacao = GETDATE(),
    AtualizadoPor = 'Sistema - Correção de Variáveis'
WHERE Id = 11;

PRINT '✅ Prompt ID 11 atualizado com sucesso!';
PRINT '';

-- Verificar atualização
PRINT '📋 Verificando prompt atualizado:';
PRINT '==================================';
PRINT '';

SELECT 
    Id,
    Nome,
    Descricao,
    Contexto,
    LEFT(ConteudoPrompt, 300) AS ConteudoPrompt_Preview,
    Variaveis,
    Ativo,
    Versao,
    DataAtualizacao,
    AtualizadoPor
FROM AIHT_Prompts
WHERE Id = 11;

PRINT '';
PRINT '🔍 Verificando variáveis no conteúdo:';
PRINT '====================================';
PRINT '';

-- Verificar se as variáveis estão presentes
SELECT 
    Id,
    CASE 
        WHEN ConteudoPrompt LIKE '%{{fabricante_veiculo}}%' 
        THEN '✅ {{fabricante_veiculo}} encontrada'
        ELSE '❌ {{fabricante_veiculo}} NÃO encontrada'
    END AS Variavel_Fabricante,
    CASE 
        WHEN ConteudoPrompt LIKE '%{{modelo_veiculo}}%' 
        THEN '✅ {{modelo_veiculo}} encontrada'
        ELSE '❌ {{modelo_veiculo}} NÃO encontrada'
    END AS Variavel_Modelo,
    CASE 
        WHEN ConteudoPrompt LIKE '%{{lista_pecas}}%' 
        THEN '✅ {{lista_pecas}} encontrada'
        ELSE '❌ {{lista_pecas}} NÃO encontrada'
    END AS Variavel_Lista
FROM AIHT_Prompts
WHERE Id = 11;

PRINT '';
PRINT '========================================';
PRINT '✅ CORREÇÃO CONCLUÍDA!';
PRINT '========================================';
PRINT '';
PRINT '📝 VARIÁVEIS MAPEADAS:';
PRINT '   - {{fabricante_veiculo}} → Nome do fabricante';
PRINT '   - {{modelo_veiculo}} → Nome do modelo';
PRINT '   - {{lista_pecas}} → Lista de peças formatada';
PRINT '';
PRINT '🔧 FONTE DOS DADOS:';
PRINT '   Tabela: AIHT_PecasIdentificadas';
PRINT '   Campos: MarcaVeiculo, ModeloVeiculo, NomePeca, CodigoPeca';
PRINT '';
PRINT '🚀 API: /api/gerar-cotacao';
PRINT '   Substitui as variáveis antes de enviar para a IA';
PRINT '';

-- Teste de substituição (simulado)
PRINT '🧪 EXEMPLO DE SUBSTITUIÇÃO:';
PRINT '====================================';
PRINT '';
PRINT 'ANTES (Template):';
PRINT '   "...para o {{fabricante_veiculo}} {{modelo_veiculo}}..."';
PRINT '   "{{lista_pecas}}"';
PRINT '';
PRINT 'DEPOIS (Substituído):';
PRINT '   "...para o Jeep Compass..."';
PRINT '   "1. Pastilha de Freio - BRP123"';
PRINT '   "2. Disco de Freio - DFR456"';
PRINT '';
PRINT '========================================';
PRINT '';
