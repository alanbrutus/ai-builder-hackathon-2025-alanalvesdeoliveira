-- =============================================
-- Script de Dados Iniciais (Seed Data)
-- AI Builder Hackathon 2025
-- Dados básicos para iniciar o sistema
-- =============================================

USE AI_Builder_Hackthon;
GO

-- Inserir Tipos de Veículos
INSERT INTO AIHT_TiposVeiculo (Nome, Descricao) VALUES
('Sedan', 'Veículo de passeio com porta-malas separado'),
('Hatchback', 'Veículo de passeio com porta-malas integrado'),
('Pick-up Pequena', 'Caminhonete de pequeno porte'),
('Pick-up Média', 'Caminhonete de médio porte'),
('SUV', 'Sport Utility Vehicle - Veículo utilitário esportivo');
GO

-- Inserir Marcas
INSERT INTO AIHT_Marcas (Nome, Pais) VALUES
('Chevrolet', 'Estados Unidos'),
('Ford', 'Estados Unidos'),
('Volkswagen', 'Alemanha'),
('Fiat', 'Itália'),
('Toyota', 'Japão'),
('Honda', 'Japão'),
('Hyundai', 'Coreia do Sul'),
('Nissan', 'Japão'),
('Renault', 'França'),
('Peugeot', 'França'),
('Jeep', 'Estados Unidos'),
('Mitsubishi', 'Japão');
GO

-- Inserir alguns Modelos de exemplo
INSERT INTO AIHT_Modelos (MarcaId, TipoVeiculoId, Nome, AnoInicio, AnoFim) VALUES
-- Chevrolet
(1, 1, 'Onix Sedan', 2016, NULL),
(1, 2, 'Onix Hatchback', 2012, NULL),
(1, 5, 'Tracker', 2013, NULL),
(1, 4, 'S10', 1995, NULL),
-- Ford
(2, 1, 'Fusion', 2006, 2020),
(2, 2, 'Ka', 2014, NULL),
(2, 5, 'EcoSport', 2003, NULL),
(2, 4, 'Ranger', 1998, NULL),
-- Volkswagen
(3, 1, 'Jetta', 2011, NULL),
(3, 2, 'Gol', 1980, NULL),
(3, 5, 'T-Cross', 2019, NULL),
(3, 4, 'Amarok', 2010, NULL),
-- Fiat
(4, 1, 'Cronos', 2018, NULL),
(4, 2, 'Argo', 2017, NULL),
(4, 5, 'Pulse', 2021, NULL),
(4, 3, 'Strada', 1998, NULL),
-- Toyota
(5, 1, 'Corolla', 1966, NULL),
(5, 2, 'Yaris', 1999, NULL),
(5, 5, 'RAV4', 1994, NULL),
(5, 4, 'Hilux', 1968, NULL),
-- Honda
(6, 1, 'Civic', 1972, NULL),
(6, 2, 'Fit', 2001, NULL),
(6, 5, 'HR-V', 1998, NULL),
-- Hyundai
(7, 1, 'HB20S', 2019, NULL),
(7, 2, 'HB20', 2012, NULL),
(7, 5, 'Creta', 2016, NULL);
GO

-- Inserir Categorias de Peças
INSERT INTO AIHT_CategoriasPecas (Nome, Descricao, CategoriaPaiId) VALUES
('Motor', 'Peças relacionadas ao motor', NULL),
('Suspensão', 'Peças do sistema de suspensão', NULL),
('Freios', 'Peças do sistema de freios', NULL),
('Transmissão', 'Peças do sistema de transmissão', NULL),
('Elétrica', 'Peças do sistema elétrico', NULL),
('Carroceria', 'Peças da carroceria', NULL),
('Filtros', 'Filtros diversos', NULL),
('Iluminação', 'Peças de iluminação', NULL),
('Arrefecimento', 'Sistema de arrefecimento', NULL),
('Escapamento', 'Sistema de escapamento', NULL);

-- Subcategorias de Motor
INSERT INTO AIHT_CategoriasPecas (Nome, Descricao, CategoriaPaiId) VALUES
('Velas de Ignição', 'Velas para ignição do motor', 1),
('Correias', 'Correias dentadas e poli-v', 1),
('Bomba de Óleo', 'Bombas de óleo do motor', 1),
('Junta de Cabeçote', 'Juntas para cabeçote', 1);

-- Subcategorias de Suspensão
INSERT INTO AIHT_CategoriasPecas (Nome, Descricao, CategoriaPaiId) VALUES
('Amortecedores', 'Amortecedores dianteiros e traseiros', 2),
('Molas', 'Molas helicoidais', 2),
('Bandejas', 'Bandejas de suspensão', 2),
('Buchas', 'Buchas de suspensão', 2);

-- Subcategorias de Freios
INSERT INTO AIHT_CategoriasPecas (Nome, Descricao, CategoriaPaiId) VALUES
('Pastilhas de Freio', 'Pastilhas para freio a disco', 3),
('Discos de Freio', 'Discos de freio ventilados e sólidos', 3),
('Lonas de Freio', 'Lonas para freio a tambor', 3),
('Cilindro Mestre', 'Cilindro mestre de freio', 3);
GO

PRINT 'Dados iniciais inseridos com sucesso!';
GO
