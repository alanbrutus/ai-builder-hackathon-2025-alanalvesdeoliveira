-- =============================================
-- Script: Reprocessar ConversaId 41
-- Descrição: Verificar peças e cotações da conversa 41
-- Data: 2025-10-26
-- =============================================

USE AI_Builder_Hackthon;
GO

PRINT '========================================';
PRINT 'ANÁLISE DA CONVERSAID 41';
PRINT '========================================';
GO

-- 1. Verificar conversa
PRINT '';
PRINT '1. DADOS DA CONVERSA';
PRINT '----------------------------';

SELECT 
    Id,
    NomeCliente,
    DataInicio,
    DataUltimaInteracao,
    Ativo
FROM AIHT_Conversas
WHERE Id = 41;
GO

-- 2. Verificar peças identificadas
PRINT '';
PRINT '2. PEÇAS IDENTIFICADAS';
PRINT '----------------------------';

SELECT 
    Id,
    NomePeca,
    CategoriaPeca,
    Prioridade,
    DataIdentificacao
FROM AIHT_PecasIdentificadas
WHERE ConversaId = 41
ORDER BY Id;
GO

-- 3. Verificar cotações existentes
PRINT '';
PRINT '3. COTAÇÕES EXISTENTES';
PRINT '----------------------------';

SELECT 
    Id,
    PecaIdentificadaId,
    NomePeca,
    TipoCotacao,
    CASE 
        WHEN Preco IS NOT NULL THEN 'R$ ' + CAST(Preco AS NVARCHAR(20))
        WHEN PrecoMinimo IS NOT NULL THEN 'R$ ' + CAST(PrecoMinimo AS NVARCHAR(20)) + ' - R$ ' + CAST(PrecoMaximo AS NVARCHAR(20))
        ELSE 'Sem preço'
    END AS Preco,
    DataCotacao
FROM AIHT_CotacoesPecas
WHERE ConversaId = 41
ORDER BY DataCotacao DESC;
GO

-- 4. Verificar logs de IA
PRINT '';
PRINT '4. LOGS DE CHAMADAS IA';
PRINT '----------------------------';

SELECT 
    Id,
    TipoChamada,
    LEFT(MensagemCliente, 50) AS Mensagem,
    Sucesso,
    TempoResposta,
    DataChamada
FROM AIHT_LogChamadasIA
WHERE ConversaId = 41
ORDER BY DataChamada DESC;
GO

-- 5. Ver resposta completa da IA (última cotação)
PRINT '';
PRINT '5. ÚLTIMA RESPOSTA DA IA (COTAÇÃO)';
PRINT '----------------------------';

SELECT TOP 1
    Id,
    LEFT(RespostaRecebida, 500) AS RespostaInicio,
    LEN(RespostaRecebida) AS TamanhoResposta,
    DataChamada
FROM AIHT_LogChamadasIA
WHERE ConversaId = 41 
    AND TipoChamada = 'cotacao'
    AND Sucesso = 1
ORDER BY DataChamada DESC;
GO

-- 6. Estatísticas
PRINT '';
PRINT '6. ESTATÍSTICAS';
PRINT '----------------------------';

SELECT 
    (SELECT COUNT(*) FROM AIHT_PecasIdentificadas WHERE ConversaId = 41) AS TotalPecas,
    (SELECT COUNT(*) FROM AIHT_CotacoesPecas WHERE ConversaId = 41) AS TotalCotacoes,
    (SELECT COUNT(*) FROM AIHT_LogChamadasIA WHERE ConversaId = 41) AS TotalChamadasIA;
GO

PRINT '';
PRINT '========================================';
PRINT 'ANÁLISE CONCLUÍDA';
PRINT '========================================';
PRINT '';
PRINT 'DIAGNÓSTICO:';
PRINT '- Se TotalPecas > 0 e TotalCotacoes = 0: Parser não funcionou';
PRINT '- Solução: Reiniciar servidor Next.js para aplicar novo parser';
PRINT '- Testar: Fazer nova solicitação de cotação';
GO
