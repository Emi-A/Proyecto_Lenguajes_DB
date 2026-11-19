# FreshSeat - Guía de instalación y configuración

## 1. Descripción del proyecto

FreshSeat es un sistema de gestión de información para una barbería.

Su objetivo es administrar la información relacionada con clientes,
trabajadores, servicios, horarios y reservaciones mediante una base
de datos Oracle.

El proyecto utiliza:

- Oracle Database para almacenar la información.
- SQL para la creación y consulta de las tablas.
- PL/SQL para implementar procedimientos almacenados y funciones.
- Python para establecer la conexión y ejecutar objetos PL/SQL.
- GitHub para compartir y mantener el código del equipo.

Este repositorio contiene los componentes desarrollados para el
Avance 2 del proyecto del curso Lenguajes de Bases de Datos.

---

## 2. Bases de datos independientes

Cada integrante del equipo utilizará su propia base de datos Oracle.

No es necesario compartir usuarios, contraseñas ni wallets.

Cada integrante debe:

1. Tener acceso a una base de datos Oracle.
2. Crear las tablas del proyecto.
3. Insertar los datos iniciales.
4. Crear los procedimientos, funciones y vistas PL/SQL.
5. Configurar su propia conexión desde Python.
6. Verificar que los objetos se hayan instalado correctamente.

Los nombres de las tablas y de los objetos PL/SQL deben mantenerse
iguales para garantizar la compatibilidad entre los integrantes.

La base de datos no se comparte directamente mediante GitHub.
El repositorio contiene los scripts necesarios para que cada persona
pueda crear los mismos objetos en su propia base Oracle.

---

## 3. Preparar Oracle Database

### 3.1 Requisitos

Para instalar el proyecto se necesita:

- Acceso a una base de datos Oracle.
- Oracle SQL Developer.
- Un usuario Oracle con permisos para crear tablas,
  procedimientos, funciones y vistas.
- Los archivos SQL disponibles en la carpeta `Scripts`.

Si se utiliza Oracle Autonomous Database, también será necesario
configurar el wallet correspondiente a la base personal.

### 3.2 Crear las tablas y los objetos PL/SQL

Abrir Oracle SQL Developer y conectarse a la base de datos personal.

Ejecutar los archivos de la carpeta `Scripts` en el siguiente orden:

1. `01.tablas.sql`
   - Crea las tablas, relaciones, restricciones e índices.

2. `FRESHSEAT1.sql`
   - Inserta los datos iniciales y los registros de prueba.

3. `FRESHSEAT2-procedimientospersona2.sql`
   - Crea los procedimientos para administrar clientes.

4. `FRESHSEAT3-procedimientos_servicio.sql`
   - Crea los procedimientos para administrar servicios.

5. `FRESHSEAT4-estados-y-funcion.sql`
   - Crea los procedimientos y la función relacionados con
     los estados de las citas.

6. `03_trabajadores.sql`
   - Crea los procedimientos para administrar trabajadores,
     horarios y servicios asignados.
   - Incluye una función de validación y una vista de consulta.

7. `Persona04_Citas.sql`
   - Crea los procedimientos para registrar, consultar,
     actualizar y cancelar citas.
   - Incluye validaciones de disponibilidad, cambios de estado,
     registro del historial y una vista de detalles.

Los siete archivos deben ejecutarse en el orden indicado.

### 3.3 Consideraciones importantes

- Los scripts deben ejecutarse en el esquema Oracle donde
  funcionará FreshSeat.

- El archivo `01.tablas.sql` contiene instrucciones `DROP TABLE`
  que eliminan las tablas existentes antes de crearlas nuevamente.

- Por esta razón, `01.tablas.sql` solamente debe ejecutarse
  cuando se desea preparar o reiniciar la base de datos desde cero.

- El archivo `FRESHSEAT1.sql` carga los datos iniciales y debe
  ejecutarse una sola vez sobre una base recién creada.

- No deben ejecutarse nuevamente los scripts de creación de tablas
  ni de carga inicial sobre una base con información que se desea
  conservar.

- Si las tablas y los datos ya existen, pueden ejecutarse únicamente
  los scripts de procedimientos que necesiten actualizarse.

- Los scripts utilizan nombres de tablas y procedimientos comunes
  para garantizar la compatibilidad entre los integrantes.

---

## 4. Estructura del proyecto

El repositorio se organiza de la siguiente manera:

- `Diccionario de FreshSeat/`
  - Contiene el diccionario de datos y la documentación
    generada para la estructura de la base de datos.

- `Scripts/`
  - Contiene los archivos SQL y PL/SQL del proyecto.

- `Python/`
  - Contiene el programa de conexión con Oracle.

- `requirements.txt`
  - Contiene las dependencias necesarias para Python.

- `.gitignore`
  - Evita incluir archivos locales o sensibles en GitHub.

