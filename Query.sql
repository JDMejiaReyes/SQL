-- i. Clientes cuyo nombre empiece con la letra R.
SELECT * FROM Cliente 
WHERE Nombre LIKE 'R%';


-- ii. Medicamentos que hayan caducado después del 20 de abril del 2026 pero antes del 07 de mayo del 2026.
-- Medicamentos comerciales caducados
SELECT 
    mc.NombreComercial, 
    emc.FechaCaducidad
FROM EntregarMedComercial emc
JOIN MedComercial mc ON emc.IdMedicamento = mc.IdMedicamento
WHERE emc.FechaCaducidad > '2026-04-20' 
  AND emc.FechaCaducidad < '2026-05-07';

--Medicamentos preparados caducados por los insumos caducaron en esa fecha
SELECT
    mp.NombreComercial,
    ei.FechaCaducidad
FROM MedPreparado mp
JOIN Contener c ON mp.IdMedicamento = c.IdMedicamento
JOIN EntregarInsumo ei ON c.IdInsumo = ei.IdInsumo
WHERE ei.FechaCaducidad > '2026-04-20' 
  AND ei.FechaCaducidad < '2026-05-07';


-- iii. Farmacéuticos que hayan nacido en el mes de noviembre.
SELECT * FROM Farmaceutico 
WHERE EXTRACT(MONTH FROM FechaNacimiento) = 11;


--iv. Medicamentos cuya forma física sea gel y vía de administración sea oral.
-- Para los Medicamentos Comerciales
SELECT * FROM MedComercial 
WHERE FormaFarmaceutica = 'Gel' AND ViaAdministracion = 'Oral';

-- Para las Fórmulas Magistrales (Medicamentos Preparados)
SELECT * FROM MedPreparado 
WHERE FormaFarmaceutica = 'Gel' AND ViaAdministracion = 'Oral';


-- v. Todos los proveedores registrados en la base de datos. 
SELECT * FROM Proveedor;

-- =================================================================
--                CONSULTAS PRACTICA 09 
-- =================================================================

-- i. Mostrar el nombre completo de todos los clientes, junto con su nombre de usuario (en dado caso que se tenga una cuenta).

SELECT 
    c.Nombre || ' ' || c.Paterno || ' ' || c.Materno AS Nombre_Completo,
    co.NombreUsuario
FROM 
    Cliente c
LEFT JOIN 
    ClienteOnline co ON c.IdCliente = co.IdCliente;


-- ii. Calcular cuántos medicamentos ha comprado cada cliente.
-- Para los medicamentos comerciales
SELECT 
    c.Nombre || ' ' || c.Paterno || ' ' || c.Materno AS Nombre_Cliente,
    COALESCE(SUM(tmc.CantidadComprada), 0) AS Total_Medicamentos_Comprados
FROM 
    Cliente c
LEFT JOIN 
    Ticket t ON c.IdCliente = t.IdCliente
LEFT JOIN 
    TenerMedComercial tmc ON t.FolioTicket = tmc.FolioTicket
GROUP BY 
    c.IdCliente, c.Nombre, c.Paterno, c.Materno
ORDER BY 
    Total_Medicamentos_Comprados DESC;

-- Para los medicamentos preparados
SELECT 
    c.Nombre || ' ' || c.Paterno || ' ' || c.Materno AS Nombre_Cliente,
    COALESCE(SUM(tmc.CantidadComprada), 0) AS Total_Medicamentos_Comprados
FROM 
    Cliente c
LEFT JOIN 
    Ticket t ON c.IdCliente = t.IdCliente
LEFT JOIN 
    TenerMedPreparado tmc ON t.FolioTicket = tmc.FolioTicket
GROUP BY 
    c.IdCliente, c.Nombre, c.Paterno, c.Materno
ORDER BY 
    Total_Medicamentos_Comprados DESC;

-- Para ambos medicamentos 
WITH DetalleTotal AS (
    -- Unificamos ambos tipos de medicamentos en una sola lista virtual
    SELECT FolioTicket, CantidadComprada FROM TenerMedComercial
    UNION ALL
    SELECT FolioTicket, CantidadComprada FROM TenerMedPreparado
)
SELECT 
    c.Nombre || ' ' || c.Paterno || ' ' || c.Materno AS Nombre_Cliente,
    COALESCE(SUM(dt.CantidadComprada), 0) AS Total_Medicamentos_Global
FROM 
    Cliente c
LEFT JOIN 
    Ticket t ON c.IdCliente = t.IdCliente
LEFT JOIN 
    DetalleTotal dt ON t.FolioTicket = dt.FolioTicket
GROUP BY 
    c.IdCliente, c.Nombre, c.Paterno, c.Materno
ORDER BY 
    Total_Medicamentos_Global DESC;

-- iii. Listar todos las enfermeras cuyo apellido materno contenga llo.

