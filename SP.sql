-- i. Un SP el cual se encarga de registrar un farmaceutico, en este SP, deber ́as introducir la informaci ́on del
-- farmaceutico y se debe de encargar de insertar en la tabla correspondiente, es importante que no permitan
-- la inserci ́on de n ́umero o s ́ımbolos cuando sean campos relacionados a nombres.
CREATE OR REPLACE PROCEDURE registrar_farmaceutico(
    p_RFC VARCHAR,
    p_Nombre VARCHAR,
    p_Paterno VARCHAR,
    p_Materno VARCHAR,
    p_Calle VARCHAR,
    p_NumeroExterior INTEGER,
    p_NumeroInterior INTEGER,
    p_Colonia VARCHAR,
    p_Estado VARCHAR,
    p_Dia VARCHAR,
    p_Entrada TIME,
    p_Salida TIME,
    p_Salario NUMERIC,
    p_IdSucursal INTEGER,
    p_CedulaProfesional INTEGER,
    p_FechaNacimiento DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validación para el Nombre (solo letras con acentos/eñes y espacios intermedios)
    IF p_Nombre !~ '^([A-Za-záéíóúÁÉÍÓÚñÑüÜ]+[ ]?)+$' THEN
        RAISE EXCEPTION 'Error de validación: El nombre "%" no puede contener números ni símbolos.', p_Nombre;
    END IF;

    -- Validación para el Apellido Paterno
    IF p_Paterno !~ '^([A-Za-záéíóúÁÉÍÓÚñÑüÜ]+[ ]?)+$' THEN
        RAISE EXCEPTION 'Error de validación: El apellido paterno "%" no puede contener números ni símbolos.', p_Paterno;
    END IF;

    -- Validación para el Apellido Materno
    IF p_Materno !~ '^([A-Za-záéíóúÁÉÍÓÚñÑüÜ]+[ ]?)+$' THEN
        RAISE EXCEPTION 'Error de validación: El apellido materno "%" no puede contener números ni símbolos.', p_Materno;
    END IF;

    -- Inserción directa en la tabla 'Farmaceutico' usando tus columnas exactas
    INSERT INTO Farmaceutico (
        RFC, Nombre, Paterno, Materno, Calle, NumeroExterior, NumeroInterior,
        Colonia, Estado, Dia, Entrada, Salida, Salario, IdSucursal,
        CedulaProfesional, FechaNacimiento
    )
    VALUES (
        p_RFC, p_Nombre, p_Paterno, p_Materno, p_Calle, p_NumeroExterior, p_NumeroInterior,
        p_Colonia, p_Estado, p_Dia, p_Entrada, p_Salida, p_Salario, p_IdSucursal,
        p_CedulaProfesional, p_FechaNacimiento
    );

    RAISE NOTICE 'Farmacéutico con RFC % registrado exitosamente.', p_RFC;
END;
$$;


-- ii. Un SP que se encargue de eliminar a un producto, a traves de su id, en este SP, se debera elmiminar
-- todas las referencias del producto en las demas tablas.

CREATE OR REPLACE PROCEDURE eliminar_medicamento_comercial(
    p_IdMedicamento INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Eliminar de las recetas donde se prescribió este medicamento comercial
    DELETE FROM PrescribirMedComercial WHERE IdMedicamento = p_IdMedicamento;

    -- 2. Eliminar de los tickets de venta donde se incluyó este medicamento comercial
    DELETE FROM TenerMedComercial WHERE IdMedicamento = p_IdMedicamento;

    -- 3. Eliminar del histórico de recepciones de stock por parte de proveedores
    DELETE FROM EntregarMedComercial WHERE IdMedicamento = p_IdMedicamento;

    -- 4. Finalmente, se elimina del catálogo maestro de medicamentos comerciales
    DELETE FROM MedComercial WHERE IdMedicamento = p_IdMedicamento;

    -- Verificación de existencia
    IF NOT FOUND THEN
        RAISE NOTICE 'El medicamento comercial con ID % no existía.', p_IdMedicamento;
    ELSE
        RAISE NOTICE 'Medicamento Comercial con ID % y sus referencias en recetas, ventas y entregas fueron eliminados correctamente.', p_IdMedicamento;
    END IF;
END;
$$;


CREATE OR REPLACE PROCEDURE eliminar_medicamento_preparado(
    p_IdMedicamento INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Eliminar de las recetas donde se prescribió esta fórmula magistral
    DELETE FROM PrescribirMedPreparado WHERE IdMedicamento = p_IdMedicamento;

    -- 2. Eliminar de los tickets de venta donde se incluyó este preparado
    DELETE FROM TenerMedPreparado WHERE IdMedicamento = p_IdMedicamento;

    -- 3. Eliminar de la bitácora de elaboración donde los farmacéuticos la prepararon
    DELETE FROM Elaborar WHERE IdMedicamento = p_IdMedicamento;

    -- 4. Eliminar de la tabla de composición que detalla qué insumos contiene la fórmula
    DELETE FROM Contener WHERE IdMedicamento = p_IdMedicamento;

    -- 5. Finalmente, se elimina del catálogo maestro de fórmulas preparadas
    DELETE FROM MedPreparado WHERE IdMedicamento = p_IdMedicamento;

    -- Verificación de existencia
    IF NOT FOUND THEN
        RAISE NOTICE 'La fórmula magistral/preparado con ID % no existía.', p_IdMedicamento;
    ELSE
        RAISE NOTICE 'Medicamento Preparado con ID % y sus referencias en recetas, ventas, elaboración y componentes fueron eliminados correctamente.', p_IdMedicamento;
    END IF;
END;
$$;


CREATE OR REPLACE PROCEDURE eliminar_insumo(
    p_IdInsumo INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Eliminar de la tabla de composición que detalla qué insumos contiene la fórmula
    DELETE FROM Contener WHERE IdInsumo = p_IdInsumo;

    -- 2. Eliminar del histórico de recepciones de stock por parte de proveedores
    DELETE FROM EntregarInsumo WHERE IdInsumo = p_IdInsumo;

    -- 3. Finalmente, se elimina del catálogo maestro de insumo
    DELETE FROM Insumo WHERE IdInsumo = p_IdInsumo;

    -- Verificación de existencia
    IF NOT FOUND THEN
        RAISE NOTICE 'El insumo con ID % no existía.', p_IdInsumo;
    ELSE
        RAISE NOTICE 'Insumo con ID % y sus referencias en elaboración y entregas fueron eliminados correctamente.', p_IdInsumo;
    END IF;
END;
$$;