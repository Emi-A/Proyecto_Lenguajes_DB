SET SERVEROUTPUT ON;

-- =========================================================
-- FRESHSEAT - PERSONA 4
-- PROCEDIMIENTOS DE CITAS E HISTORIAL
-- VERSION MEJORADA
-- =========================================================


-- =========================================================
-- 1. VERIFICAR DISPONIBILIDAD
-- =========================================================

CREATE OR REPLACE FUNCTION fn_disponibilidad_cita (
    p_id_horario IN NUMBER,
    p_inicio IN DATE,
    p_fin IN DATE,
    p_id_cita_excluir IN NUMBER DEFAULT NULL
)
RETURN NUMBER
IS
    v_id_trabajador NUMBER;
    v_inicio_horario DATE;
    v_fin_horario DATE;
    v_activo CHAR(1);
    v_ocupadas NUMBER;
BEGIN
    IF p_inicio IS NULL OR p_fin IS NULL OR p_fin <= p_inicio THEN
        RETURN 0;
    END IF;

    SELECT h.id_trabajador,
           h.fecha_hora_inicio,
           h.fecha_hora_fin,
           t.activo
    INTO v_id_trabajador,
         v_inicio_horario,
         v_fin_horario,
         v_activo
    FROM horario_trabajador h
    JOIN trabajador t
        ON h.id_trabajador = t.id_trabajador
    WHERE h.id_horario = p_id_horario;

    IF v_activo = 'N'
       OR p_inicio < v_inicio_horario
       OR p_fin > v_fin_horario THEN
        RETURN 0;
    END IF;

    SELECT COUNT(*)
    INTO v_ocupadas
    FROM cita c
    JOIN horario_trabajador h
        ON c.id_horario = h.id_horario
    JOIN estado_cita e
        ON c.id_estado = e.id_estado
    WHERE h.id_trabajador = v_id_trabajador
      AND e.nombre <> 'Cancelada'
      AND (
          p_id_cita_excluir IS NULL
          OR c.id_cita <> p_id_cita_excluir
      )
      AND c.fecha_hora_inicio < p_fin
      AND c.fecha_hora_fin > p_inicio;

    IF v_ocupadas = 0 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/


-- =========================================================
-- 2. REGISTRAR HISTORIAL
-- =========================================================

CREATE OR REPLACE PROCEDURE sp_registrar_historial (
    p_id_cita IN NUMBER,
    p_estado_anterior IN NUMBER,
    p_estado_nuevo IN NUMBER,
    p_descripcion IN VARCHAR2
)
IS
BEGIN
    INSERT INTO historial_cita (
        id_cita,
        id_estado_anterior,
        id_estado_nuevo,
        descripcion
    )
    VALUES (
        p_id_cita,
        p_estado_anterior,
        p_estado_nuevo,
        p_descripcion
    );
END;
/


-- =========================================================
-- 3. REGISTRAR CITA
-- =========================================================

CREATE OR REPLACE PROCEDURE sp_registrar_cita (
    p_id_cliente IN NUMBER,
    p_id_horario IN NUMBER,
    p_id_servicio IN NUMBER,
    p_fecha_inicio IN DATE,
    p_observaciones IN VARCHAR2,
    p_id_cita OUT NUMBER
)
IS
    v_cliente_activo CHAR(1);
    v_trabajador_activo CHAR(1);
    v_servicio_activo CHAR(1);
    v_id_trabajador NUMBER;
    v_duracion NUMBER;
    v_precio NUMBER;
    v_fecha_fin DATE;
    v_asignado NUMBER;
    v_estado NUMBER;
