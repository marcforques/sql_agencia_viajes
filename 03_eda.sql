-- =====================================================
-- 1. COMPROBACIÓN DE REGISTROS EN TABLAS RAW
-- =====================================================

SELECT 'raw_clientes' AS tabla, COUNT(*) AS total_registros FROM raw_clientes
UNION ALL
SELECT 'raw_destinos', COUNT(*) FROM raw_destinos
UNION ALL
SELECT 'raw_packs', COUNT(*) FROM raw_packs
UNION ALL
SELECT 'raw_canales', COUNT(*) FROM raw_canales
UNION ALL
SELECT 'raw_reservas', COUNT(*) FROM raw_reservas;



-- =====================================================
-- 2. VALIDACIÓN DE NULOS O CAMPOS VACÍOS EN RAW
-- =====================================================

-- Clientes con campos importantes vacíos.
SELECT *
FROM raw_clientes
WHERE id_cliente IS NULL OR TRIM(id_cliente) = ''
   OR nombre IS NULL OR TRIM(nombre) = ''
   OR email IS NULL OR TRIM(email) = ''
   OR pais IS NULL OR TRIM(pais) = ''
   OR segmento IS NULL OR TRIM(segmento) = '';


-- Destinos con campos importantes vacíos.
SELECT *
FROM raw_destinos
WHERE id_destino IS NULL OR TRIM(id_destino) = ''
   OR ciudad IS NULL OR TRIM(ciudad) = ''
   OR pais IS NULL OR TRIM(pais) = ''
   OR tipo_destino IS NULL OR TRIM(tipo_destino) = '';


-- Packs con campos importantes vacíos.
SELECT *
FROM raw_packs
WHERE id_pack IS NULL OR TRIM(id_pack) = ''
   OR nombre_pack IS NULL OR TRIM(nombre_pack) = ''
   OR categoria IS NULL OR TRIM(categoria) = ''
   OR duracion_dias IS NULL OR TRIM(duracion_dias) = ''
   OR precio_base IS NULL OR TRIM(precio_base) = ''
   OR activo IS NULL OR TRIM(activo) = '';


-- Canales con campos importantes vacíos.
SELECT *
FROM raw_canales
WHERE id_canal IS NULL OR TRIM(id_canal) = ''
   OR nombre_canal IS NULL OR TRIM(nombre_canal) = ''
   OR tipo_canal IS NULL OR TRIM(tipo_canal) = '';


-- Reservas con campos importantes vacíos.
SELECT *
FROM raw_reservas
WHERE id_reserva IS NULL OR TRIM(id_reserva) = ''
   OR localizador IS NULL OR TRIM(localizador) = ''
   OR id_cliente IS NULL OR TRIM(id_cliente) = ''
   OR id_destino IS NULL OR TRIM(id_destino) = ''
   OR id_pack IS NULL OR TRIM(id_pack) = ''
   OR id_canal IS NULL OR TRIM(id_canal) = ''
   OR fecha_reserva IS NULL OR TRIM(fecha_reserva) = ''
   OR fecha_viaje IS NULL OR TRIM(fecha_viaje) = ''
   OR numero_viajeros IS NULL OR TRIM(numero_viajeros) = ''
   OR precio_total IS NULL OR TRIM(precio_total) = ''
   OR coste_total IS NULL OR TRIM(coste_total) = ''
   OR descuento_perc IS NULL OR TRIM(descuento_perc) = ''
   OR estado IS NULL OR TRIM(estado) = '';



-- =====================================================
-- 3. VALIDACIÓN DE DUPLICADOS EN RAW
-- =====================================================

-- Emails duplicados en clientes.
SELECT
    email,
    COUNT(*) AS veces_repetido
FROM raw_clientes
WHERE email IS NOT NULL
  AND TRIM(email) <> ''
GROUP BY email
HAVING COUNT(*) > 1;


-- Destinos duplicados por ciudad y país.
SELECT
    ciudad,
    pais,
    COUNT(*) AS veces_repetido
FROM raw_destinos
WHERE ciudad IS NOT NULL
  AND pais IS NOT NULL
  AND TRIM(ciudad) <> ''
  AND TRIM(pais) <> ''
GROUP BY ciudad, pais
HAVING COUNT(*) > 1;


