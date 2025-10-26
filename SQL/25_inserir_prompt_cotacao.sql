/*
==============================================================================
Script: 25_inserir_prompt_cotacao.sql
Descrição: Insere prompt para geração de cotação de peças
Autor: Alan Alves de Oliveira
Data: 25/10/2025
Hackathon: AI Builder Hackathon 2025

Estrutura da Tabela AIHT_Prompts:
- Id (INT, IDENTITY, PK)
- Nome (VARCHAR)
- Descricao (VARCHAR)
- Contexto (VARCHAR)
- ConteudoPrompt (NVARCHAR(MAX))
- Variaveis (VARCHAR)
- Ativo (BIT)
- Versao (INT)
- DataCriacao (DATETIME)
- DataAtualizacao (DATETIME)
- CriadoPor (VARCHAR)
- AtualizadoPor (VARCHAR)
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

-- Verificar se o prompt já existe
IF EXISTS (SELECT 1 FROM AIHT_Prompts WHERE Contexto = 'cotacao')
BEGIN
    PRINT '⚠️  Prompt de cotação já existe. Atualizando...';
    
    UPDATE AIHT_Prompts
    SET 
        Nome = 'Prompt de Cotação de Peças',
        Descricao = 'Prompt utilizado para gerar cotações detalhadas de peças automotivas em e-commerce e lojas físicas',
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
        AtualizadoPor = 'Sistema'
    WHERE Contexto = 'cotacao';
    
    PRINT '✅ Prompt de cotação atualizado com sucesso!';
END
ELSE
BEGIN
    PRINT '📝 Inserindo novo prompt de cotação...';
    
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
    
    PRINT '✅ Prompt de cotação inserido com sucesso!';
END
GO

-- Verificar o prompt inserido
PRINT '';
PRINT '📋 Verificando prompt de cotação:';
PRINT '==================================';

SELECT 
    Id,
    Nome,
    Descricao,
    Contexto,
    LEFT(ConteudoPrompt, 100) + '...' AS ConteudoPrompt_Preview,
    Variaveis,
    Ativo,
    Versao,
    DataCriacao,
    DataAtualizacao,
    CriadoPor,
    AtualizadoPor
FROM AIHT_Prompts
WHERE Contexto = 'cotacao';

PRINT '';
PRINT '✅ Script executado com sucesso!';
PRINT '';
PRINT '📝 VARIÁVEIS DISPONÍVEIS NO PROMPT:';
PRINT '   - {{fabricante_veiculo}} - Nome do fabricante do veículo';
PRINT '   - {{modelo_veiculo}} - Nome do modelo do veículo';
PRINT '   - {{lista_pecas}} - Lista formatada: Nome da Peça - Código da Peça';
PRINT '';
PRINT '🔧 FONTE DOS DADOS:';
PRINT '   Tabela: AIHT_PecasIdentificadas';
PRINT '   Filtro: ConversaId';
PRINT '   Campos: NomePeca, CodigoPeca, MarcaVeiculo, ModeloVeiculo';
PRINT '';
PRINT '🚀 API: /api/gerar-cotacao';
PRINT '   Substitui automaticamente as variáveis antes de enviar para a IA';
PRINT '';
