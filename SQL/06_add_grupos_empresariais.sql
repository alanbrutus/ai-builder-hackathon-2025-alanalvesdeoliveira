-- =============================================
-- Script de Migração: Hierarquia Grupo Empresarial → Fabricante → Modelo
-- AI Builder Hackathon 2025
-- Adiciona estrutura hierárquica para seleção em cascata
-- =============================================

USE AI_Builder_Hackthon;
GO

-- =============================================
-- 1. Criar tabela de Grupos Empresariais
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AIHT_GruposEmpresariais')
BEGIN
    CREATE TABLE AIHT_GruposEmpresariais (
        Id INT PRIMARY KEY IDENTITY(1,1),
        Nome NVARCHAR(100) NOT NULL UNIQUE, -- Stellantis, Volkswagen Group, General Motors, etc.
        Descricao NVARCHAR(500),
        PaisOrigem NVARCHAR(50),
        AnoFundacao INT,
        LogoUrl NVARCHAR(500),
        SiteOficial NVARCHAR(200),
        Ordem INT DEFAULT 0, -- Para ordenação na UI
        Ativo BIT DEFAULT 1,
        DataCriacao DATETIME DEFAULT GETDATE(),
        DataAtualizacao DATETIME DEFAULT GETDATE()
    );
    PRINT 'Tabela AIHT_GruposEmpresariais criada com sucesso.';
END
ELSE
BEGIN
    PRINT 'Tabela AIHT_GruposEmpresariais já existe.';
END
GO

-- =============================================
-- 2. Adicionar coluna GrupoEmpresarialId em AIHT_Marcas
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('AIHT_Marcas') AND name = 'GrupoEmpresarialId')
BEGIN
    ALTER TABLE AIHT_Marcas
    ADD GrupoEmpresarialId INT NULL;
    
    PRINT 'Coluna GrupoEmpresarialId adicionada em AIHT_Marcas.';
END
ELSE
BEGIN
    PRINT 'Coluna GrupoEmpresarialId já existe em AIHT_Marcas.';
END
GO

-- =============================================
-- 3. Inserir Grupos Empresariais
-- =============================================
IF NOT EXISTS (SELECT * FROM AIHT_GruposEmpresariais)
BEGIN
    SET IDENTITY_INSERT AIHT_GruposEmpresariais ON;
    
    INSERT INTO AIHT_GruposEmpresariais (Id, Nome, Descricao, PaisOrigem, AnoFundacao, Ordem) VALUES
    (1, 'Stellantis', 'Grupo formado pela fusão FCA e PSA em 2021', 'Países Baixos', 2021, 1),
    (2, 'Volkswagen Group', 'Maior grupo automotivo da Europa', 'Alemanha', 1937, 2),
    (3, 'General Motors', 'Grupo automotivo americano', 'Estados Unidos', 1908, 3),
    (4, 'Renault-Nissan-Mitsubishi Alliance', 'Aliança estratégica global', 'França/Japão', 1999, 4),
    (5, 'Hyundai Motor Group', 'Grupo automotivo sul-coreano', 'Coreia do Sul', 1967, 5),
    (6, 'Ford Motor Company', 'Fabricante automotiva americana', 'Estados Unidos', 1903, 6),
    (7, 'Toyota Motor Corporation', 'Maior fabricante de veículos do mundo', 'Japão', 1937, 7),
    (8, 'Honda Motor Company', 'Fabricante japonesa de veículos e motocicletas', 'Japão', 1948, 8),
    (9, 'BMW Group', 'Grupo premium alemão', 'Alemanha', 1916, 9),
    (10, 'Daimler AG (Mercedes-Benz Group)', 'Grupo de luxo alemão', 'Alemanha', 1926, 10),
    (11, 'Geely Holding Group', 'Grupo chinês com marcas globais', 'China', 1986, 11),
    (12, 'SAIC Motor', 'Maior fabricante chinesa', 'China', 1955, 12),
    (13, 'Tata Motors', 'Grupo indiano com Jaguar Land Rover', 'Índia', 1945, 13),
    (14, 'Suzuki Motor Corporation', 'Fabricante japonesa', 'Japão', 1909, 14),
    (15, 'Mazda Motor Corporation', 'Fabricante japonesa independente', 'Japão', 1920, 15);
    
    SET IDENTITY_INSERT AIHT_GruposEmpresariais OFF;
    
    PRINT 'Grupos Empresariais inseridos com sucesso.';
END
GO

-- =============================================
-- 4. Atualizar AIHT_Marcas com GrupoEmpresarialId
-- =============================================