-- Packs duplicados por nombre.
SELECT
    nombre_pack,
    COUNT(*) AS veces_repetido
FROM raw_packs
WHERE nombre_pack IS NOT NULL
  AND TRIM(nombre_pack) <> ''
GROUP BY nombre_pack
HAVING COUNT(*) > 1;


-- Canales duplicados por nombre.
SELECT
    nombre_canal,
    COUNT(*) AS veces_repetido
FROM raw_canales
WHERE nombre_canal IS NOT NULL
  AND TRIM(nombre_canal) <> ''
GROUP BY nombre_canal
HAVING COUNT(*) > 1;


-- Reservas duplicadas por localizador.
SELECT
    localizador,
    COUNT(*) AS veces_repetido
FROM raw_reservas
WHERE localizador IS NOT NULL
  AND TRIM(localizador) <> ''
GROUP BY localizador
HAVING COUNT(*) > 1;



-- =====================================================
-- 4. DUPLICADOS CON FUNCIÓN VENTANA
-- =====================================================

WITH clientes_ordenados AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY email
            ORDER BY id_cliente
        ) AS numero_fila
    FROM raw_clientes
    WHERE email IS NOT NULL
      AND TRIM(email) <> ''
)
SELECT *
FROM clientes_ordenados
WHERE numero_fila > 1;



-- =====================================================
-- 5. VALIDACIÓN DE FORMATOS Y RANGOS EN RAW
-- =====================================================

-- Clientes con edad no numérica o fuera de rango.
SELECT *
FROM raw_clientes
WHERE edad !~ '^[0-9]+$'
   OR edad::INTEGER < 18
   OR edad::INTEGER > 100;


-- Clientes con segmento no permitido.
SELECT *
FROM raw_clientes
WHERE segmento NOT IN ('Particular', 'Premium', 'Empresa');


-- Destinos con tipo de destino no permitido.
SELECT *
FROM raw_destinos
WHERE tipo_destino NOT IN ('Playa', 'Montaña', 'Urbano', 'Rural', 'Aventura');


-- Packs con categoría no permitida.
SELECT *
FROM raw_packs
WHERE categoria NOT IN ('Escapada', 'Vacaciones', 'Aventura', 'Cultural');


-- Packs con duración o precio incorrecto.
SELECT *
FROM raw_packs
WHERE duracion_dias !~ '^[0-9]+$'
   OR duracion_dias::INTEGER <= 0
   OR precio_base !~ '^-?[0-9]+(\.[0-9]+)?$'
   OR precio_base::NUMERIC < 0;


-- Canales con tipo no permitido.
SELECT *
FROM raw_canales
WHERE tipo_canal NOT IN ('Web', 'Chatbot', 'Teléfono', 'Presencial');


-- Reservas con fechas incorrectas.
SELECT *
FROM raw_reservas
WHERE fecha_reserva !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
   OR fecha_viaje !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';


-- Reservas con valores numéricos incorrectos.
SELECT *
FROM raw_reservas
WHERE numero_viajeros !~ '^[0-9]+$'
   OR precio_total !~ '^-?[0-9]+(\.[0-9]+)?$'
   OR coste_total !~ '^-?[0-9]+(\.[0-9]+)?$'
   OR descuento_perc !~ '^-?[0-9]+(\.[0-9]+)?$';


-- Reservas con valores fuera de rango.
SELECT *
FROM raw_reservas
WHERE numero_viajeros ~ '^[0-9]+$'
  AND precio_total ~ '^-?[0-9]+(\.[0-9]+)?$'
  AND coste_total ~ '^-?[0-9]+(\.[0-9]+)?$'
  AND descuento_perc ~ '^-?[0-9]+(\.[0-9]+)?$'
  AND (
        numero_viajeros::INTEGER <= 0
     OR precio_total::NUMERIC < 0
     OR coste_total::NUMERIC < 0
     OR descuento_perc::NUMERIC < 0
     OR descuento_perc::NUMERIC > 100
  );


-- Reservas con estado no permitido.
SELECT *
FROM raw_reservas
WHERE estado NOT IN ('Pendiente', 'Confirmada', 'Cancelada', 'Completada');