SELECT * FROM Enfermero 
WHERE Materno LIKE '%llo%';

-- iv. Obtener la lista de los clientes que hayan comprado en alguna sucursal pero que no hayan recibido alguna consulta.
SELECT DISTINCT 
    c.IdCliente,
    c.Nombre || ' ' || c.Paterno || ' ' || c.Materno AS Nombre_Cliente
FROM 
    Cliente c
INNER JOIN 
    Ticket t ON c.IdCliente = t.IdCliente
WHERE 
    c.IdCliente NOT IN (
        SELECT IdCliente 
        FROM Consulta
    )
ORDER BY 
    c.IdCliente ASC;

-- v. Calcular el precio bruto por ticket.
WITH DesgloseCostos AS (
    -- 1. Subtotal de medicamentos comerciales
    SELECT 
        FolioTicket, 
        (CantidadComprada * PrecioUnitario) AS CostoItem
    FROM TenerMedComercial
    
    UNION ALL
    
    -- 2. Subtotal de medicamentos preparados
    SELECT 
        FolioTicket, 
        (CantidadComprada * PrecioUnitario) AS CostoItem
    FROM TenerMedPreparado
    
    UNION ALL
    
    -- 3. Costo de la consulta médica (si la hubo)
    SELECT 
        FolioTicket, 
        Precio AS CostoItem
    FROM Consulta
)
SELECT 
    t.FolioTicket,
    t.FechaPago,
    COALESCE(SUM(dc.CostoItem), 0) AS Precio_Bruto
FROM 
    Ticket t
LEFT JOIN 
    DesgloseCostos dc ON t.FolioTicket = dc.FolioTicket
GROUP BY 
    t.FolioTicket, t.FechaPago
ORDER BY 
    t.FolioTicket ASC;


-- viii. Listar a los enfermeros, que atendieron alguna consulta durante el 7 de mayo  del 2026 en un horario de 12:00 hrs. a 16:00 hrs.

SELECT 
    e.RFC,
    e.Nombre,
    c.Fecha,
    c.Hora
FROM Enfermero e
JOIN Consulta c 
    ON e.RFC = c.RFCEnfermero
WHERE c.Fecha = '2026-05-07'
  AND c.Hora BETWEEN '12:00:00' AND '16:00:00';


-- ix. Mostrar a todos los proveedores junto con los productos que proveen, indicando el precio unitario por producto.
SELECT 
    e.IdProveedor, 
    m.NombreComercial AS producto, 
    e.PrecioUnitario,
    'Medicamento' AS tipo_producto
FROM EntregarMedComercial e
JOIN MedComercial m ON e.IdMedicamento = m.IdMedicamento

UNION

SELECT 
    ei.IdProveedor, 
    i.NombreComercial AS producto, 
    ei.PrecioUnitario,
    'Insumo' AS tipo_producto
FROM EntregarInsumo ei
JOIN Insumo i ON ei.IdInsumo = i.IdInsumo;


-- x. Mostrar las sucursales que posean al menos 5 médicos.
SELECT s.IdSucursal, count(m.RFC) AS total_medicos
FROM Sucursal s  
JOIN Medico m ON s.IdSucursal = m.IdSucursal 
GROUP BY s.IdSucursal
HAVING count(m.RFC) >= 5;


-- xi. Listar a los vendedores cuyo total de medicamentos vendidos (número de productos distintos que ofrecen) sea mayor a 3.
SELECT 
    caj.RFC,
    caj.Nombre || ' ' || caj.Paterno || ' ' || caj.Materno AS NombreCompleto,
    COUNT(DISTINCT tmcm.IdMedicamento) + COUNT(DISTINCT tmp.IdMedicamento) AS TotalProductosDistintos,
    SUM(COALESCE(tmcm.CantidadComprada, 0) + COALESCE(tmp.CantidadComprada, 0)) AS TotalUnidadesVendidas
FROM Cajero caj
INNER JOIN Ticket t ON caj.IdSucursal = t.IdSucursal
LEFT JOIN TenerMedComercial tmcm ON t.FolioTicket = tmcm.FolioTicket
LEFT JOIN TenerMedPreparado tmp ON t.FolioTicket = tmp.FolioTicket
GROUP BY caj.RFC, caj.Nombre, caj.Paterno, caj.Materno
HAVING COUNT(DISTINCT tmcm.IdMedicamento) + COUNT(DISTINCT tmp.IdMedicamento) > 3
ORDER BY TotalProductosDistintos DESC;


-- xii. Listar a los proveedores, cuyo total de productos que proveen (numero de productos distintos que proveen) sea mayor a 3.
SELECT 
    resumen.IdProveedor, 
    COUNT(DISTINCT resumen.id_articulo) AS total_productos
