/*
==============================================================================
Script: 58_debug_conversa_54.sql
Descrição: Debug completo da conversa 54
Autor: Alan Alves de Oliveira
Data: 26/10/2025
==============================================================================
*/

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT 'DEBUG CONVERSA 54';
PRINT '========================================';
PRINT '';

-- 1. Informações da conversa
PRINT '1. INFORMAÇÕES DA CONVERSA:';
SELECT * FROM AIHT_Conversas WHERE Id = 54;
PRINT '';

-- 2. Peças identificadas
PRINT '2. PEÇAS IDENTIFICADAS:';
SELECT * FROM AIHT_PecasIdentificadas WHERE ConversaId = 54;
PRINT '';

-- 3. Logs de chamadas IA
PRINT '3. LOGS DE CHAMADAS IA:';
SELECT 
    Id,
    TipoChamada,
    MensagemCliente,
    Sucesso,
    DataChamada
FROM AIHT_LogChamadasIA
WHERE ConversaId = 54
ORDER BY DataChamada;
PRINT '';

-- 4. Testar palavra "QUERO"
PRINT '4. TESTAR PALAVRA "QUERO":';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'QUERO';
PRINT '';

PRINT '5. TESTAR "quero" (minúscula):';
EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = 'quero';
PRINT '';

-- 6. Verificar se palavra QUERO está ativa
PRINT '6. PALAVRA "QUERO" NA TABELA:';
SELECT * FROM AIHT_PalavrasCotacao WHERE UPPER(Palavra) = 'QUERO';
PRINT '';

-- 7. Buscar última mensagem do cliente
PRINT '7. ÚLTIMA MENSAGEM DO CLIENTE:';
DECLARE @UltimaMensagem NVARCHAR(MAX);
SELECT TOP 1 @UltimaMensagem = MensagemCliente 
FROM AIHT_LogChamadasIA 
WHERE ConversaId = 54 
ORDER BY DataChamada DESC;

PRINT 'Mensagem: "' + ISNULL(@UltimaMensagem, 'NULL') + '"';
PRINT 'Tamanho: ' + CAST(LEN(@UltimaMensagem) AS VARCHAR) + ' caracteres';
PRINT '';

IF @UltimaMensagem IS NOT NULL
BEGIN
    PRINT 'Testando detecção:';
    EXEC AIHT_sp_VerificarIntencaoCotacao @Mensagem = @UltimaMensagem;
END
PRINT '';

-- 8. Testar SP de listar peças
PRINT '8. TESTAR SP LISTAR PEÇAS:';
EXEC AIHT_sp_ListarPecasParaCotacao @ConversaId = 54;
PRINT '';

-- 9. Verificar total de palavras ativas
PRINT '9. TOTAL DE PALAVRAS ATIVAS:';
SELECT COUNT(*) AS Total FROM AIHT_PalavrasCotacao WHERE Ativo = 1;
PRINT '';

-- 10. Verificar se palavra S está ativa
PRINT '10. PALAVRA "S" (deve estar desativada):';
SELECT * FROM AIHT_PalavrasCotacao WHERE UPPER(Palavra) = 'S';
PRINT '';

PRINT '========================================';
PRINT 'FIM DO DEBUG';
PRINT '========================================';

GO
