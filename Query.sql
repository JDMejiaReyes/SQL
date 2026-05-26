--====================================================================================================
--                            Probando funciones Práctica 10
--====================================================================================================
-- i. Probando función que reciba el identificador del cliente y nos regrese la edad de los mismos.
SELECT calcular_edad_cliente(1);

-- Verificar todos los clientes
SELECT 
    IdCliente,
    FechaNacimiento,
    calcular_edad_cliente(IdCliente) AS Edad
FROM Cliente;


--====================================================================================================
--                            Probando disparadores Práctica 10
--====================================================================================================

/*
i. Un trigger que se encargue de actualizar el stock de los productos cada vez que un proveedor provea un
medicamento, cada vez que un farmacéutico cree un medicamento y cada vez que un cliente compre el medicamento.
*/
--====================================================================================================
--                                  Primer prueba 
--====================================================================================================
-- 1. Insertar en EntregarMedComercial (Entrada)
-- 10 unidades para el medicamento comercial con ID 3
INSERT INTO EntregarMedComercial (IdProveedor, IdSucursal, IdMedicamento, FechaRecepcion, FechaCaducidad, CondicionesAlmacenamiento, CantidadRecibida, PrecioPublico, PrecioUnitario)
VALUES (1, 1, 3, CURRENT_TIMESTAMP, '2026-12-31', 'Fresco', 10, 100.00, 50.00);

--====================================================================================================
--                                  Segunda prueba
--====================================================================================================
-- 2. Insertar en TenerMedComercial (Venta)
-- Probar venta de 5 de las 10 unidades totales del medicamento comercial con ID 3
INSERT INTO TenerMedComercial (FolioTicket, IdMedicamento, CantidadComprada, PrecioUnitario)
VALUES (1, 3, 5, 100.00);

-- Resultado esperado: La inserción debe ser exitosa.

--====================================================================================================
--                                  Tercera prueba
--====================================================================================================
-- 3. Insertar en TenerMedComercial (Venta de 6 unidades)
-- Aquí debe fallar porque 5 (stock actual) < 6 (solicitado)
INSERT INTO TenerMedComercial (FolioTicket, IdMedicamento, CantidadComprada, PrecioUnitario)
VALUES (2, 3, 6, 100.00);

-- Resultado esperado: PostgreSQL debe lanzar un error tipo RAISE EXCEPTION:
-- "Stock insuficiente para el medicamento comercial ID 3. Stock actual: 5"

/*
ii. Un trigger que se encargue de calcular el precio bruto y el precio neto que debe pagar un cliente. Cada
vez que se genere un ticket, se deberá tomar en consideración cuantos tickets antes se generaron en el año
para así poder saber el descuento que se le aplica.
*/
--====================================================================================================
--                                  Primer prueba 
--====================================================================================================
INSERT INTO Ticket (FechaPago, HoraPago, TipoVenta, IdSucursal, IdCliente, EsTicketConsulta, EsTicketMedicamento, PrecioBruto)
VALUES (CURRENT_DATE, CURRENT_TIME, 'Presencial', 1, 1, FALSE, TRUE, 100.00);

-- Verificar el resultado
SELECT IdCliente, FolioTicket, PrecioBruto, PrecioNeto FROM Ticket WHERE FolioTicket = 1;

-- Debe aparecer: PrecioBruto 100.00, PrecioNeto 100.00

--====================================================================================================
--                                  Segunda prueba
--====================================================================================================

INSERT INTO Ticket (FechaPago, HoraPago, TipoVenta, IdSucursal, IdCliente, EsTicketConsulta, EsTicketMedicamento, PrecioBruto)
VALUES (CURRENT_DATE, CURRENT_TIME, 'Presencial', 1, 1, FALSE, TRUE, 100.00);

-- Verificar el resultado
SELECT IdCliente, FolioTicket, PrecioBruto, PrecioNeto FROM Ticket WHERE FolioTicket = 2 ORDER BY FolioTicket DESC LIMIT 1;
-- Debe aparecer: PrecioBruto 100.00, PrecioNeto 95.00

--====================================================================================================
--                                  Tercera prueba
--====================================================================================================

-- Compra 3
INSERT INTO Ticket (FechaPago, HoraPago, TipoVenta, IdSucursal, IdCliente, EsTicketConsulta, EsTicketMedicamento, PrecioBruto)
VALUES (CURRENT_DATE, CURRENT_TIME, 'Presencial', 1, 1, FALSE, TRUE, 100.00);

-- Compra 4 (Aquí debe saltar el descuento al 10%)
INSERT INTO Ticket (FechaPago, HoraPago, TipoVenta, IdSucursal, IdCliente, EsTicketConsulta, EsTicketMedicamento, PrecioBruto)
VALUES (CURRENT_DATE, CURRENT_TIME, 'Presencial', 1, 1, FALSE, TRUE, 100.00);

-- Verifica el resultado
SELECT IdCliente, FolioTicket, PrecioBruto, PrecioNeto FROM Ticket WHERE FolioTicket = 4 ORDER BY FolioTicket DESC LIMIT 1;
-- Debe aparecer: PrecioBruto 100.00, PrecioNeto 90.00

--====================================================================================================
--                                  Cuarta prueba
--====================================================================================================

-- Compra 5 y 6
INSERT INTO Ticket (FechaPago, HoraPago, TipoVenta, IdSucursal, IdCliente, EsTicketConsulta, EsTicketMedicamento, PrecioBruto) VALUES (CURRENT_DATE, CURRENT_TIME, 'Presencial', 1, 1, FALSE, TRUE, 100.00);
INSERT INTO Ticket (FechaPago, HoraPago, TipoVenta, IdSucursal, IdCliente, EsTicketConsulta, EsTicketMedicamento, PrecioBruto) VALUES (CURRENT_DATE, CURRENT_TIME, 'Presencial', 1, 1, FALSE, TRUE, 100.00);

-- Compra 7 (Aquí debe saltar al 25%)
INSERT INTO Ticket (FechaPago, HoraPago, TipoVenta, IdSucursal, IdCliente, EsTicketConsulta, EsTicketMedicamento, PrecioBruto)
VALUES (CURRENT_DATE, CURRENT_TIME, 'Presencial', 1, 1, FALSE, TRUE, 100.00);

-- Verificar el resultado
SELECT IdCliente, FolioTicket, PrecioBruto, PrecioNeto FROM Ticket WHERE FolioTicket = 7 ORDER BY FolioTicket DESC LIMIT 1;
-- Debe aparecer: PrecioBruto 100.00, PrecioNeto 75.00

--====================================================================================================
--                              Verificar todos los resultados juntos
--====================================================================================================
select IdCliente, FolioTicket, PrecioBruto, PrecioNeto from Ticket;