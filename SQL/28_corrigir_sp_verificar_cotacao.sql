/*
==============================================================================
Script: 28_corrigir_sp_verificar_cotacao.sql
Descrição: Corrige SP para detectar se QUALQUER palavra está na mensagem
Autor: Alan Alves de Oliveira
Data: 25/10/2025
Problema: Mensagem "Cotação S10 LTZ 2.8 Diesel 4x4 ano 2020" não detectava
Solução: Verificar se qualquer palavra da tabela está contida na mensagem
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '🔧 Corrigindo SP de Verificação de Cotação...';
GO

-- =============================================
-- SP: Verificar Intenção de Cotação (CORRIGIDA)
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
    
    -- Verificar se QUALQUER palavra-chave está presente na mensagem
    IF EXISTS (
        SELECT 1 
        FROM AIHT_PalavrasCotacao
        WHERE Ativo = 1
        AND @MensagemUpper LIKE '%' + UPPER(Palavra) + '%'
    )
    BEGIN
        SET @IntencaoCotacao = 1;
        
        -- Listar todas as palavras encontradas
        SELECT @PalavrasEncontradas = STRING_AGG(Palavra, ', ')
        FROM AIHT_PalavrasCotacao
        WHERE Ativo = 1
        AND @MensagemUpper LIKE '%' + UPPER(Palavra) + '%';
    END
    
    -- Retornar resultado
    SELECT 
        @IntencaoCotacao AS IntencaoCotacao,
        @PalavrasEncontradas AS PalavrasEncontradas;
END;
GO

PRINT '✅ AIHT_sp_VerificarIntencaoCotacao corrigida!';
PRINT '';
GO

-- =============================================
-- Testes de Validação
-- =============================================
PRINT '========================================';
PRINT '🧪 TESTES DE VALIDAÇÃO';
PRINT '========================================';
PRINT '';

-- Teste 1: Mensagem do usuário
PRINT '📝 Teste 1: "Cotação S10 LTZ 2.8 Diesel 4x4 ano 2020"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Cotação S10 LTZ 2.8 Diesel 4x4 ano 2020';
PRINT '';

-- Teste 2: Apenas a palavra
PRINT '📝 Teste 2: "Cotação"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Cotação';
PRINT '';

-- Teste 3: Palavra no meio
PRINT '📝 Teste 3: "Preciso de uma cotação urgente"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Preciso de uma cotação urgente';
PRINT '';

-- Teste 4: Maiúsculas
PRINT '📝 Teste 4: "COTAÇÃO"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'COTAÇÃO';
PRINT '';

-- Teste 5: Minúsculas
PRINT '📝 Teste 5: "cotação"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'cotação';
PRINT '';

-- Teste 6: Sem acento
PRINT '📝 Teste 6: "cotacao"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'cotacao';
PRINT '';

-- Teste 7: Expressão
PRINT '📝 Teste 7: "quanto custa essas peças?"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'quanto custa essas peças?';
PRINT '';

-- Teste 8: Preço
PRINT '📝 Teste 8: "qual o preço?"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'qual o preço?';
PRINT '';

-- Teste 9: Múltiplas palavras
PRINT '📝 Teste 9: "quero comprar, qual o valor?"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'quero comprar, qual o valor?';
PRINT '';

-- Teste 10: Sem palavra-chave (deve retornar 0)
PRINT '📝 Teste 10: "Meu freio está fazendo barulho" (NÃO deve detectar)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Meu freio está fazendo barulho';
PRINT '';

-- Teste 11: Caso real do usuário
PRINT '📝 Teste 11: "Cotação S10 LTZ 2.8 Diesel 4x4 ano 2020"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Cotação S10 LTZ 2.8 Diesel 4x4 ano 2020';
PRINT '';

PRINT '========================================';
PRINT '✅ RESULTADOS ESPERADOS:';
PRINT '========================================';
PRINT '';
PRINT 'Testes 1-9 e 11: IntencaoCotacao = 1 ✅';
PRINT 'Teste 10: IntencaoCotacao = 0 ❌';
PRINT '';
PRINT '🔍 Se "Cotação S10..." retornar 1, está CORRETO!';
PRINT '';

-- =============================================
-- Verificar palavras cadastradas
-- =============================================
PRINT '========================================';
PRINT '📋 PALAVRAS CADASTRADAS NA TABELA';
PRINT '========================================';
PRINT '';

SELECT 
    Id,
    Palavra,
    Tipo,
    Ativo,
    DataCriacao
FROM AIHT_PalavrasCotacao
WHERE Ativo = 1
ORDER BY Tipo, Palavra;

PRINT '';
PRINT '========================================';
PRINT '✅ CORREÇÃO CONCLUÍDA!';
PRINT '========================================';
PRINT '';
PRINT '💡 A SP agora verifica se QUALQUER palavra da tabela';
PRINT '   está contida na mensagem do usuário.';
PRINT '';
PRINT '🎯 Exemplo:';
PRINT '   Mensagem: "Cotação S10 LTZ 2.8 Diesel 4x4 ano 2020"';
PRINT '   Palavra na tabela: "cotação"';
PRINT '   Verificação: "COTAÇÃO S10..." LIKE "%COTAÇÃO%"';
PRINT '   Resultado: ✅ DETECTADO!';
PRINT '';
