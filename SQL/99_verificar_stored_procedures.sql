-- =============================================
-- Script: Verificar Stored Procedures
-- =============================================

USE AI_Builder_Hackthon;
GO

-- Verificar se as stored procedures existem
SELECT 
    name AS 'Stored Procedure',
    create_date AS 'Data Criação',
    modify_date AS 'Última Modificação'
FROM sys.objects
WHERE type = 'P' 
    AND name LIKE 'AIHT_%'
ORDER BY name;
GO

-- Verificar permissões do usuário AI_Hackthon
SELECT 
    pr.name AS 'Stored Procedure',
    dp.name AS 'Usuário',
    dp.type_desc AS 'Tipo',
    pe.permission_name AS 'Permissão',
    pe.state_desc AS 'Estado'
FROM sys.database_permissions pe
INNER JOIN sys.objects pr ON pe.major_id = pr.object_id
INNER JOIN sys.database_principals dp ON pe.grantee_principal_id = dp.principal_id
WHERE pr.type = 'P' 
    AND pr.name LIKE 'AIHT_%'
    AND dp.name = 'AI_Hackthon'
ORDER BY pr.name;
GO
