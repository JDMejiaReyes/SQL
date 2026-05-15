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

-- iii. Listar todas las enfermeras cuyo apellido materno termine en Ílo.

SELECT * FROM Cliente 
WHERE Nombre LIKE 'R%';

-- xi.Listar a los vendedores cuyo total de medicamentos vendidos (número de productos distintos que ofrecen) sea mayor a 3.

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
        0 AS TotalCostoInsumos  -- ✅ Cambiado: 0 en lugar de SUM(ei...)
    FROM EntregarMedComercial emc
    GROUP BY emc.IdSucursal
    
    UNION ALL
    
    -- Segunda parte: Solo costos de insumos
    SELECT 
        ei.IdSucursal,
        0 AS TotalCostoMedComercial,  -- ✅ Cambiado: 0 en lugar de SUM(emc...)
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

