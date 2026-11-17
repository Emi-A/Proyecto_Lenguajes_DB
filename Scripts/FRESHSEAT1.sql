SELECT table_name
FROM user_tables
WHERE table_name IN (
    'CLIENTE',
    'TRABAJADOR',
    'SERVICIO',
    'ESTADO_CITA',
    'HORARIO_TRABAJADOR',
    'TRABAJADOR_SERVICIO',
    'CITA',
    'HISTORIAL_CITA'
)
ORDER BY table_name;

/* ---------------------------------------------------------------------
   11. DATOS INICIALES Y DE PRUEBA
   --------------------------------------------------------------------- */

-- Estados de cita
INSERT INTO estado_cita (nombre) VALUES ('Pendiente');
INSERT INTO estado_cita (nombre) VALUES ('Confirmada');
INSERT INTO estado_cita (nombre) VALUES ('Completada');
INSERT INTO estado_cita (nombre) VALUES ('Cancelada');


-- Clientes
INSERT INTO cliente (nombre, apellidos, telefono, correo)
VALUES ('Laura', 'Mora Jiménez', '8888-1111', 'laura.mora@correo.com');

INSERT INTO cliente (nombre, apellidos, telefono, correo)
VALUES ('Andrés', 'Vargas Rojas', '8888-2222', 'andres.vargas@correo.com');

INSERT INTO cliente (nombre, apellidos, telefono, correo)
VALUES ('Sofía', 'Castro Solís', '8888-3333', NULL);


-- Trabajadores
INSERT INTO trabajador (nombre, apellidos, telefono, correo)
VALUES ('Diego', 'Herrera Quesada', '7000-1111', 'diego@freshseat.com');

INSERT INTO trabajador (nombre, apellidos, telefono, correo)
VALUES ('Valeria', 'Ramírez Brenes', '7000-2222', 'valeria@freshseat.com');


-- Servicios
INSERT INTO servicio (nombre, descripcion, duracion_minutos, precio)
VALUES ('Corte clásico', 'Corte de cabello con máquina y tijera', 30, 6000);

INSERT INTO servicio (nombre, descripcion, duracion_minutos, precio)
VALUES ('Arreglo de barba', 'Perfilado y arreglo de barba', 20, 4000);

INSERT INTO servicio (nombre, descripcion, duracion_minutos, precio)
VALUES ('Tinte', 'Aplicación de tinte completo', 90, 18000);


-- Relación entre trabajadores y servicios
-- Diego realiza cortes y arreglos de barba
-- Valeria realiza cortes y tintes
INSERT INTO trabajador_servicio (id_trabajador, id_servicio)
VALUES (1, 1);

INSERT INTO trabajador_servicio (id_trabajador, id_servicio)
VALUES (1, 2);

INSERT INTO trabajador_servicio (id_trabajador, id_servicio)
VALUES (2, 1);

INSERT INTO trabajador_servicio (id_trabajador, id_servicio)
VALUES (2, 3);


-- Horarios de trabajadores
-- Bloques para el día siguiente a la ejecución
INSERT INTO horario_trabajador (id_trabajador, fecha_hora_inicio, fecha_hora_fin)
VALUES (1, TRUNC(SYSDATE) + 1 + 9/24,
           TRUNC(SYSDATE) + 1 + 10/24);

INSERT INTO horario_trabajador (id_trabajador, fecha_hora_inicio, fecha_hora_fin)
VALUES (1, TRUNC(SYSDATE) + 1 + 10/24,
           TRUNC(SYSDATE) + 1 + 11/24);

INSERT INTO horario_trabajador (id_trabajador, fecha_hora_inicio, fecha_hora_fin)
VALUES (2, TRUNC(SYSDATE) + 1 + 9/24,
           TRUNC(SYSDATE) + 1 + 11/24);


-- Cita de prueba
-- Laura reserva un corte clásico con Diego a las 9:00
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
    1,
    1,
    1,
    1,
    TRUNC(SYSDATE) + 1 + 9/24,
    TRUNC(SYSDATE) + 1 + 9.5/24,
    6000,
    'Primera visita'
);


-- Historial de la cita
INSERT INTO historial_cita (
    id_cita,
    id_estado_anterior,
    id_estado_nuevo,
    descripcion
)
VALUES (
    1,
    NULL,
    1,
    'Cita creada'
);


-- Confirmar los datos insertados
COMMIT;


/* ---------------------------------------------------------------------
   12. VERIFICACIÓN
   --------------------------------------------------------------------- */

-- Verificar las ocho tablas del proyecto
SELECT table_name
FROM user_tables
WHERE table_name IN (
    'CLIENTE',
    'TRABAJADOR',
    'SERVICIO',
    'ESTADO_CITA',
    'HORARIO_TRABAJADOR',
    'TRABAJADOR_SERVICIO',
    'CITA',
    'HISTORIAL_CITA'
)
ORDER BY table_name;


-- Verificar las restricciones de las tablas
SELECT
    table_name,
    constraint_type,
    COUNT(*) AS cantidad
FROM user_constraints
WHERE table_name IN (
    'CLIENTE',
    'TRABAJADOR',
    'SERVICIO',
    'ESTADO_CITA',
    'HORARIO_TRABAJADOR',
    'TRABAJADOR_SERVICIO',
    'CITA',
    'HISTORIAL_CITA'
)
GROUP BY table_name, constraint_type
ORDER BY table_name, constraint_type;


-- Verificar las llaves foráneas
SELECT
    c.table_name AS tabla,
    c.constraint_name AS llave_foranea,
    p.table_name AS tabla_referenciada
FROM user_constraints c
JOIN user_constraints p
    ON p.constraint_name = c.r_constraint_name
WHERE c.constraint_type = 'R'
ORDER BY c.table_name;


-- Verificar columnas con identificador automático
SELECT
    table_name,
    column_name,
    generation_type
FROM user_tab_identity_cols
ORDER BY table_name;


-- Verificar la cantidad de registros por tabla
SELECT 'CLIENTE' AS tabla, COUNT(*) AS filas FROM cliente
UNION ALL
SELECT 'TRABAJADOR', COUNT(*) FROM trabajador
UNION ALL
SELECT 'SERVICIO', COUNT(*) FROM servicio
UNION ALL
SELECT 'ESTADO_CITA', COUNT(*) FROM estado_cita
UNION ALL
SELECT 'HORARIO_TRABAJADOR', COUNT(*) FROM horario_trabajador
UNION ALL
SELECT 'TRABAJADOR_SERVICIO', COUNT(*) FROM trabajador_servicio
UNION ALL
SELECT 'CITA', COUNT(*) FROM cita
UNION ALL
SELECT 'HISTORIAL_CITA', COUNT(*) FROM historial_cita;


--==========================================================
SELECT id_estado, nombre
FROM estado_cita
ORDER BY id_estado;