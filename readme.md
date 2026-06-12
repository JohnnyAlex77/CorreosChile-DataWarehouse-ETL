# PROYECTO: CORREOS DE CHILE - DATA WAREHOUSE Y ETL

**Autores:** Johnny Valladares - Daniel Vergara

**Asignatura:** Arquitectura y Almacenamiento de Datos

**Evaluacion:** Sumativa N°3 - Herramientas de Implementacio(Pentaho)

**Fecha:** Junio 2026

---

## Descripcion del Proyecto

Este proyecto implementa un Data Warehouse para Correos de Chile utilizando Pentaho Data Integration (PDI) como herramienta ETL y MySQL como base de datos. El objetivo es consolidar datos transaccionales de envios postales (2000 registros) en un modelo estrella (star schema).

---

## Estructura de Archivos

| Archivo | Descripcion |
|---------|-------------|
| 01_crear_bbdd.sql | Crea la base de datos y todas las tablas |
| 02_cargar_dimensiones_y_hechos.sql | Transforma staging a modelo estrella |
| 03_verificar_carga.sql | Verifica que todo se cargo correctamente |
| carga_staging.ktr | Transformacion Pentaho (CSV -> staging) |
| job_correos_etl.kjb | Job Pentaho (opcion A: staging + SQL) |
| Correos_Transacciones_2000.csv | Dataset con 2000 transacciones |
| Trans_01_DimSucursal.ktr | Carga directa a DimSucursal |
| Trans_02_DimTipoServicio.ktr | Carga directa a DimTipoServicio |
| Trans_03_DimCliente.ktr | Carga directa a DimCliente |
| Trans_04_DimTiempo.ktr | Carga directa a DimTiempo |
| Trans_05_DimRuta.ktr | Carga directa a DimRuta |
| Trans_HechosEnvio.ktr | Carga directa a HechosEnvio |
| JOB_CorreosChile_ETL.kjb | Job con 6 transformaciones individuales |

---

## Carpeta Instalacion (softwares incluidos)

| Archivo | Descripcion |
|---------|-------------|
| jre-8u491-windows-x64/ | Java 8 (necesario para Pentaho) |
| OpenJDK17U-jdk_x64_windows_hotspot/ | Java 17 (alternativo) |
| mysql-installer-community-8.0.46.0.exe | MySQL 8.0 (base de datos) |
| xampp-windows-x64-8.2.12-0.7z | XAMPP (opcional: Apache + MySQL) |

**Nota:** XAMPP incluye MySQL, no es necesario instalar ambos.

---

## Requisitos para Ejecutar

| Software | Version | Incluido | Nota |
|----------|---------|----------|------|
| Java | 8 o superior | Si | Necesario para Pentaho |
| MySQL | 8.0 o superior | Si | O usar XAMPP |
| Pentaho PDI | 9.4 | Si | En carpeta Data Integration |
| MySQL Workbench | 8.0 | No | Opcional, para scripts SQL |

**Rutas recomendadas:**

| Elemento | Ruta |
|----------|------|
| Pentaho | C:\Pentaho\Data Integration\Spoon.bat |
| Proyecto | C:\Correos_ETL_Evaluacion\ |
| CSV | C:\Correos_ETL_Evaluacion\Correos_Transacciones_2000.csv |

---

## Opciones de Instalacion de Base de Datos

| Opcion | Instalador | Configuracion |
|--------|------------|---------------|
| 1 (recomendado) | mysql-installer-community-8.0.46.0.exe | Puerto 3306, usuario root, pass vacia |
| 2 (alternativo) | XAMPP (extraer en C:\xampp) | Iniciar MySQL desde xampp-control.exe |

---

## Configuraciones Previas (Obligatorias)

| Paso | Accion | Verificacion |
|------|--------|---------------|
| 1 | Instalar Java | `java -version` muestra 1.8.0_xxx |
| 2 | Instalar MySQL o XAMPP | MySQL corre en puerto 3306 |
| 3 | Copiar Pentaho a C:\Pentaho\ | Spoon.bat existe |
| 4 | Configurar conexion en Pentaho | Test -> "Connected ! OK" |
| 5 | Ejecutar 01_crear_bbdd.sql | Aparecen 7 tablas |