-- Reservas donde la fecha del viaje es anterior a la fecha de reserva.
SELECT *
FROM raw_reservas
WHERE fecha_reserva ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
  AND fecha_viaje ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
  AND fecha_viaje::DATE < fecha_reserva::DATE;



-- =====================================================
-- 6. LIMPIEZA Y CARGA A TABLAS FINALES
-- =====================================================

BEGIN;


-- Primero vaciamos las tablas finales para poder repetir el proceso.
TRUNCATE TABLE
    fact_reservas,
    dim_clientes,
    dim_destinos,
    dim_packs,
    dim_canales
RESTART IDENTITY CASCADE;



-- =====================================================
-- 6.1 CARGA LIMPIA DE CLIENTES
-- =====================================================

WITH clientes_validos AS (
    SELECT
        id_cliente::INTEGER AS id_cliente,
        TRIM(nombre) AS nombre,
        LOWER(TRIM(email)) AS email,
        edad::INTEGER AS edad,
        TRIM(pais) AS pais,
        TRIM(segmento) AS segmento
    FROM raw_clientes
    WHERE id_cliente ~ '^[0-9]+$'
      AND nombre IS NOT NULL AND TRIM(nombre) <> ''
      AND email IS NOT NULL AND TRIM(email) <> ''
      AND edad ~ '^[0-9]+$'
      AND edad::INTEGER BETWEEN 18 AND 100
      AND pais IS NOT NULL AND TRIM(pais) <> ''
      AND segmento IN ('Particular', 'Premium', 'Empresa')
),
clientes_sin_duplicados AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY id_cliente
            ORDER BY id_cliente
        ) AS rn_id,
        ROW_NUMBER() OVER (
            PARTITION BY email
            ORDER BY id_cliente
        ) AS rn_email
    FROM clientes_validos
)
INSERT INTO dim_clientes (
    id_cliente,
    nombre,
    email,
    edad,
    pais,
    segmento
)
SELECT
    id_cliente,
    nombre,
    email,
    edad,
    pais,
    segmento
FROM clientes_sin_duplicados
WHERE rn_id = 1
  AND rn_email = 1;



-- =====================================================
-- 6.2 CARGA LIMPIA DE DESTINOS
-- =====================================================

WITH destinos_validos AS (
    SELECT
        id_destino::INTEGER AS id_destino,
        TRIM(ciudad) AS ciudad,
        TRIM(pais) AS pais,
        TRIM(tipo_destino) AS tipo_destino
    FROM raw_destinos
    WHERE id_destino ~ '^[0-9]+$'
      AND ciudad IS NOT NULL AND TRIM(ciudad) <> ''
      AND pais IS NOT NULL AND TRIM(pais) <> ''
      AND tipo_destino IN ('Playa', 'Montaña', 'Urbano', 'Rural', 'Aventura')
),
destinos_sin_duplicados AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY id_destino
            ORDER BY id_destino
        ) AS rn_id,
        ROW_NUMBER() OVER (
            PARTITION BY ciudad, pais
            ORDER BY id_destino
        ) AS rn_destino
    FROM destinos_validos
)
INSERT INTO dim_destinos (
    id_destino,
    ciudad,
    pais,
    tipo_destino
)
SELECT
    id_destino,
    ciudad,
    pais,
    tipo_destino
FROM destinos_sin_duplicados
WHERE rn_id = 1
  AND rn_destino = 1;



-- =====================================================
-- 6.3 CARGA LIMPIA DE PACKS
-- =====================================================

