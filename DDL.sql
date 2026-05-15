DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;


-- =================================================================
--                             MÓDULO 1 
-- =================================================================

-- Tabla 1
CREATE TABLE Sucursal (
    IdSucursal SERIAL,
    NombreSucursal VARCHAR(50),
    Calle VARCHAR(50),
    NumeroExterior INTEGER,
    NumeroInterior INTEGER,
    Colonia VARCHAR(50),
    Estado VARCHAR(30),
    Telefono VARCHAR(15)
);

-- PK
ALTER TABLE Sucursal ADD CONSTRAINT Sucursal_pk
PRIMARY KEY (IdSucursal);

-- Restricciones
ALTER TABLE Sucursal
ALTER COLUMN NombreSucursal SET NOT NULL,
ALTER COLUMN Calle SET NOT NULL,
ALTER COLUMN NumeroExterior SET NOT NULL,
ALTER COLUMN Colonia SET NOT NULL,
ALTER COLUMN Estado SET NOT NULL,
ALTER COLUMN Telefono SET NOT NULL;

-- =================================================================
--                      BLOQUE DE CORRECCIONES 
-- =================================================================
-- Se agrega restricción a NumeroInterior CHECK es NULL o mayor a cero
ALTER TABLE Sucursal
ADD CONSTRAINT Sucursal_d1 CHECK (NumeroInterior IS NULL OR NumeroInterior > 0),
-- Se agrega restricción a NumeroExterior CHECK es mayor a cero
ADD CONSTRAINT Sucursal_d2 CHECK (NumeroExterior > 0);

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Sucursal IS 'Tabla que almacena la ubicación y contacto de las sucursales del sistema Hotline.';

-- Comentarios de Columnas
COMMENT ON COLUMN Sucursal.IdSucursal IS 'Identificador único de la sucursal.';
COMMENT ON COLUMN Sucursal.NombreSucursal IS 'Nombre comercial o distintivo de la sucursal.';
COMMENT ON COLUMN Sucursal.Calle IS 'Calle donde se ubica la sucursal.';
COMMENT ON COLUMN Sucursal.NumeroExterior IS 'Número exterior del inmueble.';
COMMENT ON COLUMN Sucursal.NumeroInterior IS 'Número interior del inmueble (si aplica).';
COMMENT ON COLUMN Sucursal.Colonia IS 'Colonia donde se encuentra la sucursal.';
COMMENT ON COLUMN Sucursal.Estado IS 'Estado de la República donde se ubica.';
COMMENT ON COLUMN Sucursal.Telefono IS 'Número telefónico de contacto de la sucursal.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Sucursal_pk ON Sucursal IS 'Llave primaria: Identificador único autoincremental de la sucursal.';
COMMENT ON CONSTRAINT Sucursal_d1 ON Sucursal IS 'Validación: El número interior debe ser positivo si existe.';
COMMENT ON CONSTRAINT Sucursal_d2 ON Sucursal IS 'Validación: El número exterior debe ser estrictamente positivo.';


-- Tabla 2
CREATE TABLE Clinica (
    IdClinica SERIAL,
    NombreClinica VARCHAR(50),
    NumCuarto INTEGER,
    NumEmpleado INTEGER,
    IdSucursal INTEGER
);

-- PK
ALTER TABLE Clinica ADD CONSTRAINT Clinica_pk
PRIMARY KEY (IdClinica);

-- FK
ALTER TABLE Clinica ADD CONSTRAINT Clinica_fk
FOREIGN KEY (IdSucursal) REFERENCES Sucursal(IdSucursal)
ON UPDATE CASCADE ON DELETE RESTRICT;

-- Restricciones
ALTER TABLE Clinica
ALTER COLUMN NombreClinica SET NOT NULL,
ALTER COLUMN NumCuarto SET NOT NULL,
ADD CONSTRAINT Clinica_d1 CHECK (NumCuarto > 0),
ALTER COLUMN NumEmpleado SET NOT NULL,
ALTER COLUMN IdSucursal SET NOT NULL,
ADD CONSTRAINT Clinica_u1 UNIQUE (IdSucursal);

-- =================================================================
--                      BLOQUE DE CORRECCIONES 
-- =================================================================
-- Se elimina porque el número de empleados se calcula con funciones de agregación (DQL)
ALTER TABLE Clinica DROP COLUMN NumEmpleado;

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Clinica IS 'Tabla que representa las clínicas médicas integradas dentro de una sucursal.';

-- Comentarios de Columnas
COMMENT ON COLUMN Clinica.IdClinica IS 'Identificador único de la clínica.';
COMMENT ON COLUMN Clinica.NombreClinica IS 'Nombre distintivo de la clínica.';
COMMENT ON COLUMN Clinica.NumCuarto IS 'Número de cuarto o consultorio asignado.';
COMMENT ON COLUMN Clinica.IdSucursal IS 'Identificador de la sucursal a la que pertenece la clínica.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Clinica_pk ON Clinica IS 'Llave primaria: Identificador de la clínica.';
COMMENT ON CONSTRAINT Clinica_fk ON Clinica IS 'Llave foránea: Vinculación obligatoria con una sucursal.';
COMMENT ON CONSTRAINT Clinica_d1 ON Clinica IS 'Validación: El número de cuarto asignado debe ser positivo.';
COMMENT ON CONSTRAINT Clinica_u1 ON Clinica IS 'Restricción: Garantiza que una sucursal solo tenga una clínica (relación 1:1).';

-- Tabla 3
CREATE TABLE Medico (
    RFC VARCHAR(13),
    Nombre VARCHAR(50),
    Paterno VARCHAR(50),
    Materno VARCHAR(50),
    Calle VARCHAR(50),
    NumeroExterior INTEGER,
    NumeroInterior INTEGER,
    Colonia VARCHAR(50),
    Estado VARCHAR(30),
    Dia VARCHAR(15),
    Entrada TIME,
    Salida TIME,
    Salario NUMERIC(10, 2),
    IdSucursal INTEGER,
    InstitucionEgreso VARCHAR(100),
    VigenciaCertificacion DATE,
    CedulaProfesional INTEGER
);

-- PK
ALTER TABLE Medico ADD CONSTRAINT Medico_pk
PRIMARY KEY (RFC);

-- FK
ALTER TABLE Medico ADD CONSTRAINT Medico_fk
FOREIGN KEY (IdSucursal) REFERENCES Sucursal(IdSucursal)
ON UPDATE CASCADE ON DELETE RESTRICT;

-- Restricciones
ALTER TABLE Medico
ALTER COLUMN RFC SET NOT NULL,
ALTER COLUMN Nombre SET NOT NULL,
ALTER COLUMN Paterno SET NOT NULL,
ALTER COLUMN Materno SET NOT NULL,
ALTER COLUMN Calle SET NOT NULL,
ALTER COLUMN NumeroExterior SET NOT NULL,
ALTER COLUMN Colonia SET NOT NULL,
ALTER COLUMN Estado SET NOT NULL,
ALTER COLUMN Dia SET NOT NULL,
ALTER COLUMN Entrada SET NOT NULL,
ALTER COLUMN Salida SET NOT NULL,
ALTER COLUMN Salario SET NOT NULL,
ADD CONSTRAINT Medico_d1 CHECK (Salario > 0),
ALTER COLUMN IdSucursal SET NOT NULL,
ALTER COLUMN InstitucionEgreso SET NOT NULL,
ALTER COLUMN VigenciaCertificacion SET NOT NULL,
ALTER COLUMN CedulaProfesional SET NOT NULL,
ADD CONSTRAINT Medico_u1 UNIQUE (CedulaProfesional);

-- =================================================================
--                      BLOQUE DE CORRECCIONES 
-- =================================================================
-- Se agrega restricción a NumeroInterior CHECK es NULL o mayor a cero
ALTER TABLE Medico
ADD CONSTRAINT Medico_d2 CHECK (NumeroInterior IS NULL OR NumeroInterior > 0),
-- Se agrega restricción a NumeroExterior CHECK es mayor a cero
ADD CONSTRAINT Medico_d3 CHECK (NumeroExterior > 0);

-- =================================================================
--                    BLOQUE DE ADICIONES PARA P07 
-- =================================================================
-- Se agrega el atributo fecha de nacimiento y se agrega la restricción NOT NULL
-- junto con la restricción CHECK FechaNacimiento <= CURRENT_DATE
ALTER TABLE Medico
ADD COLUMN FechaNacimiento DATE NOT NULL,
ADD CONSTRAINT Medico_d4 CHECK (FechaNacimiento <= CURRENT_DATE);
COMMENT ON CONSTRAINT Medico_d4 ON Medico IS 'Validación: La fecha de nacimiento no puede ser futura.';

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Medico IS 'Tabla que almacena la información detallada del personal médico.';

-- Comentarios de Columnas
COMMENT ON COLUMN Medico.RFC IS 'Registro Federal de Contribuyentes del médico.';
COMMENT ON COLUMN Medico.Nombre IS 'Nombre(s) del médico.';
COMMENT ON COLUMN Medico.Paterno IS 'Apellido paterno del médico.';
COMMENT ON COLUMN Medico.Materno IS 'Apellido materno del médico.';
COMMENT ON COLUMN Medico.Calle IS 'Calle del domicilio del médico.';
COMMENT ON COLUMN Medico.NumeroExterior IS 'Número exterior del domicilio.';
COMMENT ON COLUMN Medico.NumeroInterior IS 'Número interior del domicilio.';
COMMENT ON COLUMN Medico.Colonia IS 'Colonia del domicilio.';
COMMENT ON COLUMN Medico.Estado IS 'Estado del domicilio.';
COMMENT ON COLUMN Medico.Dia IS 'Día de la semana de la jornada laboral.';
COMMENT ON COLUMN Medico.Entrada IS 'Hora de entrada al turno.';
COMMENT ON COLUMN Medico.Salida IS 'Hora de salida del turno.';
COMMENT ON COLUMN Medico.Salario IS 'Salario asignado al médico.';
COMMENT ON COLUMN Medico.IdSucursal IS 'Sucursal donde labora el médico.';
COMMENT ON COLUMN Medico.InstitucionEgreso IS 'Institución educativa donde egresó el médico.';
COMMENT ON COLUMN Medico.VigenciaCertificacion IS 'Fecha de vencimiento de la certificación médica.';
COMMENT ON COLUMN Medico.CedulaProfesional IS 'Número de cédula profesional del médico.';
COMMENT ON COLUMN Medico.FechaNacimiento IS 'Fecha de nacimiento del médico.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Medico_pk ON Medico IS 'Llave primaria: RFC del médico.';
COMMENT ON CONSTRAINT Medico_fk ON Medico IS 'Llave foránea: Sucursal de adscripción.';
COMMENT ON CONSTRAINT Medico_d1 ON Medico IS 'Validación: El salario debe ser estrictamente positivo.';
COMMENT ON CONSTRAINT Medico_u1 ON Medico IS 'Restricción: Garantiza la unicidad de la cédula profesional.';
COMMENT ON CONSTRAINT Medico_d2 ON Medico IS 'Validación: El número interior debe ser positivo si existe.';
COMMENT ON CONSTRAINT Medico_d3 ON Medico IS 'Validación: El número exterior debe ser estrictamente positivo.';


-- Tabla 4
CREATE TABLE Enfermero (
    RFC VARCHAR(13),
    Nombre VARCHAR(50),
    Paterno VARCHAR(50),
    Materno VARCHAR(50),
    Calle VARCHAR(50),
    NumeroExterior INTEGER,
    NumeroInterior INTEGER,
    Colonia VARCHAR(50),
    Estado VARCHAR(30),
    Dia VARCHAR(15),
    Entrada TIME,
    Salida TIME,
    Salario NUMERIC(10, 2),
    IdSucursal INTEGER,
    TipoProcedimientoCargo VARCHAR(100),
    CertificacionReanimacion BOOLEAN,
    CedulaProfesional INTEGER
);

-- PK
ALTER TABLE Enfermero ADD CONSTRAINT Enfermero_pk
PRIMARY KEY (RFC);

-- FK
ALTER TABLE Enfermero ADD CONSTRAINT Enfermero_fk
FOREIGN KEY (IdSucursal) REFERENCES Sucursal(IdSucursal)
ON UPDATE CASCADE ON DELETE RESTRICT;

-- Restricciones
ALTER TABLE Enfermero
ALTER COLUMN RFC SET NOT NULL,
ALTER COLUMN Nombre SET NOT NULL,
ALTER COLUMN Paterno SET NOT NULL,
ALTER COLUMN Materno SET NOT NULL,
ALTER COLUMN Calle SET NOT NULL,
ALTER COLUMN NumeroExterior SET NOT NULL,
ALTER COLUMN Colonia SET NOT NULL,
ALTER COLUMN Estado SET NOT NULL,
ALTER COLUMN Dia SET NOT NULL,
ALTER COLUMN Entrada SET NOT NULL,
ALTER COLUMN Salida SET NOT NULL,
ALTER COLUMN Salario SET NOT NULL,
ADD CONSTRAINT Enfermero_d1 CHECK (Salario > 0),
ALTER COLUMN IdSucursal SET NOT NULL,
ALTER COLUMN TipoProcedimientoCargo SET NOT NULL,
ALTER COLUMN CertificacionReanimacion SET NOT NULL,
ALTER COLUMN CedulaProfesional SET NOT NULL,
ADD CONSTRAINT Enfermero_u1 UNIQUE (CedulaProfesional);

-- =================================================================
--                      BLOQUE DE CORRECCIONES 
-- =================================================================
-- Se agrega restricción a NumeroInterior CHECK es NULL o mayor a cero
ALTER TABLE Enfermero
ADD CONSTRAINT Enfermero_d2 CHECK (NumeroInterior IS NULL OR NumeroInterior > 0),
-- Se agrega restricción a NumeroExterior CHECK es mayor a cero
ADD CONSTRAINT Enfermero_d3 CHECK (NumeroExterior > 0);

-- =================================================================
--                    BLOQUE DE ADICIONES PARA P07 
-- =================================================================
-- Se agrega el atributo fecha de nacimiento y se agrega la restricción NOT NULL
-- junto con la restricción CHECK FechaNacimiento <= CURRENT_DATE
ALTER TABLE Enfermero
ADD COLUMN FechaNacimiento DATE NOT NULL,
ADD CONSTRAINT Enfermero_d4 CHECK (FechaNacimiento <= CURRENT_DATE);
COMMENT ON CONSTRAINT Enfermero_d4 ON Enfermero IS 'Validación: La fecha de nacimiento no puede ser futura.';

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Enfermero IS 'Tabla que registra al personal de enfermería y sus certificaciones.';