-- Stellantis (15 marcas)
UPDATE AIHT_Marcas SET GrupoEmpresarialId = 1 WHERE Nome IN (
    'Abarth', 'Alfa Romeo', 'Chrysler', 'Citroën', 'Dodge', 
    'DS', 'Fiat', 'Jeep', 'Lancia', 'Maserati', 
    'Opel', 'Peugeot', 'Ram', 'Vauxhall', 'Leapmotor'
);

-- Volkswagen Group
UPDATE AIHT_Marcas SET GrupoEmpresarialId = 2 WHERE Nome IN (
    'Volkswagen', 'Audi', 'Porsche', 'SEAT', 'Škoda', 
    'Bentley', 'Bugatti', 'Lamborghini', 'Ducati', 'MAN', 'Scania'
);

-- General Motors
UPDATE AIHT_Marcas SET GrupoEmpresarialId = 3 WHERE Nome IN (
    'Chevrolet', 'GMC', 'Cadillac', 'Buick'
);

-- Renault-Nissan-Mitsubishi Alliance
UPDATE AIHT_Marcas SET GrupoEmpresarialId = 4 WHERE Nome IN (
    'Renault', 'Nissan', 'Mitsubishi', 'Dacia', 'Lada', 'Infiniti'
);

-- Hyundai Motor Group
UPDATE AIHT_Marcas SET GrupoEmpresarialId = 5 WHERE Nome IN (
    'Hyundai', 'Kia', 'Genesis'
);

-- Ford Motor Company
UPDATE AIHT_Marcas SET GrupoEmpresarialId = 6 WHERE Nome IN (
    'Ford', 'Lincoln'
);

-- Toyota Motor Corporation
UPDATE AIHT_Marcas SET GrupoEmpresarialId = 7 WHERE Nome IN (
    'Toyota', 'Lexus', 'Daihatsu', 'Hino'
);

-- Honda Motor Company
UPDATE AIHT_Marcas SET GrupoEmpresarialId = 8 WHERE Nome IN (
    'Honda', 'Acura'
);

-- BMW Group
UPDATE AIHT_Marcas SET GrupoEmpresarialId = 9 WHERE Nome IN (
    'BMW', 'Mini', 'Rolls-Royce'
);

-- Daimler AG (Mercedes-Benz Group)
UPDATE AIHT_Marcas SET GrupoEmpresarialId = 10 WHERE Nome IN (
    'Mercedes-Benz', 'Mercedes-AMG', 'Smart', 'Maybach'
);

-- Geely Holding Group
UPDATE AIHT_Marcas SET GrupoEmpresarialId = 11 WHERE Nome IN (
    'Geely', 'Volvo', 'Polestar', 'Lotus', 'Lynk & Co', 'Proton'
);

-- SAIC Motor
UPDATE AIHT_Marcas SET GrupoEmpresarialId = 12 WHERE Nome IN (
    'MG', 'Roewe', 'Maxus'
);

-- Tata Motors
UPDATE AIHT_Marcas SET GrupoEmpresarialId = 13 WHERE Nome IN (
    'Tata', 'Jaguar', 'Land Rover'
);

-- Suzuki Motor Corporation
UPDATE AIHT_Marcas SET GrupoEmpresarialId = 14 WHERE Nome = 'Suzuki';

-- Mazda Motor Corporation
UPDATE AIHT_Marcas SET GrupoEmpresarialId = 15 WHERE Nome = 'Mazda';

PRINT 'GrupoEmpresarialId atualizado em AIHT_Marcas.';
GO

-- =============================================
-- 5. Inserir marcas do Stellantis que não existem
-- =============================================
-- Verificar e inserir marcas faltantes do Stellantis
IF NOT EXISTS (SELECT * FROM AIHT_Marcas WHERE Nome = 'Abarth')
    INSERT INTO AIHT_Marcas (Nome, Pais, GrupoEmpresarialId) VALUES ('Abarth', 'Itália', 1);

IF NOT EXISTS (SELECT * FROM AIHT_Marcas WHERE Nome = 'Alfa Romeo')
    INSERT INTO AIHT_Marcas (Nome, Pais, GrupoEmpresarialId) VALUES ('Alfa Romeo', 'Itália', 1);

IF NOT EXISTS (SELECT * FROM AIHT_Marcas WHERE Nome = 'Chrysler')
    INSERT INTO AIHT_Marcas (Nome, Pais, GrupoEmpresarialId) VALUES ('Chrysler', 'Estados Unidos', 1);