FROM (
    -- Primero juntamos los IDs de lo que hay en EntregarMedComercial
    SELECT IdProveedor, IdMedicamento AS id_articulo 
    FROM EntregarMedComercial
    
    UNION ALL
    
    -- Luego lo juntamos con los IDs de EntregarInsumo
    SELECT IdProveedor, IdInsumo AS id_articulo 
    FROM EntregarInsumo
) AS resumen -- "resumen" es solo un apodo temporal para esta unión, no una tabla del DDL
GROUP BY resumen.IdProveedor
HAVING COUNT(DISTINCT resumen.id_articulo) > 3;


-- xiii. Obtener las ganancias y perdidas totales (la perdida se calcula con la cantidad de productos que se le suministra el proveedor) por cada sucursal.
WITH VentasPorSucursal AS (
    SELECT 
        t.IdSucursal,
        SUM(COALESCE(tmcm.CantidadComprada * tmcm.PrecioUnitario, 0)) AS TotalVentasMedComercial,
        SUM(COALESCE(tmp.CantidadComprada * tmp.PrecioUnitario, 0)) AS TotalVentasMedPreparado,
        SUM(COALESCE(cons.Precio, 0)) AS TotalVentasConsultas
    FROM Ticket t
    LEFT JOIN TenerMedComercial tmcm ON t.FolioTicket = tmcm.FolioTicket
    LEFT JOIN TenerMedPreparado tmp ON t.FolioTicket = tmp.FolioTicket
    LEFT JOIN Consulta cons ON t.FolioTicket = cons.FolioTicket
    GROUP BY t.IdSucursal
),
CostosPorSucursal AS (
    -- Primera parte: Solo costos de medicamentos comerciales
    SELECT 
        emc.IdSucursal,
        SUM(emc.CantidadRecibida * emc.PrecioUnitario) AS TotalCostoMedComercial,
        0 AS TotalCostoInsumos  
    FROM EntregarMedComercial emc
    GROUP BY emc.IdSucursal
    
    UNION ALL
    
    -- Segunda parte: Solo costos de insumos
    SELECT 
        ei.IdSucursal,
        0 AS TotalCostoMedComercial, 
        SUM(ei.CantidadRecibida * ei.PrecioUnitario) AS TotalCostoInsumos
    FROM EntregarInsumo ei
    GROUP BY ei.IdSucursal
),
SalariosPorSucursal AS (
    SELECT IdSucursal, SUM(Salario) AS TotalSalarios FROM Medico GROUP BY IdSucursal
    UNION ALL
    SELECT IdSucursal, SUM(Salario) FROM Enfermero GROUP BY IdSucursal
    UNION ALL
    SELECT IdSucursal, SUM(Salario) FROM Farmaceutico GROUP BY IdSucursal
    UNION ALL
    SELECT IdSucursal, SUM(Salario) FROM Cajero GROUP BY IdSucursal
    UNION ALL
    SELECT IdSucursal, SUM(Salario) FROM Aseador GROUP BY IdSucursal
    UNION ALL
    SELECT IdSucursal, SUM(Salario) FROM Cuidador GROUP BY IdSucursal
)
SELECT 
    s.IdSucursal,
    s.NombreSucursal,
    s.Estado,
    COALESCE(vs.TotalVentasMedComercial, 0) + 
    COALESCE(vs.TotalVentasMedPreparado, 0) + 
    COALESCE(vs.TotalVentasConsultas, 0) AS IngresosTotales,
    COALESCE(cs.TotalCostoMedComercial, 0) + COALESCE(cs.TotalCostoInsumos, 0) AS CostoProductos,
    COALESCE(ss.TotalSalarios, 0) AS GastosNomina,
    (COALESCE(vs.TotalVentasMedComercial, 0) + COALESCE(vs.TotalVentasMedPreparado, 0) + 
     COALESCE(vs.TotalVentasConsultas, 0)) - 
    (COALESCE(cs.TotalCostoMedComercial, 0) + COALESCE(cs.TotalCostoInsumos, 0) + 
     COALESCE(ss.TotalSalarios, 0)) AS GananciaNeta,
    CASE 
        WHEN (COALESCE(vs.TotalVentasMedComercial, 0) + COALESCE(vs.TotalVentasMedPreparado, 0) + 
              COALESCE(vs.TotalVentasConsultas, 0)) - 
             (COALESCE(cs.TotalCostoMedComercial, 0) + COALESCE(cs.TotalCostoInsumos, 0) + 
              COALESCE(ss.TotalSalarios, 0)) >= 0 THEN 'GANANCIA'
        ELSE 'PERDIDA'
    END AS EstadoFinanciero
FROM Sucursal s
LEFT JOIN VentasPorSucursal vs ON s.IdSucursal = vs.IdSucursal
LEFT JOIN CostosPorSucursal cs ON s.IdSucursal = cs.IdSucursal
LEFT JOIN SalariosPorSucursal ss ON s.IdSucursal = ss.IdSucursal
ORDER BY GananciaNeta DESC;




