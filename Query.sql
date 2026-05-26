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

-- Verificar las consultas cobradas asociadas a la sucursal 10 junto con el médico y el precio de cada consulta.
SELECT c.Precio, c.RFCMedico, m.IdSucursal
FROM CobrarConsulta c
JOIN Medico m
    ON c.RFCMedico = m.RFC
WHERE m.IdSucursal = 10
  AND EXTRACT(YEAR FROM c.Fecha) = 2026;

-- Verificar manualmente la suma total de las ganancias de la sucursal 10 durante el año 2026.
SELECT SUM(c.Precio)
FROM CobrarConsulta c
JOIN Medico m
    ON c.RFCMedico = m.RFC
WHERE m.IdSucursal = 10
  AND EXTRACT(YEAR FROM c.Fecha) = 2026;



--====================================================================================================
--                            Probando disparadores Práctica 10
--====================================================================================================

/*
i. Un trigger que se encargue de actualizar el stock de los productos cada vez que un proveedor provea un
medicamento, cada vez que un farmaceutico cree un medicamento y cada vez que un cliente compre el medicamento.
*/



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