-- ============================================================
-- SCRIPT 03: VERIFICAR CARGA DEL DATA WAREHOUSE
-- CORREOS DE CHILE DATA WAREHOUSE
-- ============================================================

USE CorreosChile_DW;

-- ============================================================
-- 1. RESUMEN DE REGISTROS POR TABLA
-- ============================================================

SELECT '=== RESUMEN DE CARGA ===' AS Mensaje;

SELECT 'staging_envios' AS Tabla, COUNT(*) AS Cantidad FROM staging_envios
UNION ALL
SELECT 'DimCliente', COUNT(*) FROM DimCliente
UNION ALL
SELECT 'DimSucursal', COUNT(*) FROM DimSucursal
UNION ALL
SELECT 'DimRuta', COUNT(*) FROM DimRuta
UNION ALL
SELECT 'DimTipoServicio', COUNT(*) FROM DimTipoServicio
UNION ALL
SELECT 'DimTiempo', COUNT(*) FROM DimTiempo
UNION ALL
SELECT 'HechosEnvio', COUNT(*) FROM HechosEnvio;

-- ============================================================
-- 2. VERIFICAR INTEGRIDAD REFERENCIAL
-- ============================================================

SELECT '=== VERIFICACIÓN INTEGRIDAD ===' AS Mensaje;

SELECT 
    (SELECT COUNT(*) FROM HechosEnvio h LEFT JOIN DimCliente c ON h.ID_Cliente = c.ID_Cliente WHERE c.ID_Cliente IS NULL) AS Clientes_sin_FK,
    (SELECT COUNT(*) FROM HechosEnvio h LEFT JOIN DimSucursal s ON h.ID_Sucursal = s.ID_Sucursal WHERE s.ID_Sucursal IS NULL) AS Sucursales_sin_FK,
    (SELECT COUNT(*) FROM HechosEnvio h LEFT JOIN DimTipoServicio ts ON h.ID_TipoServicio = ts.ID_TipoServicio WHERE ts.ID_TipoServicio IS NULL) AS TipoServicio_sin_FK,
    (SELECT COUNT(*) FROM HechosEnvio h LEFT JOIN DimTiempo t ON h.ID_Tiempo_Origen = t.ID_Tiempo WHERE t.ID_Tiempo IS NULL) AS Tiempo_Origen_sin_FK;

-- ============================================================
-- 3. MUESTRA DE DATOS (10 registros)
-- ============================================================

SELECT '=== MUESTRA DE ENVÍOS ===' AS Mensaje;

SELECT 
    h.ID_Envio,
    c.ID_Cliente,
    c.Tipo_Cliente,
    c.Rubro,
    t.Fecha AS Fecha_Envio,
    ts.Nombre AS Tipo_Servicio,
    r.Region_Origen,
    r.Region_Destino,
    h.Monto_Servicio,
    h.Estado_Envio
FROM HechosEnvio h
JOIN DimCliente c ON h.ID_Cliente = c.ID_Cliente
JOIN DimTiempo t ON h.ID_Tiempo_Origen = t.ID_Tiempo
JOIN DimTipoServicio ts ON h.ID_TipoServicio = ts.ID_TipoServicio
JOIN DimRuta r ON h.ID_Ruta = r.ID_Ruta
LIMIT 10;

-- ============================================================
-- 4. CONSULTAS ANALÍTICAS DE EJEMPLO
-- ============================================================

SELECT '=== TOP 5 CLIENTES POR MONTO ===' AS Mensaje;

SELECT 
    c.ID_Cliente,
    c.Tipo_Cliente,
    SUM(h.Monto_Servicio) AS Total_Gastado,
    COUNT(*) AS Cantidad_Envios
FROM HechosEnvio h
JOIN DimCliente c ON h.ID_Cliente = c.ID_Cliente
GROUP BY c.ID_Cliente, c.Tipo_Cliente
ORDER BY Total_Gastado DESC
LIMIT 5;

SELECT '=== ENVÍOS POR MES ===' AS Mensaje;

SELECT 
    YEAR(t.Fecha) AS Año,
    MONTH(t.Fecha) AS Mes,
    COUNT(*) AS Total_Envios,
    SUM(h.Monto_Servicio) AS Ingresos_Totales
FROM HechosEnvio h
JOIN DimTiempo t ON h.ID_Tiempo_Origen = t.ID_Tiempo
GROUP BY YEAR(t.Fecha), MONTH(t.Fecha)
ORDER BY Año DESC, Mes DESC;