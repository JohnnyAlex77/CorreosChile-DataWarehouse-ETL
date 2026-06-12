-- ============================================================
-- SCRIPT 02: CARGAR DIMENSIONES Y HECHOS
-- CORREOS DE CHILE DATA WAREHOUSE
-- ============================================================

USE CorreosChile_DW;

-- Desactivar restricciones temporalmente
SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 1. LIMPIAR TABLAS
-- ============================================================

TRUNCATE TABLE HechosEnvio;
TRUNCATE TABLE DimCliente;
TRUNCATE TABLE DimSucursal;
TRUNCATE TABLE DimRuta;
TRUNCATE TABLE DimTipoServicio;
TRUNCATE TABLE DimTiempo;

-- ============================================================
-- 2. DIMENSIÓN CLIENTE
-- ============================================================

INSERT INTO DimCliente (ID_Cliente, Tipo_Cliente, Rubro, Region)
SELECT 
    ID_Cliente,
    MAX(Tipo_Cliente),
    MAX(Rubro),
    ''
FROM (
    SELECT DISTINCT 
        CAST(SUBSTRING(id_cliente, 3) AS UNSIGNED) AS ID_Cliente,
        tipo_cliente,
        NULLIF(rubro, 'N/A') AS Rubro
    FROM staging_envios
    WHERE id_cliente IS NOT NULL AND id_cliente != ''
) AS subconsulta
GROUP BY ID_Cliente;

-- ============================================================
-- 3. DIMENSIÓN SUCURSAL
-- ============================================================

INSERT INTO DimSucursal (ID_Sucursal)
SELECT DISTINCT id_sucursal
FROM staging_envios
WHERE id_sucursal IS NOT NULL AND id_sucursal != '';

-- ============================================================
-- 4. DIMENSIÓN RUTA
-- ============================================================

INSERT INTO DimRuta (Region_Origen, Region_Destino)
SELECT DISTINCT region_origen, region_destino
FROM staging_envios
WHERE region_origen IS NOT NULL AND region_destino IS NOT NULL;

-- ============================================================
-- 5. DIMENSIÓN TIPO SERVICIO
-- ============================================================

INSERT INTO DimTipoServicio (Nombre)
SELECT DISTINCT tipo_servicio
FROM staging_envios
WHERE tipo_servicio IS NOT NULL AND tipo_servicio != '';

-- ============================================================
-- 6. DIMENSIÓN TIEMPO (conversión correcta de fechas)
-- ============================================================

INSERT INTO DimTiempo (Fecha)
SELECT DISTINCT DATE(fecha)
FROM staging_envios
WHERE fecha IS NOT NULL AND fecha != ''
UNION
SELECT DISTINCT DATE(fecha_entrega_real)
FROM staging_envios
WHERE fecha_entrega_real IS NOT NULL AND fecha_entrega_real != '';

-- ============================================================
-- 7. TABLA DE HECHOS
-- ============================================================

INSERT INTO HechosEnvio (
    ID_Envio, ID_Cliente, ID_Sucursal, 
    ID_Tiempo_Origen, ID_Tiempo_Entrega, 
    ID_TipoServicio, ID_Ruta,
    Peso_Kg, Monto_Servicio, Estado_Envio, Dias_Transito, Hora
)
SELECT 
    s.id_transaccion,
    CAST(SUBSTRING(s.id_cliente, 3) AS UNSIGNED),
    NULLIF(s.id_sucursal, ''),
    dt_origen.ID_Tiempo,
    dt_entrega.ID_Tiempo,
    ts.ID_TipoServicio,
    dr.ID_Ruta,
    CAST(s.peso_kg AS DECIMAL(8,2)),
    CAST(s.monto_servicio AS SIGNED),
    NULLIF(s.estado_envio, ''),
    CAST(NULLIF(s.dias_transito, '') AS SIGNED),
    STR_TO_DATE(NULLIF(s.hora, ''), '%H:%i:%s')
FROM staging_envios s
INNER JOIN DimTiempo dt_origen ON dt_origen.Fecha = DATE(s.fecha)
LEFT JOIN DimTiempo dt_entrega ON dt_entrega.Fecha = DATE(s.fecha_entrega_real)
INNER JOIN DimTipoServicio ts ON ts.Nombre = s.tipo_servicio
INNER JOIN DimRuta dr ON dr.Region_Origen = s.region_origen 
                      AND dr.Region_Destino = s.region_destino
WHERE s.id_transaccion IS NOT NULL;

-- ============================================================
-- 8. VERIFICAR RESULTADOS
-- ============================================================

SELECT '=== DIMENSIONES Y HECHOS CARGADOS ===' AS Mensaje;
SELECT 'DimCliente' AS Tabla, COUNT(*) FROM DimCliente
UNION ALL SELECT 'DimSucursal', COUNT(*) FROM DimSucursal
UNION ALL SELECT 'DimRuta', COUNT(*) FROM DimRuta
UNION ALL SELECT 'DimTipoServicio', COUNT(*) FROM DimTipoServicio
UNION ALL SELECT 'DimTiempo', COUNT(*) FROM DimTiempo
UNION ALL SELECT 'HechosEnvio', COUNT(*) FROM HechosEnvio;

-- Reactivar restricciones
SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES = 1;