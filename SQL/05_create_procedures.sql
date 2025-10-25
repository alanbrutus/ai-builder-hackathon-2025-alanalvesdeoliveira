-- =============================================
-- Script de Stored Procedures
-- AI Builder Hackathon 2025
-- Procedures para operações comuns
-- =============================================

USE AI_Builder_Hackthon;
GO

-- Procedure: Buscar Peças por Veículo
CREATE PROCEDURE AIHT_sp_BuscarPecasPorVeiculo
    @MarcaId INT = NULL,
    @ModeloId INT = NULL,
    @Ano INT = NULL,
    @CategoriaId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT DISTINCT
        p.Id,
        p.CodigoOriginal,
        p.Nome,
        p.Descricao,
        p.Preco,
        p.EstoqueAtual,
        p.ImagemUrl,
        c.Nome AS Categoria,
        m.Nome AS Modelo,
        ma.Nome AS Marca
    FROM AIHT_Pecas p
    INNER JOIN AIHT_CategoriasPecas c ON p.CategoriaId = c.Id
    INNER JOIN AIHT_CompatibilidadePecas cp ON p.Id = cp.PecaId
    INNER JOIN AIHT_Modelos m ON cp.ModeloId = m.Id
    INNER JOIN AIHT_Marcas ma ON m.MarcaId = ma.Id
    WHERE 
        p.Ativo = 1
        AND (@MarcaId IS NULL OR m.MarcaId = @MarcaId)
        AND (@ModeloId IS NULL OR m.Id = @ModeloId)
        AND (@Ano IS NULL OR (@Ano >= cp.AnoInicio AND (@Ano <= cp.AnoFim OR cp.AnoFim IS NULL)))
        AND (@CategoriaId IS NULL OR p.CategoriaId = @CategoriaId)
    ORDER BY p.Nome;
END;
GO

-- Procedure: Criar Novo Pedido
CREATE PROCEDURE AIHT_sp_CriarPedido
    @ClienteId INT,
    @EnderecoEntregaId INT,
    @FormaPagamento NVARCHAR(50),
    @Observacoes NVARCHAR(MAX) = NULL,
    @PedidoId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        DECLARE @NumPedido NVARCHAR(20);
        DECLARE @DataAtual DATETIME = GETDATE();
        
        -- Gerar número do pedido
        SET @NumPedido = 'PED' + FORMAT(@DataAtual, 'yyyyMMddHHmmss');
        
        -- Inserir pedido
        INSERT INTO AIHT_Pedidos (
            ClienteId, NumPedido, Status, ValorSubtotal, 
            ValorTotal, EnderecoEntregaId, FormaPagamento, 
            Observacoes, DataPedido
        )
        VALUES (
            @ClienteId, @NumPedido, 'Pendente', 0, 
            0, @EnderecoEntregaId, @FormaPagamento, 
            @Observacoes, @DataAtual
        );
        
        SET @PedidoId = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        SELECT @PedidoId AS PedidoId, @NumPedido AS NumPedido;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- Procedure: Adicionar Item ao Pedido
