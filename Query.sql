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

-- ii. Probando la función que recibe el identificador de una sucursal y regresa las ganancias totales obtenidas durante el año 2026.
SELECT GananciasSucursal2026(10);

-- Suma el dinero de todas las consultas médicas hechas en 2026 por médicos de la sucursal 10.
SELECT SUM(c.Precio)
FROM CobrarConsulta c
JOIN Medico m ON c.RFCMedico = m.RFC
WHERE m.IdSucursal = 10
  AND EXTRACT(YEAR FROM c.Fecha) = 2026;

--Suma el dinero de todos los tickets (ventas) de la sucursal 10 en 2026.
SELECT SUM(t.PrecioNeto)
FROM Ticket t
WHERE t.IdSucursal = 10
  AND EXTRACT(YEAR FROM t.FechaPago) = 2026;



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


--====================================================================================================
--                              Pruebas para el check Ticket_chk_reglas_web
--====================================================================================================

-- VENTA WEB SÓLO CON MEDICAMENTOS (Válido)
INSERT INTO Ticket (FechaPago, HoraPago, TipoVenta, IdSucursal, IdCliente, EsTicketConsulta, EsTicketMedicamento)
VALUES (CURRENT_DATE, CURRENT_TIME, 'Web', 1, 1, FALSE, TRUE);

-- Resultado esperado: La consulta se ejecuta sin problemas y se crea el ticket.

-- VENTA WEB DE UNA CONSULTA (Inválido)
INSERT INTO Ticket (FechaPago, HoraPago, TipoVenta, IdSucursal, IdCliente, EsTicketConsulta, EsTicketMedicamento)
VALUES (CURRENT_DATE, CURRENT_TIME, 'Web', 1, 1, TRUE, FALSE);

-- Resultado esperado: PostgreSQL abortará la operación y lanzará este error:
-- ERROR: el nuevo registro para la relación «ticket» viola la restricción check «ticket_chk_reglas_web»

-- VENTA WEB MIXTA (Inválido)
INSERT INTO Ticket (FechaPago, HoraPago, TipoVenta, IdSucursal, IdCliente, EsTicketConsulta, EsTicketMedicamento)
VALUES (CURRENT_DATE, CURRENT_TIME, 'Web', 1, 1, TRUE, TRUE);

-- Resultado esperado: PostgreSQL también abortará la operación indicando que se violó la restricción «ticket_chk_reglas_web».

-- VENTA PRESENCIAL MIXTA (Válido)
INSERT INTO Ticket (FechaPago, HoraPago, TipoVenta, IdSucursal, IdCliente, EsTicketConsulta, EsTicketMedicamento)
VALUES (CURRENT_DATE, CURRENT_TIME, 'Presencial', 1, 1, TRUE, TRUE);

-- Resultado esperado: La consulta se ejecuta perfectamente.


--====================================================================================================
--                     Pruebas para el primer disparador del proyecto final
--====================================================================================================

-- Vender el medicamento controlado (ID 2) en el ticket presencial (Folio 1)
INSERT INTO TenerMedComercial (FolioTicket, IdMedicamento, CantidadComprada, PrecioUnitario)
VALUES (1, 2, 1, 250.00);

-- RESULTADO ESPERADO: Éxito. (Query returned successfully).

-- Vender el medicamento de venta libre (ID 1) en el ticket web (Folio 2)
INSERT INTO TenerMedComercial (FolioTicket, IdMedicamento, CantidadComprada, PrecioUnitario)
VALUES (2, 1, 3, 50.00);

-- RESULTADO ESPERADO: Éxito. (Query returned successfully).

-- Intentar vender el medicamento controlado (ID 2) en el ticket web (Folio 2)
INSERT INTO TenerMedComercial (FolioTicket, IdMedicamento, CantidadComprada, PrecioUnitario)
VALUES (2, 2, 1, 250.00);

-- RESULTADO ESPERADO: PostgreSQL detiene la transacción inmediatamente y lanza el error:
-- ERROR: Venta web rechazada: El medicamento ID 2 no es de venta libre (Tipo: Psicotrópico).

--====================================================================================================
--                     Pruebas para el primer procedimiento del proyecto final
--====================================================================================================

-- ======== Paso 1: Preparar las ventas del día (Datos de Prueba) ========

-- 1. Creamos 3 ticket para el día de hoy
INSERT INTO Ticket (FechaPago, HoraPago, TipoVenta, IdSucursal, IdCliente, EsTicketConsulta, EsTicketMedicamento)
VALUES (CURRENT_DATE, CURRENT_TIME, 'Presencial', 1, 1, FALSE, TRUE);

INSERT INTO Ticket(FechaPago,HoraPago,TipoVenta,IdSucursal,IdCliente,EsTicketConsulta,EsTicketMedicamento) 
VALUES (CURRENT_DATE, CURRENT_TIME,'Web',1,1,FALSE,TRUE);

INSERT INTO Ticket(FechaPago,HoraPago,TipoVenta,IdSucursal,IdCliente,EsTicketConsulta,EsTicketMedicamento) 
VALUES (CURRENT_DATE, CURRENT_TIME,'Presencial',1,1,FALSE,TRUE);

-- ==== Medicamentos Comerciales para el primer ticket====
-- Agregamos el primer producto (Ej. 2 cajas de $50.00 = $100.00)
INSERT INTO TenerMedComercial (FolioTicket, IdMedicamento, CantidadComprada, PrecioUnitario)
VALUES (1, 1, 2, 50.00);

-- Agregamos un segundo producto (Ej. 1 caja de $150.00 = $150.00)
INSERT INTO TenerMedComercial (FolioTicket, IdMedicamento, CantidadComprada, PrecioUnitario)
VALUES (1, 2, 1, 150.00);

-- ==== Medicamentos Preparados para el segundo ticket====
-- Agregamos el primer producto (Ej. 2 cajas de $25.00 = $50.00)
INSERT INTO TenerMedPreparado (FolioTicket, IdMedicamento, CantidadComprada, PrecioUnitario)
VALUES (2, 1, 2, 25.00);

-- Agregamos un segundo producto (Ej. 1 caja de $50.00 = $50.00)
INSERT INTO TenerMedPreparado (FolioTicket, IdMedicamento, CantidadComprada, PrecioUnitario)
VALUES (2, 2, 1, 50.00);

-- ==== Sólo Consulta para el tercer ticket====
INSERT INTO CobrarConsulta(Fecha,Hora,Diagnostico,Precio,IdCliente,RFCMedico,RFCEnfermero,FolioTicket) 
VALUES ('2024-01-18','2:00','Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.',100,3,'MBMO380825M20',NULL,3);

-- SUMA ESPERADA PARA EL CORTE DE CAJA: $450.00 

-- ======== Paso 2: Ejecutar el Procedimiento Almacenado ========
-- Llamar al procedimiento de Corte de Caja para la fecha actual
CALL sp_corte_caja_diario(CURRENT_DATE);


--====================================================================================================
--                     Pruebas para el segundo procedimiento del proyecto final
--====================================================================================================
CALL sp_reporte_stock_critico(10);


--====================================================================================================
--                     Pruebas para la primera función del proyecto final
--====================================================================================================
SELECT * FROM fn_calcular_cuenta_ticket(1); -- Sustituir el 1 por el folio de prueba