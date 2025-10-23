--Indices
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

create nonclustered index IX_Pagos_PagoID
on Pagos (PagoID);

