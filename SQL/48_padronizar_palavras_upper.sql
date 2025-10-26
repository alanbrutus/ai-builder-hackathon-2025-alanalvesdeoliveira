/*
==============================================================================
Script: 48_padronizar_palavras_upper.sql
Descrição: Padronizar todas as palavras para UPPER na tabela
Autor: Alan Alves de Oliveira
Data: 26/10/2025
Objetivo: Garantir que todas as palavras estejam em maiúsculas
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '🔧 Padronizando Palavras para UPPER...';
PRINT '';

-- Mostrar palavras antes
PRINT '📋 PALAVRAS ANTES DA PADRONIZAÇÃO:';
SELECT Id, Palavra, Tipo FROM AIHT_PalavrasCotacao WHERE Ativo = 1 ORDER BY Id;
PRINT '';

-- Atualizar todas as palavras para UPPER
UPDATE AIHT_PalavrasCotacao
SET Palavra = UPPER(LTRIM(RTRIM(Palavra)))
WHERE Ativo = 1;

PRINT '✅ Palavras atualizadas para UPPER!';
PRINT '';

-- Mostrar palavras depois
PRINT '📋 PALAVRAS DEPOIS DA PADRONIZAÇÃO:';
SELECT Id, Palavra, Tipo FROM AIHT_PalavrasCotacao WHERE Ativo = 1 ORDER BY Id;
PRINT '';

-- Verificar duplicatas
PRINT '🔍 VERIFICANDO DUPLICATAS:';
SELECT 
    Palavra, 
    COUNT(*) AS Quantidade
FROM AIHT_PalavrasCotacao
WHERE Ativo = 1
GROUP BY Palavra
HAVING COUNT(*) > 1;

PRINT '';
PRINT '========================================';
PRINT '✅ PADRONIZAÇÃO CONCLUÍDA!';
PRINT '========================================';
PRINT '';

-- Testes
PRINT '🧪 TESTES DE VALIDAÇÃO:';
PRINT '';

PRINT '📝 Teste 1: "SIM"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'SIM';
PRINT '';

PRINT '📝 Teste 2: "sim"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'sim';
PRINT '';

PRINT '📝 Teste 3: "Sim"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Sim';
PRINT '';

PRINT '📝 Teste 4: "COTAÇÃO"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'COTAÇÃO';
PRINT '';

PRINT '📝 Teste 5: "cotacao"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'cotacao';
PRINT '';

PRINT '========================================';
PRINT '✅ TODOS OS TESTES DEVEM RETORNAR 1';
PRINT '========================================';
PRINT '';

GO