WITH packs_validos AS (
    SELECT
        id_pack::INTEGER AS id_pack,
        TRIM(nombre_pack) AS nombre_pack,
        TRIM(categoria) AS categoria,
        duracion_dias::INTEGER AS duracion_dias,
        precio_base::NUMERIC AS precio_base,
        CASE
            WHEN LOWER(TRIM(activo)) = 'true' THEN TRUE
            WHEN LOWER(TRIM(activo)) = 'false' THEN FALSE
        END AS activo
    FROM raw_packs
    WHERE id_pack ~ '^[0-9]+$'
      AND nombre_pack IS NOT NULL AND TRIM(nombre_pack) <> ''
      AND categoria IN ('Escapada', 'Vacaciones', 'Aventura', 'Cultural')
      AND duracion_dias ~ '^[0-9]+$'
      AND duracion_dias::INTEGER > 0
      AND precio_base ~ '^-?[0-9]+(\.[0-9]+)?$'
      AND precio_base::NUMERIC >= 0
      AND LOWER(TRIM(activo)) IN ('true', 'false')
),
packs_sin_duplicados AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY id_pack
            ORDER BY id_pack
        ) AS rn_id,
        ROW_NUMBER() OVER (
            PARTITION BY nombre_pack
            ORDER BY id_pack
        ) AS rn_nombre
    FROM packs_validos
)
INSERT INTO dim_packs (
    id_pack,
    nombre_pack,
    categoria,
    duracion_dias,
    precio_base,
    activo
)
SELECT
    id_pack,
    nombre_pack,
    categoria,
    duracion_dias,
    precio_base,
    activo
FROM packs_sin_duplicados
WHERE rn_id = 1
  AND rn_nombre = 1;



-- =====================================================
-- 6.4 CARGA LIMPIA DE CANALES
-- =====================================================

WITH canales_validos AS (
    SELECT
        id_canal::INTEGER AS id_canal,
        TRIM(nombre_canal) AS nombre_canal,
        TRIM(tipo_canal) AS tipo_canal
    FROM raw_canales
    WHERE id_canal ~ '^[0-9]+$'
      AND nombre_canal IS NOT NULL AND TRIM(nombre_canal) <> ''
      AND tipo_canal IN ('Web', 'Chatbot', 'Teléfono', 'Presencial')
),
canales_sin_duplicados AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY id_canal
            ORDER BY id_canal
        ) AS rn_id,
        ROW_NUMBER() OVER (
            PARTITION BY nombre_canal
            ORDER BY id_canal
        ) AS rn_nombre
    FROM canales_validos
)
INSERT INTO dim_canales (
    id_canal,
    nombre_canal,
    tipo_canal
)
SELECT
    id_canal,
    nombre_canal,
    tipo_canal
FROM canales_sin_duplicados
WHERE rn_id = 1
  AND rn_nombre = 1;



-- =====================================================
-- 6.5 CARGA LIMPIA DE RESERVAS
-- =====================================================

WITH reservas_validas AS (
    SELECT
        id_reserva::INTEGER AS id_reserva,
        TRIM(localizador) AS localizador,
        id_cliente::INTEGER AS id_cliente,
        id_destino::INTEGER AS id_destino,
        id_pack::INTEGER AS id_pack,
        id_canal::INTEGER AS id_canal,
        fecha_reserva::DATE AS fecha_reserva,
        fecha_viaje::DATE AS fecha_viaje,
        numero_viajeros::INTEGER AS numero_viajeros,
        precio_total::NUMERIC AS precio_total,
        coste_total::NUMERIC AS coste_total,
        descuento_perc::NUMERIC AS descuento_perc,
        TRIM(estado) AS estado
    FROM raw_reservas
    WHERE id_reserva ~ '^[0-9]+$'
      AND localizador IS NOT NULL AND TRIM(localizador) <> ''
      AND id_cliente ~ '^[0-9]+$'
      AND id_destino ~ '^[0-9]+$'
      AND id_pack ~ '^[0-9]+$'
      AND id_canal ~ '^[0-9]+$'
      AND fecha_reserva ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
      AND fecha_viaje ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
      AND numero_viajeros ~ '^[0-9]+$'
      AND precio_total ~ '^-?[0-9]+(\.[0-9]+)?$'
      AND coste_total ~ '^-?[0-9]+(\.[0-9]+)?$'
      AND descuento_perc ~ '^-?[0-9]+(\.[0-9]+)?$'
      AND estado IN ('Pendiente', 'Confirmada', 'Cancelada', 'Completada')
),
reservas_filtradas AS (
    SELECT *
    FROM reservas_validas
    WHERE numero_viajeros > 0
      AND precio_total >= 0
      AND coste_total >= 0
      AND descuento_perc BETWEEN 0 AND 100
      AND fecha_viaje >= fecha_reserva
),
reservas_con_fk AS (
    SELECT
        r.*
    FROM reservas_filtradas r
    INNER JOIN dim_clientes c
        ON r.id_cliente = c.id_cliente
    INNER JOIN dim_destinos d
        ON r.id_destino = d.id_destino
    INNER JOIN dim_packs p
        ON r.id_pack = p.id_pack
    INNER JOIN dim_canales ca
        ON r.id_canal = ca.id_canal
),
reservas_sin_duplicados AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY id_reserva
            ORDER BY id_reserva
        ) AS rn_id,
        ROW_NUMBER() OVER (
            PARTITION BY localizador
            ORDER BY id_reserva
        ) AS rn_localizador
    FROM reservas_con_fk
)
INSERT INTO fact_reservas (
    id_reserva,
    localizador,
    id_cliente,
    id_destino,
    id_pack,
    id_canal,
    fecha_reserva,
    fecha_viaje,
    numero_viajeros,
    precio_total,
    coste_total,
    descuento_perc,
    estado
)
SELECT
    id_reserva,
    localizador,
    id_cliente,
    id_destino,
    id_pack,
    id_canal,
    fecha_reserva,
    fecha_viaje,
    numero_viajeros,
    precio_total,
    coste_total,
    descuento_perc,
    estado
