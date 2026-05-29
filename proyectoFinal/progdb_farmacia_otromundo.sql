-- ======================================================================================
-- PROYECTO FINAL: "Una farmacia de otro mundo" - Equipo Hotline
-- SCRIPT DE DISPARADORES, PROCEDIMIENTOS ALMACENADOS Y FUNCIONES 
-- ======================================================================================

-- ======================================================================================
-- SECCIÓN 1: DISPARADORES (TRIGGERS)
-- ======================================================================================

/* * DISPARADOR 1: Bloqueo de Medicamentos Controlados en Ventas Web
 * * OBJETIVO: 
 * Garantizar el cumplimiento estricto de la regla de negocio que prohíbe la venta 
 * de medicamentos que requieren receta médica a través del portal en línea.
 * * FUNCIONAMIENTO:
 * Se ejecuta ANTES de insertar un producto en el ticket (TenerMedComercial o TenerMedPreparado). 
 * Cruza la información de la tabla Ticket (para saber si el canal es 'Web') y del 
 * catálogo MedComercial o MedPreparado (para verificar el 'TipoControl'). Si detecta una violación, 
 * aborta la transacción.
 */

CREATE OR REPLACE FUNCTION fn_validar_medicamento_web()
RETURNS TRIGGER AS $$
DECLARE
    v_tipo_venta VARCHAR(20);
    v_tipo_control VARCHAR(20);
BEGIN
    -- Identificar si el ticket asociado es una compra por internet
    SELECT TipoVenta INTO v_tipo_venta 
    FROM Ticket 
    WHERE FolioTicket = NEW.FolioTicket;

    -- Si es Web, validar la naturaleza del medicamento
    -- Convertimos a mayúsculas y quitamos espacios por seguridad
    IF UPPER(TRIM(v_tipo_venta)) = 'WEB' THEN
        
        -- Tdentificar la tabla detonante
        IF TG_TABLE_NAME = 'tenermedcomercial' THEN
            -- Obtenemos el tipo de control del medicamento
            SELECT TipoControl INTO v_tipo_control 
            FROM MedComercial 
            WHERE IdMedicamento = NEW.IdMedicamento;
            
        ELSIF TG_TABLE_NAME = 'tenermedpreparado' THEN
            SELECT TipoControl INTO v_tipo_control 
            FROM MedPreparado 
            WHERE IdMedicamento = NEW.IdMedicamento;
        END IF;

        -- Bloquear si no es de venta libre
        -- Comparamos estrictamente en mayúsculas
        IF UPPER(TRIM(v_tipo_control)) != 'VENTA LIBRE' THEN
            RAISE EXCEPTION 'Venta web rechazada: El medicamento ID % de la tabla % requiere receta (Registrado como: %).', 
                NEW.IdMedicamento, TG_TABLE_NAME, v_tipo_control;
        END IF;
        
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--La ejecución se asigna mediante dos disparadores independientes 
--que invocan la misma función centralizada.
CREATE TRIGGER trg_bloquear_controlados_web_comercial
BEFORE INSERT OR UPDATE ON TenerMedComercial
FOR EACH ROW EXECUTE PROCEDURE fn_validar_medicamento_web();

CREATE TRIGGER trg_bloquear_controlados_web_preparado
BEFORE INSERT OR UPDATE ON TenerMedPreparado
FOR EACH ROW EXECUTE PROCEDURE fn_validar_medicamento_web();


/* * DISPARADOR 2: Control de Existencias mediante Validaciones Dinámicas (Stock Derivado)
 * * OBJETIVO: 
 * Garantizar la integridad del inventario de la farmacia en tiempo real. Dado que el 
 * modelo relacional define el "Stock" como un atributo calculado (derivado) para evitar 
 * redundancias e inconsistencias, este disparador actúa como un filtro protector que 
 * impide la venta de medicamentos (comerciales o preparados) si la cantidad solicitada 
 * supera las existencias físicas disponibles.
 * * FUNCIONAMIENTO:
 * Utiliza una arquitectura modular en dos capas:
 * 1. Capa de Cálculo (Funciones auxiliares): Las funciones 'fn_calcular_stock_...' 
 * suman todas las entradas (proveedores o farmacéuticos) y restan las salidas 
 * (ventas) para obtener el balance exacto bajo demanda.
 * 2. Capa de Validación (Triggers): Los disparadores se ejecutan BEFORE INSERT en las 
 * tablas de detalle de los tickets. Invocan a la capa de cálculo y, si el cliente 
 * intenta comprar más unidades de las disponibles, abortan la transacción 
 * lanzando un mensaje de excepción (RAISE EXCEPTION).
 */

