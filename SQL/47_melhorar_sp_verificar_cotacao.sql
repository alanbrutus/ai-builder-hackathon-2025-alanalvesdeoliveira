/*
==============================================================================
Script: 47_melhorar_sp_verificar_cotacao.sql
Descrição: Adiciona TRIM na SP de verificação de cotação
Autor: Alan Alves de Oliveira
Data: 26/10/2025
Melhoria: Usar TRIM para remover espaços antes e depois da mensagem
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '🔧 Melhorando SP de Verificação de Cotação...';
GO

-- =============================================
-- SP: Verificar Intenção de Cotação (MELHORADA)
-- =============================================
IF OBJECT_ID('AIHT_sp_VerificarIntencaoCotacao', 'P') IS NOT NULL
    DROP PROCEDURE AIHT_sp_VerificarIntencaoCotacao;
GO

CREATE PROCEDURE AIHT_sp_VerificarIntencaoCotacao
    @Mensagem NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Converter mensagem para maiúsculas E remover espaços
    DECLARE @MensagemUpper NVARCHAR(MAX) = UPPER(LTRIM(RTRIM(@Mensagem)));
    DECLARE @IntencaoCotacao BIT = 0;
    DECLARE @PalavrasEncontradas VARCHAR(MAX) = '';
    
    -- Verificar se QUALQUER palavra-chave está presente na mensagem
    IF EXISTS (
        SELECT 1 
        FROM AIHT_PalavrasCotacao
        WHERE Ativo = 1
        AND @MensagemUpper LIKE '%' + UPPER(LTRIM(RTRIM(Palavra))) + '%'
    )
    BEGIN
        SET @IntencaoCotacao = 1;
        
        -- Listar todas as palavras encontradas
        SELECT @PalavrasEncontradas = STRING_AGG(Palavra, ', ')
        FROM AIHT_PalavrasCotacao
        WHERE Ativo = 1
        AND @MensagemUpper LIKE '%' + UPPER(LTRIM(RTRIM(Palavra))) + '%';
    END
    
    -- Retornar resultado
    SELECT 
        @IntencaoCotacao AS IntencaoCotacao,
        @PalavrasEncontradas AS PalavrasEncontradas;
END;
GO

PRINT '✅ AIHT_sp_VerificarIntencaoCotacao melhorada!';
PRINT '';
GO

-- =============================================
-- Testes de Validação
-- =============================================
PRINT '========================================';
PRINT '🧪 TESTES DE VALIDAÇÃO';
PRINT '========================================';
PRINT '';

-- Teste 1: Com espaços antes
PRINT '📝 Teste 1: "  Sim  " (com espaços)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = '  Sim  ';
PRINT '';

-- Teste 2: Com espaços depois
PRINT '📝 Teste 2: "Sim   " (espaços no final)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Sim   ';
PRINT '';

-- Teste 3: Sem espaços
PRINT '📝 Teste 3: "Sim" (sem espaços)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Sim';
PRINT '';

-- Teste 4: Minúscula com espaços
PRINT '📝 Teste 4: "  sim  " (minúscula com espaços)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = '  sim  ';
PRINT '';

-- Teste 5: S com espaços
PRINT '📝 Teste 5: " S " (S com espaços)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = ' S ';
PRINT '';

-- Teste 6: Cotação com espaços
PRINT '📝 Teste 6: "  Cotação  " (com espaços)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = '  Cotação  ';
PRINT '';

-- Teste 7: Frase com espaços extras
PRINT '📝 Teste 7: "  Sim, quero a cotação  "';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = '  Sim, quero a cotação  ';
PRINT '';

PRINT '========================================';
PRINT '✅ TODOS OS TESTES DEVEM RETORNAR 1';
PRINT '========================================';
PRINT '';

PRINT '💡 MELHORIAS APLICADAS:';
PRINT '   1. LTRIM(RTRIM(@Mensagem)) - Remove espaços da mensagem';
PRINT '   2. LTRIM(RTRIM(Palavra)) - Remove espaços das palavras';
PRINT '   3. UPPER em ambos - Garante case-insensitive';
PRINT '';
PRINT '🎯 Agora funciona com:';
PRINT '   - "Sim" ✅';
PRINT '   - "  Sim  " ✅';
PRINT '   - "SIM" ✅';
PRINT '   - " sim " ✅';
PRINT '';

GO
