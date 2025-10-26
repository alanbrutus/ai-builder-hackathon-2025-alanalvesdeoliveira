-- Verificar peças da conversa 53
USE AI_Builder_Hackthon;
GO

PRINT 'Verificando peças da conversa 53...';
PRINT '';

SELECT 
    Id,
    ConversaId,
    NomePeca,
    CodigoPeca,
    DataIdentificacao
FROM AIHT_PecasIdentificadas
WHERE ConversaId = 53;

PRINT '';
PRINT 'Total de peças:';
SELECT COUNT(*) AS TotalPecas FROM AIHT_PecasIdentificadas WHERE ConversaId = 53;

GO