CREATE PROCEDURE AIHT_sp_AdicionarItemPedido
    @PedidoId INT,
    @PecaId INT,
    @Quantidade INT,
    @Desconto DECIMAL(10,2) = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        DECLARE @PrecoUnitario DECIMAL(10,2);
        DECLARE @PrecoTotal DECIMAL(10,2);
        DECLARE @EstoqueAtual INT;
        
        -- Verificar estoque
        SELECT @EstoqueAtual = EstoqueAtual, @PrecoUnitario = Preco
        FROM AIHT_Pecas
        WHERE Id = @PecaId;
        
        IF @EstoqueAtual < @Quantidade
        BEGIN
            RAISERROR('Estoque insuficiente para a peça solicitada.', 16, 1);
            RETURN;
        END
        
        -- Calcular preço total
        SET @PrecoTotal = (@PrecoUnitario * @Quantidade) - @Desconto;
        
        -- Inserir item
        INSERT INTO AIHT_ItensPedido (PedidoId, PecaId, Quantidade, PrecoUnitario, PrecoTotal, Desconto)
        VALUES (@PedidoId, @PecaId, @Quantidade, @PrecoUnitario, @PrecoTotal, @Desconto);
        
        -- Atualizar estoque
        UPDATE AIHT_Pecas
        SET EstoqueAtual = EstoqueAtual - @Quantidade
        WHERE Id = @PecaId;
        
        -- Atualizar totais do pedido
        UPDATE AIHT_Pedidos
        SET 
            ValorSubtotal = (SELECT SUM(PrecoTotal) FROM AIHT_ItensPedido WHERE PedidoId = @PedidoId),
            ValorTotal = (SELECT SUM(PrecoTotal) FROM AIHT_ItensPedido WHERE PedidoId = @PedidoId) + ValorFrete - ValorDesconto,
            DataAtualizacao = GETDATE()
        WHERE Id = @PedidoId;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- Procedure: Atualizar Status do Pedido
CREATE PROCEDURE AIHT_sp_AtualizarStatusPedido
    @PedidoId INT,
    @NovoStatus NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE AIHT_Pedidos
    SET 
        Status = @NovoStatus,
        DataAtualizacao = GETDATE()
    WHERE Id = @PedidoId;
    
    SELECT @@ROWCOUNT AS LinhasAfetadas;
END;
GO

-- Procedure: Registrar Avaliação
CREATE PROCEDURE AIHT_sp_RegistrarAvaliacao
    @PecaId INT,
    @ClienteId INT,
    @Nota INT,
    @Comentario NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @Nota < 1 OR @Nota > 5
    BEGIN
        RAISERROR('A nota deve estar entre 1 e 5.', 16, 1);
        RETURN;
    END
    
    INSERT INTO AIHT_Avaliacoes (PecaId, ClienteId, Nota, Comentario)
    VALUES (@PecaId, @ClienteId, @Nota, @Comentario);
    
    SELECT SCOPE_IDENTITY() AS AvaliacaoId;
END;
GO

-- Procedure: Atualizar Preço da Peça
CREATE PROCEDURE AIHT_sp_AtualizarPrecoPeca
    @PecaId INT,
    @NovoPreco DECIMAL(10,2),
    @Usuario NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        DECLARE @PrecoAnterior DECIMAL(10,2);
        
        -- Obter preço anterior
        SELECT @PrecoAnterior = Preco
        FROM AIHT_Pecas
        WHERE Id = @PecaId;
        
        -- Registrar no histórico
        INSERT INTO AIHT_HistoricoPrecos (PecaId, PrecoAnterior, PrecoNovo, UsuarioAlteracao)
        VALUES (@PecaId, @PrecoAnterior, @NovoPreco, @Usuario);
        
        -- Atualizar preço
        UPDATE AIHT_Pecas
        SET 
            Preco = @NovoPreco,
            DataAtualizacao = GETDATE()
        WHERE Id = @PecaId;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- Procedure: Buscar Peças por Texto
CREATE PROCEDURE AIHT_sp_BuscarPecasPorTexto
    @TextoBusca NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        p.Id,
        p.CodigoOriginal,
        p.Nome,
        p.Descricao,
        p.Preco,
        p.EstoqueAtual,
        p.ImagemUrl,
        c.Nome AS Categoria,
        p.Fabricante
    FROM AIHT_Pecas p
    INNER JOIN AIHT_CategoriasPecas c ON p.CategoriaId = c.Id
    WHERE 
        p.Ativo = 1
        AND (
            p.Nome LIKE '%' + @TextoBusca + '%'
            OR p.CodigoOriginal LIKE '%' + @TextoBusca + '%'
            OR p.Descricao LIKE '%' + @TextoBusca + '%'
            OR p.Fabricante LIKE '%' + @TextoBusca + '%'
        )
    ORDER BY p.Nome;
END;
GO

PRINT 'Stored Procedures criadas com sucesso!';
GO