**Configuracion de conexion en Pentaho:**

| Campo | Valor |
|-------|-------|
| Connection Name | Connexion_correos_DW |
| Connection Type | MySQL |
| Access | Native (JDBC) |
| Hostname | localhost |
| Database Name | CorreosChile_DW |
| Port Number | 3306 |
| Username | root |
| Password | (dejar vacio) |

---

## Opcion A: Enfoque Staging + SQL

**Descripcion:** Una transformacion Pentaho + script SQL.

**Flujo de ejecucion:**

| Paso | Accion |
|------|--------|
| 1 | Pentaho lee el CSV |
| 2 | Pentaho escribe en staging_envios |
| 3 | Script SQL transforma staging a dimensiones |
| 4 | Script SQL carga tabla de hechos |

**Archivos involucrados:**

| Archivo | Rol |
|---------|-----|
| carga_staging.ktr | Transformacion Pentaho |
| job_correos_etl.kjb | Job orquestador |
| 02_cargar_dimensiones_y_hechos.sql | Script SQL |

**Pasos de ejecucion:**

| Paso | Accion |
|------|--------|
| A1 | Verificar configuraciones previas |
| A2 | Abrir Spoon.bat |
| A3 | File -> Open -> job_correos_etl.kjb |
| A4 | Verificar estructura del Job |
| A5 | Clic en boton VERDE RUN |
| A6 | Monitorear log |
| A7 | Ejecutar 03_verificar_carga.sql |

**Tiempo estimado:** 30-60 segundos

---

## Opcion B: Enfoque de Transformaciones Individuales

**Descripcion:** 6 transformaciones independientes, una por cada tabla.

**Flujo de ejecucion:**

| Paso | Transformacion | Tabla destino |
|------|----------------|---------------|
| 1 | Trans_03_DimCliente | DimCliente |
| 2 | Trans_04_DimTiempo | DimTiempo |
| 3 | Trans_01_DimSucursal | DimSucursal |
| 4 | Trans_05_DimRuta | DimRuta |
| 5 | Trans_02_DimTipoServicio | DimTipoServicio |
| 6 | Trans_HechosEnvio | HechosEnvio |

**Archivos involucrados:**

| Archivo | Rol |
|---------|-----|
| Trans_01_DimSucursal.ktr | Dimension sucursal |
| Trans_02_DimTipoServicio.ktr | Dimension tipo servicio |
| Trans_03_DimCliente.ktr | Dimension cliente |
| Trans_04_DimTiempo.ktr | Dimension tiempo |
| Trans_05_DimRuta.ktr | Dimension ruta |
| Trans_HechosEnvio.ktr | Tabla de hechos |
| JOB_CorreosChile_ETL.kjb | Job orquestador |

**Pasos de ejecucion:**

| Paso | Accion |
|------|--------|
| B1 | Verificar configuraciones previas |
| B2 | Abrir Spoon.bat |
| B3 | File -> Open -> JOB_CorreosChile_ETL.kjb |
| B4 | Verificar orden de transformaciones |
| B5 | (Opcional) Revisar cada transformacion |
| B6 | Clic en boton VERDE RUN |
| B7 | Monitorear log |
| B8 | Ejecutar 03_verificar_carga.sql |

**Tiempo estimado:** 1-3 minutos

---

## Comparacion entre Opciones

| Caracteristica | Opcion A (Staging+SQL) | Opcion B (Individuales) |
|----------------|------------------------|-------------------------|
| Numero de transformaciones | 1 | 6 |
| Uso de tabla staging | Si | No |
| Tiempo de ejecucion | 30-60 segundos | 1-3 minutos |
| Complejidad de mantenimiento | Baja | Media |
| Visual en Pentaho | Simple | Muy visual |
| Profesional (estandar industria) | Alta | Media |
| Mejor para grandes volumenes | Si | No |
| Mejor para aprendizaje visual | No | Si |