-- Comentarios de Columnas
COMMENT ON COLUMN Enfermero.RFC IS 'Registro Federal de Contribuyentes del enfermero.';
COMMENT ON COLUMN Enfermero.Nombre IS 'Nombre(s) del enfermero.';
COMMENT ON COLUMN Enfermero.Paterno IS 'Apellido paterno del enfermero.';
COMMENT ON COLUMN Enfermero.Materno IS 'Apellido materno del enfermero.';
COMMENT ON COLUMN Enfermero.Calle IS 'Calle del domicilio del enfermero.';
COMMENT ON COLUMN Enfermero.NumeroExterior IS 'Número exterior del domicilio.';
COMMENT ON COLUMN Enfermero.NumeroInterior IS 'Número interior del domicilio.';
COMMENT ON COLUMN Enfermero.Colonia IS 'Colonia del domicilio.';
COMMENT ON COLUMN Enfermero.Estado IS 'Estado del domicilio.';
COMMENT ON COLUMN Enfermero.Dia IS 'Día de la semana de la jornada laboral.';
COMMENT ON COLUMN Enfermero.Entrada IS 'Hora de entrada al turno.';
COMMENT ON COLUMN Enfermero.Salida IS 'Hora de salida del turno.';
COMMENT ON COLUMN Enfermero.Salario IS 'Salario asignado al enfermero.';
COMMENT ON COLUMN Enfermero.IdSucursal IS 'Sucursal donde labora el enfermero.';
COMMENT ON COLUMN Enfermero.TipoProcedimientoCargo IS 'Especialidad o tipo de procedimiento a cargo.';
COMMENT ON COLUMN Enfermero.CertificacionReanimacion IS 'Indica si cuenta con certificación en reanimación (RCP).';
COMMENT ON COLUMN Enfermero.CedulaProfesional IS 'Número de cédula profesional del enfermero.';
COMMENT ON COLUMN Enfermero.FechaNacimiento IS 'Fecha de nacimiento del enfermero.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Enfermero_pk ON Enfermero IS 'Llave primaria: RFC del enfermero.';
COMMENT ON CONSTRAINT Enfermero_fk ON Enfermero IS 'Llave foránea: Sucursal donde labora.';
COMMENT ON CONSTRAINT Enfermero_d1 ON Enfermero IS 'Validación: El salario debe ser positivo.';
COMMENT ON CONSTRAINT Enfermero_u1 ON Enfermero IS 'Restricción: Unicidad de la cédula profesional del enfermero.';
COMMENT ON CONSTRAINT Enfermero_d2 ON Enfermero IS 'Validación: Número interior positivo o nulo.';
COMMENT ON CONSTRAINT Enfermero_d3 ON Enfermero IS 'Validación: Número exterior estrictamente positivo.';

-- Tabla 5
CREATE TABLE Farmaceutico (
    RFC VARCHAR(13),
    Nombre VARCHAR(50),
    Paterno VARCHAR(50),
    Materno VARCHAR(50),
    Calle VARCHAR(50),
    NumeroExterior INTEGER,
    NumeroInterior INTEGER,
    Colonia VARCHAR(50),
    Estado VARCHAR(30),
    Dia VARCHAR(15),
    Entrada TIME,
    Salida TIME,
    Salario NUMERIC(10, 2),
    IdSucursal INTEGER,
    CedulaProfesional INTEGER
);

-- PK
ALTER TABLE Farmaceutico ADD CONSTRAINT Farmaceutico_pk
PRIMARY KEY (RFC);

-- FK
ALTER TABLE Farmaceutico ADD CONSTRAINT Farmaceutico_fk
FOREIGN KEY (IdSucursal) REFERENCES Sucursal(IdSucursal)
ON UPDATE CASCADE ON DELETE RESTRICT;

-- Restricciones
ALTER TABLE Farmaceutico
ALTER COLUMN RFC SET NOT NULL,
ALTER COLUMN Nombre SET NOT NULL,
ALTER COLUMN Paterno SET NOT NULL,
ALTER COLUMN Materno SET NOT NULL,
ALTER COLUMN Calle SET NOT NULL,
ALTER COLUMN NumeroExterior SET NOT NULL,
ALTER COLUMN Colonia SET NOT NULL,
ALTER COLUMN Estado SET NOT NULL,
ALTER COLUMN Dia SET NOT NULL,
ALTER COLUMN Entrada SET NOT NULL,
ALTER COLUMN Salida SET NOT NULL,
ALTER COLUMN Salario SET NOT NULL,
ADD CONSTRAINT Farmaceutico_d1 CHECK (Salario > 0),
ALTER COLUMN IdSucursal SET NOT NULL,
ALTER COLUMN CedulaProfesional SET NOT NULL,
ADD CONSTRAINT Farmaceutico_u1 UNIQUE (CedulaProfesional);

-- =================================================================
--                      BLOQUE DE CORRECCIONES 
-- =================================================================
-- Se agrega restricción a NumeroInterior CHECK es NULL o mayor a cero
ALTER TABLE Farmaceutico
ADD CONSTRAINT Farmaceutico_d2 CHECK (NumeroInterior IS NULL OR NumeroInterior > 0),
-- Se agrega restricción a NumeroExterior CHECK es mayor a cero
ADD CONSTRAINT Farmaceutico_d3 CHECK (NumeroExterior > 0);

-- =================================================================
--                    BLOQUE DE ADICIONES PARA P07 
-- =================================================================
-- Se agrega el atributo fecha de nacimiento y se agrega la restricción NOT NULL
-- junto con la restricción CHECK FechaNacimiento <= CURRENT_DATE
ALTER TABLE Farmaceutico
ADD COLUMN FechaNacimiento DATE NOT NULL,
ADD CONSTRAINT Farmaceutico_d4 CHECK (FechaNacimiento <= CURRENT_DATE);
COMMENT ON CONSTRAINT Farmaceutico_d4 ON Farmaceutico IS 'Validación: La fecha de nacimiento no puede ser futura.';

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Farmaceutico IS 'Tabla que almacena los datos de los responsables de farmacia.';

-- Comentarios de Columnas
COMMENT ON COLUMN Farmaceutico.RFC IS 'Registro Federal de Contribuyentes del farmacéutico.';
COMMENT ON COLUMN Farmaceutico.Nombre IS 'Nombre(s) del farmacéutico.';
COMMENT ON COLUMN Farmaceutico.Paterno IS 'Apellido paterno del farmacéutico.';
COMMENT ON COLUMN Farmaceutico.Materno IS 'Apellido materno del farmacéutico.';
COMMENT ON COLUMN Farmaceutico.Calle IS 'Calle del domicilio del farmacéutico.';
COMMENT ON COLUMN Farmaceutico.NumeroExterior IS 'Número exterior del domicilio.';
COMMENT ON COLUMN Farmaceutico.NumeroInterior IS 'Número interior del domicilio.';
COMMENT ON COLUMN Farmaceutico.Colonia IS 'Colonia del domicilio.';
COMMENT ON COLUMN Farmaceutico.Estado IS 'Estado del domicilio.';
COMMENT ON COLUMN Farmaceutico.Dia IS 'Día de la semana de la jornada laboral.';
COMMENT ON COLUMN Farmaceutico.Entrada IS 'Hora de entrada al turno.';
COMMENT ON COLUMN Farmaceutico.Salida IS 'Hora de salida del turno.';
COMMENT ON COLUMN Farmaceutico.Salario IS 'Salario asignado al farmacéutico.';
COMMENT ON COLUMN Farmaceutico.IdSucursal IS 'Sucursal donde labora el farmacéutico.';
COMMENT ON COLUMN Farmaceutico.CedulaProfesional IS 'Número de cédula profesional del farmacéutico.';
COMMENT ON COLUMN Farmaceutico.FechaNacimiento IS 'Fecha de nacimiento del farmacéutico.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Farmaceutico_pk ON Farmaceutico IS 'Llave primaria: RFC del farmacéutico.';
COMMENT ON CONSTRAINT Farmaceutico_fk ON Farmaceutico IS 'Llave foránea: Sucursal asignada.';
COMMENT ON CONSTRAINT Farmaceutico_d1 ON Farmaceutico IS 'Validación: Salario positivo requerido.';
COMMENT ON CONSTRAINT Farmaceutico_u1 ON Farmaceutico IS 'Restricción: Unicidad de la cédula profesional.';
COMMENT ON CONSTRAINT Farmaceutico_d2 ON Farmaceutico IS 'Validación: Número interior válido.';
COMMENT ON CONSTRAINT Farmaceutico_d3 ON Farmaceutico IS 'Validación: Número exterior positivo.';


-- Tabla 6
CREATE TABLE Cajero (
    RFC VARCHAR(13),
    Nombre VARCHAR(50),
    Paterno VARCHAR(50),
    Materno VARCHAR(50),
    Calle VARCHAR(50),
    NumeroExterior INTEGER,
    NumeroInterior INTEGER,
    Colonia VARCHAR(50),
    Estado VARCHAR(30),
    Dia VARCHAR(15),
    Entrada TIME,
    Salida TIME,
    Salario NUMERIC(10, 2),
    IdSucursal INTEGER
);

-- PK
ALTER TABLE Cajero ADD CONSTRAINT Cajero_pk
PRIMARY KEY (RFC);

-- FK
ALTER TABLE Cajero ADD CONSTRAINT Cajero_fk
FOREIGN KEY (IdSucursal) REFERENCES Sucursal(IdSucursal)
ON UPDATE CASCADE ON DELETE RESTRICT;

-- Restricciones
ALTER TABLE Cajero
ALTER COLUMN RFC SET NOT NULL,
ALTER COLUMN Nombre SET NOT NULL,
ALTER COLUMN Paterno SET NOT NULL,
ALTER COLUMN Materno SET NOT NULL,
ALTER COLUMN Calle SET NOT NULL,
ALTER COLUMN NumeroExterior SET NOT NULL,
ALTER COLUMN Colonia SET NOT NULL,
ALTER COLUMN Estado SET NOT NULL,
ALTER COLUMN Dia SET NOT NULL,
ALTER COLUMN Entrada SET NOT NULL,
ALTER COLUMN Salida SET NOT NULL,
ALTER COLUMN Salario SET NOT NULL,
ADD CONSTRAINT Cajero_d1 CHECK (Salario > 0),
ALTER COLUMN IdSucursal SET NOT NULL;

-- =================================================================
--                      BLOQUE DE CORRECCIONES 
-- =================================================================
-- Se agrega restricción a NumeroInterior CHECK es NULL o mayor a cero
ALTER TABLE Cajero
ADD CONSTRAINT Cajero_d2 CHECK (NumeroInterior IS NULL OR NumeroInterior > 0),
-- Se agrega restricción a NumeroExterior CHECK es mayor a cero
ADD CONSTRAINT Cajero_d3 CHECK (NumeroExterior > 0);

-- =================================================================
--                    BLOQUE DE ADICIONES PARA P07 
-- =================================================================
-- Se agrega el atributo fecha de nacimiento y se agrega la restricción NOT NULL
-- junto con la restricción CHECK FechaNacimiento <= CURRENT_DATE
ALTER TABLE Cajero
ADD COLUMN FechaNacimiento DATE NOT NULL,
ADD CONSTRAINT Cajero_d4 CHECK (FechaNacimiento <= CURRENT_DATE);
COMMENT ON CONSTRAINT Cajero_d4 ON Cajero IS 'Validación: La fecha de nacimiento no puede ser futura.';

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Cajero IS 'Tabla que registra al personal encargado de cobros y facturación.';

-- Comentarios de Columnas
COMMENT ON COLUMN Cajero.RFC IS 'Registro Federal de Contribuyentes del cajero.';
COMMENT ON COLUMN Cajero.Nombre IS 'Nombre(s) del cajero.';
COMMENT ON COLUMN Cajero.Paterno IS 'Apellido paterno del cajero.';
COMMENT ON COLUMN Cajero.Materno IS 'Apellido materno del cajero.';
COMMENT ON COLUMN Cajero.Calle IS 'Calle del domicilio del cajero.';
COMMENT ON COLUMN Cajero.NumeroExterior IS 'Número exterior del domicilio.';
COMMENT ON COLUMN Cajero.NumeroInterior IS 'Número interior del domicilio.';
COMMENT ON COLUMN Cajero.Colonia IS 'Colonia del domicilio.';
COMMENT ON COLUMN Cajero.Estado IS 'Estado del domicilio.';
COMMENT ON COLUMN Cajero.Dia IS 'Día de la semana de la jornada laboral.';
COMMENT ON COLUMN Cajero.Entrada IS 'Hora de entrada al turno.';
COMMENT ON COLUMN Cajero.Salida IS 'Hora de salida del turno.';
COMMENT ON COLUMN Cajero.Salario IS 'Salario asignado al cajero.';
COMMENT ON COLUMN Cajero.IdSucursal IS 'Sucursal donde labora el cajero.';
COMMENT ON COLUMN Cajero.FechaNacimiento IS 'Fecha de nacimiento del cajero.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Cajero_pk ON Cajero IS 'Llave primaria: RFC del cajero.';
COMMENT ON CONSTRAINT Cajero_fk ON Cajero IS 'Llave foránea: Sucursal de asignación.';
COMMENT ON CONSTRAINT Cajero_d1 ON Cajero IS 'Validación: El salario debe ser mayor a cero.';
COMMENT ON CONSTRAINT Cajero_d2 ON Cajero IS 'Validación: Número interior válido.';
COMMENT ON CONSTRAINT Cajero_d3 ON Cajero IS 'Validación: Número exterior estrictamente positivo.';


-- Tabla 7
CREATE TABLE Aseador (
    RFC VARCHAR(13),
    Nombre VARCHAR(50),
    Paterno VARCHAR(50),
    Materno VARCHAR(50),
    Calle VARCHAR(50),
    NumeroExterior INTEGER,
    NumeroInterior INTEGER,
    Colonia VARCHAR(50),
    Estado VARCHAR(30),
    Dia VARCHAR(15),
    Entrada TIME,
    Salida TIME,
    Salario NUMERIC(10, 2),
    IdSucursal INTEGER
);

-- PK
ALTER TABLE Aseador ADD CONSTRAINT Aseador_pk
PRIMARY KEY (RFC);

-- FK
ALTER TABLE Aseador ADD CONSTRAINT Aseador_fk
FOREIGN KEY (IdSucursal) REFERENCES Sucursal(IdSucursal)
ON UPDATE CASCADE ON DELETE RESTRICT;

-- Restricciones
ALTER TABLE Aseador
ALTER COLUMN RFC SET NOT NULL,
ALTER COLUMN Nombre SET NOT NULL,
ALTER COLUMN Paterno SET NOT NULL,
ALTER COLUMN Materno SET NOT NULL,
ALTER COLUMN Calle SET NOT NULL,
ALTER COLUMN NumeroExterior SET NOT NULL,
ALTER COLUMN Colonia SET NOT NULL,
ALTER COLUMN Estado SET NOT NULL,
ALTER COLUMN Dia SET NOT NULL,
ALTER COLUMN Entrada SET NOT NULL,
ALTER COLUMN Salida SET NOT NULL,
ALTER COLUMN Salario SET NOT NULL,
ADD CONSTRAINT Aseador_d1 CHECK (Salario > 0),
ALTER COLUMN IdSucursal SET NOT NULL;

-- =================================================================
--                      BLOQUE DE CORRECCIONES 
-- =================================================================
-- Se agrega restricción a NumeroInterior CHECK es NULL o mayor a cero
ALTER TABLE Aseador
ADD CONSTRAINT Aseador_d2 CHECK (NumeroInterior IS NULL OR NumeroInterior > 0),
-- Se agrega restricción a NumeroExterior CHECK es mayor a cero
ADD CONSTRAINT Aseador_d3 CHECK (NumeroExterior > 0);

