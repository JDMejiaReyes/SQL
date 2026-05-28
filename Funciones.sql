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
    total_consultas NUMERIC(12,2);
    total_tickets NUMERIC(12,2);
BEGIN

    -- Ganancias de consultas
    SELECT SUM(c.Precio)
    INTO total_consultas
    FROM CobrarConsulta c
    JOIN Medico m ON c.RFCMedico = m.RFC
    WHERE m.IdSucursal = p_IdSucursal
      AND EXTRACT(YEAR FROM c.Fecha) = 2026;

    -- Ganancias de tickets
    SELECT SUM(t.PrecioNeto)
    INTO total_tickets
    FROM Ticket t
    WHERE t.IdSucursal = p_IdSucursal
      AND EXTRACT(YEAR FROM t.FechaPago) = 2026;

    -- Suma final
    RETURN total_consultas + total_tickets;

END;
$$ LANGUAGE plpgsql;

--===============================================================================================
--                       Funciones para implementar las reglas de negocios 
--===============================================================================================
CREATE OR REPLACE FUNCTION fn_calcular_cuenta_ticket(
    p_folio_ticket INTEGER,
    OUT precio_bruto NUMERIC(10,2),
    OUT monto_descuento NUMERIC(10,2),
    OUT precio_neto NUMERIC(10,2)
) 
AS $$
DECLARE
    v_id_cliente INTEGER;
    v_fecha_pago DATE;
    v_visitas_anio INTEGER;
    v_porcentaje_desc NUMERIC(5,2) := 0.00;
    
    v_total_comercial NUMERIC(10,2) := 0.00;
    v_total_preparado NUMERIC(10,2) := 0.00;
    v_total_consulta NUMERIC(10,2) := 0.00;
BEGIN
    -- 1. Obtener el cliente y la fecha del ticket solicitado
    SELECT IdCliente, FechaPago INTO v_id_cliente, v_fecha_pago
    FROM Ticket 
    WHERE FolioTicket = p_folio_ticket;

    -- 2. CALCULAR EL PRECIO BRUTO (Suma de todas las compras vinculadas)
    -- Medicamentos Comerciales
    SELECT COALESCE(SUM(CantidadComprada * PrecioUnitario), 0) INTO v_total_comercial
    FROM TenerMedComercial WHERE FolioTicket = p_folio_ticket;
    
    -- Medicamentos Preparados
    SELECT COALESCE(SUM(CantidadComprada * PrecioUnitario), 0) INTO v_total_preparado
    FROM TenerMedPreparado WHERE FolioTicket = p_folio_ticket;
    
    -- Cobro de Consulta (Si aplica)
    SELECT COALESCE(SUM(Precio), 0) INTO v_total_consulta
    FROM CobrarConsulta WHERE FolioTicket = p_folio_ticket;

    -- Consolidar el Precio Bruto
    precio_bruto := v_total_comercial + v_total_preparado + v_total_consulta;

    -- 3. CALCULAR EL DESCUENTO DE LEALTAD (Regla de negocio)
    -- Contamos los tickets emitidos a este cliente en el mismo año
    SELECT COUNT(FolioTicket) INTO v_visitas_anio
    FROM Ticket
    WHERE IdCliente = v_id_cliente
      AND EXTRACT(YEAR FROM FechaPago) = EXTRACT(YEAR FROM v_fecha_pago);

    -- Escala de descuentos del caso de uso
    IF v_visitas_anio > 6 THEN
        v_porcentaje_desc := 0.25;
    ELSIF v_visitas_anio >= 4 THEN
        v_porcentaje_desc := 0.10;
    ELSIF v_visitas_anio >= 2 THEN
        v_porcentaje_desc := 0.05;
    ELSE
        v_porcentaje_desc := 0.00;
    END IF;

    -- 4. CALCULAR EL PRECIO NETO
    monto_descuento := precio_bruto * v_porcentaje_desc;
    precio_neto := precio_bruto - monto_descuento;

END;
$$ LANGUAGE plpgsql;