IF NOT EXISTS (SELECT * FROM AIHT_Marcas WHERE Nome = 'Citroën')
    INSERT INTO AIHT_Marcas (Nome, Pais, GrupoEmpresarialId) VALUES ('Citroën', 'França', 1);

IF NOT EXISTS (SELECT * FROM AIHT_Marcas WHERE Nome = 'Dodge')
    INSERT INTO AIHT_Marcas (Nome, Pais, GrupoEmpresarialId) VALUES ('Dodge', 'Estados Unidos', 1);

IF NOT EXISTS (SELECT * FROM AIHT_Marcas WHERE Nome = 'DS')
    INSERT INTO AIHT_Marcas (Nome, Pais, GrupoEmpresarialId) VALUES ('DS', 'França', 1);

IF NOT EXISTS (SELECT * FROM AIHT_Marcas WHERE Nome = 'Lancia')
    INSERT INTO AIHT_Marcas (Nome, Pais, GrupoEmpresarialId) VALUES ('Lancia', 'Itália', 1);

IF NOT EXISTS (SELECT * FROM AIHT_Marcas WHERE Nome = 'Maserati')
    INSERT INTO AIHT_Marcas (Nome, Pais, GrupoEmpresarialId) VALUES ('Maserati', 'Itália', 1);

IF NOT EXISTS (SELECT * FROM AIHT_Marcas WHERE Nome = 'Opel')
    INSERT INTO AIHT_Marcas (Nome, Pais, GrupoEmpresarialId) VALUES ('Opel', 'Alemanha', 1);

IF NOT EXISTS (SELECT * FROM AIHT_Marcas WHERE Nome = 'Ram')
    INSERT INTO AIHT_Marcas (Nome, Pais, GrupoEmpresarialId) VALUES ('Ram', 'Estados Unidos', 1);

IF NOT EXISTS (SELECT * FROM AIHT_Marcas WHERE Nome = 'Vauxhall')
    INSERT INTO AIHT_Marcas (Nome, Pais, GrupoEmpresarialId) VALUES ('Vauxhall', 'Reino Unido', 1);

IF NOT EXISTS (SELECT * FROM AIHT_Marcas WHERE Nome = 'Leapmotor')
    INSERT INTO AIHT_Marcas (Nome, Pais, GrupoEmpresarialId) VALUES ('Leapmotor', 'China', 1);

PRINT 'Marcas do Stellantis inseridas/atualizadas.';
GO

-- =============================================
-- 6. Criar Foreign Key para garantir integridade
-- =============================================
IF NOT EXISTS (
    SELECT * FROM sys.foreign_keys 
    WHERE name = 'FK_Marcas_GruposEmpresariais'
)
BEGIN
    ALTER TABLE AIHT_Marcas
    ADD CONSTRAINT FK_Marcas_GruposEmpresariais
    FOREIGN KEY (GrupoEmpresarialId) REFERENCES AIHT_GruposEmpresariais(Id);
    
    PRINT 'Foreign Key FK_Marcas_GruposEmpresariais criada.';
END
GO

-- =============================================
-- 7. Criar View para hierarquia completa
-- =============================================
IF OBJECT_ID('AIHT_vw_HierarquiaCompleta', 'V') IS NOT NULL
    DROP VIEW AIHT_vw_HierarquiaCompleta;
GO

CREATE VIEW AIHT_vw_HierarquiaCompleta AS
SELECT 
    g.Id AS GrupoEmpresarialId,
    g.Nome AS GrupoEmpresarial,
    g.PaisOrigem AS GrupoPais,
    m.Id AS FabricanteId,
    m.Nome AS Fabricante,
    m.Pais AS FabricantePais,
    md.Id AS ModeloId,
    md.Nome AS Modelo,
    md.AnoInicio,
    md.AnoFim,
    tv.Nome AS TipoVeiculo,
    CASE 
        WHEN md.AnoFim IS NULL THEN CAST(md.AnoInicio AS NVARCHAR) + ' - Atual'
        ELSE CAST(md.AnoInicio AS NVARCHAR) + ' - ' + CAST(md.AnoFim AS NVARCHAR)
    END AS PeriodoFabricacao,
    g.Nome + ' > ' + m.Nome + ' > ' + md.Nome AS HierarquiaCompleta
FROM AIHT_GruposEmpresariais g
INNER JOIN AIHT_Marcas m ON g.Id = m.GrupoEmpresarialId
INNER JOIN AIHT_Modelos md ON m.Id = md.MarcaId
INNER JOIN AIHT_TiposVeiculo tv ON md.TipoVeiculoId = tv.Id
WHERE g.Ativo = 1 AND m.Ativo = 1 AND md.Ativo = 1;
GO