-- =================================================================
--                    BLOQUE DE ADICIONES PARA P07 
-- =================================================================
-- Se agrega el atributo fecha de nacimiento y se agrega la restricción NOT NULL
-- junto con la restricción CHECK FechaNacimiento <= CURRENT_DATE
ALTER TABLE Aseador
ADD COLUMN FechaNacimiento DATE NOT NULL,
ADD CONSTRAINT Aseador_d4 CHECK (FechaNacimiento <= CURRENT_DATE);
COMMENT ON CONSTRAINT Aseador_d4 ON Aseador IS 'Validación: La fecha de nacimiento no puede ser futura.';

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Aseador IS 'Tabla que registra al personal encargado de la limpieza.';

-- Comentarios de Columnas
COMMENT ON COLUMN Aseador.RFC IS 'Registro Federal de Contribuyentes del aseador.';
COMMENT ON COLUMN Aseador.Nombre IS 'Nombre(s) del aseador.';
COMMENT ON COLUMN Aseador.Paterno IS 'Apellido paterno del aseador.';
COMMENT ON COLUMN Aseador.Materno IS 'Apellido materno del aseador.';
COMMENT ON COLUMN Aseador.Calle IS 'Calle del domicilio del aseador.';
COMMENT ON COLUMN Aseador.NumeroExterior IS 'Número exterior del domicilio.';
COMMENT ON COLUMN Aseador.NumeroInterior IS 'Número interior del domicilio.';
COMMENT ON COLUMN Aseador.Colonia IS 'Colonia del domicilio.';
COMMENT ON COLUMN Aseador.Estado IS 'Estado del domicilio.';
COMMENT ON COLUMN Aseador.Dia IS 'Día de la semana de la jornada laboral.';
COMMENT ON COLUMN Aseador.Entrada IS 'Hora de entrada al turno.';
COMMENT ON COLUMN Aseador.Salida IS 'Hora de salida del turno.';
COMMENT ON COLUMN Aseador.Salario IS 'Salario asignado al aseador.';
COMMENT ON COLUMN Aseador.IdSucursal IS 'Sucursal donde labora el aseador.';
COMMENT ON COLUMN Aseador.FechaNacimiento IS 'Fecha de nacimiento del aseador.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Aseador_pk ON Aseador IS 'Llave primaria: RFC del aseador.';
COMMENT ON CONSTRAINT Aseador_fk ON Aseador IS 'Llave foránea: Sucursal donde labora.';
COMMENT ON CONSTRAINT Aseador_d1 ON Aseador IS 'Validación: El salario debe ser positivo.';
COMMENT ON CONSTRAINT Aseador_d2 ON Aseador IS 'Validación: Número interior positivo o nulo.';
COMMENT ON CONSTRAINT Aseador_d3 ON Aseador IS 'Validación: Número exterior estrictamente positivo.';


-- Tabla 8
CREATE TABLE Cuidador (
    RFC VARCHAR(13),
    Nombre VARCHAR(50),
    Paterno VARCHAR(50),
    Materno VARCHAR(50),
    Calle VARCHAR(50),
    NumeroExterior INTEGER,
    NumeroInterior INTEGER,
    Colonia VARCHAR(50),
    Estado VARCHAR(30),
    Dia VARCHAR(15),
    Entrada TIME,
    Salida TIME,
    Salario NUMERIC(10, 2),
    IdSucursal INTEGER
);

-- PK
ALTER TABLE Cuidador ADD CONSTRAINT Cuidador_pk
PRIMARY KEY (RFC);

-- FK
ALTER TABLE Cuidador ADD CONSTRAINT Cuidador_fk
FOREIGN KEY (IdSucursal) REFERENCES Sucursal(IdSucursal)
ON UPDATE CASCADE ON DELETE RESTRICT;

-- Restricciones
ALTER TABLE Cuidador
ALTER COLUMN RFC SET NOT NULL,
ALTER COLUMN Nombre SET NOT NULL,
ALTER COLUMN Paterno SET NOT NULL,
ALTER COLUMN Materno SET NOT NULL,
ALTER COLUMN Calle SET NOT NULL,
ALTER COLUMN NumeroExterior SET NOT NULL,
ALTER COLUMN Colonia SET NOT NULL,
ALTER COLUMN Estado SET NOT NULL,
ALTER COLUMN Dia SET NOT NULL,
ALTER COLUMN Entrada SET NOT NULL,
ALTER COLUMN Salida SET NOT NULL,
ALTER COLUMN Salario SET NOT NULL,
ADD CONSTRAINT Cuidador_d1 CHECK (Salario > 0),
ALTER COLUMN IdSucursal SET NOT NULL;

-- =================================================================
--                      BLOQUE DE CORRECCIONES 
-- =================================================================
-- Se agrega restricción a NumeroInterior CHECK es NULL o mayor a cero
ALTER TABLE Cuidador
ADD CONSTRAINT Cuidador_d2 CHECK (NumeroInterior IS NULL OR NumeroInterior > 0),
-- Se agrega restricción a NumeroExterior CHECK es mayor a cero
ADD CONSTRAINT Cuidador_d3 CHECK (NumeroExterior > 0);

-- =================================================================
--                    BLOQUE DE ADICIONES PARA P07 
-- =================================================================
-- Se agrega el atributo fecha de nacimiento y se agrega la restricción NOT NULL
-- junto con la restricción CHECK FechaNacimiento <= CURRENT_DATE
ALTER TABLE Cuidador
ADD COLUMN FechaNacimiento DATE NOT NULL,
ADD CONSTRAINT Cuidador_d4 CHECK (FechaNacimiento <= CURRENT_DATE);
COMMENT ON CONSTRAINT Cuidador_d4 ON Cuidador IS 'Validación: La fecha de nacimiento no puede ser futura.';

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Cuidador IS 'Tabla que registra al personal de asistencia o cuidadores.';

-- Comentarios de Columnas
COMMENT ON COLUMN Cuidador.RFC IS 'Registro Federal de Contribuyentes del cuidador.';
COMMENT ON COLUMN Cuidador.Nombre IS 'Nombre(s) del cuidador.';
COMMENT ON COLUMN Cuidador.Paterno IS 'Apellido paternal del cuidador.';
COMMENT ON COLUMN Cuidador.Materno IS 'Apellido maternal del cuidador.';
COMMENT ON COLUMN Cuidador.Calle IS 'Calle del domicilio del cuidador.';
COMMENT ON COLUMN Cuidador.NumeroExterior IS 'Número exterior del domicilio.';
COMMENT ON COLUMN Cuidador.NumeroInterior IS 'Número interior del domicilio.';
COMMENT ON COLUMN Cuidador.Colonia IS 'Colonia del domicilio.';
COMMENT ON COLUMN Cuidador.Estado IS 'Estado del domicilio.';
COMMENT ON COLUMN Cuidador.Dia IS 'Día de la semana de la jornada laboral.';
COMMENT ON COLUMN Cuidador.Entrada IS 'Hora de entrada al turno.';
COMMENT ON COLUMN Cuidador.Salida IS 'Hora de salida del turno.';
COMMENT ON COLUMN Cuidador.Salario IS 'Salario asignado al cuidador.';
COMMENT ON COLUMN Cuidador.IdSucursal IS 'Sucursal donde labora el cuidador.';
COMMENT ON COLUMN Cuidador.FechaNacimiento IS 'Fecha de nacimiento del cuidador.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Cuidador_pk ON Cuidador IS 'Llave primaria: RFC del cuidador.';
COMMENT ON CONSTRAINT Cuidador_fk ON Cuidador IS 'Llave foránea: Sucursal de adscripción.';
COMMENT ON CONSTRAINT Cuidador_d1 ON Cuidador IS 'Validación: El salario debe ser estrictamente positivo.';
COMMENT ON CONSTRAINT Cuidador_d2 ON Cuidador IS 'Validación: Número interior positivo o nulo.';
COMMENT ON CONSTRAINT Cuidador_d3 ON Cuidador IS 'Validación: Número exterior estrictamente positivo.';


-- Tabla 9
CREATE TABLE Telefonos_Medico (
    RFC VARCHAR(13),
    Telefono VARCHAR(15)
);

-- PK
ALTER TABLE Telefonos_Medico ADD CONSTRAINT Telefonos_Medico_pk
PRIMARY KEY (RFC, Telefono);

-- FK
ALTER TABLE Telefonos_Medico ADD CONSTRAINT Telefonos_Medico_fk
FOREIGN KEY (RFC) REFERENCES Medico(RFC)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Restricciones
ALTER TABLE Telefonos_Medico
ADD CONSTRAINT Telefonos_Medico_v CHECK (Telefono ~ '^(\+[0-9]{1,3})?[0-9]{10}$');

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Telefonos_Medico IS 'Atributo multivaluado que almacena los teléfonos de los médicos.';

-- Comentarios de Columnas
COMMENT ON COLUMN Telefonos_Medico.RFC IS 'RFC del médico al que pertenece el teléfono.';
COMMENT ON COLUMN Telefonos_Medico.Telefono IS 'Número telefónico de contacto.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Telefonos_Medico_pk ON Telefonos_Medico IS 'Llave primaria compuesta (RFC y teléfono).';
COMMENT ON CONSTRAINT Telefonos_Medico_fk ON Telefonos_Medico IS 'Llave foránea: Vinculación con la tabla Medico.';
COMMENT ON CONSTRAINT Telefonos_Medico_v ON Telefonos_Medico IS 'Validación: Formato de número telefónico (10 dígitos, opcionalmente con código de país).';


-- Tabla 10
CREATE TABLE Correos_Medico (
    RFC VARCHAR(13),
    Correo VARCHAR(50)
);

-- PK
ALTER TABLE Correos_Medico ADD CONSTRAINT Correos_Medico_pk
PRIMARY KEY (RFC, Correo);

