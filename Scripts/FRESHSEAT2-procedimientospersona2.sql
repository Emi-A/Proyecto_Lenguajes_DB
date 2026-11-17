/* ---------------------------------------------------------------------
   FRESHSEAT - PROCEDIMIENTOS PL/SQL
   SC-504 Lenguajes de Bases de Datos
   Grupo 1 - Avance 2
   Jose Daniel Pereira
   --------------------------------------------------------------------- */


/* ---------------------------------------------------------------------
   1. REGISTRAR CLIENTE
   --------------------------------------------------------------------- */

CREATE OR REPLACE PROCEDURE sp_registrar_cliente (
    p_nombre      IN VARCHAR2,
    p_apellidos   IN VARCHAR2,
    p_telefono    IN VARCHAR2,
    p_correo      IN VARCHAR2,
    p_id_cliente  OUT NUMBER
)
AS
BEGIN

    INSERT INTO cliente (
        nombre,
        apellidos,
        telefono,
        correo
    )
    VALUES (
        p_nombre,
        p_apellidos,
        p_telefono,
        p_correo
    )
    RETURNING id_cliente INTO p_id_cliente;

END sp_registrar_cliente;
/


/* ---------------------------------------------------------------------
   2. ACTUALIZAR CLIENTE
   --------------------------------------------------------------------- */

CREATE OR REPLACE PROCEDURE sp_actualizar_cliente (
    p_id_cliente IN NUMBER,
    p_nombre     IN VARCHAR2,
    p_apellidos  IN VARCHAR2,
    p_telefono   IN VARCHAR2,
    p_correo     IN VARCHAR2
)
AS
BEGIN

    UPDATE cliente
    SET
        nombre = p_nombre,
        apellidos = p_apellidos,
        telefono = p_telefono,
        correo = p_correo
    WHERE id_cliente = p_id_cliente;

END sp_actualizar_cliente;
/


/* ---------------------------------------------------------------------
   3. CONSULTAR CLIENTES
   --------------------------------------------------------------------- */

CREATE OR REPLACE PROCEDURE sp_listar_clientes (
    p_resultado OUT SYS_REFCURSOR
)
AS
BEGIN

    OPEN p_resultado FOR
        SELECT
            id_cliente,
            nombre,
            apellidos,
            telefono,
            correo,
            activo
        FROM cliente
        ORDER BY id_cliente;

END sp_listar_clientes;
/


/* ---------------------------------------------------------------------
   4. DESACTIVAR CLIENTE
   --------------------------------------------------------------------- */

CREATE OR REPLACE PROCEDURE sp_desactivar_cliente (
    p_id_cliente IN NUMBER
)
AS
BEGIN

    UPDATE cliente
    SET activo = 'N'
    WHERE id_cliente = p_id_cliente;

END sp_desactivar_cliente;
/