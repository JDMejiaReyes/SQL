--===============================================================================================
--                                   Disparadores Práctica 10
--===============================================================================================


/*
i. Un trigger que se encargue de actualizar el stock de los productos cada vez que un proveedor provea un
medicamento, cada vez que un farmacéutico cree un medicamento y cada vez que un cliente compre el medicamento.
*/

--FUNCIONES DEL DISPARADOR
-- Función para calcular el stock comercial actual (Entradas - Salidas)
CREATE OR REPLACE FUNCTION fn_calcular_stock_comercial(p_id_medicamento INT)
RETURNS INTEGER AS $$
DECLARE
    v_entradas INTEGER := 0;
    v_salidas INTEGER := 0;
BEGIN
    -- Entradas: Suma de la tabla EntregarMedComercial
    SELECT COALESCE(SUM(CantidadRecibida), 0) INTO v_entradas
    FROM EntregarMedComercial 
    WHERE IdMedicamento = p_id_medicamento;

    -- Salidas: Suma de la tabla TenerMedComercial
    SELECT COALESCE(SUM(CantidadComprada), 0) INTO v_salidas
    FROM TenerMedComercial 
    WHERE IdMedicamento = p_id_medicamento;

    RETURN v_entradas - v_salidas;
END;
$$ LANGUAGE plpgsql;

-- Función para calcular el stock preparado actual (Entradas - Salidas)
CREATE OR REPLACE FUNCTION fn_calcular_stock_preparado(p_id_medicamento INT)
RETURNS INTEGER AS $$
DECLARE
    v_entradas INTEGER := 0;
    v_salidas INTEGER := 0;
BEGIN
    -- Entradas: Suma de la tabla Elaborar
    SELECT COALESCE(SUM(CantidadElaborada), 0) INTO v_entradas
    FROM Elaborar 
    WHERE IdMedicamento = p_id_medicamento;

    -- Salidas: Suma de la tabla TenerMedPreparado
    SELECT COALESCE(SUM(CantidadComprada), 0) INTO v_salidas
    FROM TenerMedPreparado 
    WHERE IdMedicamento = p_id_medicamento;

    RETURN v_entradas - v_salidas;
END;
$$ LANGUAGE plpgsql;

--CREACIÓN DEL DISPARADOR
-- Trigger para validar venta de Medicamentos Comerciales
CREATE OR REPLACE FUNCTION fn_validar_venta_comercial() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.CantidadComprada > fn_calcular_stock_comercial(NEW.IdMedicamento) THEN
        RAISE EXCEPTION 'Stock insuficiente para el medicamento comercial ID %. Stock actual: %', 
            NEW.IdMedicamento, fn_calcular_stock_comercial(NEW.IdMedicamento);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_valida_stock_comercial
BEFORE INSERT ON TenerMedComercial
FOR EACH ROW EXECUTE PROCEDURE fn_validar_venta_comercial();

-- Trigger para validar venta de Medicamentos Preparados
CREATE OR REPLACE FUNCTION fn_validar_venta_preparado() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.CantidadComprada > fn_calcular_stock_preparado(NEW.IdMedicamento) THEN
        RAISE EXCEPTION 'Stock insuficiente para el medicamento preparado ID %. Stock actual: %', 
            NEW.IdMedicamento, fn_calcular_stock_preparado(NEW.IdMedicamento);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_valida_stock_preparado
BEFORE INSERT ON TenerMedPreparado
FOR EACH ROW EXECUTE PROCEDURE fn_validar_venta_preparado();


/*
ii. Un trigger que se encargue de calcular el precio bruto y el precio neto que debe pagar un cliente. Cada
vez que se genere un ticket, se deberá tomar en consideración cuantos tickets antes se generaron en el año
para así poder saber el descuento que se le aplica.
*/

--FUNCIÓN DEL DISPARADOR
CREATE OR REPLACE FUNCTION fn_calcular_descuento_lealtad()
RETURNS TRIGGER AS $$
DECLARE
    v_num_tickets INTEGER;
    v_descuento NUMERIC(5,2) := 0.00;
BEGIN
    -- 1. Contar cuántos tickets previos generó el cliente en el mismo año 
    -- (Excluimos el actual en caso de que sea un UPDATE)
    SELECT COUNT(FolioTicket) INTO v_num_tickets
    FROM Ticket
    WHERE IdCliente = NEW.IdCliente
      AND EXTRACT(YEAR FROM FechaPago) = EXTRACT(YEAR FROM NEW.FechaPago)
      AND FolioTicket IS DISTINCT FROM NEW.FolioTicket;

    -- Sumamos la visita que se está registrando en este momento
    v_num_tickets := v_num_tickets + 1;

    -- 2. Reglas de Negocio del caso de uso: Escala de descuentos
    IF v_num_tickets > 6 THEN
        v_descuento := 0.25;      -- 25% de descuento si acude más de 6 veces
    ELSIF v_num_tickets >= 4 THEN
        v_descuento := 0.10;      -- 10% de descuento si acude 4 o más veces (hasta 6)
    ELSIF v_num_tickets >= 2 THEN
        v_descuento := 0.05;      -- 5% de descuento si acude 2 o más veces (hasta 3)
    ELSE
        v_descuento := 0.00;      -- 0% si es su primera visita en el año
    END IF;

    -- 3. Calcular el Precio Neto final
    NEW.PrecioNeto := NEW.PrecioBruto - (NEW.PrecioBruto * v_descuento);

    -- Retornamos el registro NEW modificado para que PostgreSQL lo guarde
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--CREACIÓN DEL DISPARADOR
CREATE TRIGGER trg_ticket_descuento_lealtad
BEFORE INSERT OR UPDATE OF PrecioBruto ON Ticket
FOR EACH ROW
EXECUTE PROCEDURE fn_calcular_descuento_lealtad();