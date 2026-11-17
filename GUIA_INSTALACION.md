# FreshSeat - Guía de instalación y configuración

## 1. Descripción del proyecto

FreshSeat es un sistema de gestión de información para una barbería.

El proyecto utiliza:

- Oracle Database para almacenar la información.
- SQL y PL/SQL para gestionar los datos.
- Python para establecer la conexión y ejecutar los objetos PL/SQL.
- GitHub para compartir y mantener el código del proyecto.

## 2. Bases de datos independientes

Cada integrante del equipo utilizará su propia base de datos Oracle.

No es necesario compartir usuarios, contraseñas ni wallets.

Cada integrante debe:

1. Tener acceso a una base de datos Oracle.
2. Crear las tablas del proyecto.
3. Insertar los datos iniciales.
4. Crear los procedimientos y funciones PL/SQL.
5. Configurar su propia conexión desde Python.

Los nombres de las tablas y de los objetos PL/SQL deben mantenerse
iguales para garantizar la compatibilidad entre los integrantes.

## 3. Preparar Oracle Database

Abrir Oracle SQL Developer y conectarse a la base de datos personal.

Ejecutar los scripts de la carpeta Scripts en este orden:

1. 01.tablas.sql
2. FRESHSEAT1.sql
3. FRESHSEAT2-procedimientospersona2.sql
4. FRESHSEAT3-procedimientos_servicio.sql
5. FRESHSEAT4-estados-y-funcion.sql

IMPORTANTE:

- Estos scripts deben ejecutarse en el esquema donde funcionará FreshSeat.
- Revisar los comandos DROP TABLE antes de ejecutar el script de tablas.
- No ejecutar scripts de creación o carga inicial sobre una base con
  información que se desee conservar.
- Los datos de ejemplo deben insertarse una sola vez.
- Los scripts adicionales que se incorporen posteriormente también
  deberán ejecutarse según sus dependencias.

## 4. Preparar Python

Instalar Python en la computadora.

Abrir una terminal en la carpeta principal del proyecto.

Crear el entorno virtual:

```powershell
python -m venv .venv
```

Instalar las dependencias:

```powershell
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

## 5. Configurar la conexión Oracle

El archivo Python/conexion_oracle.py solicitará:

- Usuario de Oracle.
- Nombre del servicio Oracle o DSN.
- Si la conexión utiliza wallet.
- Contraseña de Oracle.
- Ruta del wallet, cuando corresponda.
- Contraseña del wallet, cuando corresponda.

No es necesario modificar el código Python para introducir estos datos.

### Si se utiliza Oracle Autonomous Database

Cada integrante debe descargar el wallet de su propia base de datos,
descomprimirlo y conservarlo fuera del repositorio.

La carpeta debe incluir los archivos necesarios para la conexión,
entre ellos:

- tnsnames.ora
- ewallet.pem

El nombre del servicio se obtiene del archivo tnsnames.ora
correspondiente a la base personal.

### Si se utiliza una base Oracle sin wallet

Responder "n" cuando el programa consulte si utiliza wallet.

Indicar un DSN válido para esa base de datos.

Ejemplo de formato para una conexión local:

localhost:1521/XEPDB1

El host, puerto y servicio dependerán de la instalación de cada usuario.

## 6. Ejecutar la prueba de conexión

Desde la carpeta principal del proyecto, ejecutar:

```powershell
.\.venv\Scripts\python.exe .\Python\conexion_oracle.py
```

El programa verifica:

1. La conexión con Oracle.
2. La ejecución de SP_LISTAR_CLIENTES.
3. La ejecución de SP_LISTAR_SERVICIOS.
4. La ejecución de SP_LISTAR_ESTADOS.
5. La ejecución de FN_NOMBRE_ESTADO.

Para completar estas pruebas, los objetos PL/SQL deben haber sido
creados previamente en la base de datos del usuario.

## 7. Seguridad

No subir a GitHub:

- Contraseñas.
- Archivos del wallet de Oracle.
- Archivos de configuración con credenciales.
- Carpetas de entornos virtuales.
- Archivos .env con información sensible.

Cada integrante es responsable de configurar su propia conexión.

## 8. Verificación

Si la configuración es correcta, el programa mostrará:

PRUEBAS FINALIZADAS CORRECTAMENTE

Si ocurre un error, revisar:

- Que Oracle esté disponible.
- Que las credenciales sean correctas.
- Que el servicio o DSN corresponda a la base utilizada.
- Que el wallet sea el correspondiente a esa base.
- Que las tablas y procedimientos estén creados en el esquema correcto.

## 9. Trabajo colaborativo

El proyecto se mantiene en el repositorio compartido de GitHub.

Cada integrante debe subir sus aportes e informar al equipo
cuando incorpore nuevos scripts o funcionalidades.

La aplicación final deberá integrar las operaciones CRUD y demás
funcionalidades requeridas por el curso.