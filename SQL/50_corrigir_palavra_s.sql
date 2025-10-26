/*
==============================================================================
Script: 50_corrigir_palavra_s.sql
Descrição: Remover palavra "S" que está causando falsos positivos
Autor: Alan Alves de Oliveira
Data: 26/10/2025
Problema: "S" detecta qualquer palavra com S (está, custa, etc)
Solução: Desativar a palavra "S" ou removê-la
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '🔧 Corrigindo Problema da Palavra "S"...';
PRINT '';

-- Mostrar problema
PRINT '❌ PROBLEMA ATUAL:';
PRINT '   A palavra "S" detecta falsos positivos:';
PRINT '   - "está" contém S';
PRINT '   - "custa" contém S';
PRINT '   - "esse" contém S';
PRINT '';

-- Desativar palavra "S"
PRINT '🔧 Desativando palavra "S"...';
UPDATE AIHT_PalavrasCotacao
SET Ativo = 0
WHERE UPPER(LTRIM(RTRIM(Palavra))) = 'S';

PRINT '✅ Palavra "S" desativada!';
PRINT '';

-- Verificar
PRINT '📋 PALAVRA "S" APÓS CORREÇÃO:';
SELECT Id, Palavra, Tipo, Ativo FROM AIHT_PalavrasCotacao WHERE UPPER(Palavra) = 'S';
PRINT '';

-- Testes
PRINT '========================================';
PRINT '🧪 TESTES DE VALIDAÇÃO';
PRINT '========================================';
PRINT '';

PRINT '📝 Teste 1: "SIM" (deve detectar)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'SIM';
PRINT '';

PRINT '📝 Teste 2: "sim" (deve detectar)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'sim';
PRINT '';

PRINT '📝 Teste 3: "Meu carro está com problema" (NÃO deve detectar)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Meu carro está com problema';
PRINT '';

PRINT '📝 Teste 4: "quanto custa" (deve detectar)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'quanto custa';
PRINT '';

PRINT '📝 Teste 5: "esse carro" (NÃO deve detectar)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'esse carro';
PRINT '';

PRINT '📝 Teste 6: "cotação" (deve detectar)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'cotação';
PRINT '';

PRINT '========================================';
PRINT '✅ RESULTADOS ESPERADOS:';
PRINT '========================================';
PRINT '';
PRINT 'Testes 1, 2, 4, 6: IntencaoCotacao = 1 ✅';
PRINT 'Testes 3, 5: IntencaoCotacao = 0 ❌';
PRINT '';

PRINT '💡 SOLUÇÃO APLICADA:';
PRINT '   Palavra "S" foi desativada para evitar falsos positivos.';
PRINT '   "SIM" ainda funciona porque é uma palavra completa.';
PRINT '';

GO
