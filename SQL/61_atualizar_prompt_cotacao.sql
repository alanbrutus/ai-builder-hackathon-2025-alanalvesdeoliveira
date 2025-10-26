/*
==============================================================================
Script: 61_atualizar_prompt_cotacao.sql
Descrição: Atualizar prompt de cotação para formato compatível com parser
Autor: Alan Alves de Oliveira
Data: 26/10/2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '🔧 Atualizando Prompt de Cotação...';
PRINT '';

-- Atualizar prompt de cotação
UPDATE AIHT_Prompts
SET ConteudoPrompt = N'Preciso que realize um processo de cotação para o {{fabricante_veiculo}} {{modelo_veiculo}} em e-Commerce e lojas presenciais para as peças relacionadas abaixo:

-- Início Peças
{{lista_pecas}}
-- Fim Peças

**IMPORTANTE: SIGA EXATAMENTE ESTE FORMATO DE RESPOSTA:**

Para cada peça, crie uma seção começando com "### " seguido do número e nome da peça.

### 1. [Nome da Primeira Peça]

?? **Tipo:** e-Commerce
?? **Link:** [URL completa do produto]
?? **Preço:** R$ [valor] ou R$ [mínimo] - R$ [máximo]
?? **Condições de Pagamento:** [formas de pagamento]
? **Observações:** [disponibilidade, prazo de entrega, se é original/paralela/genérica]

?? **Tipo:** Loja Física
?? **Endereço:** [Endereço completo da loja]
?? **Preço:** R$ [valor] ou R$ [mínimo] - R$ [máximo]
?? **Condições de Pagamento:** [formas de pagamento]
? **Observações:** [disponibilidade, horário de funcionamento]

### 2. [Nome da Segunda Peça]

?? **Tipo:** e-Commerce
?? **Link:** [URL completa do produto]
?? **Preço:** R$ [valor] ou R$ [mínimo] - R$ [máximo]
?? **Condições de Pagamento:** [formas de pagamento]
? **Observações:** [disponibilidade, prazo de entrega]

---

**REGRAS OBRIGATÓRIAS:**
1. SEMPRE comece cada peça com "### " + número + ". " + nome da peça
2. Use "??" para campos obrigatórios (Tipo, Link/Endereço, Preço, Condições)
3. Use "?" para observações
4. Para e-Commerce, pesquise em: Mercado Livre, OLX, Shopee, Amazon
5. Para Lojas Físicas, indique endereços reais na região
6. Forneça faixas de preço realistas (R$ mínimo - R$ máximo)
7. Indique se a peça é original, paralela ou genérica
8. Mencione prazos de entrega estimados
9. Sugira as melhores opções custo-benefício

**EXEMPLO DE FORMATO CORRETO:**

### 1. Filtro de Óleo

?? **Tipo:** e-Commerce
?? **Link:** https://www.mercadolivre.com.br/filtro-oleo-exemplo
?? **Preço:** R$ 25,00 - R$ 45,00
?? **Condições de Pagamento:** Cartão, PIX, Boleto
? **Observações:** Original Tecfil, entrega em 3-5 dias úteis

?? **Tipo:** Loja Física
?? **Endereço:** Auto Peças Central - Rua Exemplo, 123, Centro
?? **Preço:** R$ 30,00 - R$ 50,00
?? **Condições de Pagamento:** Dinheiro, Cartão, PIX
? **Observações:** Disponível em estoque, aberto de seg-sex 8h-18h',
    DataAtualizacao = GETDATE()
WHERE Contexto = 'cotacao';

PRINT '✅ Prompt de cotação atualizado!';
PRINT '';

-- Verificar atualização
PRINT 'Verificando prompt atualizado:';
SELECT 
    Id,
    Contexto,
    Nome,
    LEN(ConteudoPrompt) AS TamanhoCaracteres,
    DataAtualizacao
FROM AIHT_Prompts
WHERE Contexto = 'cotacao';

PRINT '';
PRINT '========================================';
PRINT '✅ PROMPT ATUALIZADO COM SUCESSO!';
PRINT '========================================';
PRINT '';
PRINT 'Formato agora compatível com o parser:';
PRINT '  - Seções de peça: ### 1. Nome da Peça';
PRINT '  - Campos obrigatórios: ?? **Campo:**';
PRINT '  - Observações: ? **Observações:**';
PRINT '';

GO
