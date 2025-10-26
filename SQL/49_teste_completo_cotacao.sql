/*
==============================================================================
Script: 49_teste_completo_cotacao.sql
Descrição: Teste completo do sistema de detecção de cotação
Autor: Alan Alves de Oliveira
Data: 26/10/2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT 'TESTE COMPLETO DO SISTEMA DE COTAÇÃO';
PRINT '========================================';
PRINT '';

-- 1. Verificar se a SP existe
PRINT '1. VERIFICAR SE A SP EXISTE:';
IF OBJECT_ID('AIHT_sp_VerificarIntencaoCotacao', 'P') IS NOT NULL
    PRINT '   ✅ SP AIHT_sp_VerificarIntencaoCotacao existe'
ELSE
    PRINT '   ❌ SP AIHT_sp_VerificarIntencaoCotacao NÃO existe'
PRINT '';

-- 2. Verificar palavras na tabela
PRINT '2. PALAVRAS NA TABELA (Ativas):';
SELECT COUNT(*) AS TotalPalavras FROM AIHT_PalavrasCotacao WHERE Ativo = 1;
PRINT '';

-- 3. Mostrar algumas palavras
PRINT '3. PRIMEIRAS 10 PALAVRAS:';
SELECT TOP 10 Id, Palavra, Tipo FROM AIHT_PalavrasCotacao WHERE Ativo = 1 ORDER BY Id;
PRINT '';

-- 4. Testar SP diretamente
PRINT '========================================';
PRINT 'TESTES DA STORED PROCEDURE';
PRINT '========================================';
PRINT '';

PRINT '📝 Teste 1: "SIM"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'SIM';
PRINT '';

PRINT '📝 Teste 2: "sim"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'sim';
PRINT '';

PRINT '📝 Teste 3: "cotação"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'cotação';
PRINT '';

PRINT '📝 Teste 4: "cotacao"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'cotacao';
PRINT '';

PRINT '📝 Teste 5: "quero cotação"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'quero cotação';
PRINT '';

PRINT '📝 Teste 6: "quanto custa"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'quanto custa';
PRINT '';

PRINT '📝 Teste 7: "preço"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'preço';
PRINT '';

PRINT '📝 Teste 8: "valor"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'valor';
PRINT '';

PRINT '📝 Teste 9: "ok"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'ok';
PRINT '';

PRINT '📝 Teste 10: "pode"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'pode';
PRINT '';

-- 5. Teste com mensagem que NÃO deve detectar
PRINT '📝 Teste 11: "Meu carro está com problema" (NÃO deve detectar)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Meu carro está com problema';
PRINT '';

-- 6. Ver código da SP
PRINT '========================================';
PRINT 'CÓDIGO DA STORED PROCEDURE';
PRINT '========================================';
PRINT '';

SELECT OBJECT_DEFINITION(OBJECT_ID('AIHT_sp_VerificarIntencaoCotacao')) AS CodigoSP;

PRINT '';
PRINT '========================================';
PRINT 'FIM DOS TESTES';
PRINT '========================================';

GO
