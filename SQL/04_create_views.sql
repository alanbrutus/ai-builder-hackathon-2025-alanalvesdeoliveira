-- =============================================
-- Script de Criação de Views
-- AI Builder Hackathon 2025
-- Views para facilitar consultas complexas
-- =============================================

USE AI_Builder_Hackthon;
GO

-- View: Catálogo Completo de Peças
CREATE VIEW AIHT_vw_CatalogoPecas AS
SELECT 
    p.Id,
    p.CodigoOriginal,
    p.Nome,
    p.Descricao,
    p.Fabricante,
    p.Preco,
    p.EstoqueAtual,
    p.ImagemUrl,
    p.Garantia,
    c.Nome AS Categoria,
    cp.Nome AS CategoriaPai,
    CASE 
        WHEN p.EstoqueAtual > p.EstoqueMinimo THEN 'Em Estoque'
        WHEN p.EstoqueAtual > 0 THEN 'Estoque Baixo'
        ELSE 'Indisponível'
    END AS StatusEstoque,
    p.Ativo
FROM AIHT_Pecas p
INNER JOIN AIHT_CategoriasPecas c ON p.CategoriaId = c.Id
LEFT JOIN AIHT_CategoriasPecas cp ON c.CategoriaPaiId = cp.Id;
GO

-- View: Compatibilidade de Peças com Veículos
CREATE VIEW AIHT_vw_CompatibilidadeVeiculos AS
SELECT 
    p.Id AS PecaId,
    p.CodigoOriginal,
    p.Nome AS NomePeca,
    m.Id AS ModeloId,
    m.Nome AS NomeModelo,
    ma.Nome AS Marca,
    tv.Nome AS TipoVeiculo,
    cp.AnoInicio,
    cp.AnoFim,
    cp.Observacoes
FROM AIHT_CompatibilidadePecas cp
INNER JOIN AIHT_Pecas p ON cp.PecaId = p.Id
INNER JOIN AIHT_Modelos m ON cp.ModeloId = m.Id
INNER JOIN AIHT_Marcas ma ON m.MarcaId = ma.Id
INNER JOIN AIHT_TiposVeiculo tv ON m.TipoVeiculoId = tv.Id
WHERE p.Ativo = 1 AND m.Ativo = 1;
GO

-- View: Resumo de Pedidos
CREATE VIEW AIHT_vw_ResumoPedidos AS
SELECT 
    ped.Id,
    ped.NumPedido,
    ped.Status,
    cli.Nome AS NomeCliente,
    cli.Email AS EmailCliente,
    ped.ValorTotal,
    ped.DataPedido,
    COUNT(ip.Id) AS QuantidadeItens,
    e.Cidade,
    e.Estado
FROM AIHT_Pedidos ped
INNER JOIN AIHT_Clientes cli ON ped.ClienteId = cli.Id
INNER JOIN AIHT_Enderecos e ON ped.EnderecoEntregaId = e.Id
LEFT JOIN AIHT_ItensPedido ip ON ped.Id = ip.PedidoId
GROUP BY 
    ped.Id, ped.NumPedido, ped.Status, cli.Nome, cli.Email,
    ped.ValorTotal, ped.DataPedido, e.Cidade, e.Estado;
GO

-- View: Itens do Pedido Detalhado
CREATE VIEW AIHT_vw_ItensPedidoDetalhado AS
SELECT 
    ip.Id,
    ip.PedidoId,
    ped.NumPedido,
    p.CodigoOriginal,
    p.Nome AS NomePeca,
    ip.Quantidade,
    ip.PrecoUnitario,
    ip.PrecoTotal,
    ip.Desconto,
    c.Nome AS Categoria
FROM AIHT_ItensPedido ip
INNER JOIN AIHT_Pedidos ped ON ip.PedidoId = ped.Id
INNER JOIN AIHT_Pecas p ON ip.PecaId = p.Id
INNER JOIN AIHT_CategoriasPecas c ON p.CategoriaId = c.Id;
GO

-- View: Avaliações de Peças
CREATE VIEW AIHT_vw_AvaliacoesPecas AS
SELECT 
    p.Id AS PecaId,
    p.CodigoOriginal,
    p.Nome AS NomePeca,
    AVG(CAST(a.Nota AS FLOAT)) AS MediaAvaliacao,
    COUNT(a.Id) AS TotalAvaliacoes,
    MAX(a.DataAvaliacao) AS UltimaAvaliacao
FROM AIHT_Pecas p
LEFT JOIN AIHT_Avaliacoes a ON p.Id = a.PecaId
GROUP BY p.Id, p.CodigoOriginal, p.Nome;
GO

-- View: Peças Mais Vendidas
CREATE VIEW AIHT_vw_PecasMaisVendidas AS
SELECT TOP 100
    p.Id,
    p.CodigoOriginal,
    p.Nome,
    p.Preco,
    c.Nome AS Categoria,
    SUM(ip.Quantidade) AS TotalVendido,
    SUM(ip.PrecoTotal) AS ValorTotalVendas,
    COUNT(DISTINCT ip.PedidoId) AS NumeroPedidos
FROM AIHT_Pecas p
INNER JOIN AIHT_ItensPedido ip ON p.Id = ip.PecaId
INNER JOIN AIHT_CategoriasPecas c ON p.CategoriaId = c.Id
GROUP BY p.Id, p.CodigoOriginal, p.Nome, p.Preco, c.Nome
ORDER BY TotalVendido DESC;
GO

-- View: Clientes com Mais Pedidos
CREATE VIEW AIHT_vw_TopClientes AS
SELECT TOP 100
    c.Id,
    c.Nome,
    c.Email,
    c.TipoPessoa,
    COUNT(p.Id) AS TotalPedidos,
    SUM(p.ValorTotal) AS ValorTotalCompras,
    MAX(p.DataPedido) AS UltimaCompra
FROM AIHT_Clientes c
INNER JOIN AIHT_Pedidos p ON c.Id = p.ClienteId
GROUP BY c.Id, c.Nome, c.Email, c.TipoPessoa
ORDER BY ValorTotalCompras DESC;
GO

-- View: Estoque Crítico
CREATE VIEW AIHT_vw_EstoqueCritico AS
SELECT 
    p.Id,
    p.CodigoOriginal,
    p.Nome,
    p.EstoqueAtual,
    p.EstoqueMinimo,
    c.Nome AS Categoria,
    p.Preco,
    CASE 
        WHEN p.EstoqueAtual = 0 THEN 'Sem Estoque'
        WHEN p.EstoqueAtual <= p.EstoqueMinimo THEN 'Estoque Crítico'
    END AS Situacao
FROM AIHT_Pecas p
INNER JOIN AIHT_CategoriasPecas c ON p.CategoriaId = c.Id
WHERE p.EstoqueAtual <= p.EstoqueMinimo AND p.Ativo = 1;
GO

PRINT 'Views criadas com sucesso!';
GO
