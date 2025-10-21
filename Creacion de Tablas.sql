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