FROM reservas_sin_duplicados
WHERE rn_id = 1
  AND rn_localizador = 1;



-- =====================================================
-- 6.6 AJUSTE DE SECUENCIAS SERIAL
-- =====================================================

SELECT setval(
    pg_get_serial_sequence('dim_clientes', 'id_cliente'),
    COALESCE((SELECT MAX(id_cliente) FROM dim_clientes), 1),
    true
);

SELECT setval(
    pg_get_serial_sequence('dim_destinos', 'id_destino'),
    COALESCE((SELECT MAX(id_destino) FROM dim_destinos), 1),
    true
);

SELECT setval(
    pg_get_serial_sequence('dim_packs', 'id_pack'),
    COALESCE((SELECT MAX(id_pack) FROM dim_packs), 1),
    true
);

SELECT setval(
    pg_get_serial_sequence('dim_canales', 'id_canal'),
    COALESCE((SELECT MAX(id_canal) FROM dim_canales), 1),
    true
);

SELECT setval(
    pg_get_serial_sequence('fact_reservas', 'id_reserva'),
    COALESCE((SELECT MAX(id_reserva) FROM fact_reservas), 1),
    true
);


COMMIT;



-- =====================================================
-- 7. COMPROBACIÓN DE DATOS CARGADOS EN TABLAS FINALES
-- =====================================================

SELECT 'dim_clientes' AS tabla, COUNT(*) AS total_registros FROM dim_clientes
UNION ALL
SELECT 'dim_destinos', COUNT(*) FROM dim_destinos
UNION ALL
SELECT 'dim_packs', COUNT(*) FROM dim_packs
UNION ALL
SELECT 'dim_canales', COUNT(*) FROM dim_canales
UNION ALL
SELECT 'fact_reservas', COUNT(*) FROM fact_reservas;



-- =====================================================
-- 8. CREACIÓN DE FUNCIÓN, ÍNDICES Y VISTAS
-- =====================================================

DROP VIEW IF EXISTS vw_reservas_detalle;
DROP VIEW IF EXISTS vw_resumen_destinos;

DROP FUNCTION IF EXISTS fn_margen(NUMERIC, NUMERIC);

CREATE FUNCTION fn_margen(precio NUMERIC, coste NUMERIC)
RETURNS NUMERIC
LANGUAGE SQL
AS $$
    SELECT precio - coste;
$$;


-- Índice útil para consultas temporales.
CREATE INDEX IF NOT EXISTS idx_fact_reservas_fecha
ON fact_reservas(fecha_reserva);


-- Índice útil para analizar reservas por destino y estado.
CREATE INDEX IF NOT EXISTS idx_fact_reservas_destino_estado
ON fact_reservas(id_destino, estado);


-- Vista 1: detalle de reservas con nombres legibles.
CREATE VIEW vw_reservas_detalle AS
SELECT
    r.id_reserva,
    r.localizador,
    c.nombre AS cliente,
    c.email,
    c.segmento,
    d.ciudad AS destino,
    d.pais AS pais_destino,
    d.tipo_destino,
    p.nombre_pack,
    p.categoria,
    ca.nombre_canal,
    ca.tipo_canal,
    r.fecha_reserva,
    r.fecha_viaje,
    r.numero_viajeros,
    r.precio_total,
    r.coste_total,
    r.descuento_perc,
    fn_margen(r.precio_total, r.coste_total) AS margen,
    r.estado
