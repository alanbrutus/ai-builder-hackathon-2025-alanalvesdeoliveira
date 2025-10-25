-- =============================================
-- Script de Criação de Índices
-- AI Builder Hackathon 2025
-- Otimização de Performance
-- =============================================

USE AI_Builder_Hackthon;
GO

-- Índices para Tabela Marcas
CREATE INDEX AIHT_IX_Marcas_Nome ON AIHT_Marcas(Nome);
CREATE INDEX AIHT_IX_Marcas_Ativo ON AIHT_Marcas(Ativo);
GO

-- Índices para Tabela Modelos
CREATE INDEX AIHT_IX_Modelos_MarcaId ON AIHT_Modelos(MarcaId);
CREATE INDEX AIHT_IX_Modelos_TipoVeiculoId ON AIHT_Modelos(TipoVeiculoId);
CREATE INDEX AIHT_IX_Modelos_Nome ON AIHT_Modelos(Nome);
CREATE INDEX AIHT_IX_Modelos_Ativo ON AIHT_Modelos(Ativo);
GO

-- Índices para Tabela Peças
CREATE INDEX AIHT_IX_Pecas_CodigoOriginal ON AIHT_Pecas(CodigoOriginal);
CREATE INDEX AIHT_IX_Pecas_Nome ON AIHT_Pecas(Nome);
CREATE INDEX AIHT_IX_Pecas_CategoriaId ON AIHT_Pecas(CategoriaId);
CREATE INDEX AIHT_IX_Pecas_Ativo ON AIHT_Pecas(Ativo);
CREATE INDEX AIHT_IX_Pecas_Preco ON AIHT_Pecas(Preco);
GO

-- Índices para Tabela CompatibilidadePecas
CREATE INDEX AIHT_IX_CompatibilidadePecas_PecaId ON AIHT_CompatibilidadePecas(PecaId);
CREATE INDEX AIHT_IX_CompatibilidadePecas_ModeloId ON AIHT_CompatibilidadePecas(ModeloId);
GO

-- Índices para Tabela Clientes
CREATE INDEX AIHT_IX_Clientes_Email ON AIHT_Clientes(Email);
CREATE INDEX AIHT_IX_Clientes_CPF ON AIHT_Clientes(CPF);
CREATE INDEX AIHT_IX_Clientes_CNPJ ON AIHT_Clientes(CNPJ);
CREATE INDEX AIHT_IX_Clientes_Ativo ON AIHT_Clientes(Ativo);
GO

-- Índices para Tabela Enderecos
CREATE INDEX AIHT_IX_Enderecos_ClienteId ON AIHT_Enderecos(ClienteId);
CREATE INDEX AIHT_IX_Enderecos_CEP ON AIHT_Enderecos(CEP);
GO

-- Índices para Tabela Pedidos
CREATE INDEX AIHT_IX_Pedidos_ClienteId ON AIHT_Pedidos(ClienteId);
CREATE INDEX AIHT_IX_Pedidos_NumPedido ON AIHT_Pedidos(NumPedido);
CREATE INDEX AIHT_IX_Pedidos_Status ON AIHT_Pedidos(Status);
CREATE INDEX AIHT_IX_Pedidos_DataPedido ON AIHT_Pedidos(DataPedido);
GO

-- Índices para Tabela ItensPedido
CREATE INDEX AIHT_IX_ItensPedido_PedidoId ON AIHT_ItensPedido(PedidoId);
CREATE INDEX AIHT_IX_ItensPedido_PecaId ON AIHT_ItensPedido(PecaId);
GO

-- Índices para Tabela Avaliacoes
CREATE INDEX AIHT_IX_Avaliacoes_PecaId ON AIHT_Avaliacoes(PecaId);
CREATE INDEX AIHT_IX_Avaliacoes_ClienteId ON AIHT_Avaliacoes(ClienteId);
CREATE INDEX AIHT_IX_Avaliacoes_Nota ON AIHT_Avaliacoes(Nota);
GO

-- Índices para Tabela HistoricoPrecos
CREATE INDEX AIHT_IX_HistoricoPrecos_PecaId ON AIHT_HistoricoPrecos(PecaId);
CREATE INDEX AIHT_IX_HistoricoPrecos_DataAlteracao ON AIHT_HistoricoPrecos(DataAlteracao);
GO

PRINT 'Índices criados com sucesso!';
GO
