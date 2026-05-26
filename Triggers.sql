--===============================================================================================
--                                   Disparadores Práctica 10
--===============================================================================================


/*
i. Un trigger que se encargue de actualizar el stock de los productos cada vez que un proveedor provea un
medicamento, cada vez que un farmaceutico cree un medicamento y cada vez que un cliente compre el medicamento.
*/



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