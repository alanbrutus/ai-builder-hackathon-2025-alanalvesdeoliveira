-- =============================================
-- Script: Conceder Permissões ao Usuário AI_Hackthon
-- Descrição: Concede permissões de EXECUTE em todas as stored procedures
-- =============================================

USE AI_Builder_Hackthon;
GO

-- Conceder permissão de EXECUTE em todas as stored procedures do schema dbo
GRANT EXECUTE ON SCHEMA::dbo TO AI_Hackthon;
GO

-- Conceder permissões específicas nas stored procedures
GRANT EXECUTE ON dbo.AIHT_sp_ListarGruposEmpresariais TO AI_Hackthon;
GRANT EXECUTE ON dbo.AIHT_sp_ListarFabricantesPorGrupo TO AI_Hackthon;
GRANT EXECUTE ON dbo.AIHT_sp_ListarModelosPorFabricante TO AI_Hackthon;
GRANT EXECUTE ON dbo.AIHT_sp_ObterPromptPorContexto TO AI_Hackthon;
GO

-- Conceder permissões de SELECT nas tabelas (caso precise fazer queries diretas)
GRANT SELECT ON dbo.AIHT_GruposEmpresariais TO AI_Hackthon;
GRANT SELECT ON dbo.AIHT_Fabricantes TO AI_Hackthon;
GRANT SELECT ON dbo.AIHT_Modelos TO AI_Hackthon;
GRANT SELECT ON dbo.AIHT_Prompts TO AI_Hackthon;
GO

PRINT 'Permissões concedidas com sucesso ao usuário AI_Hackthon!';
GO