**Recomendacion:**

| Caso | Opcion recomendada |
|------|-------------------|
| Demostracion en evaluacion | Opcion B (mas visual) |
| Produccion o datos masivos | Opcion A (mas eficiente) |
| Maxima puntuacion | Mostrar ambas y explicar diferencias |

---

## Resultado Esperado (Ambas Opciones)

| Tabla | Cantidad |
|-------|----------|
| staging_envios | 2000 |
| DimCliente | ~1651 |
| DimSucursal | 5 |
| DimRuta | 25 |
| DimTipoServicio | 4 |
| DimTiempo | ~460 |
| HechosEnvio | 2000 |

---

## Solucion de Problemas Comunes

| Problema | Solucion |
|----------|----------|
| Connection failed | Verificar MySQL encendido, puerto, usuario, pass |
| Duplicate entry | TRUNCATE tabla antes de insertar o usar INSERT IGNORE |
| Cannot truncate | Ejecutar SET FOREIGN_KEY_CHECKS = 0 |
| Pentaho no arranca | Verificar Java, aumentar memoria en Spoon.bat |
| HechosEnvio vacio | Verificar orden de ejecucion (dimensiones primero) |
| Botones desactivados | Usar Insert/Update en lugar de Table output |
| MySQL no arranca en XAMPP | Verificar puerto 3306 no ocupado |

---

## Consultas Analiticas de Ejemplo

**Top 5 clientes por monto:**

```sql
SELECT c.ID_Cliente, c.Tipo_Cliente, SUM(h.Monto_Servicio) AS Total_Gastado
FROM HechosEnvio h
JOIN DimCliente c ON h.ID_Cliente = c.ID_Cliente
GROUP BY c.ID_Cliente, c.Tipo_Cliente
ORDER BY Total_Gastado DESC LIMIT 5;
```
**Rutas con mayores demoras:**

```sql

SELECT r.Region_Origen, r.Region_Destino, 
       AVG(h.Dias_Transito) AS Promedio_Dias,
       COUNT(*) AS Cantidad_Envios
FROM HechosEnvio h
JOIN DimRuta r ON h.ID_Ruta = r.ID_Ruta
WHERE h.Dias_Transito IS NOT NULL
GROUP BY r.Region_Origen, r.Region_Destino
ORDER BY Promedio_Dias DESC LIMIT 10;
```
**Envios por mes:**

```sql

SELECT YEAR(t.Fecha) AS Anio, MONTH(t.Fecha) AS Mes,
       ts.Nombre AS Tipo_Servicio,
       SUM(h.Monto_Servicio) AS Ingresos,
       COUNT(*) AS Cantidad
FROM HechosEnvio h
JOIN DimTiempo t ON h.ID_Tiempo_Origen = t.ID_Tiempo
JOIN DimTipoServicio ts ON h.ID_TipoServicio = ts.ID_TipoServicio
GROUP BY YEAR(t.Fecha), MONTH(t.Fecha), ts.Nombre
ORDER BY Anio DESC, Mes DESC, Ingresos DESC;
```
---

## Enlaces de Interes

|Recurso|Enlace|
|---|---|
|Repositorio GitHub|[https://github.com/JohnnyAlex77/CorreosChile-DataWarehouse-ETL](https://github.com/JohnnyAlex77/CorreosChile-DataWarehouse-ETL)|
|Instaladores (OneDrive)|[https://inacapmailcl-my.sharepoint.com/:f:/g/personal/johnny_valladares_inacapmail_cl/IgDv67BN8fxeRIQ2fgzOVTDfASKetYRhTODbdmOEKcXoOmE?e=Qrf5hs](https://inacapmailcl-my.sharepoint.com/:f:/g/personal/johnny_valladares_inacapmail_cl/IgDv67BN8fxeRIQ2fgzOVTDfASKetYRhTODbdmOEKcXoOmE?e=Qrf5hs)|

---

## Contacto

|Autor|GitHub|
|---|---|
|Johnny Valladares|@JohnnyAlex77|
|Daniel Vergara|-|

---

**Licencia:** MIT
