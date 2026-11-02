# Proyecto SQL - Agencia de Viajes

Este proyecto forma parte del módulo de SQL y consiste en diseñar una base de datos relacional sencilla para una agencia de viajes.

La idea del proyecto es simular un pequeño sistema de reservas, donde hay clientes, destinos, packs turísticos, canales de venta y reservas. A partir de esos datos se hace una limpieza inicial y después un análisis exploratorio con SQL para sacar conclusiones de negocio.

## Objetivo del proyecto

El objetivo principal es crear una base de datos relacional que sea coherente y que permita analizar las reservas de una agencia de viajes.

Con este proyecto se busca practicar:

* Creación de tablas.
* Uso de claves primarias y claves foráneas.
* Restricciones como `NOT NULL`, `UNIQUE`, `CHECK` y `DEFAULT`.
* Importación de datos desde CSV.
* Limpieza de datos sucios.
* Consultas analíticas con SQL.
* Uso de `JOIN`, `GROUP BY`, funciones de fecha, CTEs, subconsultas y funciones ventana.

## Motor utilizado

El proyecto está hecho con:

* PostgreSQL
* DBeaver

## Estructura del proyecto

```text
proyecto-sql-agencia-viajes/
│
├── sql/
│   ├── 01_schema.sql
│   └── 03_eda.sql
│
├── data/
│   ├── raw_clientes.csv
│   ├── raw_destinos.csv
│   ├── raw_packs.csv
│   ├── raw_canales.csv
│   └── raw_reservas.csv
│
└── README.md
```

## Modelo de datos

El proyecto tiene dos tipos de tablas.

Primero están las tablas `raw`, que sirven para importar los CSV sucios:

```text
raw_clientes
raw_destinos
raw_packs
raw_canales
raw_reservas
```

Estas tablas no tienen restricciones fuertes porque su función es recibir los datos tal como vienen, aunque tengan errores.

Después están las tablas finales:

```text
dim_clientes
dim_destinos
dim_packs
dim_canales
fact_reservas
```

Estas tablas sí tienen claves primarias, claves foráneas y restricciones para asegurar que los datos finales sean correctos.

## Tabla principal

La tabla principal del proyecto es:

```text
fact_reservas
```

Cada fila representa una reserva realizada por un cliente.

Esta tabla se conecta con las dimensiones mediante claves foráneas:

* `id_cliente`
* `id_destino`
* `id_pack`
* `id_canal`

## Dimensiones

Las dimensiones son:

### `dim_clientes`

Guarda la información de los clientes, como nombre, email, edad, país y segmento.

### `dim_destinos`

Guarda los destinos disponibles de la agencia.

### `dim_packs`

Guarda los packs turísticos que se pueden reservar.

### `dim_canales`

Guarda los canales por los que se realiza una reserva, como web, chatbot, teléfono u oficina.

## Limpieza de datos

Los CSV utilizados tienen errores intencionados para poder practicar la parte de calidad de datos.

Algunos errores incluidos son:

* Valores nulos.
* Campos vacíos.
* Duplicados.
* Edades fuera de rango.
* Fechas incorrectas.
* Precios negativos.
* Descuentos superiores al 100%.
* Estados no permitidos.
* Claves que no existen en otras tablas.

La limpieza se hace desde el archivo `03_eda.sql`.

Primero se detectan los errores en las tablas `raw`. Después se cargan solo los datos válidos en las tablas finales.

## Archivos SQL

### `01_schema.sql`

Este archivo crea toda la estructura de la base de datos.

Incluye:

* Tablas `raw`.
* Tablas finales.
* Primary Keys.
* Foreign Keys.
* Constraints.
* Reglas de integridad.

### `03_eda.sql`

Este es el archivo principal del análisis.

Incluye:

* Comprobación de registros importados.
* Detección de nulos.
* Detección de duplicados.
* Validación de rangos.
* Limpieza y carga a tablas finales.
* Transacciones.
* Creación de vistas.
* Creación de una función para calcular margen.
* Índices.
* Consultas analíticas de negocio.

## Cómo ejecutar el proyecto

El orden correcto es:

1. Crear una base de datos en PostgreSQL.
2. Ejecutar `01_schema.sql`.
3. Importar los CSV sucios en las tablas `raw`.
4. Ejecutar `03_eda.sql`.
5. Revisar los resultados de las consultas analíticas.

Los CSV no se deben importar directamente en las tablas finales, porque contienen errores y las restricciones bloquearían la carga.

## Consultas de negocio

En el análisis se responden preguntas como:

* Cuántas reservas hay.
* Cuántos ingresos genera la agencia.
* Qué destinos generan más ingresos.
* Qué packs son más rentables.
* Qué canal de venta funciona mejor.
* Qué clientes tienen mayor gasto.
* Qué tipo de destino tiene más cancelaciones.
* Cómo evolucionan los ingresos por mes.

## Vistas creadas

Se crean dos vistas sencillas:

### `vw_reservas_detalle`

Sirve para ver las reservas con nombres legibles en lugar de solo IDs.

### `vw_resumen_destinos`

Sirve para ver un resumen económico por destino, incluyendo reservas, viajeros, ingresos, ticket medio y margen.

## Función creada

Se crea una función sencilla llamada:

```sql
fn_margen(precio, coste)
```

Esta función calcula el margen de una reserva restando el coste al precio total.

## Conclusión

Este proyecto es sencillo, pero permite practicar las partes más importantes de SQL.

La base de datos queda organizada en una primera capa de datos sucios y una segunda capa de datos limpios. Esto permite demostrar que los datos se validan antes de hacer el análisis.

A partir del modelo final se pueden obtener métricas útiles para una agencia de viajes, como ingresos, margen, canales más rentables, destinos más vendidos y clientes con mayor gasto.
