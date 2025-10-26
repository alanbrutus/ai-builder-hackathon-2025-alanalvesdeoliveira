/*
==============================================================================
Script: 46_adicionar_palavras_confirmacao.sql
Descrição: Adiciona palavras de confirmação para detectar intenção de cotação
Autor: Alan Alves de Oliveira
Data: 26/10/2025
Problema: Usuário responde "Sim" mas sistema não detecta intenção de cotação
Solução: Adicionar palavras de confirmação (sim, s, quero, ok, etc)
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '🔧 Adicionando Palavras de Confirmação...';
PRINT '';

-- Adicionar palavras de confirmação
INSERT INTO AIHT_PalavrasCotacao (Palavra, Tipo, Ativo)
SELECT 'sim', 'confirmacao', 1
WHERE NOT EXISTS (SELECT 1 FROM AIHT_PalavrasCotacao WHERE UPPER(Palavra) = 'SIM');

INSERT INTO AIHT_PalavrasCotacao (Palavra, Tipo, Ativo)
SELECT 's', 'confirmacao', 1
WHERE NOT EXISTS (SELECT 1 FROM AIHT_PalavrasCotacao WHERE UPPER(Palavra) = 'S');

INSERT INTO AIHT_PalavrasCotacao (Palavra, Tipo, Ativo)
SELECT 'quero', 'confirmacao', 1
WHERE NOT EXISTS (SELECT 1 FROM AIHT_PalavrasCotacao WHERE UPPER(Palavra) = 'QUERO');

INSERT INTO AIHT_PalavrasCotacao (Palavra, Tipo, Ativo)
SELECT 'ok', 'confirmacao', 1
WHERE NOT EXISTS (SELECT 1 FROM AIHT_PalavrasCotacao WHERE UPPER(Palavra) = 'OK');

INSERT INTO AIHT_PalavrasCotacao (Palavra, Tipo, Ativo)
SELECT 'okay', 'confirmacao', 1
WHERE NOT EXISTS (SELECT 1 FROM AIHT_PalavrasCotacao WHERE UPPER(Palavra) = 'OKAY');

INSERT INTO AIHT_PalavrasCotacao (Palavra, Tipo, Ativo)
SELECT 'confirmo', 'confirmacao', 1
WHERE NOT EXISTS (SELECT 1 FROM AIHT_PalavrasCotacao WHERE UPPER(Palavra) = 'CONFIRMO');

INSERT INTO AIHT_PalavrasCotacao (Palavra, Tipo, Ativo)
SELECT 'aceito', 'confirmacao', 1
WHERE NOT EXISTS (SELECT 1 FROM AIHT_PalavrasCotacao WHERE UPPER(Palavra) = 'ACEITO');

INSERT INTO AIHT_PalavrasCotacao (Palavra, Tipo, Ativo)
SELECT 'pode', 'confirmacao', 1
WHERE NOT EXISTS (SELECT 1 FROM AIHT_PalavrasCotacao WHERE UPPER(Palavra) = 'PODE');

INSERT INTO AIHT_PalavrasCotacao (Palavra, Tipo, Ativo)
SELECT 'vamos', 'confirmacao', 1
WHERE NOT EXISTS (SELECT 1 FROM AIHT_PalavrasCotacao WHERE UPPER(Palavra) = 'VAMOS');

INSERT INTO AIHT_PalavrasCotacao (Palavra, Tipo, Ativo)
SELECT 'claro', 'confirmacao', 1
WHERE NOT EXISTS (SELECT 1 FROM AIHT_PalavrasCotacao WHERE UPPER(Palavra) = 'CLARO');

PRINT '✅ Palavras de confirmação adicionadas!';
PRINT '';

-- Verificar palavras cadastradas
PRINT '========================================';
PRINT '📋 PALAVRAS CADASTRADAS (TODAS)';
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
PRINT '🧪 TESTES DE VALIDAÇÃO';
PRINT '========================================';
PRINT '';

-- Teste 1: Sim
PRINT '📝 Teste 1: "Sim"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Sim';
PRINT '';

-- Teste 2: sim (minúscula)
PRINT '📝 Teste 2: "sim"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'sim';
PRINT '';

-- Teste 3: S
PRINT '📝 Teste 3: "S"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'S';
PRINT '';

-- Teste 4: Quero
PRINT '📝 Teste 4: "Quero"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Quero';
PRINT '';

-- Teste 5: Ok
PRINT '📝 Teste 5: "Ok"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Ok';
PRINT '';

-- Teste 6: Frase com sim
PRINT '📝 Teste 6: "Sim, quero a cotação"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Sim, quero a cotação';
PRINT '';

-- Teste 7: Pode ser
PRINT '📝 Teste 7: "Pode ser"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Pode ser';
PRINT '';

-- Teste 8: Claro
PRINT '📝 Teste 8: "Claro!"';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'Claro!';
PRINT '';

PRINT '========================================';
PRINT '✅ TODOS OS TESTES DEVEM RETORNAR 1';
PRINT '========================================';
PRINT '';

PRINT '💡 IMPORTANTE:';
PRINT '   Agora o sistema detecta confirmações simples como:';
PRINT '   - "Sim"';
PRINT '   - "S"';
PRINT '   - "Quero"';
PRINT '   - "Ok"';
PRINT '   - "Pode"';
PRINT '   - "Claro"';
PRINT '   E outras variações de confirmação!';
PRINT '';

GO
