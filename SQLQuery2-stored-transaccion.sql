--Transaccion
CREATE PROCEDURE sp_RegistrarVenta
    @ClienteID INT,
    @MetodoPago VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @PedidoID INT;
        DECLARE @Total DECIMAL(10,2);

        -- 1️⃣ Crear el pedido
        INSERT INTO Pedidos (ClienteID, FechaPedido, EstadoID, Total)
        VALUES (@ClienteID, GETDATE(), 'Pendiente', 0);

        SET @PedidoID = SCOPE_IDENTITY(); -- Obtener ID del nuevo pedido

        -- 2️⃣ Insertar detalles de venta (ejemplo: puedes adaptar para recibir datos)
        -- En un escenario real, esto se hace recibiendo los detalles desde la app
        INSERT INTO DetalleVenta (PedidoID, ProductoID, Cantidad, PrecioUnitario)
        VALUES 
            (@PedidoID, 1, 2, 100.00),   -- Producto 1, 2 unidades
            (@PedidoID, 2, 1, 50.00);    -- Producto 2, 1 unidad

        -- 3️⃣ Actualizar stock de los productos vendidos
        UPDATE p
        SET p.Stock = p.Stock - dv.Cantidad
        FROM Productos p
        JOIN DetalleVenta dv ON p.ProductoID = dv.ProductoID
        WHERE dv.PedidoID = @PedidoID;

        -- 4️⃣ Calcular el total del pedido
        SELECT @Total = SUM(Cantidad * PrecioUnitario)
        FROM DetalleVenta
        WHERE PedidoID = @PedidoID;

        UPDATE Pedidos
        SET Total = @Total, EstadoID = 'Completado'
        WHERE PedidoID = @PedidoID;

        -- 5️⃣ Registrar el pago
        INSERT INTO Pagos (PedidoID, Monto, MetodoPago, FechaPago)
        VALUES (@PedidoID, @Total, @MetodoPago, GETDATE());

        COMMIT TRANSACTION;
        PRINT 'Venta registrada correctamente.';

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al registrar la venta.';
        PRINT ERROR_MESSAGE();
    END CATCH;
END;
GO

--Stored procedure para consultar ventas por cliente
CREATE PROCEDURE sp_ConsultarVentasPorCliente
    @ClienteID INT
AS
BEGIN
    SELECT 
        p.PedidoID,
        p.FechaPedido,
        p.EstadoID,
        p.Total,
        COUNT(dv.DetalleID) AS ProductosVendidos
    FROM Pedidos p
    INNER JOIN DetalleVenta dv ON p.PedidoID = dv.PedidoID
    WHERE p.ClienteID = @ClienteID
    GROUP BY p.PedidoID, p.FechaPedido, p.Estado, p.Total
    ORDER BY p.FechaPedido DESC;
END;
