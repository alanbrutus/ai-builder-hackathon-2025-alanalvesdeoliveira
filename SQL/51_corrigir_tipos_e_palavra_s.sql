/*
==============================================================================
Script: 51_corrigir_tipos_e_palavra_s.sql
Descrição: Corrigir tipos e desativar palavra "S"
Autor: Alan Alves de Oliveira
Data: 26/10/2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '🔧 Corrigindo Tipos e Palavra S...';
PRINT '';

-- 1. Mostrar problema atual
PRINT '❌ PROBLEMA: Palavra "S" causa falsos positivos';
PRINT '   - "está" → detecta S';
PRINT '   - "custa" → detecta S';
PRINT '';

-- 2. Desativar palavra "S"
PRINT '🔧 Desativando palavra "S"...';
UPDATE AIHT_PalavrasCotacao
SET Ativo = 0
WHERE UPPER(LTRIM(RTRIM(Palavra))) = 'S';

DECLARE @LinhasAfetadas INT = @@ROWCOUNT;
PRINT '   ✅ ' + CAST(@LinhasAfetadas AS VARCHAR) + ' linha(s) desativada(s)';
PRINT '';

-- 3. Corrigir tipos das palavras de confirmação (se necessário)
PRINT '🔧 Padronizando tipo "Confirmacao"...';
UPDATE AIHT_PalavrasCotacao
SET Tipo = 'Confirmacao'
WHERE Palavra IN ('SIM', 'QUERO', 'OK', 'OKAY', 'CONFIRMO', 'ACEITO', 'PODE', 'VAMOS', 'CLARO')
AND Ativo = 1;

SET @LinhasAfetadas = @@ROWCOUNT;
PRINT '   ✅ ' + CAST(@LinhasAfetadas AS VARCHAR) + ' linha(s) atualizada(s)';
PRINT '';

-- 4. Verificar palavras ativas
PRINT '📋 PALAVRAS ATIVAS POR TIPO:';
SELECT 
    Tipo,
    COUNT(*) AS Quantidade
FROM AIHT_PalavrasCotacao
WHERE Ativo = 1
GROUP BY Tipo
ORDER BY Tipo;
PRINT '';

-- 5. Mostrar palavra "S"
PRINT '📋 STATUS DA PALAVRA "S":';
SELECT Id, Palavra, Tipo, Ativo FROM AIHT_PalavrasCotacao WHERE UPPER(Palavra) = 'S';
PRINT '';

-- 6. Testes
PRINT '========================================';
PRINT '🧪 TESTES DE VALIDAÇÃO';
PRINT '========================================';
PRINT '';

PRINT '📝 Teste 1: "SIM" (deve detectar)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'SIM';
PRINT '';

PRINT '📝 Teste 2: "Meu carro está com problema" (NÃO deve detectar)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Meu carro está com problema';
PRINT '';

PRINT '📝 Teste 3: "quanto custa" (deve detectar)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'quanto custa';
PRINT '';

PRINT '📝 Teste 4: "esse carro" (NÃO deve detectar)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'esse carro';
PRINT '';

PRINT '📝 Teste 5: "cotacao" (deve detectar)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'cotacao';
PRINT '';

PRINT '📝 Teste 6: "ok" (deve detectar)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'ok';
PRINT '';

PRINT '========================================';
PRINT '✅ RESULTADOS ESPERADOS:';
PRINT '========================================';
PRINT '';
PRINT 'Testes 1, 3, 5, 6: IntencaoCotacao = 1 ✅';
PRINT 'Testes 2, 4: IntencaoCotacao = 0 ❌';
PRINT '';

PRINT '💡 CORREÇÕES APLICADAS:';
PRINT '   1. Palavra "S" desativada (evita falsos positivos)';
PRINT '   2. Tipo padronizado para "Confirmacao"';
PRINT '   3. "SIM" continua funcionando normalmente';
PRINT '';

GO
