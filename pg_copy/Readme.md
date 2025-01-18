## PG_COPY.SH

Este script permite realizar un volcado (pg_dump) de una base de datos PostgreSQL y restaurarla (pg_restore) en otro servidor de base de datos PostgreSQL, todo utilizando contenedores Docker. El script lee los parámetros de configuración desde un archivo y ejecuta las operaciones dentro de contenedores para evitar la necesidad de tener herramientas PostgreSQL instaladas en el sistema host.

### Requisitos

* **Docker**: Debes tener Docker instalado en tu sistema para ejecutar los contenedores.
*  **Archivo de configuración**: El script lee los parámetros de configuración desde un archivo de texto. Este archivo debe especificar los detalles de conexión de las bases de datos de origen y destino.