FROM fact_reservas r
INNER JOIN dim_clientes c
    ON r.id_cliente = c.id_cliente
INNER JOIN dim_destinos d
    ON r.id_destino = d.id_destino
INNER JOIN dim_packs p
    ON r.id_pack = p.id_pack
INNER JOIN dim_canales ca
    ON r.id_canal = ca.id_canal;


-- Vista 2: resumen económico por destino.
CREATE VIEW vw_resumen_destinos AS
SELECT
    d.ciudad,
    d.pais,
    d.tipo_destino,
    COUNT(r.id_reserva) AS total_reservas,
    SUM(r.numero_viajeros) AS total_viajeros,
    SUM(r.precio_total) AS ingresos,
    AVG(r.precio_total) AS ticket_medio,
    SUM(fn_margen(r.precio_total, r.coste_total)) AS margen_total
FROM fact_reservas r
INNER JOIN dim_destinos d
    ON r.id_destino = d.id_destino
WHERE r.estado <> 'Cancelada'
GROUP BY
    d.ciudad,
    d.pais,
    d.tipo_destino;



-- =====================================================
-- 9. VALIDACIÓN FINAL DEL MODELO LIMPIO
-- =====================================================

-- Clientes fuera de rango.
SELECT *
FROM dim_clientes
WHERE edad < 18
   OR edad > 100;


-- Reservas con valores incorrectos.
SELECT *
FROM fact_reservas
WHERE numero_viajeros <= 0
   OR precio_total < 0
   OR coste_total < 0
   OR descuento_perc < 0
   OR descuento_perc > 100;


-- Fechas incoherentes.
SELECT *
FROM fact_reservas
WHERE fecha_viaje < fecha_reserva;


-- Reservas sin cliente asociado.
SELECT r.*
FROM fact_reservas r
LEFT JOIN dim_clientes c
    ON r.id_cliente = c.id_cliente
WHERE c.id_cliente IS NULL;



-- =====================================================
-- 10. RESUMEN GENERAL DEL NEGOCIO
-- =====================================================

SELECT
    COUNT(*) AS total_reservas,
    COUNT(DISTINCT id_cliente) AS clientes_con_reserva,
    SUM(numero_viajeros) AS total_viajeros,
    SUM(precio_total) AS ingresos_totales,
    SUM(coste_total) AS costes_totales,
    SUM(fn_margen(precio_total, coste_total)) AS margen_total,
    ROUND(AVG(precio_total), 2) AS ticket_medio
FROM fact_reservas
WHERE estado <> 'Cancelada';



-- =====================================================
-- 11. EVOLUCIÓN MENSUAL DE INGRESOS Y RESERVA
-- =====================================================

SELECT
    DATE_TRUNC('month', fecha_reserva) AS mes,
    COUNT(*) AS total_reservas,
    SUM(precio_total) AS ingresos,
    ROUND(AVG(precio_total), 2) AS ticket_medio
FROM fact_reservas
WHERE estado <> 'Cancelada'
GROUP BY DATE_TRUNC('month', fecha_reserva)
ORDER BY mes;



-- =====================================================
-- 12. DESTINOS CON MÁS INGRESOS
-- =====================================================

SELECT
    d.ciudad,
    d.pais,
    d.tipo_destino,
    COUNT(r.id_reserva) AS total_reservas,
    SUM(r.numero_viajeros) AS total_viajeros,
    SUM(r.precio_total) AS ingresos,
    SUM(fn_margen(r.precio_total, r.coste_total)) AS margen
FROM fact_reservas r
INNER JOIN dim_destinos d
    ON r.id_destino = d.id_destino
WHERE r.estado <> 'Cancelada'
GROUP BY
    d.ciudad,
    d.pais,
    d.tipo_destino
ORDER BY ingresos DESC;



-- =====================================================
-- 13. RENDIMIENTO POR CANAL DE VENTA
-- =====================================================

