/*
==============================================================================
Script: 27_teste_upper_cotacao.sql
Descrição: Testa validação com UPPER() na detecção de cotação
Autor: Alan Alves de Oliveira
Data: 25/10/2025
Hackathon: AI Builder Hackathon 2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT '🧪 TESTES DE VALIDAÇÃO COM UPPER()';
PRINT '========================================';
PRINT '';

-- =============================================
-- Teste 1: Palavra "Cotação" em diferentes cases
-- =============================================
PRINT '📝 Teste 1: Palavra "Cotação" em diferentes cases';
PRINT '------------------------------------------------';

PRINT 'Teste 1.1: "Cotação" (primeira maiúscula)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Cotação';

PRINT '';
PRINT 'Teste 1.2: "cotação" (tudo minúsculo)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'cotação';

PRINT '';
PRINT 'Teste 1.3: "COTAÇÃO" (tudo maiúsculo)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'COTAÇÃO';

PRINT '';
PRINT 'Teste 1.4: "CoTaÇãO" (misto)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'CoTaÇãO';

PRINT '';
PRINT 'Teste 1.5: "Preciso de uma COTAÇÃO"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Preciso de uma COTAÇÃO';

-- =============================================
-- Teste 2: Palavra "cotacao" (sem acento)
-- =============================================
PRINT '';
PRINT '📝 Teste 2: Palavra "cotacao" (sem acento)';
PRINT '------------------------------------------------';

PRINT 'Teste 2.1: "cotacao" (tudo minúsculo)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'cotacao';

PRINT '';
PRINT 'Teste 2.2: "COTACAO" (tudo maiúsculo)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'COTACAO';

PRINT '';
PRINT 'Teste 2.3: "Cotacao" (primeira maiúscula)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Cotacao';

-- =============================================
-- Teste 3: Expressões
-- =============================================
PRINT '';
PRINT '📝 Teste 3: Expressões';
PRINT '------------------------------------------------';

PRINT 'Teste 3.1: "quanto custa" (minúsculo)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'quanto custa essas peças?';

PRINT '';
PRINT 'Teste 3.2: "QUANTO CUSTA" (maiúsculo)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'QUANTO CUSTA ESSAS PEÇAS?';

PRINT '';
PRINT 'Teste 3.3: "Quanto Custa" (title case)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Quanto Custa Essas Peças?';

PRINT '';
PRINT 'Teste 3.4: "QuAnTo CuStA" (misto)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'QuAnTo CuStA essas peças?';

-- =============================================
-- Teste 4: Palavras com acentuação
-- =============================================
PRINT '';
PRINT '📝 Teste 4: Palavras com acentuação';
PRINT '------------------------------------------------';

PRINT 'Teste 4.1: "preço" (minúsculo)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'qual o preço?';

PRINT '';
PRINT 'Teste 4.2: "PREÇO" (maiúsculo)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'qual o PREÇO?';

PRINT '';
PRINT 'Teste 4.3: "Preço" (primeira maiúscula)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'qual o Preço?';

PRINT '';
PRINT 'Teste 4.4: "preco" (sem acento, minúsculo)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'qual o preco?';

PRINT '';
PRINT 'Teste 4.5: "PRECO" (sem acento, maiúsculo)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'qual o PRECO?';

-- =============================================
-- Teste 5: Múltiplas palavras
-- =============================================
PRINT '';
PRINT '📝 Teste 5: Múltiplas palavras-chave';
PRINT '------------------------------------------------';

PRINT 'Teste 5.1: "QUERO COMPRAR, qual o VALOR?"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'QUERO COMPRAR, qual o VALOR?';

PRINT '';
PRINT 'Teste 5.2: "quero comprar, qual o valor?"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'quero comprar, qual o valor?';

PRINT '';
PRINT 'Teste 5.3: "Quero Comprar, Qual O Valor?"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Quero Comprar, Qual O Valor?';

-- =============================================
-- Teste 6: Casos negativos (não deve detectar)
-- =============================================
PRINT '';
PRINT '📝 Teste 6: Casos negativos (NÃO deve detectar)';
PRINT '------------------------------------------------';

PRINT 'Teste 6.1: "Obrigado pela ajuda"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Obrigado pela ajuda';

PRINT '';
PRINT 'Teste 6.2: "OBRIGADO PELA AJUDA"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'OBRIGADO PELA AJUDA';

PRINT '';
PRINT 'Teste 6.3: "Meu freio está fazendo barulho"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Meu freio está fazendo barulho';

PRINT '';
PRINT 'Teste 6.4: "MEU FREIO ESTÁ FAZENDO BARULHO"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'MEU FREIO ESTÁ FAZENDO BARULHO';

-- =============================================
-- Teste 7: Casos especiais
-- =============================================
PRINT '';
PRINT '📝 Teste 7: Casos especiais';
PRINT '------------------------------------------------';

PRINT 'Teste 7.1: Apenas "Cotação"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Cotação';

PRINT '';
PRINT 'Teste 7.2: Apenas "COTAÇÃO"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'COTAÇÃO';

PRINT '';
PRINT 'Teste 7.3: "   cotação   " (com espaços)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = '   cotação   ';

PRINT '';
PRINT 'Teste 7.4: "Cotação!" (com pontuação)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Cotação!';

PRINT '';
PRINT 'Teste 7.5: "Cotação?" (com interrogação)';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Cotação?';

-- =============================================
-- Resumo
-- =============================================
PRINT '';
PRINT '========================================';
PRINT '✅ RESUMO DOS TESTES';
PRINT '========================================';
PRINT '';
PRINT '📊 Resultados Esperados:';
PRINT '';
PRINT '✅ Testes 1.1 a 1.5: TODOS devem detectar "cotação"';
PRINT '✅ Testes 2.1 a 2.3: TODOS devem detectar "cotacao"';
PRINT '✅ Testes 3.1 a 3.4: TODOS devem detectar "quanto custa"';
PRINT '✅ Testes 4.1 a 4.5: TODOS devem detectar "preço" ou "preco"';
PRINT '✅ Testes 5.1 a 5.3: TODOS devem detectar múltiplas palavras';
PRINT '❌ Testes 6.1 a 6.4: NENHUM deve detectar (sem palavras-chave)';
PRINT '✅ Testes 7.1 a 7.5: TODOS devem detectar "cotação"';
PRINT '';
PRINT '🔍 Validação: A SP usa UPPER() para comparação case-insensitive';
PRINT '';

-- =============================================
-- Verificar implementação da SP
-- =============================================
PRINT '';
PRINT '========================================';
PRINT '🔧 VERIFICANDO IMPLEMENTAÇÃO DA SP';
PRINT '========================================';
PRINT '';

-- Mostrar definição da SP
SELECT 
    OBJECT_NAME(object_id) AS StoredProcedure,
    CASE 
        WHEN OBJECT_DEFINITION(object_id) LIKE '%UPPER(@Mensagem)%' 
        THEN '✅ USA UPPER() na mensagem'
        ELSE '❌ NÃO USA UPPER() na mensagem'
    END AS ValidacaoMensagem,
    CASE 
        WHEN OBJECT_DEFINITION(object_id) LIKE '%UPPER(Palavra)%' 
        THEN '✅ USA UPPER() na palavra'
        ELSE '❌ NÃO USA UPPER() na palavra'
    END AS ValidacaoPalavra
FROM sys.objects
WHERE name = 'AIHT_sp_VerificarIntencaoCotacao'
AND type = 'P';

PRINT '';
PRINT '========================================';
PRINT '✅ TESTES CONCLUÍDOS!';
PRINT '========================================';
PRINT '';
PRINT '💡 DICA: Se algum teste falhar, execute:';
PRINT '   SQL/24_atualizar_sp_verificar_cotacao.sql';
PRINT '';