BEGIN
    p_id_cita := NULL;

    SELECT activo
    INTO v_cliente_activo
    FROM cliente
    WHERE id_cliente = p_id_cliente;

    IF v_cliente_activo = 'N' THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'El cliente esta inactivo'
        );
    END IF;

    SELECT h.id_trabajador, t.activo
    INTO v_id_trabajador, v_trabajador_activo
    FROM horario_trabajador h
    JOIN trabajador t
        ON h.id_trabajador = t.id_trabajador
    WHERE h.id_horario = p_id_horario;

    IF v_trabajador_activo = 'N' THEN
        RAISE_APPLICATION_ERROR(
            -20002,
            'El trabajador esta inactivo'
        );
    END IF;

    SELECT duracion_minutos, precio, activo
    INTO v_duracion, v_precio, v_servicio_activo
    FROM servicio
    WHERE id_servicio = p_id_servicio;

    IF v_servicio_activo = 'N' THEN
        RAISE_APPLICATION_ERROR(
            -20003,
            'El servicio esta inactivo'
        );
    END IF;

    SELECT COUNT(*)
    INTO v_asignado
    FROM trabajador_servicio
    WHERE id_trabajador = v_id_trabajador
      AND id_servicio = p_id_servicio;

    IF v_asignado = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20004,
            'El trabajador no realiza ese servicio'
        );
    END IF;

    IF p_fecha_inicio IS NULL THEN
        RAISE_APPLICATION_ERROR(
            -20005,
            'Debe indicar una fecha'
        );
    END IF;

    -- No permitir citas en fechas pasadas
    IF p_fecha_inicio < SYSDATE THEN
        RAISE_APPLICATION_ERROR(
            -20017,
            'No se pueden agendar citas en el pasado'
        );
    END IF;

    v_fecha_fin := p_fecha_inicio + v_duracion / 1440;

    IF fn_disponibilidad_cita(
        p_id_horario,
        p_fecha_inicio,
        v_fecha_fin
    ) = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20006,
            'No hay espacio en ese horario'
        );
    END IF;

    SELECT id_estado
    INTO v_estado
    FROM estado_cita
    WHERE nombre = 'Pendiente';

    INSERT INTO cita (
        id_cliente,
        id_horario,
        id_servicio,
        id_estado,
        fecha_hora_inicio,
        fecha_hora_fin,
        precio_acordado,
        observaciones
    )
    VALUES (
        p_id_cliente,
        p_id_horario,
        p_id_servicio,
        v_estado,
        p_fecha_inicio,
        v_fecha_fin,
        v_precio,
        p_observaciones
    )
    RETURNING id_cita INTO p_id_cita;

    sp_registrar_historial(
        p_id_cita,
        NULL,
        v_estado,
        'Cita creada'
    );

    DBMS_OUTPUT.PUT_LINE(
        'Se registro la cita ' || p_id_cita
    );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20007,
            'No se encontro el cliente, horario, servicio o estado'
        );
END;
/


-- =========================================================
-- 4. VISTA DE CITAS
-- =========================================================

CREATE OR REPLACE VIEW vw_citas_detalle AS
SELECT
    c.id_cita,
    c.id_cliente,
    cl.nombre || ' ' || cl.apellidos AS cliente,
    c.id_horario,
    h.id_trabajador,
    t.nombre || ' ' || t.apellidos AS trabajador,
    c.id_servicio,
    s.nombre AS servicio,
    c.id_estado,
    e.nombre AS estado,
    c.fecha_hora_inicio,
    c.fecha_hora_fin,
    c.precio_acordado,
    c.observaciones
FROM cita c
JOIN cliente cl
    ON c.id_cliente = cl.id_cliente
JOIN horario_trabajador h
    ON c.id_horario = h.id_horario
JOIN trabajador t
    ON h.id_trabajador = t.id_trabajador
JOIN servicio s
    ON c.id_servicio = s.id_servicio
JOIN estado_cita e
    ON c.id_estado = e.id_estado;


-- =========================================================
-- 5. CONSULTAR CITA
-- =========================================================

CREATE OR REPLACE PROCEDURE sp_consultar_cita (
    p_id_cita IN NUMBER,
    p_resultado OUT SYS_REFCURSOR
)
IS
    v_total NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_total
    FROM cita
    WHERE id_cita = p_id_cita;

    IF v_total = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20008,
            'No existe esa cita'
        );
    END IF;

    OPEN p_resultado FOR
        SELECT *
        FROM vw_citas_detalle
        WHERE id_cita = p_id_cita;
END;
/


-- =========================================================
-- 6. ACTUALIZAR CITA
-- =========================================================

CREATE OR REPLACE PROCEDURE sp_actualizar_cita (
    p_id_cita IN NUMBER,
    p_id_horario IN NUMBER,
    p_id_servicio IN NUMBER,
    p_fecha_inicio IN DATE,
    p_observaciones IN VARCHAR2
)
IS
    v_estado NUMBER;
    v_nombre_estado VARCHAR2(30);
    v_id_trabajador NUMBER;
    v_trabajador_activo CHAR(1);
    v_servicio_activo CHAR(1);
    v_duracion NUMBER;
    v_precio NUMBER;
    v_fecha_fin DATE;
    v_asignado NUMBER;
