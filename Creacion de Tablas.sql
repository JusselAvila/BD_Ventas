create database Tienda
Use Tienda;

CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY IDENTITY(1,1),
    PrimerNombre NVARCHAR(100) NOT NULL,
    Apellido NVARCHAR(100) NOT NULL,
    CorreoElectronico NVARCHAR(100) NULL,
    Telefono NVARCHAR(40) NULL,
    FechaRegistro DATETIME DEFAULT GETDATE()
);

INSERT INTO Clientes (PrimerNombre, Apellido, CorreoElectronico, Telefono) VALUES
('Ana', 'Gutiérrez', 'ana.guti@gmail.com', '7701111'),     
('Carlos', 'Mendoza', 'carlos.m@gmail.com', '6802222'),    
('Laura', 'Pérez', 'laura.perez@gmail.com', '7893333'),    
('José', 'Vaca', 'jose.vaca@gmail.com', '7004444'),        
('María', 'Roca', 'maria.roca@gmail.com', '6905555');      

CREATE TABLE Productos (
    ProductoID INT PRIMARY KEY IDENTITY(1,1),
    NombreProducto NVARCHAR(255) NOT NULL,
    Descripcion NVARCHAR(500),
    Precio DECIMAL(10, 2) NOT NULL, 
    Stock INT NOT NULL
);

INSERT INTO Productos (NombreProducto, Descripcion, Precio, Stock) VALUES
('Laptop Pro X', 'Portátil i7, ideal para diseño gráfico.', 1250.00, 50),    
('Monitor LED 27"', 'Monitor 4K, 144Hz. Muy vendido en el Fidalga.', 350.50, 120),
('Teclado Mecánico', 'Switches táctiles, layout español Bolivia.', 85.99, 200), 
('Mouse Óptico', 'Mouse ligero con DPI ajustable.', 25.00, 300),                
('Impresora Multifunción', 'Epson L3110 con sistema continuo.', 180.00, 75),    
('Cable UTP Cat 6', 'Bobina de 305m, para red de oficina.', 110.00, 30);    

CREATE TABLE EstadoPedido (
    EstadoID INT PRIMARY KEY IDENTITY(1,1),
    NombreEstado NVARCHAR(50) NOT NULL,
);

INSERT INTO EstadoPedido (NombreEstado) VALUES
('Pendiente'),         
('Completado');

CREATE TABLE Pedidos (
    PedidoID INT PRIMARY KEY IDENTITY(1,1),
    ClienteID INT NOT NULL,
    FechaPedido DATETIME DEFAULT GETDATE(),
    EstadoID INT NOT NULL, 
    FOREIGN KEY (EstadoID) REFERENCES EstadoPedido(EstadoID),
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);

INSERT INTO Pedidos(ClienteID,EstadoID) VALUES
(1,1),(1,2),(1,2),(2,1),(2,2),(3,2),(4,2)

SELECT * FROM Pedidos

CREATE TABLE DetalleVenta (
    DetalleID INT PRIMARY KEY IDENTITY(1,1),
    PedidoID INT NOT NULL,
    ProductoID INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario FLOAT NOT NULL,
    
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID),
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);

INSERT INTO DetalleVenta(PedidoID, ProductoID, Cantidad, PrecioUnitario) VALUES
(1, 1, 2, 1300),(2, 1, 2, 1310),(3, 2, 4, 400),(4, 3, 3, 100),(5, 4, 3, 200),(6, 4, 2, 210),(7, 5, 30, 30);



CREATE TABLE MetodoPago (
    MetodoPagoID INT PRIMARY KEY IDENTITY(1,1),
    NombreMetodo NVARCHAR(50) NOT NULL, 
);

INSERT INTO MetodoPago(NombreMetodo) VALUES
('Tarjeta'),('QR'),('Efectivo');


CREATE TABLE Pagos (
    PagoID INT PRIMARY KEY IDENTITY(1,1),
    PedidoID INT NOT NULL,
    MetodoPagoID INT NOT NULL, 
    FOREIGN KEY (MetodoPagoID) REFERENCES MetodoPago(MetodoPagoID),
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID)
);

INSERT INTO Pagos (PedidoID, MetodoPagoID) VALUES
(1, 1), 
(2,  2),
(3,  3), 
(4, 1),  
(5,  2),  
(6,  3),  
(7,  2);  