PRINT 'View AIHT_vw_HierarquiaCompleta criada.';
GO

-- =============================================
-- 8. Stored Procedure: Listar Grupos Empresariais
-- =============================================
IF OBJECT_ID('AIHT_sp_ListarGruposEmpresariais', 'P') IS NOT NULL
    DROP PROCEDURE AIHT_sp_ListarGruposEmpresariais;
GO

CREATE PROCEDURE AIHT_sp_ListarGruposEmpresariais
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        g.Id,
        g.Nome,
        g.Descricao,
        g.PaisOrigem,
        g.AnoFundacao,
        COUNT(DISTINCT m.Id) AS TotalFabricantes,
        COUNT(DISTINCT md.Id) AS TotalModelos
    FROM AIHT_GruposEmpresariais g
    LEFT JOIN AIHT_Marcas m ON g.Id = m.GrupoEmpresarialId AND m.Ativo = 1
    LEFT JOIN AIHT_Modelos md ON m.Id = md.MarcaId AND md.Ativo = 1
    WHERE g.Ativo = 1
    GROUP BY g.Id, g.Nome, g.Descricao, g.PaisOrigem, g.AnoFundacao, g.Ordem
    ORDER BY g.Ordem, g.Nome;
END;
GO

PRINT 'Procedure AIHT_sp_ListarGruposEmpresariais criada.';
GO

-- =============================================
-- 9. Stored Procedure: Listar Fabricantes por Grupo
-- =============================================
IF OBJECT_ID('AIHT_sp_ListarFabricantesPorGrupo', 'P') IS NOT NULL
    DROP PROCEDURE AIHT_sp_ListarFabricantesPorGrupo;
GO

CREATE PROCEDURE AIHT_sp_ListarFabricantesPorGrupo
    @GrupoEmpresarialId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        m.Id,
        m.Nome,
        m.Pais,
        COUNT(DISTINCT md.Id) AS TotalModelos
    FROM AIHT_Marcas m
    LEFT JOIN AIHT_Modelos md ON m.Id = md.MarcaId AND md.Ativo = 1
    WHERE m.GrupoEmpresarialId = @GrupoEmpresarialId
        AND m.Ativo = 1
    GROUP BY m.Id, m.Nome, m.Pais
    ORDER BY m.Nome;
END;
GO

PRINT 'Procedure AIHT_sp_ListarFabricantesPorGrupo criada.';
GO

-- =============================================
-- 10. Stored Procedure: Listar Modelos por Fabricante
-- =============================================
IF OBJECT_ID('AIHT_sp_ListarModelosPorFabricante', 'P') IS NOT NULL
    DROP PROCEDURE AIHT_sp_ListarModelosPorFabricante;
GO

CREATE PROCEDURE AIHT_sp_ListarModelosPorFabricante
    @FabricanteId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        md.Id,
        md.Nome,
        md.AnoInicio,
        md.AnoFim,
        tv.Nome AS TipoVeiculo,
        CASE 
            WHEN md.AnoFim IS NULL THEN CAST(md.AnoInicio AS NVARCHAR) + ' - Atual'
            ELSE CAST(md.AnoInicio AS NVARCHAR) + ' - ' + CAST(md.AnoFim AS NVARCHAR)
        END AS Periodo
    FROM AIHT_Modelos md
    INNER JOIN AIHT_TiposVeiculo tv ON md.TipoVeiculoId = tv.Id
    WHERE md.MarcaId = @FabricanteId
        AND md.Ativo = 1
    ORDER BY md.Nome, md.AnoInicio DESC;
END;
GO

PRINT 'Procedure AIHT_sp_ListarModelosPorFabricante criada.';
GO

-- =============================================
-- 11. Stored Procedure: Buscar Hierarquia por Modelo
-- =============================================
IF OBJECT_ID('AIHT_sp_BuscarHierarquiaPorModelo', 'P') IS NOT NULL
    DROP PROCEDURE AIHT_sp_BuscarHierarquiaPorModelo;
GO