SELECT
    ca.nombre_canal,
    ca.tipo_canal,
    COUNT(r.id_reserva) AS total_reservas,
    SUM(r.precio_total) AS ingresos,
    ROUND(AVG(r.precio_total), 2) AS ticket_medio,
    SUM(fn_margen(r.precio_total, r.coste_total)) AS margen
FROM fact_reservas r
INNER JOIN dim_canales ca
    ON r.id_canal = ca.id_canal
WHERE r.estado <> 'Cancelada'
GROUP BY
    ca.nombre_canal,
    ca.tipo_canal
ORDER BY ingresos DESC;



-- =====================================================
-- 14. PACKS MÁS RENTABLES
-- =====================================================

SELECT
    p.nombre_pack,
    p.categoria,
    COUNT(r.id_reserva) AS total_reservas,
    SUM(r.precio_total) AS ingresos,
    SUM(fn_margen(r.precio_total, r.coste_total)) AS margen_total,
    ROUND(AVG(fn_margen(r.precio_total, r.coste_total)), 2) AS margen_medio
FROM fact_reservas r
INNER JOIN dim_packs p
    ON r.id_pack = p.id_pack
WHERE r.estado <> 'Cancelada'
GROUP BY
    p.nombre_pack,
    p.categoria
ORDER BY margen_total DESC;



-- =====================================================
-- 15. CLIENTES CON MAYOR GASTO ACUMULADO
-- =====================================================

SELECT
    c.id_cliente,
    c.nombre,
    c.segmento,
    COUNT(r.id_reserva) AS total_reservas,
    SUM(r.precio_total) AS gasto_total,
    ROUND(AVG(r.precio_total), 2) AS ticket_medio
FROM fact_reservas r
INNER JOIN dim_clientes c
    ON r.id_cliente = c.id_cliente
WHERE r.estado <> 'Cancelada'
GROUP BY
    c.id_cliente,
    c.nombre,
    c.segmento
ORDER BY gasto_total DESC
LIMIT 10;



-- =====================================================
-- 16. CLIENTES SIN RESERVAS
-- =====================================================

SELECT
    c.id_cliente,
    c.nombre,
    c.email,
    c.segmento
FROM dim_clientes c
LEFT JOIN fact_reservas r
    ON c.id_cliente = r.id_cliente
WHERE r.id_reserva IS NULL;



-- =====================================================
-- 17. TASA DE CANCELACIÓN POR TIPO DE DESTINO
-- =====================================================

SELECT
    d.tipo_destino,
    COUNT(r.id_reserva) AS total_reservas,
    SUM(
        CASE
            WHEN r.estado = 'Cancelada' THEN 1
            ELSE 0
        END
    ) AS reservas_canceladas,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN r.estado = 'Cancelada' THEN 1
                ELSE 0
            END
        ) / COUNT(r.id_reserva),
        2
    ) AS porcentaje_cancelacion
FROM fact_reservas r
INNER JOIN dim_destinos d
    ON r.id_destino = d.id_destino
GROUP BY d.tipo_destino
ORDER BY porcentaje_cancelacion DESC;



-- =====================================================
-- 18. CLIENTES CON GASTO SUPERIOR A LA MEDIA
-- =====================================================

SELECT
    c.id_cliente,
    c.nombre,
    c.segmento,
    SUM(r.precio_total) AS gasto_total
FROM fact_reservas r
INNER JOIN dim_clientes c
    ON r.id_cliente = c.id_cliente
WHERE r.estado <> 'Cancelada'
GROUP BY
    c.id_cliente,
    c.nombre,
    c.segmento
HAVING SUM(r.precio_total) > (
    SELECT AVG(gasto_cliente)
    FROM (
        SELECT
            id_cliente,
            SUM(precio_total) AS gasto_cliente
        FROM fact_reservas
        WHERE estado <> 'Cancelada'
        GROUP BY id_cliente
    ) subconsulta
)
ORDER BY gasto_total DESC;



-- =====================================================
-- 19. RANKING DE DESTINOS POR TIPO DE DESTINO
-- =====================================================