BEGIN
    SELECT c.id_estado, e.nombre
    INTO v_estado, v_nombre_estado
    FROM cita c
    JOIN estado_cita e
        ON c.id_estado = e.id_estado
    WHERE c.id_cita = p_id_cita;

    -- No modificar citas canceladas ni completadas
    IF v_nombre_estado IN ('Cancelada', 'Completada') THEN
        RAISE_APPLICATION_ERROR(
            -20009,
            'No se puede modificar una cita ' ||
            LOWER(v_nombre_estado)
        );
    END IF;

    SELECT h.id_trabajador, t.activo
    INTO v_id_trabajador, v_trabajador_activo
    FROM horario_trabajador h
    JOIN trabajador t
        ON h.id_trabajador = t.id_trabajador
    WHERE h.id_horario = p_id_horario;

    IF v_trabajador_activo = 'N' THEN
        RAISE_APPLICATION_ERROR(
            -20010,
            'El trabajador esta inactivo'
        );
    END IF;

    SELECT duracion_minutos, precio, activo
    INTO v_duracion, v_precio, v_servicio_activo
    FROM servicio
    WHERE id_servicio = p_id_servicio;

    IF v_servicio_activo = 'N' THEN
        RAISE_APPLICATION_ERROR(
            -20011,
            'El servicio esta inactivo'
        );
    END IF;

    SELECT COUNT(*)
    INTO v_asignado
    FROM trabajador_servicio
    WHERE id_trabajador = v_id_trabajador
      AND id_servicio = p_id_servicio;

    IF v_asignado = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20012,
            'El trabajador no realiza ese servicio'
        );
    END IF;

    IF p_fecha_inicio IS NULL THEN
        RAISE_APPLICATION_ERROR(
            -20013,
            'Debe indicar una fecha'
        );
    END IF;

    -- No mover citas a fechas pasadas
    IF p_fecha_inicio < SYSDATE THEN
        RAISE_APPLICATION_ERROR(
            -20018,
            'No se puede mover una cita al pasado'
        );
    END IF;

    v_fecha_fin := p_fecha_inicio + v_duracion / 1440;

    IF fn_disponibilidad_cita(
        p_id_horario,
        p_fecha_inicio,
        v_fecha_fin,
        p_id_cita
    ) = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20014,
            'El nuevo horario no esta disponible'
        );
    END IF;

    UPDATE cita
    SET id_horario = p_id_horario,
        id_servicio = p_id_servicio,
        fecha_hora_inicio = p_fecha_inicio,
        fecha_hora_fin = v_fecha_fin,
        precio_acordado = v_precio,
        observaciones = p_observaciones
    WHERE id_cita = p_id_cita;

    sp_registrar_historial(
        p_id_cita,
        v_estado,
        v_estado,
        'Cita actualizada'
    );

    DBMS_OUTPUT.PUT_LINE(
        'Se actualizo la cita ' || p_id_cita
    );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20015,
            'No se encontro la cita, horario o servicio'
        );
END;
/


-- =========================================================
-- 7. CANCELAR CITA
-- =========================================================

CREATE OR REPLACE PROCEDURE sp_cancelar_cita (
    p_id_cita IN NUMBER
)
IS
    v_estado_anterior NUMBER;
    v_nombre_estado VARCHAR2(30);
    v_estado_cancelado NUMBER;
BEGIN
    SELECT c.id_estado, e.nombre
    INTO v_estado_anterior, v_nombre_estado
    FROM cita c
    JOIN estado_cita e
        ON c.id_estado = e.id_estado
    WHERE c.id_cita = p_id_cita;

    -- No cancelar citas completadas
    IF v_nombre_estado = 'Completada' THEN
        RAISE_APPLICATION_ERROR(
            -20019,
            'No se puede cancelar una cita completada'
        );
    END IF;

    IF v_nombre_estado = 'Cancelada' THEN
        DBMS_OUTPUT.PUT_LINE(
            'La cita ya esta cancelada'
        );
        RETURN;
    END IF;

    SELECT id_estado
    INTO v_estado_cancelado
    FROM estado_cita
    WHERE nombre = 'Cancelada';

    UPDATE cita
    SET id_estado = v_estado_cancelado
    WHERE id_cita = p_id_cita;

    sp_registrar_historial(
        p_id_cita,
        v_estado_anterior,
        v_estado_cancelado,
        'Cita cancelada'
    );

    DBMS_OUTPUT.PUT_LINE(
        'Se cancelo la cita ' || p_id_cita
    );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20016,
            'No se encontro la cita o el estado Cancelada'
        );