CREATE PROCEDURE AIHT_sp_BuscarHierarquiaPorModelo
    @ModeloId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        g.Id AS GrupoEmpresarialId,
        g.Nome AS GrupoEmpresarial,
        m.Id AS FabricanteId,
        m.Nome AS Fabricante,
        md.Id AS ModeloId,
        md.Nome AS Modelo,
        md.AnoInicio,
        md.AnoFim,
        tv.Nome AS TipoVeiculo,
        g.Nome + ' > ' + m.Nome + ' > ' + md.Nome AS HierarquiaCompleta
    FROM AIHT_Modelos md
    INNER JOIN AIHT_Marcas m ON md.MarcaId = m.Id
    INNER JOIN AIHT_GruposEmpresariais g ON m.GrupoEmpresarialId = g.Id
    INNER JOIN AIHT_TiposVeiculo tv ON md.TipoVeiculoId = tv.Id
    WHERE md.Id = @ModeloId;
END;
GO

PRINT 'Procedure AIHT_sp_BuscarHierarquiaPorModelo criada.';
GO

-- =============================================
-- 12. Stored Procedure: Buscar Modelos por Nome (Autocomplete)
-- =============================================
IF OBJECT_ID('AIHT_sp_BuscarModelosPorNome', 'P') IS NOT NULL
    DROP PROCEDURE AIHT_sp_BuscarModelosPorNome;
GO

CREATE PROCEDURE AIHT_sp_BuscarModelosPorNome
    @TextoBusca NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP 20
        md.Id AS ModeloId,
        md.Nome AS Modelo,
        m.Nome AS Fabricante,
        g.Nome AS GrupoEmpresarial,
        tv.Nome AS TipoVeiculo,
        CASE 
            WHEN md.AnoFim IS NULL THEN CAST(md.AnoInicio AS NVARCHAR) + ' - Atual'
            ELSE CAST(md.AnoInicio AS NVARCHAR) + ' - ' + CAST(md.AnoFim AS NVARCHAR)
        END AS Periodo,
        m.Nome + ' ' + md.Nome AS NomeCompleto,
        g.Nome + ' > ' + m.Nome + ' > ' + md.Nome AS HierarquiaCompleta
    FROM AIHT_Modelos md
    INNER JOIN AIHT_Marcas m ON md.MarcaId = m.Id
    INNER JOIN AIHT_GruposEmpresariais g ON m.GrupoEmpresarialId = g.Id
    INNER JOIN AIHT_TiposVeiculo tv ON md.TipoVeiculoId = tv.Id
    WHERE (md.Nome LIKE '%' + @TextoBusca + '%' 
        OR m.Nome LIKE '%' + @TextoBusca + '%'
        OR g.Nome LIKE '%' + @TextoBusca + '%')
        AND md.Ativo = 1
        AND m.Ativo = 1
        AND g.Ativo = 1
    ORDER BY m.Nome, md.Nome;
END;
GO

PRINT 'Procedure AIHT_sp_BuscarModelosPorNome criada.';
GO

-- =============================================
-- 13. Criar índices para performance
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'AIHT_IX_Marcas_GrupoEmpresarialId')
BEGIN
    CREATE INDEX AIHT_IX_Marcas_GrupoEmpresarialId ON AIHT_Marcas(GrupoEmpresarialId);
    PRINT 'Índice AIHT_IX_Marcas_GrupoEmpresarialId criado.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'AIHT_IX_GruposEmpresariais_Ativo')
BEGIN
    CREATE INDEX AIHT_IX_GruposEmpresariais_Ativo ON AIHT_GruposEmpresariais(Ativo);
    PRINT 'Índice AIHT_IX_GruposEmpresariais_Ativo criado.';
END
GO

-- =============================================
-- Resumo da Execução
-- =============================================
PRINT '';
PRINT '=============================================';
PRINT 'Migração concluída com sucesso!';
PRINT '=============================================';
PRINT 'Estrutura criada:';
PRINT '  - Tabela: AIHT_GruposEmpresariais';
PRINT '  - Coluna: AIHT_Marcas.GrupoEmpresarialId';
PRINT '  - View: AIHT_vw_HierarquiaCompleta';
PRINT '  - 5 Stored Procedures para consultas';
PRINT '';
PRINT 'Hierarquia implementada:';
PRINT '  Grupo Empresarial → Fabricante → Modelo';
PRINT '';
PRINT 'Exemplo: Stellantis → Jeep → Compass';
PRINT '';
PRINT 'Procedures disponíveis:';
PRINT '  - AIHT_sp_ListarGruposEmpresariais';
PRINT '  - AIHT_sp_ListarFabricantesPorGrupo';
PRINT '  - AIHT_sp_ListarModelosPorFabricante';
PRINT '  - AIHT_sp_BuscarHierarquiaPorModelo';
PRINT '  - AIHT_sp_BuscarModelosPorNome';
PRINT '=============================================';
GO
