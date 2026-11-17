/* ---------------------------------------------------------------------
   FRESHSEAT - PROCEDIMIENTOS Y FUNCIONES PL/SQL
   SC-504 Lenguajes de Bases de Datos
   Grupo 1 - Avance 2
   Jose Daniel Pereira
   --------------------------------------------------------------------- */


/* ---------------------------------------------------------------------
   9. CONSULTAR ESTADOS DE CITA
   --------------------------------------------------------------------- */

CREATE OR REPLACE PROCEDURE sp_listar_estados (
    p_resultado OUT SYS_REFCURSOR
)
AS
BEGIN

    OPEN p_resultado FOR
        SELECT
            id_estado,
            nombre
        FROM estado_cita
        ORDER BY id_estado;

END sp_listar_estados;
/


/* ---------------------------------------------------------------------
   10. FUNCIÓN - OBTENER NOMBRE DEL ESTADO
   --------------------------------------------------------------------- */

CREATE OR REPLACE FUNCTION fn_nombre_estado (
    p_id_estado IN NUMBER
)
RETURN VARCHAR2
AS
    v_nombre estado_cita.nombre%TYPE;
BEGIN

    SELECT nombre
    INTO v_nombre
    FROM estado_cita
    WHERE id_estado = p_id_estado;

    RETURN v_nombre;

END fn_nombre_estado;
/