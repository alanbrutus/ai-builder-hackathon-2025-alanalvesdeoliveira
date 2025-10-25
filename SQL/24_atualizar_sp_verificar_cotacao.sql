-- =============================================
-- Script: Atualizar SP Verificar Cotação (Case-Insensitive)
-- Descrição: Usa UPPER para comparação sem case sensitivity
-- =============================================

USE AI_Builder_Hackthon;
GO

-- =============================================
-- SP: Verificar Intenção de Cotação (ATUALIZADA)
-- =============================================
IF OBJECT_ID('AIHT_sp_VerificarIntencaoCotacao', 'P') IS NOT NULL
    DROP PROCEDURE AIHT_sp_VerificarIntencaoCotacao;
GO

CREATE PROCEDURE AIHT_sp_VerificarIntencaoCotacao
    @Mensagem NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Converter mensagem para maiúsculas
    DECLARE @MensagemUpper NVARCHAR(MAX) = UPPER(@Mensagem);
    DECLARE @IntencaoCotacao BIT = 0;
    DECLARE @PalavrasEncontradas VARCHAR(MAX) = '';
    
    -- Verificar se alguma palavra-chave está presente (case-insensitive)
    SELECT 
        @IntencaoCotacao = 1,
        @PalavrasEncontradas = STRING_AGG(Palavra, ', ')
    FROM AIHT_PalavrasCotacao
    WHERE Ativo = 1
    AND @MensagemUpper LIKE '%' + UPPER(Palavra) + '%';
    
    SELECT 
        @IntencaoCotacao AS IntencaoCotacao,
        @PalavrasEncontradas AS PalavrasEncontradas;
END;
GO

PRINT '✓ AIHT_sp_VerificarIntencaoCotacao atualizada (case-insensitive)';
GO

-- =============================================
-- Testes Completos
-- =============================================
PRINT '';
PRINT '========================================';
PRINT 'Testando Detecção Case-Insensitive...';
PRINT '========================================';
GO

-- Teste 1: Minúsculas
PRINT '';
PRINT 'Teste 1: "quanto custa essas peças?" (minúsculas)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'quanto custa essas peças?';
GO

-- Teste 2: Maiúsculas
PRINT '';
PRINT 'Teste 2: "QUANTO CUSTA ESSAS PEÇAS?" (MAIÚSCULAS)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'QUANTO CUSTA ESSAS PEÇAS?';
GO

-- Teste 3: Misto
PRINT '';
PRINT 'Teste 3: "QuAnTo CuStA essas PeÇaS?" (misto)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'QuAnTo CuStA essas PeÇaS?';
GO

-- Teste 4: Com acentuação
PRINT '';
PRINT 'Teste 4: "Qual o PREÇO?" (com acentuação)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Qual o PREÇO?';
GO

-- Teste 5: Múltiplas palavras
PRINT '';
PRINT 'Teste 5: "QUERO COMPRAR, qual o VALOR?" (múltiplas)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'QUERO COMPRAR, qual o VALOR?';
GO

-- Teste 6: Sem intenção
PRINT '';
PRINT 'Teste 6: "Obrigado pela AJUDA" (sem intenção)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Obrigado pela AJUDA';
GO

-- Teste 7: Palavra parcial
PRINT '';
PRINT 'Teste 7: "cotação" vs "COTACAO" (com e sem acento)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Preciso de uma cotação';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Preciso de uma COTACAO';
GO

PRINT '';
PRINT '========================================';
PRINT 'Todos os testes devem detectar corretamente!';
PRINT '========================================';
GO

-- =============================================
-- Verificar palavras cadastradas
-- =============================================
PRINT '';
PRINT 'Palavras-chave cadastradas (case será ignorado):';
SELECT 
    Id,
    Palavra,
    UPPER(Palavra) AS PalavraUpper,
    Tipo,
    Ativo
FROM AIHT_PalavrasCotacao
WHERE Ativo = 1
ORDER BY Tipo, Palavra;
GO
