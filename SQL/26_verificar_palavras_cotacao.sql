/*
==============================================================================
Script: 26_verificar_palavras_cotacao.sql
Descrição: Verifica e adiciona palavras-chave de cotação faltantes
Autor: Alan Alves de Oliveira
Data: 25/10/2025
Hackathon: AI Builder Hackathon 2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '🔍 Verificando palavras-chave de cotação...';
PRINT '';

-- Verificar se "cotação" existe (com e sem acento)
IF NOT EXISTS (SELECT 1 FROM AIHT_PalavrasCotacao WHERE UPPER(Palavra) = 'COTAÇÃO')
BEGIN
    INSERT INTO AIHT_PalavrasCotacao (Palavra, Tipo, Ativo, DataCriacao)
    VALUES ('cotação', 'Palavra', 1, GETDATE());
    PRINT '✅ Palavra "cotação" adicionada';
END
ELSE
BEGIN
    PRINT '✓ Palavra "cotação" já existe';
END

IF NOT EXISTS (SELECT 1 FROM AIHT_PalavrasCotacao WHERE UPPER(Palavra) = 'COTACAO')
BEGIN
    INSERT INTO AIHT_PalavrasCotacao (Palavra, Tipo, Ativo, DataCriacao)
    VALUES ('cotacao', 'Palavra', 1, GETDATE());
    PRINT '✅ Palavra "cotacao" (sem acento) adicionada';
END
ELSE
BEGIN
    PRINT '✓ Palavra "cotacao" (sem acento) já existe';
END

-- Verificar outras palavras essenciais
DECLARE @palavrasEssenciais TABLE (Palavra VARCHAR(100), Tipo VARCHAR(50));

INSERT INTO @palavrasEssenciais VALUES
('preço', 'Palavra'),
('preco', 'Palavra'),
('valor', 'Palavra'),
('quanto custa', 'Expressao'),
('quanto é', 'Expressao'),
('quanto sai', 'Expressao'),
('qual o preço', 'Expressao'),
('qual o valor', 'Expressao'),
('quero comprar', 'Expressao'),
('onde comprar', 'Expressao'),
('comprar', 'Palavra'),
('orçamento', 'Palavra'),
('orcamento', 'Palavra');

-- Inserir palavras que não existem
INSERT INTO AIHT_PalavrasCotacao (Palavra, Tipo, Ativo, DataCriacao)
SELECT p.Palavra, p.Tipo, 1, GETDATE()
FROM @palavrasEssenciais p
WHERE NOT EXISTS (
    SELECT 1 
    FROM AIHT_PalavrasCotacao pc 
    WHERE UPPER(pc.Palavra) = UPPER(p.Palavra)
);

PRINT '';
PRINT '📊 Palavras de cotação cadastradas:';
PRINT '====================================';

SELECT 
    Id,
    Palavra,
    Tipo,
    Ativo,
    DataCriacao
FROM AIHT_PalavrasCotacao
ORDER BY 
    CASE Tipo 
        WHEN 'Palavra' THEN 1 
        WHEN 'Expressao' THEN 2 
        ELSE 3 
    END,
    Palavra;

PRINT '';
PRINT '✅ Verificação concluída!';
PRINT '';
PRINT '🧪 TESTE A DETECÇÃO:';
PRINT '';
PRINT 'EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = ''Cotação'';';
PRINT 'EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = ''quanto custa?'';';
PRINT 'EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = ''quero comprar'';';
PRINT '';
