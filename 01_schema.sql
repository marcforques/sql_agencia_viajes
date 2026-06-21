SELECT current_database();


-- ===================================================== 
-- CREACIÓN DE TABLAS RAW PARA CSV SUCIOS
-- =====================================================
DROP TABLE IF EXISTS raw_reservas;
DROP TABLE IF EXISTS raw_canales;
DROP TABLE IF EXISTS raw_packs;
DROP TABLE IF EXISTS raw_destinos;
DROP TABLE IF EXISTS raw_clientes;


-- Tabla raw de clientes
CREATE TABLE raw_clientes (
    id_cliente TEXT,
    nombre TEXT,
    email TEXT,
    edad TEXT,
    pais TEXT,
    segmento TEXT
);


-- Tabla raw de destinos
CREATE TABLE raw_destinos (
    id_destino TEXT,
    ciudad TEXT,
    pais TEXT,
    tipo_destino TEXT
);


-- Tabla raw de packs
CREATE TABLE raw_packs (
    id_pack TEXT,
    nombre_pack TEXT,
    categoria TEXT,
    duracion_dias TEXT,
    precio_base TEXT,
    activo TEXT
);


-- Tabla raw de canales
CREATE TABLE raw_canales (
    id_canal TEXT,
    nombre_canal TEXT,
    tipo_canal TEXT
);


-- Tabla raw de reservas
CREATE TABLE raw_reservas (
    id_reserva TEXT,
    localizador TEXT,
    id_cliente TEXT,
    id_destino TEXT,
    id_pack TEXT,
    id_canal TEXT,
    fecha_reserva TEXT,
    fecha_viaje TEXT,
    numero_viajeros TEXT,
    precio_total TEXT,
    coste_total TEXT,
    descuento_perc TEXT,
    estado TEXT
);



-- ===================================================== 
-- CREACIÓN DE TABLAS FINALES
-- =====================================================
DROP TABLE IF EXISTS fact_reservas CASCADE;
DROP TABLE IF EXISTS dim_canales CASCADE;
DROP TABLE IF EXISTS dim_packs CASCADE;
DROP TABLE IF EXISTS dim_destinos CASCADE;
DROP TABLE IF EXISTS dim_clientes CASCADE;



-- =====================================================
-- TABLA: dim_clientes
-- =====================================================

CREATE TABLE dim_clientes (
    id_cliente SERIAL PRIMARY KEY,

    nombre VARCHAR(100) NOT NULL,

    email VARCHAR(150) NOT NULL UNIQUE,

    edad INTEGER CHECK (edad BETWEEN 18 AND 100),

    pais VARCHAR(50) NOT NULL,

    segmento VARCHAR(20) NOT NULL DEFAULT 'Particular',

    CONSTRAINT ck_cliente_segmento 
        CHECK (segmento IN ('Particular', 'Premium', 'Empresa'))
);



-- =====================================================
-- TABLA: dim_destinos
-- =====================================================

CREATE TABLE dim_destinos (
    id_destino SERIAL PRIMARY KEY,

    ciudad VARCHAR(100) NOT NULL,

    pais VARCHAR(100) NOT NULL,

    tipo_destino VARCHAR(50) NOT NULL,

    CONSTRAINT uq_destino_ciudad_pais 
        UNIQUE (ciudad, pais),

    CONSTRAINT ck_tipo_destino 
        CHECK (tipo_destino IN ('Playa', 'Montaña', 'Urbano', 'Rural', 'Aventura'))
);



-- =====================================================
-- TABLA: dim_packs
-- =====================================================

CREATE TABLE dim_packs (
    id_pack SERIAL PRIMARY KEY,

    nombre_pack VARCHAR(100) NOT NULL UNIQUE,

    categoria VARCHAR(30) NOT NULL,

    duracion_dias INTEGER NOT NULL,

    precio_base NUMERIC(10,2) NOT NULL,

    activo BOOLEAN NOT NULL DEFAULT TRUE,

    -- La duración debe ser mayor que cero.
    CONSTRAINT ck_duracion_pack 
        CHECK (duracion_dias > 0),

    -- El precio base no puede ser negativo.
    CONSTRAINT ck_precio_pack 
        CHECK (precio_base >= 0),

    CONSTRAINT ck_categoria_pack 
        CHECK (categoria IN ('Escapada', 'Vacaciones', 'Aventura', 'Cultural'))
);



-- =====================================================
-- TABLA: dim_canales
-- =====================================================

CREATE TABLE dim_canales (
    id_canal SERIAL PRIMARY KEY,

    nombre_canal VARCHAR(50) NOT NULL UNIQUE,

    tipo_canal VARCHAR(20) NOT NULL,

    CONSTRAINT ck_tipo_canal 
        CHECK (tipo_canal IN ('Web', 'Chatbot', 'Teléfono', 'Presencial'))
);



-- =====================================================
-- TABLA: fact_reservas
-- =====================================================

CREATE TABLE fact_reservas (
    id_reserva SERIAL PRIMARY KEY,

    localizador VARCHAR(20) NOT NULL UNIQUE,

    id_cliente INTEGER NOT NULL,

    id_destino INTEGER NOT NULL,

    id_pack INTEGER NOT NULL,

    id_canal INTEGER NOT NULL,

    fecha_reserva DATE NOT NULL,

    fecha_viaje DATE NOT NULL,

    numero_viajeros INTEGER NOT NULL,

    precio_total NUMERIC(10,2) NOT NULL,

    coste_total NUMERIC(10,2) NOT NULL,

    descuento_perc NUMERIC(5,2) NOT NULL DEFAULT 0,

    estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente',

    CONSTRAINT fk_reserva_cliente 
        FOREIGN KEY (id_cliente) 
        REFERENCES dim_clientes(id_cliente),

    CONSTRAINT fk_reserva_destino 
        FOREIGN KEY (id_destino) 
        REFERENCES dim_destinos(id_destino),

    CONSTRAINT fk_reserva_pack 
        FOREIGN KEY (id_pack) 
        REFERENCES dim_packs(id_pack),

    CONSTRAINT fk_reserva_canal 
        FOREIGN KEY (id_canal) 
        REFERENCES dim_canales(id_canal),

    CONSTRAINT ck_numero_viajeros 
        CHECK (numero_viajeros > 0),

    CONSTRAINT ck_precio_total 
        CHECK (precio_total >= 0),

    CONSTRAINT ck_coste_total 
        CHECK (coste_total >= 0),

    CONSTRAINT ck_descuento 
        CHECK (descuento_perc BETWEEN 0 AND 100),

    CONSTRAINT ck_estado_reserva 
        CHECK (estado IN ('Pendiente', 'Confirmada', 'Cancelada', 'Completada')),

    CONSTRAINT ck_fechas_reserva 
        CHECK (fecha_viaje >= fecha_reserva)
);



-- =====================================================
-- COMPROBACIÓN DE TABLAS CREADAS
-- =====================================================

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
      'raw_clientes',
      'raw_destinos',
      'raw_packs',
      'raw_canales',
      'raw_reservas',
      'dim_clientes',
      'dim_destinos',
      'dim_packs',
      'dim_canales',
      'fact_reservas'
  )
ORDER BY table_name;