- `GUIA_INSTALACION.md`
  - Contiene las instrucciones de instalación y configuración.

---

## 5. Preparar Python

### 5.1 Instalar Python

Instalar Python en la computadora donde se ejecutará el programa.

Se recomienda utilizar un entorno virtual para mantener las
dependencias del proyecto separadas de otras instalaciones.

### 5.2 Crear el entorno virtual

Abrir una terminal en la carpeta principal del proyecto.

En Windows, ejecutar:

```powershell
python -m venv .venv
```

### 5.3 Instalar las dependencias

Ejecutar el siguiente comando:

```powershell
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

Esto instalará las dependencias definidas por el proyecto,
incluyendo el paquete necesario para conectarse con Oracle.

---

## 6. Configurar la conexión Oracle

El archivo `Python/conexion_oracle.py` permite configurar
la conexión sin modificar directamente el código Python.

Al ejecutarlo, el programa solicitará:

1. Usuario de Oracle.
2. Nombre del servicio Oracle o DSN.
3. Si la conexión utiliza wallet.
4. Contraseña del usuario Oracle.
5. Ruta de la carpeta del wallet, cuando corresponda.
6. Contraseña del wallet, cuando corresponda.

Cada integrante debe ingresar los datos de su propia base de datos.

### 6.1 Conexión con Oracle Autonomous Database

Si se utiliza Oracle Autonomous Database:

1. Descargar el wallet de la base de datos personal.
2. Descomprimirlo en una carpeta de la computadora.
3. Conservar esa carpeta fuera del repositorio GitHub.
4. Identificar el servicio de conexión en `tnsnames.ora`.
5. Ejecutar el programa Python.
6. Indicar que la conexión utiliza wallet.
7. Ingresar la ruta de la carpeta y las credenciales solicitadas.

La carpeta del wallet debe incluir los archivos proporcionados
por Oracle para establecer la conexión.

El nombre del servicio y la ruta del wallet dependerán de la
configuración de cada integrante.

### 6.2 Conexión con Oracle sin wallet

Si la base Oracle no utiliza wallet:

1. Ejecutar el programa Python.
2. Responder `n` cuando se pregunte si utiliza wallet.
3. Ingresar el DSN correspondiente a la base de datos.
4. Ingresar el usuario y la contraseña de Oracle.

Ejemplo de DSN para una instalación local:

```text
localhost:1521/XEPDB1
```

El host, puerto y servicio dependerán de cada instalación.

---

## 7. Ejecutar la prueba de conexión desde Python

Desde la carpeta principal del proyecto, ejecutar:

```powershell
.\.venv\Scripts\python.exe .\Python\conexion_oracle.py
```

El programa solicitará los datos necesarios para establecer
la conexión con Oracle.

Si la conexión es exitosa, se ejecutarán comprobaciones
sobre los objetos PL/SQL desarrollados para el proyecto.

Actualmente, el programa verifica:

1. La conexión con Oracle.
2. La ejecución de `SP_LISTAR_CLIENTES`.
3. La ejecución de `SP_LISTAR_SERVICIOS`.
4. La ejecución de `SP_LISTAR_ESTADOS`.
5. La ejecución de `FN_NOMBRE_ESTADO`.

También muestra información recuperada de la base de datos
para comprobar que los objetos funcionan correctamente.

Para ejecutar estas pruebas, las tablas y los procedimientos
correspondientes deben haber sido creados previamente.

El programa Python constituye una prueba de integración
entre Python y Oracle.

Los demás procedimientos PL/SQL pueden ejecutarse y
verificarse desde Oracle SQL Developer.

---

## 8. Verificación de los módulos PL/SQL

Además de la conexión mediante Python, se realizaron
comprobaciones de los módulos de trabajadores y citas
utilizando Oracle SQL Developer.

### 8.1 Módulo de trabajadores, horarios y servicios

El archivo `03_trabajadores.sql` contiene:

- 10 procedimientos almacenados.
- 1 función.
- 1 vista.

Se verificó que los 12 objetos estuvieran compilados
correctamente con estado `VALID`.

Entre las funcionalidades implementadas se encuentran:

- Registrar trabajadores.
- Actualizar trabajadores.
- Consultar trabajadores.
- Desactivar trabajadores.
- Registrar horarios.
- Actualizar horarios.
- Consultar horarios.
- Eliminar horarios.
- Asignar servicios a trabajadores.
- Quitar servicios a trabajadores.
- Validar los servicios que puede realizar un trabajador.
- Consultar trabajadores con sus respectivos servicios.

También se incorporaron validaciones para evitar
operaciones incompatibles con las citas existentes.

### 8.2 Módulo de citas e historial

El archivo `Persona04_Citas.sql` contiene:

- 8 procedimientos almacenados.
- 1 función de disponibilidad.
- 1 vista de detalles de citas.

Se verificó que los 10 objetos estuvieran compilados
correctamente con estado `VALID`.

Las funcionalidades implementadas incluyen:

- Verificar la disponibilidad de horarios.
- Registrar nuevas citas.
- Consultar citas.
- Actualizar citas.
- Cancelar citas.
- Confirmar citas.
- Completar citas cuando corresponda.
- Registrar cambios en el historial.
- Consultar el historial de una cita.
- Consultar los detalles de las citas mediante una vista.

También se incluyeron validaciones para:

- Evitar citas en horarios ocupados.
- Impedir registrar o mover citas a fechas pasadas.
- Impedir modificar citas canceladas o completadas.
- Impedir cancelar citas completadas.
- Controlar las transiciones entre estados.
- Impedir completar citas cuya fecha aún no ha ocurrido.

### 8.3 Pruebas funcionales

Se realizaron pruebas funcionales en Oracle SQL Developer.

Para el módulo de citas se verificaron:

1. Disponibilidad inicial de un horario.
2. Registro de una cita.
3. Consulta de la cita registrada.
4. Actualización de la cita.
5. Rechazo de una cita en un horario ocupado.
6. Confirmación de una cita.
7. Rechazo de la finalización anticipada de una cita.
8. Cancelación de una cita.
9. Registro de los cambios en el historial.
10. Disponibilidad del horario después de cancelar.

Las diez comprobaciones terminaron correctamente.

Para evitar modificar permanentemente la información
existente, las pruebas utilizaron registros temporales
que fueron deshechos mediante `ROLLBACK TO`.

### 8.4 Consultar el estado de los objetos

Para comprobar los objetos PL/SQL instalados en Oracle,
puede ejecutarse la siguiente consulta en SQL Developer:

```sql
SELECT object_name, object_type, status
FROM user_objects
WHERE object_type IN ('PROCEDURE', 'FUNCTION', 'VIEW')
ORDER BY object_type, object_name;
```

Los procedimientos, funciones y vistas instalados
correctamente deben aparecer con estado `VALID`.

---

## 9. Seguridad

No deben subirse a GitHub:

- Contraseñas de Oracle.
- Contraseñas del wallet.
- Archivos del wallet de Oracle.
- Archivos de configuración con credenciales.
- Carpetas de entornos virtuales.
- Archivos `.env` con información sensible.

Cada integrante es responsable de configurar su propia conexión.

El repositorio no necesita almacenar información privada
para permitir la instalación del proyecto.

---

## 10. Solución de problemas

### 10.1 Error al conectar con Oracle

Verificar:

- Que Oracle esté disponible.
- Que las credenciales sean correctas.
- Que el servicio o DSN corresponda a la base utilizada.
- Que el wallet pertenezca a la base correspondiente.
- Que la ruta del wallet sea correcta.

### 10.2 Error al ejecutar procedimientos

Verificar:

- Que las tablas hayan sido creadas correctamente.
- Que los datos iniciales estén disponibles.
- Que los procedimientos hayan sido compilados.
- Que los objetos pertenezcan al esquema correcto.
- Que el estado de los objetos sea `VALID`.

### 10.3 No aparecen datos en las consultas

Verificar que las tablas tengan registros.

Los procedimientos de consulta pueden ejecutarse correctamente
y devolver cero registros cuando una tabla está vacía.

### 10.4 Error al ejecutar los scripts SQL

Verificar que se hayan ejecutado en el orden indicado.

No repetir los scripts de creación y carga inicial
sobre una base que ya contiene información que se desea conservar.

---

## 11. Trabajo colaborativo

El proyecto se mantiene en el repositorio compartido de GitHub.

Cada integrante desarrolla y prueba sus funcionalidades
utilizando su propia base de datos Oracle.

Los cambios en el código se comparten mediante GitHub
para mantener una versión común del proyecto.

Los archivos SQL permiten que los demás integrantes
creen los mismos procedimientos y estructuras en sus bases.

La aplicación final deberá integrar las operaciones CRUD
y demás funcionalidades requeridas por el curso.

---

## 12. Resumen del Avance 2

Para este avance se cuenta con:

- Modelo de datos y diccionario de la base.
- Scripts de creación de tablas y relaciones.
- Datos iniciales de prueba.
- Procedimientos PL/SQL para clientes.
- Procedimientos PL/SQL para servicios.
- Procedimientos PL/SQL para trabajadores y horarios.
- Procedimientos PL/SQL para administrar citas.
- Funciones y vistas de consulta.
- Validaciones de disponibilidad y estados de citas.
- Registro del historial de cambios.
- Programa Python con conexión configurable a Oracle.
- Repositorio GitHub con el código desarrollado por el equipo.
- Verificaciones de compilación y pruebas funcionales realizadas.

Cada integrante puede instalar los componentes del proyecto
en su propia base Oracle siguiendo las instrucciones de esta guía.