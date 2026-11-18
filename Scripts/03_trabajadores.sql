/* ----------------------------------------
-- Registrar trabajador
-- Se agrega un trabajador nuevo.
---------------------------------------- */

CREATE OR REPLACE PROCEDURE sp_registrar_trabajador (
    p_nombre         IN VARCHAR2,
    p_apellidos      IN VARCHAR2,
    p_telefono       IN VARCHAR2,
    p_correo         IN VARCHAR2,
    p_id_trabajador  OUT NUMBER
)
AS
BEGIN

    INSERT INTO trabajador (
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
    RETURNING id_trabajador INTO p_id_trabajador;

END sp_registrar_trabajador;
/


-- ACTUALIZAR TRABAJADOR
-- Se modifican los datos de un trabajador.

CREATE OR REPLACE PROCEDURE sp_actualizar_trabajador (

    -- ID del trabajador que queremos actualizar
    p_id_trabajador IN NUMBER,

    -- Datos nuevos del trabajador
    p_nombre IN VARCHAR2,
    p_apellidos IN VARCHAR2,
    p_telefono IN VARCHAR2,
    p_correo IN VARCHAR2

)
AS
BEGIN

    -- Actualizamos los datos del trabajador
    UPDATE trabajador
    SET nombre = p_nombre,
        apellidos = p_apellidos,
        telefono = p_telefono,
        correo = p_correo

    -- Buscamos el trabajador por su ID
    WHERE id_trabajador = p_id_trabajador;

END sp_actualizar_trabajador;
/


-- LISTAR TRABAJADORES
-- Muestra los trabajadores registrados.

CREATE OR REPLACE PROCEDURE sp_listar_trabajadores (
    
    -- Devuelve la lista de trabajadores
    p_resultado OUT SYS_REFCURSOR

)
AS
BEGIN

    -- Consultamos los trabajadores
    OPEN p_resultado FOR
        SELECT id_trabajador,
               nombre,
               apellidos,
               telefono,
               correo,
               activo
        FROM trabajador
        ORDER BY id_trabajador;

END sp_listar_trabajadores;
/


-- DESACTIVAR TRABAJADOR
-- Cambia el estado del trabajador a inactivo.

CREATE OR REPLACE PROCEDURE sp_desactivar_trabajador (

    -- ID del trabajador que queremos desactivar
    p_id_trabajador IN NUMBER

)
AS
BEGIN

    -- Cambiamos el estado del trabajador a N
    UPDATE trabajador
    SET activo = 'N'

    -- Buscamos al trabajador por su ID
    WHERE id_trabajador = p_id_trabajador;

END sp_desactivar_trabajador;
/


-- REGISTRAR HORARIO
-- Se agrega un horario a un trabajador.

CREATE OR REPLACE PROCEDURE sp_registrar_horario (

    -- ID del trabajador
    p_id_trabajador IN NUMBER,

    -- Fecha y hora de inicio
    p_inicio IN DATE,

    -- Fecha y hora de finalizacion
    p_fin IN DATE,

    -- Devuelve el ID del horario creado
    p_id_horario OUT NUMBER

)
AS
BEGIN

    -- Guardamos el horario del trabajador
    INSERT INTO horario_trabajador (
        id_trabajador,
        fecha_hora_inicio,
        fecha_hora_fin
    )
    VALUES (
        p_id_trabajador,
        p_inicio,
        p_fin
    )

    -- Guardamos el ID generado por Oracle
    RETURNING id_horario INTO p_id_horario;

END sp_registrar_horario;
/


-- ACTUALIZAR HORARIO
-- Se modifica un horario de un trabajador.

CREATE OR REPLACE PROCEDURE sp_actualizar_horario (

    -- ID del horario que queremos modificar
    p_id_horario IN NUMBER,

    -- Nueva fecha y hora de inicio
    p_inicio IN DATE,

    -- Nueva fecha y hora de finalizacion
    p_fin IN DATE

)
AS
BEGIN

    -- Actualizamos el horario
    UPDATE horario_trabajador
    SET fecha_hora_inicio = p_inicio,
        fecha_hora_fin = p_fin

    -- Buscamos el horario por su ID
    WHERE id_horario = p_id_horario;

END sp_actualizar_horario;
/


-- LISTAR HORARIOS
-- Muestra los horarios de los trabajadores.

CREATE OR REPLACE PROCEDURE sp_listar_horarios (

    -- Devuelve la lista de horarios
    p_resultado OUT SYS_REFCURSOR

)
AS
BEGIN

    -- Consultamos los horarios registrados
    OPEN p_resultado FOR
        SELECT id_horario,
               id_trabajador,
               fecha_hora_inicio,
               fecha_hora_fin
        FROM horario_trabajador
        ORDER BY id_horario;

END sp_listar_horarios;
/


-- ELIMINAR HORARIO
-- Se elimina un horario de un trabajador.

CREATE OR REPLACE PROCEDURE sp_eliminar_horario (

    -- ID del horario que queremos eliminar
    p_id_horario IN NUMBER

)
AS
BEGIN

    -- Eliminamos el horario seleccionado
    DELETE FROM horario_trabajador

    -- Buscamos el horario por su ID
    WHERE id_horario = p_id_horario;

END sp_eliminar_horario;
/


-- ASIGNAR SERVICIO A TRABAJADOR
-- Se asigna un servicio a un trabajador.

CREATE OR REPLACE PROCEDURE sp_asignar_servicio (

    -- ID del trabajador
    p_id_trabajador IN NUMBER,

    -- ID del servicio que vamos a asignar
    p_id_servicio IN NUMBER

)
AS
BEGIN

    -- Guardamos la relacion entre trabajador y servicio
    INSERT INTO trabajador_servicio (
        id_trabajador,
        id_servicio
    )
    VALUES (
        p_id_trabajador,
        p_id_servicio
    );

END sp_asignar_servicio;
/


-- QUITAR SERVICIO A TRABAJADOR
-- Se quita un servicio asignado a un trabajador.

CREATE OR REPLACE PROCEDURE sp_quitar_servicio (

    -- ID del trabajador
    p_id_trabajador IN NUMBER,

    -- ID del servicio que queremos quitar
    p_id_servicio IN NUMBER

)
AS
BEGIN

    -- Eliminamos la asignacion entre trabajador y servicio
    DELETE FROM trabajador_servicio

    -- Buscamos la relacion que queremos quitar
    WHERE id_trabajador = p_id_trabajador
      AND id_servicio = p_id_servicio;

END sp_quitar_servicio;
/


-- VALIDAR SERVICIO DE UN TRABAJADOR
-- Comprueba si un trabajador puede realizar un servicio.

CREATE OR REPLACE FUNCTION fn_validar_servicio_trabajador (

    -- ID del trabajador
    p_id_trabajador IN NUMBER,

    -- ID del servicio
    p_id_servicio IN NUMBER

)
RETURN NUMBER
AS

    -- Variable para guardar el resultado
    v_cantidad NUMBER;

BEGIN

    -- Contamos si el trabajador tiene el servicio asignado
    SELECT COUNT(*)
    INTO v_cantidad
    FROM trabajador_servicio ts
    JOIN trabajador t
        ON ts.id_trabajador = t.id_trabajador
    JOIN servicio s
        ON ts.id_servicio = s.id_servicio
    WHERE ts.id_trabajador = p_id_trabajador
      AND ts.id_servicio = p_id_servicio
      AND t.activo = 'S'
      AND s.activo = 'S';

    -- Si existe la asignacion, devuelve 1
    IF v_cantidad > 0 THEN
        RETURN 1;

    -- Si no existe, devuelve 0
    ELSE
        RETURN 0;
    END IF;

END fn_validar_servicio_trabajador;
/


-- VISTA DE TRABAJADORES Y SERVICIOS
-- Muestra los trabajadores y los servicios que realizan.

CREATE OR REPLACE VIEW vw_trabajadores_servicios AS

-- Seleccionamos los datos que queremos mostrar
SELECT
    t.id_trabajador,
    t.nombre,
    t.apellidos,
    t.telefono,
    t.correo,
    s.id_servicio,
    s.nombre AS nombre_servicio,
    s.duracion_minutos,
    s.precio

-- Consultamos la tabla de trabajadores
FROM trabajador t

-- Relacionamos los trabajadores con sus servicios
JOIN trabajador_servicio ts
    ON t.id_trabajador = ts.id_trabajador

-- Obtenemos la informacion de cada servicio
JOIN servicio s
    ON ts.id_servicio = s.id_servicio

-- Mostramos solo trabajadores y servicios activos
WHERE t.activo = 'S'
  AND s.activo = 'S';
/


-- ==========================================
-- PRUEBAS DE LA PERSONA 3
-- Trabajadores, horarios y servicios
-- ==========================================

-- Permite mostrar los resultados
SET SERVEROUTPUT ON;

-- Declaramos las variables para las pruebas
DECLARE

    -- Guarda el ID del trabajador nuevo
    v_trabajador NUMBER;

    -- Guarda el ID del horario nuevo
    v_horario NUMBER;

    -- Guarda el ID del servicio de corte
    v_servicio NUMBER;

    -- Guarda el resultado de la funcion
    v_resultado NUMBER;

    -- Guarda la cantidad de registros
    v_cantidad NUMBER;

    -- Cursor para consultar trabajadores
    v_cursor_trabajadores SYS_REFCURSOR;

    -- Variables para recibir los datos del trabajador
    v_id NUMBER;
    v_nombre VARCHAR2(60);
    v_apellidos VARCHAR2(100);
    v_telefono VARCHAR2(20);
    v_correo VARCHAR2(120);
    v_activo CHAR(1);

    -- Cursor para consultar horarios
    v_cursor_horarios SYS_REFCURSOR;

    -- Variables para recibir los datos del horario
    v_id_horario NUMBER;
    v_id_trabajador NUMBER;
    v_inicio DATE;
    v_fin DATE;

BEGIN

    -- ======================================
    -- PRUEBA 1: REGISTRAR TRABAJADOR
    -- ======================================

    DBMS_OUTPUT.PUT_LINE('--- REGISTRAR TRABAJADOR ---');

    -- Registramos un trabajador ficticio
    sp_registrar_trabajador(
        'Andres',
        'Morales Vargas',
        '8888-4444',
        'andres.prueba@freshseat.com',
        v_trabajador
    );

    -- Mostramos el ID generado
    DBMS_OUTPUT.PUT_LINE('Trabajador registrado: ' || v_trabajador);


    -- ======================================
    -- PRUEBA 2: ACTUALIZAR TRABAJADOR
    -- ======================================

    DBMS_OUTPUT.PUT_LINE('--- ACTUALIZAR TRABAJADOR ---');

    -- Modificamos los datos del trabajador
    sp_actualizar_trabajador(
        v_trabajador,
        'Andres',
        'Morales Lopez',
        '8888-9999',
        'andres.nuevo@freshseat.com'
    );

    -- Comprobamos que se actualizo
    SELECT COUNT(*)
    INTO v_cantidad
    FROM trabajador
    WHERE id_trabajador = v_trabajador
      AND apellidos = 'Morales Lopez';

    DBMS_OUTPUT.PUT_LINE('Registros actualizados: ' || v_cantidad);


    -- ======================================
    -- PRUEBA 3: LISTAR TRABAJADORES
    -- ======================================

    DBMS_OUTPUT.PUT_LINE('--- LISTAR TRABAJADORES ---');

    -- Llamamos al procedimiento de consulta
    sp_listar_trabajadores(v_cursor_trabajadores);

    -- Leemos los trabajadores encontrados
    LOOP

        FETCH v_cursor_trabajadores INTO
            v_id,
            v_nombre,
            v_apellidos,
            v_telefono,
            v_correo,
            v_activo;

        -- Terminamos cuando no quedan registros
        EXIT WHEN v_cursor_trabajadores%NOTFOUND;

        -- Mostramos el trabajador
        DBMS_OUTPUT.PUT_LINE(
            'Trabajador ' || v_id || ' - ' ||
            v_nombre || ' ' || v_apellidos
        );

    END LOOP;

    -- Cerramos el cursor
    CLOSE v_cursor_trabajadores;


    -- ======================================
    -- PRUEBA 4: REGISTRAR HORARIO
    -- ======================================

    DBMS_OUTPUT.PUT_LINE('--- REGISTRAR HORARIO ---');

    -- Registramos un horario para manana
    sp_registrar_horario(
        v_trabajador,
        TRUNC(SYSDATE) + 1 + 14/24,
        TRUNC(SYSDATE) + 1 + 15/24,
        v_horario
    );

    -- Mostramos el horario creado
    DBMS_OUTPUT.PUT_LINE('Horario registrado: ' || v_horario);


    -- ======================================
    -- PRUEBA 5: ACTUALIZAR HORARIO
    -- ======================================

    DBMS_OUTPUT.PUT_LINE('--- ACTUALIZAR HORARIO ---');

    -- Cambiamos el horario de 2 a 4 de la tarde
    sp_actualizar_horario(
        v_horario,
        TRUNC(SYSDATE) + 1 + 14/24,
        TRUNC(SYSDATE) + 1 + 16/24
    );

    -- Comprobamos el horario actualizado
    SELECT fecha_hora_fin
    INTO v_fin
    FROM horario_trabajador
    WHERE id_horario = v_horario;

    DBMS_OUTPUT.PUT_LINE(
        'Nueva hora de finalizacion: ' ||
        TO_CHAR(v_fin, 'DD/MM/YYYY HH24:MI')
    );


    -- ======================================
    -- PRUEBA 6: LISTAR HORARIOS
    -- ======================================

    DBMS_OUTPUT.PUT_LINE('--- LISTAR HORARIOS ---');

    -- Llamamos al procedimiento de consulta
    sp_listar_horarios(v_cursor_horarios);

    -- Leemos los horarios encontrados
    LOOP

        FETCH v_cursor_horarios INTO
            v_id_horario,
            v_id_trabajador,
            v_inicio,
            v_fin;

        -- Terminamos cuando no quedan horarios
        EXIT WHEN v_cursor_horarios%NOTFOUND;

        -- Mostramos el horario
        DBMS_OUTPUT.PUT_LINE(
            'Horario ' || v_id_horario ||
            ' - Trabajador ' || v_id_trabajador ||
            ' - ' || TO_CHAR(v_inicio, 'DD/MM/YYYY HH24:MI') ||
            ' a ' || TO_CHAR(v_fin, 'HH24:MI')
        );

    END LOOP;

    -- Cerramos el cursor
    CLOSE v_cursor_horarios;


    -- ======================================
    -- PRUEBA 7: ASIGNAR SERVICIO
    -- ======================================

    DBMS_OUTPUT.PUT_LINE('--- ASIGNAR SERVICIO ---');

    -- Buscamos el servicio Corte clasico
    SELECT id_servicio
    INTO v_servicio
    FROM servicio
    WHERE nombre = 'Corte clásico';

    -- Asignamos el servicio al trabajador
    sp_asignar_servicio(
        v_trabajador,
        v_servicio
    );

    DBMS_OUTPUT.PUT_LINE('Servicio asignado correctamente');


    -- ======================================
    -- PRUEBA 8: FUNCION DE VALIDACION
    -- ======================================

    DBMS_OUTPUT.PUT_LINE('--- VALIDAR SERVICIO ---');

    -- Comprobamos si puede realizar el servicio
    v_resultado := fn_validar_servicio_trabajador(
        v_trabajador,
        v_servicio
    );

    -- Mostramos el resultado
    DBMS_OUTPUT.PUT_LINE(
        'Puede realizar el servicio: ' || v_resultado
    );


    -- ======================================
    -- PRUEBA 9: VISTA DE TRABAJADORES
    -- ======================================

    DBMS_OUTPUT.PUT_LINE('--- VISTA DE TRABAJADORES ---');

    -- Comprobamos si aparece en la vista
    SELECT COUNT(*)
    INTO v_cantidad
    FROM vw_trabajadores_servicios
    WHERE id_trabajador = v_trabajador
      AND id_servicio = v_servicio;

    DBMS_OUTPUT.PUT_LINE(
        'Asignaciones encontradas en la vista: ' || v_cantidad
    );


    -- ======================================
    -- PRUEBA 10: QUITAR SERVICIO
    -- ======================================

    DBMS_OUTPUT.PUT_LINE('--- QUITAR SERVICIO ---');

    -- Quitamos el servicio asignado
    sp_quitar_servicio(
        v_trabajador,
        v_servicio
    );

    -- Comprobamos que ya no puede realizarlo
    v_resultado := fn_validar_servicio_trabajador(
        v_trabajador,
        v_servicio
    );

    DBMS_OUTPUT.PUT_LINE(
        'Puede realizar el servicio despues de quitarlo: ' ||
        v_resultado
    );


    -- ======================================
    -- PRUEBA 11: ELIMINAR HORARIO
    -- ======================================

    DBMS_OUTPUT.PUT_LINE('--- ELIMINAR HORARIO ---');

    -- Eliminamos el horario de prueba
    sp_eliminar_horario(v_horario);

    -- Comprobamos que fue eliminado
    SELECT COUNT(*)
    INTO v_cantidad
    FROM horario_trabajador
    WHERE id_horario = v_horario;

    DBMS_OUTPUT.PUT_LINE(
        'Horarios encontrados despues de eliminar: ' ||
        v_cantidad
    );


    -- ======================================
    -- PRUEBA 12: DESACTIVAR TRABAJADOR
    -- ======================================

    DBMS_OUTPUT.PUT_LINE('--- DESACTIVAR TRABAJADOR ---');

    -- Desactivamos el trabajador ficticio
    sp_desactivar_trabajador(v_trabajador);

    -- Consultamos su estado
    SELECT activo
    INTO v_activo
    FROM trabajador
    WHERE id_trabajador = v_trabajador;

    DBMS_OUTPUT.PUT_LINE(
        'Estado del trabajador: ' || v_activo
    );


    -- ======================================
    -- FINALIZAR PRUEBAS
    -- ======================================

    -- Deshacemos todos los cambios de prueba
    ROLLBACK;

    -- Mostramos el mensaje final
    DBMS_OUTPUT.PUT_LINE('--- PRUEBAS FINALIZADAS ---');
    DBMS_OUTPUT.PUT_LINE('Cambios de prueba deshechos con ROLLBACK');

-- Si ocurre un error, deshacemos los cambios
EXCEPTION
    WHEN OTHERS THEN

        ROLLBACK;

        DBMS_OUTPUT.PUT_LINE(
            'Error en las pruebas: ' || SQLERRM
        );

END;
/