-- FK
ALTER TABLE Correos_Medico ADD CONSTRAINT Correos_Medico_fk
FOREIGN KEY (RFC) REFERENCES Medico(RFC)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Restricciones
ALTER TABLE Correos_Medico
ADD CONSTRAINT Correos_Medico_v CHECK (Correo ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Correos_Medico IS 'Atributo multivaluado que almacena los correos electrónicos de los médicos.';

-- Comentarios de Columnas
COMMENT ON COLUMN Correos_Medico.RFC IS 'RFC del médico al que pertenece el correo.';
COMMENT ON COLUMN Correos_Medico.Correo IS 'Dirección de correo electrónico.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Correos_Medico_pk ON Correos_Medico IS 'Llave primaria compuesta (RFC y correo).';
COMMENT ON CONSTRAINT Correos_Medico_fk ON Correos_Medico IS 'Llave foránea: Vinculación con la tabla Medico.';
COMMENT ON CONSTRAINT Correos_Medico_v ON Correos_Medico IS 'Validación: Formato de correo electrónico.';


-- Tabla 11
CREATE TABLE Especialidades (
    RFC VARCHAR(13),
    Especialidad VARCHAR(50)
);

-- PK
ALTER TABLE Especialidades ADD CONSTRAINT Especialidades_pk
PRIMARY KEY (RFC, Especialidad);

-- FK
ALTER TABLE Especialidades ADD CONSTRAINT Especialidades_fk
FOREIGN KEY (RFC) REFERENCES Medico(RFC)
ON UPDATE CASCADE ON DELETE CASCADE;

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Especialidades IS 'Atributo multivaluado que registra las especialidades médicas.';

-- Comentarios de Columnas
COMMENT ON COLUMN Especialidades.RFC IS 'RFC del médico con la especialidad.';
COMMENT ON COLUMN Especialidades.Especialidad IS 'Nombre de la especialidad médica.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Especialidades_pk ON Especialidades IS 'Llave primaria compuesta (RFC y especialidad).';
COMMENT ON CONSTRAINT Especialidades_fk ON Especialidades IS 'Llave foránea: Vinculación con la tabla Medico.';


-- Tabla 12
CREATE TABLE Telefonos_Enfermero (
    RFC VARCHAR(13),
    Telefono VARCHAR(15)
);

-- PK
ALTER TABLE Telefonos_Enfermero ADD CONSTRAINT Telefonos_Enfermero_pk
PRIMARY KEY (RFC, Telefono);

-- FK
ALTER TABLE Telefonos_Enfermero ADD CONSTRAINT Telefonos_Enfermero_fk
FOREIGN KEY (RFC) REFERENCES Enfermero(RFC)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Restricciones
ALTER TABLE Telefonos_Enfermero
ADD CONSTRAINT Telefonos_Enfermero_v CHECK (Telefono ~ '^(\+[0-9]{1,3})?[0-9]{10}$');

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Telefonos_Enfermero IS 'Atributo multivaluado: Teléfonos de contacto de enfermeros.';

-- Comentarios de Columnas
COMMENT ON COLUMN Telefonos_Enfermero.RFC IS 'RFC del enfermero al que pertenece el teléfono.';
COMMENT ON COLUMN Telefonos_Enfermero.Telefono IS 'Número telefónico de contacto.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Telefonos_Enfermero_pk ON Telefonos_Enfermero IS 'Llave primaria compuesta (RFC y Telefono).';
COMMENT ON CONSTRAINT Telefonos_Enfermero_fk ON Telefonos_Enfermero Is 'Llave foránea: Vinculación con la tabla Enfermero.';
COMMENT ON CONSTRAINT Telefonos_Enfermero_v ON Telefonos_Enfermero IS 'Validación: Formato de número telefónico (10 dígitos, opcionalmente con código de país).';

-- Tabla 13
CREATE TABLE Correos_Enfermero (
    RFC VARCHAR(13),
    Correo VARCHAR(50)
);

-- PK
ALTER TABLE Correos_Enfermero ADD CONSTRAINT Correos_Enfermero_pk
PRIMARY KEY (RFC, Correo);

-- FK
ALTER TABLE Correos_Enfermero ADD CONSTRAINT Correos_Enfermero_fk
FOREIGN KEY (RFC) REFERENCES Enfermero(RFC)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Restricciones
ALTER TABLE Correos_Enfermero
ADD CONSTRAINT Correos_Enfermero_v CHECK (Correo ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Correos_Enfermero IS 'Atributo multivaluado: Correos electrónicos de enfermeros.';

-- Comentarios de Columnas
COMMENT ON COLUMN Correos_Enfermero.RFC IS 'RFC del enfermero al que pertenece el correo.';
COMMENT ON COLUMN Correos_Enfermero.Correo IS 'Dirección de correo electrónico.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Correos_Enfermero_pk ON Correos_Enfermero IS 'Lllave primaria compuesta (RFC y Correo).';
COMMENT ON CONSTRAINT Correos_Enfermero_fk ON Correos_Enfermero IS 'Llave foránea: Vinculación con la tabla Enfermero.';
COMMENT ON CONSTRAINT Correos_Enfermero_v ON Correos_Enfermero IS 'Validación: Formato de correo electrónico.';


-- Tabla 14
CREATE TABLE Telefonos_Farmaceutico (
    RFC VARCHAR(13),
    Telefono VARCHAR(15)
);

-- PK
ALTER TABLE Telefonos_Farmaceutico ADD CONSTRAINT Telefonos_Farmaceutico_pk
PRIMARY KEY (RFC, Telefono);

-- FK
ALTER TABLE Telefonos_Farmaceutico ADD CONSTRAINT Telefonos_Farmaceutico_fk
FOREIGN KEY (RFC) REFERENCES Farmaceutico(RFC)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Restricciones
ALTER TABLE Telefonos_Farmaceutico
ADD CONSTRAINT Telefonos_Farmaceutico_v CHECK (Telefono ~ '^(\+[0-9]{1,3})?[0-9]{10}$');

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Telefonos_Farmaceutico IS 'Atributo multivaluado: Teléfonos de farmacéuticos.';

-- Comentarios de Columnas
COMMENT ON COLUMN Telefonos_Farmaceutico.RFC IS 'RFC del farmacéutico al que pertenece el teléfono.';
COMMENT ON COLUMN Telefonos_Farmaceutico.Telefono IS 'Número telefónico de contacto.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Telefonos_Farmaceutico_pk ON Telefonos_Farmaceutico IS 'Llave primaria compuesta (RFC y Telefono).';
COMMENT ON CONSTRAINT Telefonos_Farmaceutico_fk ON Telefonos_Farmaceutico IS 'Llave foránea: Vinculación con la tabla Farmaceutico.';
COMMENT ON CONSTRAINT Telefonos_Farmaceutico_v ON Telefonos_Farmaceutico IS 'Validación: Formato de número telefónico (10 dígitos, opcionalmente con código de país).';

-- Tabla 15
CREATE TABLE Correos_Farmaceutico (
    RFC VARCHAR(13),
    Correo VARCHAR(50)
);

-- PK
ALTER TABLE Correos_Farmaceutico ADD CONSTRAINT Correos_Farmaceutico_pk
PRIMARY KEY (RFC, Correo);

-- FK
ALTER TABLE Correos_Farmaceutico ADD CONSTRAINT Correos_Farmaceutico_fk
FOREIGN KEY (RFC) REFERENCES Farmaceutico(RFC)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Restricciones
ALTER TABLE Correos_Farmaceutico
ADD CONSTRAINT Correos_Farmaceutico_v CHECK (Correo ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Correos_Farmaceutico IS 'Atributo multivaluado: Correos de farmacéuticos.';

-- Comentarios de Columnas
COMMENT ON COLUMN Correos_Farmaceutico.RFC IS 'RFC del farmacéutico al que pertenece el correo.';
COMMENT ON COLUMN Correos_Farmaceutico.Correo IS 'Dirección de correo electrónico.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Correos_Farmaceutico_pk ON Correos_Farmaceutico IS 'Llave primaria compuesta (RFC y Correo).';
COMMENT ON CONSTRAINT Correos_Farmaceutico_fk ON Correos_Farmaceutico IS 'Llave foránea: Vinculación con la tabla Farmaceutico.';
COMMENT ON CONSTRAINT Correos_Farmaceutico_v ON Correos_Farmaceutico IS 'Validación: Formato de correo electrónico.';

-- Tabla 16
CREATE TABLE Especialidades_Preparacion (
    RFC VARCHAR(13),
    EspecialidadPreparacion VARCHAR(50)
);

-- PK
ALTER TABLE Especialidades_Preparacion ADD CONSTRAINT Especialidades_Preparacion_pk
PRIMARY KEY (RFC, EspecialidadPreparacion);

-- FK
ALTER TABLE Especialidades_Preparacion ADD CONSTRAINT Especialidades_Preparacion_fk
FOREIGN KEY (RFC) REFERENCES Farmaceutico(RFC)
ON UPDATE CASCADE ON DELETE CASCADE;

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Especialidades_Preparacion IS 'Atributo multivaluado: Especialidades en fórmulas magistrales.';

-- Comentarios de Columnas
COMMENT ON COLUMN Especialidades_Preparacion.RFC IS 'RFC del farmacéutico con la especialidad.';
COMMENT ON COLUMN Especialidades_Preparacion.EspecialidadPreparacion IS 'Especialidad en preparación de fórmulas magistrales.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Especialidades_Preparacion_pk ON Especialidades_Preparacion IS 'Llave primaria compuesta (RFC y EspecialidadPreparacion).';
COMMENT ON CONSTRAINT Especialidades_Preparacion_fk ON Especialidades_Preparacion IS 'Llave foránea: Vinculación con la tabla Farmaceutico.';


-- Tabla 17
CREATE TABLE Telefonos_Cajero (
    RFC VARCHAR(13),
    Telefono VARCHAR(15)
);

-- PK
ALTER TABLE Telefonos_Cajero ADD CONSTRAINT Telefonos_Cajero_pk
PRIMARY KEY (RFC, Telefono);

-- FK
ALTER TABLE Telefonos_Cajero ADD CONSTRAINT Telefonos_Cajero_fk
FOREIGN KEY (RFC) REFERENCES Cajero(RFC)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Restricciones
ALTER TABLE Telefonos_Cajero
ADD CONSTRAINT Telefonos_Cajero_v CHECK (Telefono ~ '^(\+[0-9]{1,3})?[0-9]{10}$');

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Telefonos_Cajero IS 'Atributo multivaluado: Teléfonos de cajeros.';

-- Comentarios de Columnas
COMMENT ON COLUMN Telefonos_Cajero.RFC IS 'RFC del cajero al que pertenece el teléfono.';
COMMENT ON COLUMN Telefonos_Cajero.Telefono IS 'Número telefónico de contacto.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Telefonos_Cajero_pk ON Telefonos_Cajero IS 'Llave primaria compuesta (RFC y Telefono).';
COMMENT ON CONSTRAINT Telefonos_Cajero_fk ON Telefonos_Cajero IS 'Llave foránea: Vinculación con la tabla Cajero.';
COMMENT ON CONSTRAINT Telefonos_Cajero_v ON Telefonos_Cajero IS 'Validación: Formato de número telefónico (10 dígitos, opcionalmente con código de país)..';

-- Tabla 18
CREATE TABLE Correos_Cajero (
    RFC VARCHAR(13),
    Correo VARCHAR(50)
);

-- PK
ALTER TABLE Correos_Cajero ADD CONSTRAINT Correos_Cajero_pk
PRIMARY KEY (RFC, Correo);

-- FK
ALTER TABLE Correos_Cajero ADD CONSTRAINT Correos_Cajero_fk
FOREIGN KEY (RFC) REFERENCES Cajero(RFC)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Restricciones
ALTER TABLE Correos_Cajero
ADD CONSTRAINT Correos_Cajero_v CHECK (Correo ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Correos_Cajero IS 'Atributo multivaluado: Correos de cajeros.';

-- Comentarios de Columnas
COMMENT ON COLUMN Correos_Cajero.RFC IS 'RFC del cajero al que pertenece el correo.';
COMMENT ON COLUMN Correos_Cajero.Correo IS 'Dirección de correo electrónico.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Correos_Cajero_pk ON Correos_Cajero IS 'Llave primaria compuesta (RFC y Correo).';
COMMENT ON CONSTRAINT Correos_Cajero_fk ON Correos_Cajero IS 'Llave foránea: Vinculación con la tabla Cajero.';
COMMENT ON CONSTRAINT Correos_Cajero_v ON Correos_Cajero IS 'Validación: Formato de correo electrónico.';

-- Tabla 19
CREATE TABLE Telefonos_Aseador (
    RFC VARCHAR(13),
    Telefono VARCHAR(15)
);

-- PK
ALTER TABLE Telefonos_Aseador ADD CONSTRAINT Telefonos_Aseador_pk
PRIMARY KEY (RFC, Telefono);

-- FK
ALTER TABLE Telefonos_Aseador ADD CONSTRAINT Telefonos_Aseador_fk
FOREIGN KEY (RFC) REFERENCES Aseador(RFC)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Restricciones
ALTER TABLE Telefonos_Aseador
ADD CONSTRAINT Telefonos_Aseador_v CHECK (Telefono ~ '^(\+[0-9]{1,3})?[0-9]{10}$');

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Telefonos_Aseador IS 'Atributo multivaluado: Teléfonos de aseadores.';

-- Comentarios de Columnas
COMMENT ON COLUMN Telefonos_Aseador.RFC IS 'RFC del aseador al que pertenece el teléfono.';
COMMENT ON COLUMN Telefonos_Aseador.Telefono IS 'Número telefónico de contacto.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Telefonos_Aseador_pk ON Telefonos_Aseador IS 'Llave primaria compuesta (RFC y Telefono).';
COMMENT ON CONSTRAINT Telefonos_Aseador_fk ON Telefonos_Aseador IS 'Llave foránea: Vinculación con la tabla Aseador.';
COMMENT ON CONSTRAINT Telefonos_Aseador_v ON Telefonos_Aseador IS 'Validación: Formato de número telefónico (10 dígitos, opcionalmente con código de país).';

-- Tabla 20
CREATE TABLE Correos_Aseador (
    RFC VARCHAR(13),
    Correo VARCHAR(50)
);

-- PK
ALTER TABLE Correos_Aseador ADD CONSTRAINT Correos_Aseador_pk
PRIMARY KEY (RFC, Correo);

-- FK
ALTER TABLE Correos_Aseador ADD CONSTRAINT Correos_Aseador_fk
FOREIGN KEY (RFC) REFERENCES Aseador(RFC)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Restricciones
ALTER TABLE Correos_Aseador
ADD CONSTRAINT Correos_Aseador_v CHECK (Correo ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Correos_Aseador IS 'Atributo multivaluado: Correos de aseadores.';

-- Comentarios de Columnas
COMMENT ON COLUMN Correos_Aseador.RFC IS 'RFC del aseador al que pertenece el correo.';
COMMENT ON COLUMN Correos_Aseador.Correo IS 'Dirección de correo electrónico.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Correos_Aseador_pk ON Correos_Aseador IS 'Llave primaria compuesta (RFC y Correo).';
COMMENT ON CONSTRAINT Correos_Aseador_fk ON Correos_Aseador IS 'Llave foránea: Vinculación con la tabla Aseador.';
COMMENT ON CONSTRAINT Correos_Aseador_v ON Correos_Aseador IS 'Validación: Formato de correo electrónico.';

-- Tabla 21
CREATE TABLE Telefonos_Cuidador (
    RFC VARCHAR(13),
    Telefono VARCHAR(15)
);

-- PK
ALTER TABLE Telefonos_Cuidador ADD CONSTRAINT Telefonos_Cuidador_pk
PRIMARY KEY (RFC, Telefono);

-- FK
ALTER TABLE Telefonos_Cuidador ADD CONSTRAINT Telefonos_Cuidador_fk
FOREIGN KEY (RFC) REFERENCES Cuidador(RFC)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Restricciones
ALTER TABLE Telefonos_Cuidador
ADD CONSTRAINT Telefonos_Cuidador_v CHECK (Telefono ~ '^(\+[0-9]{1,3})?[0-9]{10}$');

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Telefonos_Cuidador IS 'Atributo multivaluado: Teléfonos de cuidadores.';

-- Comentarios de Columnas
COMMENT ON COLUMN Telefonos_Cuidador.RFC IS 'RFC del cuidador al que pertenece el teléfono.';
COMMENT ON COLUMN Telefonos_Cuidador.Telefono IS 'Número telefónico de contacto.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Telefonos_Cuidador_pk ON Telefonos_Cuidador IS 'Llave primaria compuesta (RFC y Telefono).';
COMMENT ON CONSTRAINT Telefonos_Cuidador_fk ON Telefonos_Cuidador IS 'Llave foránea: Vinculación con la tabla Cuidador.';
COMMENT ON CONSTRAINT Telefonos_Cuidador_v ON Telefonos_Cuidador IS 'Validación: Formato de número telefónico (10 dígitos, opcionalmente con código de país).';

-- Tabla 22
CREATE TABLE Correos_Cuidador (
    RFC VARCHAR(13),
    Correo VARCHAR(50)
);

-- PK
ALTER TABLE Correos_Cuidador ADD CONSTRAINT Correos_Cuidador_pk
PRIMARY KEY (RFC, Correo);

-- FK
ALTER TABLE Correos_Cuidador ADD CONSTRAINT Correos_Cuidador_fk
FOREIGN KEY (RFC) REFERENCES Cuidador(RFC)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Restricciones
ALTER TABLE Correos_Cuidador
ADD CONSTRAINT Correos_Cuidador_v CHECK (Correo ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Correos_Cuidador IS 'Atributo multivaluado: Correos de cuidadores.';

-- Comentarios de Columnas
COMMENT ON COLUMN Correos_Cuidador.RFC IS 'RFC del cuidador al que pertenece el correo.';
COMMENT ON COLUMN Correos_Cuidador.Correo IS 'Dirección de correo electrónico.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Correos_Cuidador_pk ON Correos_Cuidador IS 'Llave primaria compuesta (RFC y Correo).';
COMMENT ON CONSTRAINT Correos_Cuidador_fk ON Correos_Cuidador IS 'Llave foránea: Vinculación con la tabla Cuidador.';
COMMENT ON CONSTRAINT Correos_Cuidador_v ON Correos_Cuidador IS 'Validación: Formato de correo electrónico.';


-- Tabla 23
CREATE TABLE Horarios_Sucursal (
    IdSucursal INTEGER,
    Dia VARCHAR(15),
    Apertura TIME,
    Cierre TIME
);

-- PK
ALTER TABLE Horarios_Sucursal ADD CONSTRAINT Horarios_Sucursal_pk
PRIMARY KEY (IdSucursal, Dia);

-- FK
ALTER TABLE Horarios_Sucursal ADD CONSTRAINT Horarios_Sucursal_fk
FOREIGN KEY (IdSucursal) REFERENCES Sucursal(IdSucursal)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Restricciones
ALTER TABLE Horarios_Sucursal
ALTER COLUMN Apertura SET NOT NULL,
ALTER COLUMN Cierre SET NOT NULL;

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Horarios_Sucursal IS 'Tabla que define los horarios de apertura y cierre de las sucursales.';

-- Comentarios de Columnas
COMMENT ON COLUMN Horarios_Sucursal.IdSucursal IS 'Identificador de la sucursal.';
COMMENT ON COLUMN Horarios_Sucursal.Dia IS 'Día de la semana.';
COMMENT ON COLUMN Horarios_Sucursal.Apertura IS 'Hora de apertura.';
COMMENT ON COLUMN Horarios_Sucursal.Cierre IS 'Hora de cierre.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Horarios_Sucursal_pk ON Horarios_Sucursal IS 'Llave primaria compuesta (IdSucursal y día).';
COMMENT ON CONSTRAINT Horarios_Sucursal_fk ON Horarios_Sucursal IS 'Llave foránea: Vinculación con la sucursal.';


-- Tabla 24
CREATE TABLE Horarios_Clinica (
    IdClinica INTEGER,
    Dia VARCHAR(15),
    Apertura TIME,
    Cierre TIME
);

-- PK
ALTER TABLE Horarios_Clinica ADD CONSTRAINT Horarios_Clinica_pk
PRIMARY KEY (IdClinica, Dia);

-- FK
ALTER TABLE Horarios_Clinica ADD CONSTRAINT Horarios_Clinica_fk
FOREIGN KEY (IdClinica) REFERENCES Clinica(IdClinica)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Restricciones
ALTER TABLE Horarios_Clinica
ALTER COLUMN Apertura SET NOT NULL,
ALTER COLUMN Cierre SET NOT NULL;

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Horarios_Clinica IS 'Tabla que define los horarios de servicio de las clínicas.';

-- Comentarios de Columnas
COMMENT ON COLUMN Horarios_Clinica.IdClinica IS 'Identificador de la clínica.';
COMMENT ON COLUMN Horarios_Clinica.Dia IS 'Día de la semana.';
COMMENT ON COLUMN Horarios_Clinica.Apertura IS 'Hora de apertura.';
COMMENT ON COLUMN Horarios_Clinica.Cierre IS 'Hora de cierre.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Horarios_Clinica_pk ON Horarios_Clinica IS 'Llave primaria compuesta (IdClinica y día).';
COMMENT ON CONSTRAINT Horarios_Clinica_fk ON Horarios_Clinica IS 'Llave foránea: Vinculación con la clínica.';


-- =================================================================
--                             MÓDULO 2 
-- =================================================================

-- Tabla 1
CREATE TABLE MedComercial (
    IdMedicamento SERIAL,
    NombreComercial VARCHAR(50),
    FormaFarmaceutica VARCHAR(20),
    Concentracion VARCHAR(20),
    Presentacion VARCHAR(50),
    ViaAdministracion VARCHAR(20),
    Clasificacion VARCHAR (20),
    TipoControl VARCHAR (20),
    Descripcion TEXT,
    NombreGenerico VARCHAR(50),
    LabFabricante VARCHAR(50)
);

-- PK
ALTER TABLE MedComercial ADD CONSTRAINT MedComercial_pk
PRIMARY KEY (IdMedicamento);

-- Restricciones
ALTER TABLE MedComercial
ALTER COLUMN NombreComercial SET NOT NULL,
ALTER COLUMN FormaFarmaceutica SET NOT NULL,
ALTER COLUMN Concentracion SET NOT NULL,
ALTER COLUMN Presentacion SET NOT NULL,
ALTER COLUMN ViaAdministracion SET NOT NULL,
ALTER COLUMN Clasificacion SET NOT NULL,
ALTER COLUMN TipoControl SET NOT NULL,
ALTER COLUMN Descripcion SET NOT NULL,
ALTER COLUMN NombreGenerico SET NOT NULL,
ALTER COLUMN LabFabricante SET NOT NULL;

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE MedComercial IS 'Catálogo de medicamentos comerciales de patente.';

-- Comentarios de Columnas
COMMENT ON COLUMN MedComercial.IdMedicamento IS 'Identificador único del medicamento comercial.';
COMMENT ON COLUMN MedComercial.NombreComercial IS 'Nombre comercial del producto.';
COMMENT ON COLUMN MedComercial.FormaFarmaceutica IS 'Forma farmacéutica (ej. Tabletas, Jarabe).';
COMMENT ON COLUMN MedComercial.Concentracion IS 'Concentración del principio activo.';
COMMENT ON COLUMN MedComercial.Presentacion IS 'Presentación comercial (ej. Caja con 20 tabletas).';
COMMENT ON COLUMN MedComercial.ViaAdministracion IS 'Vía de administración (ej. Oral, Intravenosa).';
COMMENT ON COLUMN MedComercial.Clasificacion IS 'Clasificación terapéutica.';
COMMENT ON COLUMN MedComercial.TipoControl IS 'Tipo de control (ej. Antibiótico, Psicotrópico).';
COMMENT ON COLUMN MedComercial.Descripcion IS 'Descripción detallada del medicamento.';
COMMENT ON COLUMN MedComercial.NombreGenerico IS 'Nombre genérico del medicamento.';
COMMENT ON COLUMN MedComercial.LabFabricante IS 'Laboratorio fabricante.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT MedComercial_pk ON MedComercial IS 'Llave primaria: Identificador único del medicamento comercial.';


-- Tabla 2
CREATE TABLE MedPreparado (
    IdMedicamento SERIAL,
    NombreComercial VARCHAR(50),
    FormaFarmaceutica VARCHAR(20),
    Concentracion VARCHAR(20),
    Presentacion VARCHAR(50),
    ViaAdministracion VARCHAR(20),
    Clasificacion VARCHAR (20),
    TipoControl VARCHAR (20),
    Descripcion TEXT,
    Categoria VARCHAR(50)
);

-- PK
ALTER TABLE MedPreparado ADD CONSTRAINT MedPreparado_pk
PRIMARY KEY (IdMedicamento);

-- Restricciones
ALTER TABLE MedPreparado
ALTER COLUMN NombreComercial SET NOT NULL,
ALTER COLUMN FormaFarmaceutica SET NOT NULL,
ALTER COLUMN Concentracion SET NOT NULL,
ALTER COLUMN Presentacion SET NOT NULL,
ALTER COLUMN ViaAdministracion SET NOT NULL,
ALTER COLUMN Clasificacion SET NOT NULL,
ALTER COLUMN TipoControl SET NOT NULL,
ALTER COLUMN Descripcion SET NOT NULL,


ALTER COLUMN Categoria SET NOT NULL;

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE MedPreparado IS 'Catálogo de fórmulas magistrales preparadas en la farmacia.';

-- Comentarios de Columnas
COMMENT ON COLUMN MedPreparado.IdMedicamento IS 'Identificador único de la fórmula magistral.';
COMMENT ON COLUMN MedPreparado.NombreComercial IS 'Nombre asignado a la preparación.';
COMMENT ON COLUMN MedPreparado.FormaFarmaceutica IS 'Forma farmacéutica de la preparación.';
COMMENT ON COLUMN MedPreparado.Concentracion IS 'Concentración de la mezcla preparada.';
COMMENT ON COLUMN MedPreparado.Presentacion IS 'Presentación final del preparado.';
COMMENT ON COLUMN MedPreparado.ViaAdministracion IS 'Vía de administración recomendada.';
COMMENT ON COLUMN MedPreparado.Clasificacion IS 'Clasificación de la preparación.';
COMMENT ON COLUMN MedPreparado.TipoControl IS 'Tipo de control sanitario.';
COMMENT ON COLUMN MedPreparado.Descripcion IS 'Descripción de la fórmula y sus beneficios.';
COMMENT ON COLUMN MedPreparado.Categoria IS 'Categoría de la fórmula magistral.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT MedPreparado_pk ON MedPreparado IS 'Llave primaria: Identificador de la fórmula magistral.';


-- Tabla 3
CREATE TABLE Insumo (
    IdInsumo SERIAL,
    NombreCientifico VARCHAR(50),
    NombreComercial VARCHAR(50),
    Tipo VARCHAR(20),
    FormaFisica VARCHAR(20),
    Potencia VARCHAR(20),
    Grado VARCHAR(20),
    Riesgo VARCHAR(20),
    EsEsteril BOOLEAN,
    Temperatura VARCHAR(20),
    Sensibilidad VARCHAR(20),
    Observaciones TEXT
);

-- PK
ALTER TABLE Insumo ADD CONSTRAINT Insumo_pk
PRIMARY KEY (IdInsumo);

-- Restricciones
ALTER TABLE Insumo
ALTER COLUMN NombreCientifico SET NOT NULL,
ALTER COLUMN NombreComercial SET NOT NULL,
ALTER COLUMN Tipo SET NOT NULL,
ALTER COLUMN FormaFisica SET NOT NULL,
ALTER COLUMN Potencia SET NOT NULL,
ALTER COLUMN Grado SET NOT NULL,
ALTER COLUMN Riesgo SET NOT NULL,
ALTER COLUMN EsEsteril SET NOT NULL,
ALTER COLUMN Temperatura SET NOT NULL,
ALTER COLUMN Sensibilidad SET NOT NULL,
ALTER COLUMN Observaciones SET NOT NULL;

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Insumo IS 'Catálogo de materias primas e insumos necesarios para fórmulas magistrales.';

-- Comentarios de Columnas
COMMENT ON COLUMN Insumo.IdInsumo IS 'Identificador único del insumo.';
COMMENT ON COLUMN Insumo.NombreCientifico IS 'Nombre científico de la materia prima.';
COMMENT ON COLUMN Insumo.NombreComercial IS 'Nombre comercial del insumo.';
COMMENT ON COLUMN Insumo.Tipo IS 'Tipo de insumo (ej. Activo, Excipiente).';
COMMENT ON COLUMN Insumo.FormaFisica IS 'Forma física (ej. Polvo, Líquido).';
COMMENT ON COLUMN Insumo.Potencia IS 'Potencia o pureza del insumo.';
COMMENT ON COLUMN Insumo.Grado IS 'Grado de calidad (ej. Farmacéutico).';
COMMENT ON COLUMN Insumo.Riesgo IS 'Nivel de riesgo en manejo.';
COMMENT ON COLUMN Insumo.EsEsteril IS 'Indica si el insumo es estéril.';
COMMENT ON COLUMN Insumo.Temperatura IS 'Temperatura de almacenamiento requerida.';
COMMENT ON COLUMN Insumo.Sensibilidad IS 'Sensibilidad a factores externos (ej. Luz, Humedad).';
COMMENT ON COLUMN Insumo.Observaciones IS 'Observaciones adicionales de manejo.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Insumo_pk ON Insumo IS 'Llave primaria: Identificador del insumo o materia prima.';


-- Tabla 4
CREATE TABLE Elaborar (
    RFC VARCHAR(13),
    IdMedicamento INTEGER,
    FechaElaboracion TIMESTAMP,
    CantidadElaborada INTEGER
);

-- PK
ALTER TABLE Elaborar ADD CONSTRAINT Elaborar_pk
PRIMARY KEY (RFC, IdMedicamento);

-- FK
ALTER TABLE Elaborar ADD CONSTRAINT Elaborar_fk1
FOREIGN KEY (RFC) REFERENCES Farmaceutico(RFC)
ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE Elaborar ADD CONSTRAINT Elaborar_fk2
FOREIGN KEY (IdMedicamento) REFERENCES MedPreparado(IdMedicamento)
ON UPDATE CASCADE ON DELETE RESTRICT;

-- Restricciones
ALTER TABLE Elaborar
ALTER COLUMN FechaElaboracion SET NOT NULL,
ALTER COLUMN CantidadElaborada SET NOT NULL,

ADD CONSTRAINT Elaborar_d1 CHECK (CantidadElaborada > 0);

-- =================================================================
--                      BLOQUE DE CORRECCIONES 
-- =================================================================
-- Se elimina la PK Elaborar_pk
ALTER TABLE Elaborar 
DROP CONSTRAINT Elaborar_pk;

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Elaborar IS 'Relación que registra la fabricación física de lotes de medicamentos preparados.';

-- Comentarios de Columnas
COMMENT ON COLUMN Elaborar.RFC IS 'RFC del farmacéutico que elaboró el medicamento.';
COMMENT ON COLUMN Elaborar.IdMedicamento IS 'Identificador del medicamento preparado.';
COMMENT ON COLUMN Elaborar.FechaElaboracion IS 'Fecha y hora de elaboración.';
COMMENT ON COLUMN Elaborar.CantidadElaborada IS 'Cantidad total de unidades producidas.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Elaborar_fk1 ON Elaborar IS 'Llave foránea: Farmacéutico responsable de la elaboración.';
COMMENT ON CONSTRAINT Elaborar_fk2 ON Elaborar IS 'Llave foránea: Fórmula magistral elaborada.';
COMMENT ON CONSTRAINT Elaborar_d1 ON Elaborar IS 'Validación: La cantidad elaborada debe ser mayor a cero.';


-- Tabla 5
CREATE TABLE Contener (
    IdMedicamento INTEGER,
    IdInsumo INTEGER,
    CantidadRequerida NUMERIC(10, 4)
);

-- PK
ALTER TABLE Contener ADD CONSTRAINT Contener_pk
PRIMARY KEY (IdMedicamento, IdInsumo);

-- FK
ALTER TABLE Contener ADD CONSTRAINT Contener_fk1
FOREIGN KEY (IdMedicamento) REFERENCES MedPreparado(IdMedicamento)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE Contener ADD CONSTRAINT Contener_fk2
FOREIGN KEY (IdInsumo) REFERENCES Insumo(IdInsumo)
ON UPDATE CASCADE ON DELETE RESTRICT;

-- Restricciones
ALTER TABLE Contener
ALTER COLUMN CantidadRequerida SET NOT NULL,

ADD CONSTRAINT Contener_d1 CHECK (CantidadRequerida > 0);

-- =================================================================
--                      BLOQUE DE CORRECCIONES 
-- =================================================================
-- Se elimina la PK Conetener_pk
ALTER TABLE Contener 
DROP CONSTRAINT Contener_pk;

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Contener IS 'Relación que define la composición o receta de las fórmulas magistrales.';

-- Comentarios de Columnas
COMMENT ON COLUMN Contener.IdMedicamento IS 'Identificador del medicamento preparado.';
COMMENT ON COLUMN Contener.IdInsumo IS 'Identificador del insumo contenido.';
COMMENT ON COLUMN Contener.CantidadRequerida IS 'Cantidad necesaria del insumo para la fórmula.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Contener_fk1 ON Contener IS 'Llave foránea: Fórmula magistral a la que pertenecen los insumos.';
COMMENT ON CONSTRAINT Contener_fk2 ON Contener IS 'Llave foránea: Insumo requerido para la preparación.';
COMMENT ON CONSTRAINT Contener_d1 ON Contener IS 'Validación: La cantidad requerida del insumo debe ser positiva.';


-- =================================================================
--                             MÓDULO 3 
-- =================================================================

-- Tabla 1
CREATE TABLE Proveedor (
    IdProveedor SERIAL,
    RazonSocial VARCHAR(30),
    Calle VARCHAR(50), 
    NumeroExterior INTEGER, 
    NumeroInterior INTEGER,
    Colonia VARCHAR(50),
    Estado VARCHAR(30)
);

-- PK
ALTER TABLE Proveedor ADD CONSTRAINT Proveedor_pk
PRIMARY KEY (IdProveedor);

-- Restricciones
ALTER TABLE Proveedor
ALTER COLUMN RazonSocial SET NOT NULL,
ALTER COLUMN Calle SET NOT NULL,
ALTER COLUMN NumeroExterior SET NOT NULL,

ADD CONSTRAINT Proveedor_d1 CHECK (NumeroExterior > 0),
ALTER COLUMN Colonia SET NOT NULL,
ALTER COLUMN Estado SET NOT NULL;

-- =================================================================
--                      BLOQUE DE CORRECCIONES 
-- =================================================================
-- Se agrega restricción a NumeroInterior CHECK es NULL o mayor a cero
ALTER TABLE Proveedor
ADD CONSTRAINT Proveedor_d2 CHECK (NumeroInterior IS NULL OR NumeroInterior > 0);

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Proveedor IS 'Catálogo de proveedores de medicamentos (comerciales) e insumos.';

-- Comentarios de Columnas
COMMENT ON COLUMN Proveedor.IdProveedor IS 'Identificador único del proveedor.';
COMMENT ON COLUMN Proveedor.RazonSocial IS 'Razón social de la empresa proveedora.';
COMMENT ON COLUMN Proveedor.Calle IS 'Calle del domicilio fiscal.';
COMMENT ON COLUMN Proveedor.NumeroExterior IS 'Número exterior del domicilio.';
COMMENT ON COLUMN Proveedor.NumeroInterior IS 'Número interior del domicilio.';
COMMENT ON COLUMN Proveedor.Colonia IS 'Colonia del domicilio.';
COMMENT ON COLUMN Proveedor.Estado IS 'Estado donde se ubica.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Proveedor_pk ON Proveedor IS 'Llave primaria: Identificador único del proveedor.';
COMMENT ON CONSTRAINT Proveedor_d1 ON Proveedor IS 'Validación: El número exterior debe ser positivo.';
COMMENT ON CONSTRAINT Proveedor_d2 ON Proveedor IS 'Validación: El número interior debe ser positivo si existe.';


-- Tabla 2
CREATE TABLE Telefonos_Proveedor (
    IdProveedor INTEGER,
    Telefono VARCHAR(15)
);

-- PK
ALTER TABLE Telefonos_Proveedor ADD CONSTRAINT Telefonos_Proveedor_pk 
PRIMARY KEY (IdProveedor, Telefono);

-- FK
ALTER TABLE Telefonos_Proveedor ADD CONSTRAINT Telefonos_Proveedor_fk 
FOREIGN KEY (IdProveedor) REFERENCES Proveedor(IdProveedor)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Restricciones
ALTER TABLE Telefonos_Proveedor
ADD CONSTRAINT Telefonos_Proveedor_v CHECK (Telefono ~ '^(\+[0-9]{1,3})?[0-9]{10}$');

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Telefonos_Proveedor IS 'Atributo multivaluado que almacena los teléfonos de los proveedores.';

-- Comentarios de Columnas
COMMENT ON COLUMN Telefonos_Proveedor.IdProveedor IS 'Identificador del proveedor.';
COMMENT ON COLUMN Telefonos_Proveedor.Telefono IS 'Número telefónico de contacto.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Telefonos_Proveedor_pk ON Telefonos_Proveedor IS 'Llave primaria compuesta (IdProveedor y teléfono).';
COMMENT ON CONSTRAINT Telefonos_Proveedor_fk ON Telefonos_Proveedor IS 'Llave foránea: Relación con la tabla Proveedor.';
COMMENT ON CONSTRAINT Telefonos_Proveedor_v ON Telefonos_Proveedor IS 'Validación: Formato de número telefónico (10 dígitos, opcionalmente con código de país).';


-- Tabla 3
CREATE TABLE EntregarMedComercial (
    IdProveedor INTEGER,
    IdSucursal INTEGER,
    IdMedicamento INTEGER,
    FechaRecepcion TIMESTAMP,
    FechaCaducidad DATE,
    CondicionesAlmacenamiento VARCHAR(100),
    CantidadRecibida INTEGER,
    PrecioPublico NUMERIC(10, 2),
    PrecioUnitario NUMERIC(10, 2)
);

-- PK
ALTER TABLE EntregarMedComercial ADD CONSTRAINT EntregarMedComercial_pk 
PRIMARY KEY (IdProveedor, IdSucursal, IdMedicamento);

-- FK
ALTER TABLE EntregarMedComercial ADD CONSTRAINT EntregarMedComercial_fk1 
FOREIGN KEY (IdProveedor) REFERENCES Proveedor(IdProveedor)
ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE EntregarMedComercial ADD CONSTRAINT EntregarMedComercial_fk2 
FOREIGN KEY (IdSucursal) REFERENCES Sucursal(IdSucursal)
ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE EntregarMedComercial ADD CONSTRAINT EntregarMedComercial_fk3 
FOREIGN KEY (IdMedicamento) REFERENCES MedComercial(IdMedicamento)
ON UPDATE CASCADE ON DELETE RESTRICT;

-- Restricciones
ALTER TABLE EntregarMedComercial
ALTER COLUMN FechaRecepcion SET NOT NULL,
ALTER COLUMN FechaCaducidad SET NOT NULL,
ALTER COLUMN CondicionesAlmacenamiento SET NOT NULL,
ALTER COLUMN CantidadRecibida SET NOT NULL,

ADD CONSTRAINT EntregarMedComercial_d1 CHECK (CantidadRecibida > 0),
ALTER COLUMN PrecioPublico SET NOT NULL,

ADD CONSTRAINT EntregarMedComercial_d2 CHECK (PrecioPublico >= 0),
ALTER COLUMN PrecioUnitario SET NOT NULL,

ADD CONSTRAINT EntregarMedComercial_d3 CHECK (PrecioUnitario >= 0);

-- =================================================================
--                      BLOQUE DE CORRECCIONES 
-- =================================================================
-- Se elimina la PK EntregarMedComercial_pk
ALTER TABLE EntregarMedComercial 
DROP CONSTRAINT EntregarMedComercial_pk;

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE EntregarMedComercial IS 'Relación transaccional que registra la recepción de medicamentos comerciales.';

-- Comentarios de Columnas
COMMENT ON COLUMN EntregarMedComercial.IdProveedor IS 'Identificador del proveedor que entrega.';
COMMENT ON COLUMN EntregarMedComercial.IdSucursal IS 'Identificador de la sucursal que recibe.';
COMMENT ON COLUMN EntregarMedComercial.IdMedicamento IS 'Identificador del medicamento comercial.';
COMMENT ON COLUMN EntregarMedComercial.FechaRecepcion IS 'Fecha y hora de recepción del lote.';
COMMENT ON COLUMN EntregarMedComercial.FechaCaducidad IS 'Fecha de caducidad del lote recibido.';
COMMENT ON COLUMN EntregarMedComercial.CondicionesAlmacenamiento IS 'Condiciones específicas para el almacenaje.';
COMMENT ON COLUMN EntregarMedComercial.CantidadRecibida IS 'Número de unidades recibidas.';
COMMENT ON COLUMN EntregarMedComercial.PrecioPublico IS 'Precio sugerido de venta al público.';
COMMENT ON COLUMN EntregarMedComercial.PrecioUnitario IS 'Costo unitario de adquisición.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT EntregarMedComercial_fk1 ON EntregarMedComercial IS 'Llave foránea: Proveedor que realiza la entrega.';
COMMENT ON CONSTRAINT EntregarMedComercial_fk2 ON EntregarMedComercial IS 'Llave foránea: Sucursal que recibe el medicamento.';
COMMENT ON CONSTRAINT EntregarMedComercial_fk3 ON EntregarMedComercial IS 'Llave foránea: Medicamento comercial recibido.';
COMMENT ON CONSTRAINT EntregarMedComercial_d1 ON EntregarMedComercial IS 'Validación: La cantidad recibida debe ser mayor a cero.';
COMMENT ON CONSTRAINT EntregarMedComercial_d2 ON EntregarMedComercial IS 'Validación: El precio público debe ser igual o mayor a cero.';
COMMENT ON CONSTRAINT EntregarMedComercial_d3 ON EntregarMedComercial IS 'Validación: El precio unitario debe ser igual o mayor a cero.';

-- Tabla 4
CREATE TABLE EntregarInsumo (
    IdProveedor INTEGER,
    IdSucursal INTEGER,
    IdInsumo INTEGER,
    FechaRecepcion TIMESTAMP,
    FechaCaducidad DATE,
    CondicionesAlmacenamiento VARCHAR(100),
    CantidadRecibida INTEGER,
    PrecioPublico NUMERIC(10, 2),
    PrecioUnitario NUMERIC(10, 2)
);

-- PK
ALTER TABLE EntregarInsumo ADD CONSTRAINT EntregarInsumo_pk 
PRIMARY KEY (IdProveedor, IdSucursal, IdInsumo);

-- FK
ALTER TABLE EntregarInsumo ADD CONSTRAINT EntregarInsumo_fk1 
FOREIGN KEY (IdProveedor) REFERENCES Proveedor(IdProveedor)
ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE EntregarInsumo ADD CONSTRAINT EntregarInsumo_fk2 
FOREIGN KEY (IdSucursal) REFERENCES Sucursal(IdSucursal)
ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE EntregarInsumo ADD CONSTRAINT EntregarInsumo_fk3 
FOREIGN KEY (IdInsumo) REFERENCES Insumo(IdInsumo)
ON UPDATE CASCADE ON DELETE RESTRICT;

-- Restricciones
ALTER TABLE EntregarInsumo
ALTER COLUMN FechaRecepcion SET NOT NULL,
ALTER COLUMN FechaCaducidad SET NOT NULL,
ALTER COLUMN CondicionesAlmacenamiento SET NOT NULL,
ALTER COLUMN CantidadRecibida SET NOT NULL,

ADD CONSTRAINT EntregarInsumo_d1 CHECK (CantidadRecibida > 0),
ALTER COLUMN PrecioPublico SET NOT NULL,

ADD CONSTRAINT EntregarInsumo_d2 CHECK (PrecioPublico >= 0),
ALTER COLUMN PrecioUnitario SET NOT NULL,

ADD CONSTRAINT EntregarInsumo_d3 CHECK (PrecioUnitario >= 0);

-- =================================================================
--                      BLOQUE DE CORRECCIONES 
-- =================================================================
-- Se elimina la PK EntregarInsumo_pk
ALTER TABLE EntregarInsumo 
DROP CONSTRAINT EntregarInsumo_pk;

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE EntregarInsumo IS 'Relación transaccional que registra la recepción de insumos o materias primas.';

-- Comentarios de Columnas
COMMENT ON COLUMN EntregarInsumo.IdProveedor IS 'Identificador del proveedor que entrega.';
COMMENT ON COLUMN EntregarInsumo.IdSucursal IS 'Identificador de la sucursal que recibe.';
COMMENT ON COLUMN EntregarInsumo.IdInsumo IS 'Identificador del insumo recibido.';
COMMENT ON COLUMN EntregarInsumo.FechaRecepcion IS 'Fecha y hora de recepción.';
COMMENT ON COLUMN EntregarInsumo.FechaCaducidad IS 'Fecha de caducidad del insumo.';
COMMENT ON COLUMN EntregarInsumo.CondicionesAlmacenamiento IS 'Condiciones requeridas para su conservación.';
COMMENT ON COLUMN EntregarInsumo.CantidadRecibida IS 'Cantidad total de unidades o volumen recibido.';
COMMENT ON COLUMN EntregarInsumo.PrecioPublico IS 'Precio de venta al público (si aplica).';
COMMENT ON COLUMN EntregarInsumo.PrecioUnitario IS 'Costo unitario del insumo.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT EntregarInsumo_fk1 ON EntregarInsumo IS 'Llave foránea: Proveedor que suministra el insumo.';
COMMENT ON CONSTRAINT EntregarInsumo_fk2 ON EntregarInsumo IS 'Llave foránea: Sucursal receptora.';
COMMENT ON CONSTRAINT EntregarInsumo_fk3 ON EntregarInsumo IS 'Llave foránea: Insumo o materia prima recibida.';
COMMENT ON CONSTRAINT EntregarInsumo_d1 ON EntregarInsumo IS 'Validación: La cantidad de insumo recibida debe ser positiva.';
COMMENT ON CONSTRAINT EntregarInsumo_d2 ON EntregarInsumo IS 'Validación: El precio público debe ser igual o mayor a cero.';
COMMENT ON CONSTRAINT EntregarInsumo_d3 ON EntregarInsumo IS 'Validación: El precio unitario debe ser igual o mayor a cero.';


-- =================================================================
--                             MÓDULO 5 
-- =================================================================

-- Tabla 1
CREATE TABLE Cliente(
    IdCliente SERIAL,
    Nombre VARCHAR(50),
    Paterno VARCHAR(50),
    Materno VARCHAR(50),
    FechaNacimiento DATE,
    Calle VARCHAR(50),
    NumeroExterior INTEGER,
    NumeroInterior INTEGER,
    Colonia VARCHAR(50),
    Estado VARCHAR(50),
    MetodoPago VARCHAR(20)
);

-- PK
ALTER TABLE Cliente ADD CONSTRAINT Cliente_pk
PRIMARY KEY (IdCliente);

-- Restricciones
ALTER TABLE Cliente
ALTER COLUMN Nombre SET NOT NULL,
ALTER COLUMN Paterno SET NOT NULL,
ALTER COLUMN FechaNacimiento SET NOT NULL,

ADD CONSTRAINT Cliente_d1 CHECK (FechaNacimiento <= CURRENT_DATE),
ALTER COLUMN Calle SET NOT NULL,
ALTER COLUMN NumeroExterior SET NOT NULL,

ADD CONSTRAINT Cliente_d2 CHECK (NumeroExterior > 0),
ALTER COLUMN Colonia SET NOT NULL,
ALTER COLUMN Estado SET NOT NULL,
ALTER COLUMN MetodoPago SET NOT NULL,

ADD CONSTRAINT Cliente_d3 CHECK (MetodoPago IN ('Tarjeta', 'Efectivo'));

-- =================================================================
--                      BLOQUE DE CORRECCIONES 
-- =================================================================
-- Se agrega restricción a Materno NOT NULL
ALTER TABLE Cliente
ALTER COLUMN Materno SET NOT NULL,

-- Se agrega restricción a NumeroInterior CHECK es NULL o mayor a cero
ADD CONSTRAINT Cliente_d4 CHECK (NumeroInterior IS NULL OR NumeroInterior > 0);

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Cliente IS 'Catálogo general de clientes de la farmacia.';

-- Comentarios de Columnas
COMMENT ON COLUMN Cliente.IdCliente IS 'Identificador único del cliente.';
COMMENT ON COLUMN Cliente.Nombre IS 'Nombre(s) del cliente.';
COMMENT ON COLUMN Cliente.Paterno IS 'Apellido paterno del cliente.';
COMMENT ON COLUMN Cliente.Materno IS 'Apellido materno del cliente.';
COMMENT ON COLUMN Cliente.FechaNacimiento IS 'Fecha de nacimiento del cliente.';
COMMENT ON COLUMN Cliente.Calle IS 'Calle del domicilio del cliente.';
COMMENT ON COLUMN Cliente.NumeroExterior IS 'Número exterior del domicilio.';
COMMENT ON COLUMN Cliente.NumeroInterior IS 'Número interior del domicilio.';
COMMENT ON COLUMN Cliente.Colonia IS 'Colonia del domicilio.';
COMMENT ON COLUMN Cliente.Estado IS 'Estado del domicilio.';
COMMENT ON COLUMN Cliente.MetodoPago IS 'Método de pago preferido.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Cliente_pk ON Cliente IS 'Llave primaria: Identificador único del cliente.';
COMMENT ON CONSTRAINT Cliente_d1 ON Cliente IS 'Validación: La fecha de nacimiento no puede ser futura.';
COMMENT ON CONSTRAINT Cliente_d2 ON Cliente IS 'Validación: El número exterior debe ser positivo.';
COMMENT ON CONSTRAINT Cliente_d3 ON Cliente IS 'Validación: Restringe los métodos de pago a Tarjeta o Efectivo.';
COMMENT ON CONSTRAINT Cliente_d4 ON Cliente IS 'Validación: El número interior debe ser positivo si se proporciona.';


-- Tabla 2
CREATE TABLE ClienteOnline(
    IdCliente INTEGER,
    NombreUsuario VARCHAR(20),
    Contraseña VARCHAR(255),
    NumeroTarjeta VARCHAR(20),
    FechaVencimiento VARCHAR(5)
);

-- PK
ALTER TABLE ClienteOnline ADD CONSTRAINT ClienteOnline_pk
PRIMARY KEY (IdCliente);

-- FK
ALTER TABLE ClienteOnline ADD CONSTRAINT ClienteOnline_fk
FOREIGN KEY (IdCliente) REFERENCES Cliente(IdCliente)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Restricciones
ALTER TABLE ClienteOnline
ALTER COLUMN NombreUsuario SET NOT NULL,

ADD CONSTRAINT Clienteonline_u1 UNIQUE (NombreUsuario),
ALTER COLUMN Contraseña SET NOT NULL,
ALTER COLUMN NumeroTarjeta SET NOT NULL,
ALTER COLUMN FechaVencimiento SET NOT NULL;

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE ClienteOnline IS 'Extensión de la tabla Cliente para usuarios con cuenta en línea.';

-- Comentarios de Columnas
COMMENT ON COLUMN ClienteOnline.IdCliente IS 'Identificador del cliente vinculado.';
COMMENT ON COLUMN ClienteOnline.NombreUsuario IS 'Nombre de usuario para acceso al sistema.';
COMMENT ON COLUMN ClienteOnline.Contraseña IS 'Contraseña encriptada de la cuenta.';
COMMENT ON COLUMN ClienteOnline.NumeroTarjeta IS 'Número de tarjeta de crédito/débito guardada.';
COMMENT ON COLUMN ClienteOnline.FechaVencimiento IS 'Fecha de vencimiento de la tarjeta.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT ClienteOnline_pk ON ClienteOnline IS 'Llave primaria: Identificador del cliente (Relación 1:1 con Cliente).';
COMMENT ON CONSTRAINT ClienteOnline_fk ON ClienteOnline IS 'Llave foránea: Vinculación obligatoria con la entidad base Cliente.';
COMMENT ON CONSTRAINT Clienteonline_u1 ON ClienteOnline IS 'Restricción: El nombre de usuario debe ser único en el sistema.';


-- Tabla 3
CREATE TABLE Ticket(
    FolioTicket SERIAL,
    FechaPago DATE,
    HoraPago TIME,
    TipoVenta VARCHAR(20),
    PrecioBruto NUMERIC(10,2),
    PrecioNeto NUMERIC(10,2),
    IdSucursal INTEGER,
    IdCliente INTEGER
);

-- PK
ALTER TABLE Ticket ADD CONSTRAINT Ticket_pk
PRIMARY KEY (FolioTicket);

-- FK
ALTER TABLE Ticket ADD CONSTRAINT Ticket_fk1
FOREIGN KEY (IdSucursal) REFERENCES Sucursal(IdSucursal)
ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE Ticket ADD CONSTRAINT Ticket_fk2
FOREIGN KEY (IdCliente) REFERENCES Cliente(IdCliente)
ON UPDATE CASCADE ON DELETE RESTRICT;

-- Restricciones
ALTER TABLE Ticket
ALTER COLUMN FechaPago SET NOT NULL,
ALTER COLUMN HoraPago SET NOT NULL,
ALTER COLUMN TipoVenta SET NOT NULL,

ADD CONSTRAINT Ticket_d1 CHECK (TipoVenta IN ('Presencial', 'Web')),
ALTER COLUMN PrecioBruto SET NOT NULL,

ADD CONSTRAINT Ticket_d2 CHECK (PrecioBruto >= 0),
ALTER COLUMN PrecioNeto SET NOT NULL,

ADD CONSTRAINT Ticket_d3 CHECK (PrecioNeto >= 0),
ALTER COLUMN IdCliente SET NOT NULL,
ALTER COLUMN IdSucursal SET NOT NULL;

-- =================================================================
--                      BLOQUE DE CORRECCIONES 
-- =================================================================
-- Se eliminan porque el precio bruto y el precio neto se deben calcular mediante consultas DQL
ALTER TABLE Ticket 
    DROP COLUMN PrecioBruto,
    DROP COLUMN PrecioNeto;

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Ticket IS 'Registro de transacciones de venta (tickets de compra).';

-- Comentarios de Columnas
COMMENT ON COLUMN Ticket.FolioTicket IS 'Folio único autoincremental del ticket.';
COMMENT ON COLUMN Ticket.FechaPago IS 'Fecha en que se realizó el pago.';
COMMENT ON COLUMN Ticket.HoraPago IS 'Hora en que se registró el pago.';
COMMENT ON COLUMN Ticket.TipoVenta IS 'Canal de venta (Presencial o Web).';
COMMENT ON COLUMN Ticket.IdSucursal IS 'Sucursal donde se generó el ticket.';
COMMENT ON COLUMN Ticket.IdCliente IS 'Cliente que realizó la compra.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Ticket_pk ON Ticket IS 'Llave primaria: Folio único del ticket.';
COMMENT ON CONSTRAINT Ticket_fk1 ON Ticket IS 'Llave foránea: Sucursal donde se realizó la venta.';
COMMENT ON CONSTRAINT Ticket_fk2 ON Ticket IS 'Llave foránea: Cliente que realizó la compra.';
COMMENT ON CONSTRAINT Ticket_d1 ON Ticket IS 'Validación: Restringe el tipo de venta a Presencial o Web.';


-- Tabla 4
CREATE TABLE Telefonos_Cliente (
    IdCliente INTEGER,
    Telefono VARCHAR(15)
);

-- PK
ALTER TABLE Telefonos_Cliente ADD CONSTRAINT Telefonos_Cliente_pk
PRIMARY KEY (IdCliente, Telefono);

-- FK
ALTER TABLE Telefonos_Cliente ADD CONSTRAINT Telefonos_Cliente_fk
FOREIGN KEY (IdCliente) REFERENCES Cliente(IdCliente)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Restricciones
ALTER TABLE Telefonos_Cliente

ADD CONSTRAINT Telefonos_Cliente_v CHECK (Telefono ~ '^(\+[0-9]{1,3})?[0-9]{10}$');

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Telefonos_Cliente IS 'Atributo multivaluado: Teléfonos de contacto de los clientes.';

-- Comentarios de Columnas
COMMENT ON COLUMN Telefonos_Cliente.IdCliente IS 'Identificador del cliente.';
COMMENT ON COLUMN Telefonos_Cliente.Telefono IS 'Número telefónico de contacto.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Telefonos_Cliente_pk ON Telefonos_Cliente IS 'Llave primaria compuesta (IdCliente y teléfono).';
COMMENT ON CONSTRAINT Telefonos_Cliente_fk ON Telefonos_Cliente IS 'Llave foránea: Vinculación con la tabla Cliente.';
COMMENT ON CONSTRAINT Telefonos_Cliente_v ON Telefonos_Cliente IS 'Validación: Formato de número telefónico (10 dígitos, opcionalmente con código de país).';

-- Tabla 5
CREATE TABLE Correos_Cliente (
    IdCliente INTEGER,
    Correo VARCHAR(15)
);

-- PK
ALTER TABLE Correos_Cliente ADD CONSTRAINT Correos_Cliente_pk
PRIMARY KEY (IdCliente, Correo);

-- FK
ALTER TABLE Correos_Cliente ADD CONSTRAINT Correos_Cliente_fk
FOREIGN KEY (IdCliente) REFERENCES Cliente(IdCliente)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Restricciones
ALTER TABLE Correos_Cliente
ADD CONSTRAINT Correos_Cliente_v CHECK (Correo ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Correos_Cliente IS 'Atributo multivaluado: Correos electrónicos de los clientes.';

-- Comentarios de Columnas
COMMENT ON COLUMN Correos_Cliente.IdCliente IS 'Identificador del cliente.';
COMMENT ON COLUMN Correos_Cliente.Correo IS 'Dirección de correo electrónico.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Correos_Cliente_pk ON Correos_Cliente IS 'Llave primaria compuesta (IdCliente y correo).';
COMMENT ON CONSTRAINT Correos_Cliente_fk ON Correos_Cliente IS 'Llave foránea: Vinculación con la tabla Cliente.';
COMMENT ON CONSTRAINT Correos_Cliente_v ON Correos_Cliente IS 'Validación: Formato de correo electrónico.';


-- Tabla 6
CREATE TABLE TenerMedComercial(
    FolioTicket INTEGER,
    IdMedicamento INTEGER,
    CantidadComprada INTEGER,
    PrecioUnitario NUMERIC(10,2)
);

-- PK
ALTER TABLE TenerMedComercial ADD CONSTRAINT TenerMedComercial_pk
PRIMARY KEY (FolioTicket, IdMedicamento);

-- FK
ALTER TABLE TenerMedComercial ADD CONSTRAINT TenerMedComercial_fk1
FOREIGN KEY (FolioTicket) REFERENCES Ticket(FolioTicket)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE TenerMedComercial ADD CONSTRAINT TenerMedComercial_fk2
FOREIGN KEY (IdMedicamento) REFERENCES MedComercial(IdMedicamento)
ON UPDATE CASCADE ON DELETE RESTRICT;

-- Restricciones
ALTER TABLE TenerMedComercial
ALTER COLUMN CantidadComprada SET NOT NULL,

ADD CONSTRAINT TenerMedComercial_d1 CHECK (CantidadComprada > 0),
ALTER COLUMN PrecioUnitario SET NOT NULL,

ADD CONSTRAINT TenerMedComercial_d2 CHECK (PrecioUnitario >= 0);

-- =================================================================
--                      BLOQUE DE CORRECCIONES 
-- =================================================================
-- Se elimina la PK TenerMedComercial_pk
ALTER TABLE TenerMedComercial
DROP CONSTRAINT TenerMedComercial_pk;

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE TenerMedComercial IS 'Detalle de los medicamentos comerciales incluidos en un ticket.';

-- Comentarios de Columnas
COMMENT ON COLUMN TenerMedComercial.FolioTicket IS 'Folio del ticket asociado.';
COMMENT ON COLUMN TenerMedComercial.IdMedicamento IS 'Identificador del medicamento comercial.';
COMMENT ON COLUMN TenerMedComercial.CantidadComprada IS 'Cantidad de unidades adquiridas.';
COMMENT ON COLUMN TenerMedComercial.PrecioUnitario IS 'Precio unitario al momento de la venta.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT TenerMedComercial_fk1 ON TenerMedComercial IS 'Llave foránea: Ticket al que pertenece el detalle.';
COMMENT ON CONSTRAINT TenerMedComercial_fk2 ON TenerMedComercial IS 'Llave foránea: Medicamento comercial vendido.';
COMMENT ON CONSTRAINT TenerMedComercial_d1 ON TenerMedComercial IS 'Validación: La cantidad comprada debe ser mayor a cero.';
COMMENT ON CONSTRAINT TenerMedComercial_d2 ON TenerMedComercial IS 'Validación: El precio unitario no puede ser negativo.';


-- Tabla 7
CREATE TABLE TenerMedPreparado(
    FolioTicket INTEGER,
    IdMedicamento INTEGER,
    CantidadComprada INTEGER,
    PrecioUnitario NUMERIC(10,2)
);

-- PK
ALTER TABLE TenerMedPreparado ADD CONSTRAINT TenerMedPreparado_pk
PRIMARY KEY (FolioTicket, IdMedicamento);

-- FK
ALTER TABLE TenerMedPreparado ADD CONSTRAINT TenerMedPreparado_fk1
FOREIGN KEY (FolioTicket) REFERENCES Ticket(FolioTicket)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE TenerMedPreparado ADD CONSTRAINT TenerMedPreparado_fk2
FOREIGN KEY (IdMedicamento) REFERENCES MedPreparado(IdMedicamento)
ON UPDATE CASCADE ON DELETE RESTRICT;

-- Restricciones
ALTER TABLE TenerMedPreparado
ALTER COLUMN CantidadComprada SET NOT NULL,

ADD CONSTRAINT TenerMedPreparado_d1 CHECK (CantidadComprada > 0),
ALTER COLUMN PrecioUnitario SET NOT NULL,

ADD CONSTRAINT TenerMedPreparado_d2 CHECK (PrecioUnitario >= 0);

-- =================================================================
--                      BLOQUE DE CORRECCIONES 
-- =================================================================
-- Se elimina la PK TenerMedPreparado_pk
ALTER TABLE TenerMedPreparado 
DROP CONSTRAINT TenerMedPreparado_pk;

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE TenerMedPreparado IS 'Detalle de los medicamentos preparados incluidos en un ticket.';

-- Comentarios de Columnas
COMMENT ON COLUMN TenerMedPreparado.FolioTicket IS 'Folio del ticket asociado.';
COMMENT ON COLUMN TenerMedPreparado.IdMedicamento IS 'Identificador del medicamento preparado.';
COMMENT ON COLUMN TenerMedPreparado.CantidadComprada IS 'Cantidad de unidades adquiridas.';
COMMENT ON COLUMN TenerMedPreparado.PrecioUnitario IS 'Precio unitario de la preparación.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT TenerMedPreparado_fk1 ON TenerMedPreparado IS 'Llave foránea: Ticket al que pertenece el detalle.';
COMMENT ON CONSTRAINT TenerMedPreparado_fk2 ON TenerMedPreparado IS 'Llave foránea: Medicamento preparado vendido.';
COMMENT ON CONSTRAINT TenerMedPreparado_d1 ON TenerMedPreparado IS 'Validación: La cantidad comprada debe ser mayor a cero.';
COMMENT ON CONSTRAINT TenerMedPreparado_d2 ON TenerMedPreparado IS 'Validación: El precio unitario no puede ser negativo.';


-- =================================================================
--                             MÓDULO 4 
-- =================================================================

-- Tabla 1
CREATE TABLE Consulta(
    IdConsulta SERIAL,
    Fecha DATE,
    Hora TIME,
    Diagnostico TEXT,
    Precio NUMERIC(10,2),
    IdCliente INTEGER,
    RFCMedico VARCHAR(13),
    RFCEnfermero VARCHAR(13),
    FolioTicket INTEGER
);

-- PK
ALTER TABLE Consulta ADD CONSTRAINT Consulta_pk
PRIMARY KEY (IdConsulta);

-- FK
ALTER TABLE Consulta ADD CONSTRAINT Consulta_fk1
FOREIGN KEY (IdCliente) REFERENCES Cliente(IdCliente)
ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE Consulta ADD CONSTRAINT Consulta_fk2
FOREIGN KEY (RFCMedico) REFERENCES Medico(RFC)
ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE Consulta ADD CONSTRAINT Consulta_fk3
FOREIGN KEY (RFCEnfermero) REFERENCES Enfermero(RFC)
ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE Consulta ADD CONSTRAINT Consulta_fk4
FOREIGN KEY (FolioTicket) REFERENCES Ticket(FolioTicket)
ON UPDATE CASCADE ON DELETE RESTRICT;

-- Restricciones
ALTER TABLE Consulta
ALTER COLUMN Fecha SET NOT NULL,
ALTER COLUMN Hora SET NOT NULL,
ALTER COLUMN RFCMedico SET NOT NULL,
ALTER COLUMN Precio SET NOT NULL,
ALTER COLUMN Diagnostico SET NOT NULL,
ADD CONSTRAINT Consulta_d1 CHECK (Precio >= 0),
ALTER COLUMN FolioTicket SET NOT NULL,
ADD CONSTRAINT Consulta_u2 UNIQUE (FolioTicket);

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Consulta IS 'Registro de consultas médicas realizadas en las clínicas.';

-- Comentarios de Columnas 
COMMENT ON COLUMN Consulta.IdConsulta IS 'Identificador único de la consulta médica.';
COMMENT ON COLUMN Consulta.Fecha IS 'Fecha en la que se realiza la consulta.';
COMMENT ON COLUMN Consulta.Hora IS 'Hora programada o de inicio de la consulta.';
COMMENT ON COLUMN Consulta.Diagnostico IS 'Descripción clínica detallada de los hallazgos en la consulta.';
COMMENT ON COLUMN Consulta.Precio IS 'Costo total de los servicios médicos prestados en la consulta.';
COMMENT ON COLUMN Consulta.IdCliente IS 'Identificador del paciente; es obligatorio para registrar la atención.';
COMMENT ON COLUMN Consulta.RFCMedico IS 'RFC del médico responsable de atender la consulta.';
COMMENT ON COLUMN Consulta.RFCEnfermero IS 'RFC del enfermero de apoyo; es opcional (permite NULL).';
COMMENT ON COLUMN Consulta.FolioTicket IS 'Folio del ticket de pago vinculado a la transacción de la consulta.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Consulta_pk ON Consulta IS 'Llave primaria: Identificador único de la consulta.';
COMMENT ON CONSTRAINT Consulta_fk1 ON Consulta IS 'Llave foránea: Cliente que recibe la consulta.';
COMMENT ON CONSTRAINT Consulta_fk2 ON Consulta IS 'Llave foránea: Médico que atiende la consulta.';
COMMENT ON CONSTRAINT Consulta_fk3 ON Consulta IS 'Llave foránea: Enfermero de apoyo en la consulta.';
COMMENT ON CONSTRAINT Consulta_fk4 ON Consulta IS 'Llave foránea: Ticket de pago vinculado a la consulta.';
COMMENT ON CONSTRAINT Consulta_d1 ON Consulta IS 'Validación: El precio de la consulta no puede ser negativo.';
COMMENT ON CONSTRAINT Consulta_u2 ON Consulta IS 'Restricción: Unicidad del ticket por consulta (1:1).';

-- =================================================================
--                    BLOQUE DE CORRECCIONES PARA P08 
-- =================================================================
-- Obligatoriedad del Cliente (Dominio)
ALTER TABLE Consulta
ALTER COLUMN IdCliente SET NOT NULL;
-- Nota: RFCEnfermero se mantiene sin NOT NULL para permitir valores nulos 
-- cuando no haya personal de enfermería asignado a la consulta.

-- Tabla 2
CREATE TABLE Receta(
    IdConsulta INTEGER,
    NumeroReceta INTEGER,
    PesoPaciente NUMERIC(5,2),
    TallaPaciente NUMERIC(5,2),
    Consultorio INTEGER,
    Turno VARCHAR(50)
);

-- PK
ALTER TABLE Receta ADD CONSTRAINT Receta_pk
PRIMARY KEY (IdConsulta, NumeroReceta);

-- FK
ALTER TABLE Receta ADD CONSTRAINT Receta_fk
FOREIGN KEY (IdConsulta) REFERENCES Consulta(IdConsulta)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Restricciones
ALTER TABLE Receta
ALTER COLUMN PesoPaciente SET NOT NULL,

ADD CONSTRAINT Receta_d1 CHECK (PesoPaciente > 0),
ALTER COLUMN TallaPaciente SET NOT NULL,

ADD CONSTRAINT Receta_d2 CHECK (TallaPaciente > 0),
ALTER COLUMN Consultorio SET NOT NULL,

ADD CONSTRAINT Receta_d3 CHECK (Consultorio > 0),
ALTER COLUMN Turno SET NOT NULL,

ADD CONSTRAINT Receta_d4 CHECK (Turno IN ('Matutino', 'Vespertino'));

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Receta IS 'Documento médico generado en una consulta con indicaciones de tratamiento.';

-- Comentarios de Columnas
COMMENT ON COLUMN Receta.IdConsulta IS 'Identificador de la consulta médica vinculada.';
COMMENT ON COLUMN Receta.NumeroReceta IS 'Número secuencial de la receta dentro de la consulta.';
COMMENT ON COLUMN Receta.PesoPaciente IS 'Peso del paciente registrado al momento de la consulta (kg).';
COMMENT ON COLUMN Receta.TallaPaciente IS 'Estatura o talla del paciente (cm).';
COMMENT ON COLUMN Receta.Consultorio IS 'Número de consultorio físico donde se atendió.';
COMMENT ON COLUMN Receta.Turno IS 'Turno de atención (Matutino o Vespertino).';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Receta_pk ON Receta IS 'Llave primaria compuesta (IdConsulta y NumeroReceta).';
COMMENT ON CONSTRAINT Receta_fk ON Receta IS 'Llave foránea: Consulta médica que originó la receta.';
COMMENT ON CONSTRAINT Receta_d1 ON Receta IS 'Validación: El peso del paciente debe ser positivo.';
COMMENT ON CONSTRAINT Receta_d2 ON Receta IS 'Validación: La talla del paciente debe ser positiva.';
COMMENT ON CONSTRAINT Receta_d3 ON Receta IS 'Validación: El número de consultorio debe ser positivo.';
COMMENT ON CONSTRAINT Receta_d4 ON Receta IS 'Validación: Restringe el turno a Matutino o Vespertino.';


-- Tabla 3
CREATE TABLE Alergias_Reportadas(
    IdConsulta INTEGER,
    NumeroReceta INTEGER,
    AlergiasReportadas TEXT
);

-- PK
ALTER TABLE Alergias_Reportadas ADD CONSTRAINT Alergias_Reportadas_pk
PRIMARY KEY (IdConsulta, NumeroReceta, AlergiasReportadas);

-- FK
ALTER TABLE Alergias_Reportadas ADD CONSTRAINT Alergias_Reportadas_fk
FOREIGN KEY (IdConsulta, NumeroReceta) REFERENCES Receta(IdConsulta, NumeroReceta)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Restricciones
ALTER TABLE Alergias_Reportadas
ALTER COLUMN AlergiasReportadas SET DEFAULT 'Ninguna conocida';

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE Alergias_Reportadas IS 'Atributo multivaluado que registra las alergias del paciente en una receta.';

-- Comentarios de Columnas
COMMENT ON COLUMN Alergias_Reportadas.IdConsulta IS 'Identificador de la consulta vinculada.';
COMMENT ON COLUMN Alergias_Reportadas.NumeroReceta IS 'Número de receta vinculado.';
COMMENT ON COLUMN Alergias_Reportadas.AlergiasReportadas IS 'Descripción de la alergia reportada por el paciente.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT Alergias_Reportadas_pk ON Alergias_Reportadas IS 'Llave primaria compuesta (IdConsulta, NumeroReceta y AlergiasReportadas).';
COMMENT ON CONSTRAINT Alergias_Reportadas_fk ON Alergias_Reportadas IS 'Llave foránea (compuesta): Receta a la que pertenece el reporte de alergias.';


-- Tabla 4
CREATE TABLE PreescribirMedComercial(
    IdConsulta INTEGER,
    NumeroReceta INTEGER,
    IdMedicamento INTEGER,
    DosisPrescrita VARCHAR(50),
    Frecuencia VARCHAR(50),
    ViaAdministracionIndicada VARCHAR(50),
    Duracion VARCHAR(50)
);

-- PK
ALTER TABLE PreescribirMedComercial ADD CONSTRAINT PreescribirMedComercial_pk
PRIMARY KEY (IdConsulta, NumeroReceta, IdMedicamento);

-- FK
ALTER TABLE PreescribirMedComercial ADD CONSTRAINT PreescribirMedComercial_fk1
FOREIGN KEY (IdConsulta, NumeroReceta) REFERENCES Receta(IdConsulta, NumeroReceta)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE PreescribirMedComercial ADD CONSTRAINT PreescribirMedComercial_fk2
FOREIGN KEY (IdMedicamento) REFERENCES MedComercial(IdMedicamento)
ON UPDATE CASCADE ON DELETE RESTRICT;

-- Restricciones
ALTER TABLE PreescribirMedComercial
ALTER COLUMN DosisPrescrita SET NOT NULL,
ALTER COLUMN Frecuencia SET NOT NULL,
ALTER COLUMN Duracion SET NOT NULL;

-- =================================================================
--                      BLOQUE DE CORRECCIONES 
-- =================================================================
-- Se renombra la tabla para mantener congruencia estricta con el Modelo Relacional
ALTER TABLE PreescribirMedComercial RENAME TO PrescribirMedComercial;

-- Se renombran las Llaves Foráneas para corregir el error ortográfico
ALTER TABLE PrescribirMedComercial RENAME CONSTRAINT PreescribirMedComercial_fk1 TO PrescribirMedComercial_fk1;
ALTER TABLE PrescribirMedComercial RENAME CONSTRAINT PreescribirMedComercial_fk2 TO PrescribirMedComercial_fk2;

-- Se agrega restricción NOT NULL para ViaAdministracionIndicada
ALTER TABLE PrescribirMedComercial
ALTER COLUMN ViaAdministracionIndicada SET NOT NULL;

-- Se elimina la PK PreescribirMedComercial_pk
ALTER TABLE PrescribirMedComercial 
DROP CONSTRAINT PreescribirMedComercial_pk;

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE PrescribirMedComercial IS 'Detalle de medicamentos comerciales recetados.';

-- Comentarios de Columnas
COMMENT ON COLUMN PrescribirMedComercial.IdConsulta IS 'Identificador de la consulta vinculada.';
COMMENT ON COLUMN PrescribirMedComercial.NumeroReceta IS 'Número de receta vinculado.';
COMMENT ON COLUMN PrescribirMedComercial.IdMedicamento IS 'Identificador del medicamento comercial recetado.';
COMMENT ON COLUMN PrescribirMedComercial.DosisPrescrita IS 'Cantidad y unidad del medicamento a administrar.';
COMMENT ON COLUMN PrescribirMedComercial.Frecuencia IS 'Intervalo de tiempo entre dosis.';
COMMENT ON COLUMN PrescribirMedComercial.ViaAdministracionIndicada IS 'Vía de administración especificada por el médico.';
COMMENT ON COLUMN PrescribirMedComercial.Duracion IS 'Periodo total del tratamiento.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT PrescribirMedComercial_fk1 ON PrescribirMedComercial IS 'Llave foránea (compuesta): Receta que incluye la prescripción.';
COMMENT ON CONSTRAINT PrescribirMedComercial_fk2 ON PrescribirMedComercial IS 'Llave foránea: Medicamento comercial recetado.';


--Tabla 5
CREATE TABLE PreescribirMedPreparado(
    IdConsulta INTEGER,
    NumeroReceta INTEGER,
    IdMedicamento INTEGER,
    DosisPrescrita VARCHAR(50),
    Frecuencia VARCHAR(50),
    ViaAdministracionIndicada VARCHAR(50),
    Duracion VARCHAR(50)
);

-- PK
ALTER TABLE PreescribirMedPreparado ADD CONSTRAINT PreescribirMedPreparado_pk
PRIMARY KEY (IdConsulta, NumeroReceta, IdMedicamento);

-- FK
ALTER TABLE PreescribirMedPreparado ADD CONSTRAINT PreescribirMedPreparado_fk1
FOREIGN KEY (IdConsulta, NumeroReceta) REFERENCES Receta(IdConsulta, NumeroReceta)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE PreescribirMedPreparado ADD CONSTRAINT PreescribirMedPreparado_fk2
FOREIGN KEY (IdMedicamento) REFERENCES MedComercial(IdMedicamento)
ON UPDATE CASCADE ON DELETE RESTRICT;

-- Restricciones
ALTER TABLE PreescribirMedPreparado
ALTER COLUMN DosisPrescrita SET NOT NULL,
ALTER COLUMN Frecuencia SET NOT NULL,
ALTER COLUMN Duracion SET NOT NULL;

-- =================================================================
--                      BLOQUE DE CORRECCIONES 
-- =================================================================
-- Se renombra la tabla para mantener congruencia estricta con el Modelo Relacional
ALTER TABLE PreescribirMedPreparado RENAME TO PrescribirMedPreparado;

-- Se renombran las Llaves Foráneas para corregir el error ortográfico
ALTER TABLE PrescribirMedPreparado RENAME CONSTRAINT PreescribirMedPreparado_fk1 TO PrescribirMedPreparado_fk1;
ALTER TABLE PrescribirMedPreparado RENAME CONSTRAINT PreescribirMedPreparado_fk2 TO PrescribirMedPreparado_fk2;

-- Se agrega restricción NOT NULL para ViaAdministracionIndicada
ALTER TABLE PrescribirMedPreparado
ALTER COLUMN ViaAdministracionIndicada SET NOT NULL;

-- Se elimina la PK PreescribirMedPreparado_pk
ALTER TABLE PrescribirMedPreparado 
DROP CONSTRAINT PreescribirMedPreparado_pk;

-- =================================================================
--                      BLOQUE DE COMENTARIOS 
-- =================================================================
COMMENT ON TABLE PrescribirMedPreparado IS 'Detalle de medicamentos preparados recetados.';

-- Comentarios de Columnas
COMMENT ON COLUMN PrescribirMedPreparado.IdConsulta IS 'Identificador de la consulta vinculada.';
COMMENT ON COLUMN PrescribirMedPreparado.NumeroReceta IS 'Número de receta vinculado.';
COMMENT ON COLUMN PrescribirMedPreparado.IdMedicamento IS 'Identificador de la fórmula magistral recetada.';
COMMENT ON COLUMN PrescribirMedPreparado.DosisPrescrita IS 'Instrucciones de dosificación para el preparado.';
COMMENT ON COLUMN PrescribirMedPreparado.Frecuencia IS 'Periodicidad de la administración.';
COMMENT ON COLUMN PrescribirMedPreparado.ViaAdministracionIndicada IS 'Vía de administración recomendada por el especialista.';
COMMENT ON COLUMN PrescribirMedPreparado.Duracion IS 'Duración total del tratamiento con el preparado.';

-- Comentarios de Restricciones
COMMENT ON CONSTRAINT PrescribirMedPreparado_fk1 ON PrescribirMedPreparado IS 'Llave foránea (compuesta): Receta que incluye la prescripción.';
COMMENT ON CONSTRAINT PrescribirMedPreparado_fk2 ON PrescribirMedPreparado IS 'Llave foránea: Medicamento preparado recetado.';

-- =================================================================
--                    BLOQUE DE CORRECCIONES PARA P08 
-- =================================================================
-- Eliminar la FK incorrecta que apuntaba a MedComercial
ALTER TABLE PrescribirMedPreparado DROP CONSTRAINT PrescribirMedPreparado_fk2;
-- Crear la FK correcta hacia MedPreparado con las políticas de mantenimiento
ALTER TABLE PrescribirMedPreparado ADD CONSTRAINT PrescribirMedPreparado_fk2
FOREIGN KEY (IdMedicamento) REFERENCES MedPreparado(IdMedicamento)
ON UPDATE CASCADE ON DELETE RESTRICT;