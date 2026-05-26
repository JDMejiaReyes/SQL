--===============================================================================================
--                                   Funciones Practica 10
--===============================================================================================
-- i. Una función que reciba el identificador del cliente y nos regrese la edad de los mismos.
CREATE OR REPLACE FUNCTION calcular_edad_cliente(p_id_cliente INTEGER)
RETURNS INTEGER AS $$
DECLARE
    v_edad INTEGER;
BEGIN
    -- Calcular edad con manejo de NULL
    SELECT 
        CASE 
            WHEN FechaNacimiento IS NULL THEN NULL
            ELSE DATE_PART('year', AGE(CURRENT_DATE, FechaNacimiento))::INTEGER
        END
    INTO v_edad
    FROM Cliente
    WHERE IdCliente = p_id_cliente;
    
    -- Si no se encontró el cliente, devolver NULL
    RETURN v_edad;
END;
$$ LANGUAGE plpgsql;


-- ii. Una función que reciba la sucursal y calcule las ganancias que posee durante el año 2026.

CREATE OR REPLACE FUNCTION GananciasSucursal2026(
    p_IdSucursal INTEGER
)
RETURNS NUMERIC(12,2)
AS $$
DECLARE
    total_ganancias NUMERIC(12,2);
BEGIN

    SELECT SUM(c.Precio)
    INTO total_ganancias
    FROM CobrarConsulta c
    JOIN Medico m
        ON c.RFCMedico = m.RFC
    WHERE m.IdSucursal = p_IdSucursal
      AND EXTRACT(YEAR FROM c.Fecha) = 2026;

    RETURN total_ganancias;

END;
$$ LANGUAGE plpgsql;