WITH ingresos_destino AS (
    SELECT
        d.tipo_destino,
        d.ciudad,
        d.pais,
        SUM(r.precio_total) AS ingresos
    FROM fact_reservas r
    INNER JOIN dim_destinos d
        ON r.id_destino = d.id_destino
    WHERE r.estado <> 'Cancelada'
    GROUP BY
        d.tipo_destino,
        d.ciudad,
        d.pais
)
SELECT
    tipo_destino,
    ciudad,
    pais,
    ingresos,
    RANK() OVER (
        PARTITION BY tipo_destino
        ORDER BY ingresos DESC
    ) AS ranking_tipo_destino
FROM ingresos_destino
ORDER BY
    tipo_destino,
    ranking_tipo_destino;



-- ==================================================================
-- 20. COMPARACIÓN DE CADA RESERVA CON EL TICKET MEDIO DE SU CANAL
-- ==================================================================


SELECT
    localizador,
    nombre_canal,
    cliente,
    destino,
    precio_total,
    ROUND(
        AVG(precio_total) OVER (
            PARTITION BY nombre_canal
        ),
        2
    ) AS ticket_medio_canal,
    CASE
        WHEN precio_total > AVG(precio_total) OVER (PARTITION BY nombre_canal)
            THEN 'Por encima de la media'
        ELSE 'Por debajo o igual a la media'
    END AS comparacion_ticket
FROM vw_reservas_detalle
WHERE estado <> 'Cancelada'
ORDER BY
    nombre_canal,
    precio_total DESC;



-- =====================================================
-- 21. CRECIMIENTO MENSUAL DE INGRESOS
-- =====================================================

WITH ingresos_mensuales AS (
    SELECT
        DATE_TRUNC('month', fecha_reserva) AS mes,
        SUM(precio_total) AS ingresos
    FROM fact_reservas
    WHERE estado <> 'Cancelada'
    GROUP BY DATE_TRUNC('month', fecha_reserva)
),
comparacion_mensual AS (
    SELECT
        mes,
        ingresos,
        LAG(ingresos) OVER (
            ORDER BY mes
        ) AS ingresos_mes_anterior
    FROM ingresos_mensuales
)
SELECT
    mes,
    ingresos,
    ingresos_mes_anterior,
    ingresos - ingresos_mes_anterior AS diferencia_ingresos,
    ROUND(
        100.0 * (ingresos - ingresos_mes_anterior)
        / NULLIF(ingresos_mes_anterior, 0),
        2
    ) AS crecimiento_porcentual
FROM comparacion_mensual
ORDER BY mes;



-- =====================================================
-- 22. CONSULTA SOBRE LA VISTA DE RESUMEN DE DESTINOS
-- =====================================================

SELECT
    ciudad,
    pais,
    tipo_destino,
    total_reservas,
    total_viajeros,
    ingresos,
    ROUND(ticket_medio, 2) AS ticket_medio,
    margen_total
FROM vw_resumen_destinos
WHERE total_reservas >= 5
ORDER BY margen_total DESC;



-- =====================================================
-- 23. RESERVAS POR ESTADO
-- =====================================================

SELECT
    estado,
    COUNT(*) AS total_reservas,
    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM fact_reservas),
        2
    ) AS porcentaje
FROM fact_reservas
GROUP BY estado
ORDER BY total_reservas DESC;



-- =====================================================
-- 24. ANÁLISIS POR SEGMENTO DE CLIENTE
-- =====================================================

SELECT
    c.segmento,
    COUNT(r.id_reserva) AS total_reservas,
    SUM(r.precio_total) AS ingresos,
    ROUND(AVG(r.precio_total), 2) AS ticket_medio,
    SUM(fn_margen(r.precio_total, r.coste_total)) AS margen
FROM fact_reservas r
INNER JOIN dim_clientes c
    ON r.id_cliente = c.id_cliente
WHERE r.estado <> 'Cancelada'
GROUP BY c.segmento
ORDER BY ingresos DESC;



-- =====================================================
-- 25. CONCLUSIÓN OPERATIVA
-- =====================================================

SELECT
    COUNT(*) AS reservas_no_canceladas,
    SUM(precio_total) AS ingresos_totales,
    SUM(fn_margen(precio_total, coste_total)) AS margen_total,
    ROUND(AVG(precio_total), 2) AS ticket_medio,
    ROUND(AVG(fecha_viaje - fecha_reserva), 2) AS media_dias_anticipacion
FROM fact_reservas
WHERE estado <> 'Cancelada';
