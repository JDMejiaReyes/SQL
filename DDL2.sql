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
ADD CONSTRAINT Sucursal_d1 CHECK (NumeroInterior IS NULL OR NumeroInterior > 0),
ADD CONSTRAINT Sucursal_d2 CHECK (NumeroExterior > 0),
ALTER COLUMN Colonia SET NOT NULL,
ALTER COLUMN Estado SET NOT NULL,
ALTER COLUMN Telefono SET NOT NULL;

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
ALTER COLUMN IdSucursal SET NOT NULL,
ADD CONSTRAINT Clinica_u1 UNIQUE (IdSucursal);

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
    Salario NUMERIC(7, 2),
    IdSucursal INTEGER,
    InstitucionEgreso VARCHAR(100),
    VigenciaCertificacion DATE,
    CedulaProfesional INTEGER,
    FechaNacimiento DATE
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
ADD CONSTRAINT Medico_u1 UNIQUE (CedulaProfesional),
ALTER COLUMN FechaNacimiento SET NOT NULL,
ADD CONSTRAINT Medico_d2 CHECK (NumeroInterior IS NULL OR NumeroInterior > 0),
ADD CONSTRAINT Medico_d3 CHECK (NumeroExterior > 0),
ADD CONSTRAINT Medico_d4 CHECK (FechaNacimiento <= CURRENT_DATE);

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
COMMENT ON CONSTRAINT Medico_d4 ON Medico IS 'Validación: La fecha de nacimiento no puede ser futura.';


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
    Salario NUMERIC(7, 2),
    IdSucursal INTEGER,
    TipoProcedimientoCargo VARCHAR(100),
    CertificacionReanimacion BOOLEAN,
    CedulaProfesional INTEGER,
    FechaNacimiento DATE
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
ADD CONSTRAINT Enfermero_u1 UNIQUE (CedulaProfesional),
ALTER COLUMN FechaNacimiento SET NOT NULL,
ADD CONSTRAINT Enfermero_d2 CHECK (NumeroInterior IS NULL OR NumeroInterior > 0),
ADD CONSTRAINT Enfermero_d3 CHECK (NumeroExterior > 0),
ADD CONSTRAINT Enfermero_d4 CHECK (FechaNacimiento <= CURRENT_DATE);

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
COMMENT ON CONSTRAINT Enfermero_d4 ON Enfermero IS 'Validación: La fecha de nacimiento no puede ser futura.';


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
    Salario NUMERIC(7, 2),
    IdSucursal INTEGER,
    CedulaProfesional INTEGER,
    FechaNacimiento DATE
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
ADD CONSTRAINT Farmaceutico_u1 UNIQUE (CedulaProfesional),
ALTER COLUMN FechaNacimiento SET NOT NULL,
ADD CONSTRAINT Farmaceutico_d2 CHECK (NumeroInterior IS NULL OR NumeroInterior > 0),
ADD CONSTRAINT Farmaceutico_d3 CHECK (NumeroExterior > 0),
ADD CONSTRAINT Farmaceutico_d4 CHECK (FechaNacimiento <= CURRENT_DATE);

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
COMMENT ON CONSTRAINT Farmaceutico_d4 ON Farmaceutico IS 'Validación: La fecha de nacimiento no puede ser futura.';


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
    Salario NUMERIC(7, 2),
    IdSucursal INTEGER,
    FechaNacimiento DATE
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
ALTER COLUMN IdSucursal SET NOT NULL,
ALTER COLUMN FechaNacimiento SET NOT NULL,
ADD CONSTRAINT Cajero_d2 CHECK (NumeroInterior IS NULL OR NumeroInterior > 0),
ADD CONSTRAINT Cajero_d3 CHECK (NumeroExterior > 0),
ADD CONSTRAINT Cajero_d4 CHECK (FechaNacimiento <= CURRENT_DATE);

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
COMMENT ON CONSTRAINT Cajero_d4 ON Cajero IS 'Validación: La fecha de nacimiento no puede ser futura.';


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
    Salario NUMERIC(7, 2),
    IdSucursal INTEGER,
    FechaNacimiento DATE
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
ALTER COLUMN IdSucursal SET NOT NULL,
ALTER COLUMN FechaNacimiento SET NOT NULL,
ADD CONSTRAINT Aseador_d2 CHECK (NumeroInterior IS NULL OR NumeroInterior > 0),
ADD CONSTRAINT Aseador_d3 CHECK (NumeroExterior > 0),
ADD CONSTRAINT Aseador_d4 CHECK (FechaNacimiento <= CURRENT_DATE);

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
COMMENT ON CONSTRAINT Aseador_d4 ON Aseador IS 'Validación: La fecha de nacimiento no puede ser futura.';


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
    Salario NUMERIC(7, 2),
    IdSucursal INTEGER,
    FechaNacimiento DATE
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
ALTER COLUMN IdSucursal SET NOT NULL,
ALTER COLUMN FechaNacimiento SET NOT NULL,
ADD CONSTRAINT Cuidador_d2 CHECK (NumeroInterior IS NULL OR NumeroInterior > 0),
ADD CONSTRAINT Cuidador_d3 CHECK (NumeroExterior > 0),
ADD CONSTRAINT Cuidador_d4 CHECK (FechaNacimiento <= CURRENT_DATE);

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
COMMENT ON CONSTRAINT Cuidador_d4 ON Cuidador IS 'Validación: La fecha de nacimiento no puede ser futura.';


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