END;
/


-- =========================================================
-- 8. CAMBIAR ESTADO DE CITA
-- =========================================================

CREATE OR REPLACE PROCEDURE sp_cambiar_estado_cita (
    p_id_cita IN NUMBER,
    p_estado_nuevo IN VARCHAR2
)
IS
    v_id_actual NUMBER;
    v_estado_actual VARCHAR2(30);
    v_inicio DATE;
    v_id_nuevo NUMBER;
BEGIN
    SELECT c.id_estado,
           e.nombre,
           c.fecha_hora_inicio
    INTO v_id_actual,
         v_estado_actual,
         v_inicio
    FROM cita c
    JOIN estado_cita e
        ON c.id_estado = e.id_estado
    WHERE c.id_cita = p_id_cita;

    -- Validar transiciones permitidas
    IF NOT (
        (v_estado_actual = 'Pendiente'
         AND p_estado_nuevo = 'Confirmada')
        OR
        (v_estado_actual = 'Confirmada'
         AND p_estado_nuevo = 'Completada')
    ) THEN
        RAISE_APPLICATION_ERROR(
            -20020,
            'No se puede pasar de ' ||
            v_estado_actual || ' a ' || p_estado_nuevo
        );
    END IF;

    -- No completar una cita que todavía no ocurre
    IF p_estado_nuevo = 'Completada'
       AND v_inicio > SYSDATE THEN
        RAISE_APPLICATION_ERROR(
            -20021,
            'La cita todavia no ha ocurrido'
        );
    END IF;

    SELECT id_estado
    INTO v_id_nuevo
    FROM estado_cita
    WHERE nombre = p_estado_nuevo;

    UPDATE cita
    SET id_estado = v_id_nuevo
    WHERE id_cita = p_id_cita;

    sp_registrar_historial(
        p_id_cita,
        v_id_actual,
        v_id_nuevo,
        'Cita ' || LOWER(p_estado_nuevo)
    );

    DBMS_OUTPUT.PUT_LINE(
        'La cita ' || p_id_cita ||
        ' ahora esta ' || p_estado_nuevo
    );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20022,
            'No se encontro la cita o el estado'
        );
END;
/


-- =========================================================
-- 9. LISTAR CITAS
-- =========================================================

CREATE OR REPLACE PROCEDURE sp_listar_citas
IS
    v_total NUMBER := 0;
BEGIN
    FOR r IN (
        SELECT id_cita,
               cliente,
               trabajador,
               servicio,
               fecha_hora_inicio,
               estado
        FROM vw_citas_detalle
        ORDER BY fecha_hora_inicio
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Cita ' || r.id_cita ||
            ' - ' || r.cliente ||
            ' - ' || r.trabajador ||
            ' - ' || r.servicio ||
            ' - ' ||
            TO_CHAR(
                r.fecha_hora_inicio,
                'DD/MM/YYYY HH24:MI'
            ) ||
            ' - ' || r.estado
        );

        v_total := v_total + 1;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(
        'Total de citas: ' || v_total
    );
END;
/


-- =========================================================
-- 10. CONSULTAR HISTORIAL
-- =========================================================

CREATE OR REPLACE PROCEDURE sp_consultar_historial (
    p_id_cita IN NUMBER
)
IS
    v_total NUMBER := 0;
BEGIN
    FOR r IN (
        SELECT h.fecha_cambio,
               a.nombre AS anterior,
               n.nombre AS nuevo,
               h.descripcion
        FROM historial_cita h
        LEFT JOIN estado_cita a
            ON h.id_estado_anterior = a.id_estado
        JOIN estado_cita n
            ON h.id_estado_nuevo = n.id_estado
        WHERE h.id_cita = p_id_cita
        ORDER BY h.id_historial
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(
                r.fecha_cambio,
                'DD/MM/YYYY HH24:MI'
            ) ||
            ' - ' ||
            NVL(r.anterior, 'Sin estado') ||
            ' a ' || r.nuevo ||
            ' - ' || r.descripcion
        );

        v_total := v_total + 1;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(
        'Total de cambios: ' || v_total
    );
END;
/