-- ============================================================
-- SCRIPT 01: CREAR BASE DE DATOS Y TABLAS
-- CORREOS DE CHILE DATA WAREHOUSE
-- ============================================================

-- 1. Eliminar la base de datos si existe
DROP DATABASE IF EXISTS CorreosChile_DW;

-- 2. Crear la base de datos nueva
CREATE DATABASE CorreosChile_DW
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_spanish_ci;

-- 3. Usar la base de datos
USE CorreosChile_DW;

-- 4. Crear tabla STAGING (carga temporal desde Pentaho)
-- IMPORTANTE: Todos los campos como VARCHAR para evitar errores de conversión
CREATE TABLE staging_envios (
    id_transaccion VARCHAR(50),
    fecha VARCHAR(20),
    hora VARCHAR(10),
    id_cliente VARCHAR(20),
    tipo_cliente VARCHAR(50),
    rubro VARCHAR(50),
    region_origen VARCHAR(50),
    region_destino VARCHAR(50),
    tipo_servicio VARCHAR(50),
    peso_kg VARCHAR(20),
    monto_servicio VARCHAR(20),
    id_sucursal VARCHAR(10),
    estado_envio VARCHAR(50),
    fecha_entrega_real VARCHAR(20),
    dias_transito VARCHAR(10)
);

-- 5. Crear DIMENSIONES
CREATE TABLE DimCliente (
    ID_Cliente INT PRIMARY KEY,
    Tipo_Cliente VARCHAR(20),
    Rubro VARCHAR(50),
    Region VARCHAR(50)
);

CREATE TABLE DimSucursal (
    ID_Sucursal VARCHAR(10) PRIMARY KEY
);

CREATE TABLE DimRuta (
    ID_Ruta INT PRIMARY KEY AUTO_INCREMENT,
    Region_Origen VARCHAR(50),
    Region_Destino VARCHAR(50)
);

CREATE TABLE DimTipoServicio (
    ID_TipoServicio INT PRIMARY KEY AUTO_INCREMENT,
    Nombre VARCHAR(50)
);

CREATE TABLE DimTiempo (
    ID_Tiempo INT PRIMARY KEY AUTO_INCREMENT,
    Fecha DATE UNIQUE
);

-- 6. Crear TABLA DE HECHOS
CREATE TABLE HechosEnvio (
    ID_Hecho INT PRIMARY KEY AUTO_INCREMENT,
    ID_Envio VARCHAR(50),
    ID_Cliente INT,
    ID_Sucursal VARCHAR(10),
    ID_Tiempo_Origen INT,
    ID_Tiempo_Entrega INT NULL,
    ID_TipoServicio INT,
    ID_Ruta INT,
    Peso_Kg DECIMAL(8,2),
    Monto_Servicio INT,
    Estado_Envio VARCHAR(20),
    Dias_Transito INT NULL,
    Hora TIME NULL,
    FOREIGN KEY (ID_Cliente) REFERENCES DimCliente(ID_Cliente),
    FOREIGN KEY (ID_Sucursal) REFERENCES DimSucursal(ID_Sucursal),
    FOREIGN KEY (ID_Tiempo_Origen) REFERENCES DimTiempo(ID_Tiempo),
    FOREIGN KEY (ID_Tiempo_Entrega) REFERENCES DimTiempo(ID_Tiempo),
    FOREIGN KEY (ID_TipoServicio) REFERENCES DimTipoServicio(ID_TipoServicio),
    FOREIGN KEY (ID_Ruta) REFERENCES DimRuta(ID_Ruta)
);

-- 7. Verificar creación
SELECT '=== BASE DE DATOS CREADA ===' AS Mensaje;
SHOW TABLES;