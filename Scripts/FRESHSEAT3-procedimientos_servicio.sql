/* ---------------------------------------------------------------------
   FRESHSEAT - PROCEDIMIENTOS PL/SQL DE SERVICIO
   SC-504 Lenguajes de Bases de Datos
   Grupo 1 - Avance 2
   Jose Daniel Pereira
   --------------------------------------------------------------------- */


/* ---------------------------------------------------------------------
   5. REGISTRAR SERVICIO
   --------------------------------------------------------------------- */

CREATE OR REPLACE PROCEDURE sp_registrar_servicio (
    p_nombre           IN VARCHAR2,
    p_descripcion      IN VARCHAR2,
    p_duracion_minutos IN NUMBER,
    p_precio           IN NUMBER,
    p_id_servicio      OUT NUMBER
)
AS
BEGIN

    INSERT INTO servicio (
        nombre,
        descripcion,
        duracion_minutos,
        precio
    )
    VALUES (
        p_nombre,
        p_descripcion,
        p_duracion_minutos,
        p_precio
    )
    RETURNING id_servicio INTO p_id_servicio;

END sp_registrar_servicio;
/


/* ---------------------------------------------------------------------
   6. ACTUALIZAR SERVICIO
   --------------------------------------------------------------------- */

CREATE OR REPLACE PROCEDURE sp_actualizar_servicio (
    p_id_servicio      IN NUMBER,
    p_nombre           IN VARCHAR2,
    p_descripcion      IN VARCHAR2,
    p_duracion_minutos IN NUMBER,
    p_precio           IN NUMBER
)
AS
BEGIN

    UPDATE servicio
    SET
        nombre = p_nombre,
        descripcion = p_descripcion,
        duracion_minutos = p_duracion_minutos,
        precio = p_precio
    WHERE id_servicio = p_id_servicio;

END sp_actualizar_servicio;
/


/* ---------------------------------------------------------------------
   7. CONSULTAR SERVICIOS
   --------------------------------------------------------------------- */

CREATE OR REPLACE PROCEDURE sp_listar_servicios (
    p_resultado OUT SYS_REFCURSOR
)
AS
BEGIN

    OPEN p_resultado FOR
        SELECT
            id_servicio,
            nombre,
            descripcion,
            duracion_minutos,
            precio,
            activo
        FROM servicio
        ORDER BY id_servicio;

END sp_listar_servicios;
/


/* ---------------------------------------------------------------------
   8. DESACTIVAR SERVICIO
   --------------------------------------------------------------------- */

CREATE OR REPLACE PROCEDURE sp_desactivar_servicio (
    p_id_servicio IN NUMBER
)
AS
BEGIN

    UPDATE servicio
    SET activo = 'N'
    WHERE id_servicio = p_id_servicio;

END sp_desactivar_servicio;
/