-- --------------------------------------------------------------------------------------
-- 1. CAPA DE CÁLCULO (FUNCIONES DEL DISPARADOR)
-- --------------------------------------------------------------------------------------

-- Función auxiliar para calcular el stock comercial actual (Entradas - Salidas)
CREATE OR REPLACE FUNCTION fn_calcular_stock_comercial(p_id_medicamento INT)
RETURNS INTEGER AS $$
DECLARE
    v_entradas INTEGER := 0;
    v_salidas INTEGER := 0;
BEGIN
    -- Entradas: Suma de la tabla EntregarMedComercial (Abastecimiento de proveedores)
    SELECT COALESCE(SUM(CantidadRecibida), 0) INTO v_entradas
    FROM EntregarMedComercial 
    WHERE IdMedicamento = p_id_medicamento;

    -- Salidas: Suma de la tabla TenerMedComercial (Ventas a clientes)
    SELECT COALESCE(SUM(CantidadComprada), 0) INTO v_salidas
    FROM TenerMedComercial 
    WHERE IdMedicamento = p_id_medicamento;

    RETURN v_entradas - v_salidas;
END;
$$ LANGUAGE plpgsql;

-- Función auxiliar para calcular el stock preparado actual (Entradas - Salidas)
CREATE OR REPLACE FUNCTION fn_calcular_stock_preparado(p_id_medicamento INT)
RETURNS INTEGER AS $$
DECLARE
    v_entradas INTEGER := 0;
    v_salidas INTEGER := 0;
BEGIN
    -- Entradas: Suma de la tabla Elaborar (Fabricación por farmacéuticos)
    SELECT COALESCE(SUM(CantidadElaborada), 0) INTO v_entradas
    FROM Elaborar 
    WHERE IdMedicamento = p_id_medicamento;

    -- Salidas: Suma de la tabla TenerMedPreparado (Ventas a clientes)
    SELECT COALESCE(SUM(CantidadComprada), 0) INTO v_salidas
    FROM TenerMedPreparado 
    WHERE IdMedicamento = p_id_medicamento;

    RETURN v_entradas - v_salidas;
END;
$$ LANGUAGE plpgsql;


-- --------------------------------------------------------------------------------------
-- 2. CAPA DE VALIDACIÓN (CREACIÓN DE LOS DISPARADORES)
-- --------------------------------------------------------------------------------------

-- Función validadora para venta de Medicamentos Comerciales
CREATE OR REPLACE FUNCTION fn_validar_venta_comercial() RETURNS TRIGGER AS $$
BEGIN
    -- Si lo comprado supera el balance calculado, bloquea la venta
    IF NEW.CantidadComprada > fn_calcular_stock_comercial(NEW.IdMedicamento) THEN
        RAISE EXCEPTION 'Regla de negocio: Stock insuficiente para el medicamento comercial ID %. Stock actual: %', 
            NEW.IdMedicamento, fn_calcular_stock_comercial(NEW.IdMedicamento);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger asociado a la tabla TenerMedComercial
CREATE TRIGGER trg_valida_stock_comercial
BEFORE INSERT ON TenerMedComercial
FOR EACH ROW EXECUTE PROCEDURE fn_validar_venta_comercial();


-- Función validadora para venta de Medicamentos Preparados
CREATE OR REPLACE FUNCTION fn_validar_venta_preparado() RETURNS TRIGGER AS $$
BEGIN
    -- Si lo comprado supera el balance calculado, bloquea la venta
    IF NEW.CantidadComprada > fn_calcular_stock_preparado(NEW.IdMedicamento) THEN
        RAISE EXCEPTION 'Regla de negocio: Stock insuficiente para el medicamento preparado ID %. Stock actual: %', 
            NEW.IdMedicamento, fn_calcular_stock_preparado(NEW.IdMedicamento);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger asociado a la tabla TenerMedPreparado