create nonclustered index ix_Clientes_CorreoElectronico
on Clientes(CorreoElectronico);

create nonclustered index IX_Clientes_FechaRegistro
on Clientes (FechaRegistro);

create nonclustered index IX_Productos_Nombre
on Productos (NombreProducto);

create nonclustered index IX_Pedidos_ClienteID
on Pedidos (ClienteID);

create nonclustered index IX_Pedidos_FechaPedido
on Pedidos (FechaPedido);

create nonclustered index IX_Pedidos_EstadoID
on Pedidos (EstadoID);

create nonclustered index IX_DetalleVenta_PedidoProducto
on DetalleVenta (PedidoID, ProductoID);

create nonclustered index IX_Pagos_PedidoID
on Pagos (PedidoID);

create nonclustered index IX_Pagos_FechaPago
on Pagos (FechaPago);

--Transacción T-SQL: Registrar Venta y Actualizar Stock

DECLARE @ClienteID INT = 1; 
DECLARE @FechaPedido DATETIME = GETDATE();
DECLARE @TotalVenta DECIMAL(10, 2) = 0.00;
DECLARE @NuevoPedidoID INT;

DECLARE @ProductosVenta TABLE (
    ProductoID INT,
    Cantidad INT,
    PrecioUnitario DECIMAL(10, 2)
);

INSERT INTO @ProductosVenta (ProductoID, Cantidad, PrecioUnitario)
VALUES
(101, 2, 50.00),  
(105, 1, 120.00);

-- inicio de la transaccion

BEGIN TRANSACTION;

BEGIN TRY
   
    -- Calcular el total de la venta
    SELECT @TotalVenta = SUM(Cantidad * PrecioUnitario)
    FROM @ProductosVenta;
    
    -- 2. Insertar el encabezado del pedido en la tabla Pedidos
    INSERT INTO Pedidos (ClienteID, FechaPedido, Estado, Total)
    VALUES (@ClienteID, @FechaPedido, 'Pendiente', @TotalVenta);

    -- Obtener el ID del pedido recién insertado
    SET @NuevoPedidoID = SCOPE_IDENTITY();

    -- 3. Insertar el detalle del pedido en la tabla DetalleVenta
    INSERT INTO DetalleVenta (PedidoID, ProductoID, Cantidad, PrecioUnitario)
    SELECT @NuevoPedidoID, pv.ProductoID, pv.Cantidad, pv.PrecioUnitario
    FROM @ProductosVenta pv;

    -- 4. Actualizar el Stock de los productos
    UPDATE P
    SET P.Stock = P.Stock - PV.Cantidad
    FROM Productos P
    INNER JOIN @ProductosVenta PV ON P.ProductoID = PV.ProductoID;

    -- 5. Si todo fue exitoso, confirmar la transacción
    COMMIT TRANSACTION;
    SELECT 'Venta registrada con éxito. PedidoID: ' + CAST(@NuevoPedidoID AS NVARCHAR) AS Resultado;

END TRY
BEGIN CATCH
    
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    
    THROW;
    SELECT 'Error al registrar la venta. La transacción fue revertida.' AS Resultado;

END CATCH;


-- Nombre: Consultar_Ventas_Por_Cliente
-- Descripción: Consulta todos los pedidos, detalles y pagos
--              asociados a un ClienteID específico.

CREATE PROCEDURE Consultar_Ventas_Por_Cliente
    @ClienteID INT
AS
BEGIN
    -- Configuración estándar para consultas
    SET NOCOUNT ON;

    SELECT
        C.Nombre AS NombreCliente,
        P.PedidoID,
        P.FechaPedido,
        P.Estado AS EstadoPedido,
        P.Total AS TotalPedido,
        DV.Cantidad,
        DV.PrecioUnitario,
        PR.NombreProducto,
        PA.Monto AS MontoPagado,
        PA.MetodoPago,
        PA.FechaPago
    FROM
        Clientes C
    
    INNER JOIN 
        Pedidos P ON C.ClienteID = P.ClienteID
    
    INNER JOIN 
        DetalleVenta DV ON P.PedidoID = DV.PedidoID
    
    INNER JOIN 
        Productos PR ON DV.ProductoID = PR.ProductoID
    
    LEFT JOIN 
        Pagos PA ON P.PedidoID = PA.PedidoID
    WHERE
        C.ClienteID = @ClienteID
    ORDER BY
        P.FechaPedido DESC, P.PedidoID;

END
GO