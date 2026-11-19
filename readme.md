# FreshSeat - Sistema de Gestión para Barberías

## Proyecto de Lenguajes de Bases de Datos

FreshSeat es un proyecto académico que permite administrar
la información de una barbería mediante una base de datos Oracle.

El sistema contempla la gestión de:

- Clientes.
- Trabajadores.
- Servicios.
- Horarios.
- Reservaciones y citas.
- Estados de las citas.
- Historial de cambios.

## Tecnologías utilizadas

- Oracle Database.
- SQL y PL/SQL.
- Oracle SQL Developer.
- Python.
- Git y GitHub.

## Avance 2 - Componentes desarrollados

Para este avance se implementaron:

1. Modelo de datos y diccionario.
2. Creación de tablas y relaciones.
3. Carga de datos iniciales.
4. Procedimientos de clientes.
5. Procedimientos de servicios.
6. Procedimientos de trabajadores y horarios.
7. Procedimientos de citas.
8. Funciones de validación.
9. Vistas de consulta.
10. Registro del historial de las citas.
11. Conexión configurable entre Python y Oracle.

Los módulos PL/SQL fueron compilados y se realizaron
pruebas funcionales en Oracle SQL Developer.

## Instalación y configuración

Para instalar y ejecutar el proyecto, consultar:

**[Guía de instalación de FreshSeat](GUIA_INSTALACION.md)**

La guía contiene:

- Requisitos.
- Orden de ejecución de los scripts SQL.
- Configuración de Oracle.
- Instalación de dependencias Python.
- Configuración del wallet, cuando corresponda.
- Ejecución de las pruebas de conexión.
- Verificación de los objetos PL/SQL.

## Organización del repositorio

- `Scripts/`: código SQL y PL/SQL.
- `Python/`: conexión y pruebas desde Python.
- `Diccionario de FreshSeat/`: documentación del modelo de datos.
- `requirements.txt`: dependencias de Python.
- `GUIA_INSTALACION.md`: instrucciones completas.

## Bases de datos independientes

Cada integrante del equipo utiliza su propia base de datos Oracle.

Los archivos SQL permiten reproducir las tablas y los
objetos PL/SQL en diferentes bases de datos.

No es necesario compartir usuarios, contraseñas ni wallets.

## Seguridad

El repositorio no debe contener credenciales personales
ni archivos privados del wallet de Oracle.

Cada integrante debe configurar su propia conexión.