CREATE TRIGGER trg_valida_stock_preparado
BEFORE INSERT ON TenerMedPreparado
FOR EACH ROW EXECUTE PROCEDURE fn_validar_venta_preparado();


-- ======================================================================================
-- SECCIÓN 2: PROCEDIMIENTOS ALMACENADOS 
-- ======================================================================================

/* * PROCEDIMIENTO 1: Corte de Caja Diario Dinámico
 * * OBJETIVO: 
 * Generar un reporte financiero del total de ingresos de un día específico.
 * * FUNCIONAMIENTO:
 * Dado que en el Modelo E-R los atributos de precios del Ticket son derivados, este 
 * SP calcula el total real multiplicando la "Cantidad Comprada" por el "Precio Unitario" 
 * directamente desde las tablas de detalles (TenerMedComercial, TenerMedPreparado, CobrarConsulta), 
 * uniendo la información con los tickets emitidos en la fecha solicitada.
 */

CREATE OR REPLACE PROCEDURE sp_corte_caja_diario(p_fecha_corte DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_comercial NUMERIC(12,2) := 0.00;
    v_total_preparado NUMERIC(12,2) := 0.00;
    v_total_consulta NUMERIC(12,2) := 0.00;
    v_gran_total NUMERIC(12,2) := 0.00;
BEGIN
    -- Calcular ingresos por Medicamentos Comerciales
    SELECT COALESCE(SUM(tmc.CantidadComprada * tmc.PrecioUnitario), 0) 
    INTO v_total_comercial
    FROM TenerMedComercial tmc
    JOIN Ticket t ON tmc.FolioTicket = t.FolioTicket
    WHERE t.FechaPago = p_fecha_corte;

    -- Calcular ingresos por Fórmulas Magistrales (Preparados)
    SELECT COALESCE(SUM(tmp.CantidadComprada * tmp.PrecioUnitario), 0) 
    INTO v_total_preparado
    FROM TenerMedPreparado tmp
    JOIN Ticket t ON tmp.FolioTicket = t.FolioTicket
    WHERE t.FechaPago = p_fecha_corte;

    -- Calcular ingresos por Consultas Médicas
    SELECT COALESCE(SUM(cc.Precio), 0) 
    INTO v_total_consulta
    FROM CobrarConsulta cc
    JOIN Ticket t ON cc.FolioTicket = t.FolioTicket
    WHERE t.FechaPago = p_fecha_corte;

    -- Consolidar el Total Final
    v_gran_total := v_total_comercial + v_total_preparado + v_total_consulta;

    -- Imprimir el desglose financiero en la consola
    RAISE NOTICE '==================================================';
    RAISE NOTICE '       CORTE DE CAJA: %', p_fecha_corte;
    RAISE NOTICE '==================================================';
    RAISE NOTICE 'Ingresos por Comerciales: $ %', v_total_comercial;
    RAISE NOTICE 'Ingresos por Preparados:  $ %', v_total_preparado;
    RAISE NOTICE 'Ingresos por Consultas:   $ %', v_total_consulta;
    RAISE NOTICE '--------------------------------------------------';
    RAISE NOTICE 'TOTAL DEL DÍA:       $ %', v_gran_total;
    RAISE NOTICE '==================================================';
END;
$$;


/* * PROCEDIMIENTO 2: Reporte de Alerta de Reabastecimiento (Stock Crítico)
 * * OBJETIVO: 
 * Auxiliar al gerente de la farmacia identificando qué medicamentos comerciales 
 * están a punto de agotarse o ya se agotaron, para solicitar a los proveedores.
 * * FUNCIONAMIENTO:
 * Recibe un parámetro numérico "p_limite" (ej. 5 unidades). Recorre el catálogo de 
 * medicamentos comerciales, calcula el stock de cada uno mediante el enfoque de 
 * atributo derivado, y si el stock es menor o igual al límite, lo imprime en el reporte.
 */

CREATE OR REPLACE PROCEDURE sp_reporte_stock_critico(p_limite INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    -- Cursor para recorrer los medicamentos
    r RECORD;
    v_stock_calculado INTEGER;
    v_entradas INTEGER;
    v_salidas INTEGER;
BEGIN
    RAISE NOTICE '==================================================';
    RAISE NOTICE ' REPORTE DE STOCK CRÍTICO (Alerta de % unidades)', p_limite;
    RAISE NOTICE '==================================================';

    FOR r IN SELECT IdMedicamento, NombreComercial FROM MedComercial LOOP
        
        -- Calcular Entradas
        SELECT COALESCE(SUM(CantidadRecibida), 0) INTO v_entradas
        FROM EntregarMedComercial WHERE IdMedicamento = r.IdMedicamento;

        -- Calcular Salidas
        SELECT COALESCE(SUM(CantidadComprada), 0) INTO v_salidas 
        FROM TenerMedComercial WHERE IdMedicamento = r.IdMedicamento;

        -- Balance
        v_stock_calculado := v_entradas - v_salidas;

        -- Evaluar si requiere reabastecimiento
        IF v_stock_calculado <= p_limite THEN
            RAISE NOTICE 'ALERTA -> ID: % | Nombre: % | Stock Restante: %', 
                r.IdMedicamento, r.NombreComercial, v_stock_calculado;
        END IF;

    END LOOP;
    
    RAISE NOTICE '==================================================';
    RAISE NOTICE ' Fin del reporte.';
END;
$$;

-- ======================================================================================
-- SECCIÓN 3: Funciones (Extra)
-- ======================================================================================

/* * FUNCIÓN 1: Cálculo Dinámico de Totales y Programa de Lealtad (Atributos Derivados)
 * * OBJETIVO: 
 * Generar al momento los totales financieros de una transacción, respetando la 
 * normalización del Modelo E-R Extendido donde el "Precio Bruto" y el "Precio Neto" 
 * se definieron como atributos derivados. Adicionalmente, automatiza las reglas 
 * del programa de lealtad de la farmacia.
 * * FUNCIONAMIENTO:
 * La función recibe el folio de un ticket (p_folio_ticket) y retorna tres parámetros 
 * de salida (OUT). Su ejecución se divide en tres fases:
 * 1. Consolidación del Precio Bruto: Suma los importes individuales multiplicando 
 * cantidad por precio unitario desde las tablas de detalle (TenerMedComercial, 
 * TenerMedPreparado y CobrarConsulta).
 * 2. Evaluación de Lealtad: Cuenta el histórico de visitas (tickets) del cliente 
 * asociado durante el año en curso para determinar la escala de descuento 
 * correspondiente (5%, 10% o 25%).
 * 3. Cálculo Neto: Aplica el porcentaje de descuento al precio bruto y retorna 
 * el desglose financiero exacto de la compra.
 */

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
    -- Obtener el cliente y la fecha del ticket solicitado
    SELECT IdCliente, FechaPago INTO v_id_cliente, v_fecha_pago
    FROM Ticket 
    WHERE FolioTicket = p_folio_ticket;

    -- CALCULAR EL PRECIO BRUTO (Suma de todas las compras vinculadas)
    
    -- Medicamentos Comerciales
    SELECT COALESCE(SUM(CantidadComprada * PrecioUnitario), 0) INTO v_total_comercial
    FROM TenerMedComercial WHERE FolioTicket = p_folio_ticket;
    
    -- Medicamentos Preparados
    SELECT COALESCE(SUM(CantidadComprada * PrecioUnitario), 0) INTO v_total_preparado
    FROM TenerMedPreparado WHERE FolioTicket = p_folio_ticket;
    
    -- Cobro de Consulta médica (Si aplica)
    SELECT COALESCE(SUM(Precio), 0) INTO v_total_consulta
    FROM CobrarConsulta WHERE FolioTicket = p_folio_ticket;

    -- Consolidar el Precio Bruto
    precio_bruto := v_total_comercial + v_total_preparado + v_total_consulta;

    -- CALCULAR EL DESCUENTO DE LEALTAD (Regla de negocio)
    
    -- Contar los tickets emitidos a este cliente en el mismo año
    SELECT COUNT(FolioTicket) INTO v_visitas_anio
    FROM Ticket
    WHERE IdCliente = v_id_cliente AND EXTRACT(YEAR FROM FechaPago) = EXTRACT(YEAR FROM v_fecha_pago);

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

    -- CALCULAR EL PRECIO NETO
    monto_descuento := precio_bruto * v_porcentaje_desc;
    precio_neto := precio_bruto - monto_descuento;

END;
$$ LANGUAGE plpgsql;