/* =====================================================================
   FreshSeat - Sistema de Gestión de Reservas para Barberías y Salones
   Curso: SC-504 Lenguajes de Base de Datos - Universidad Fidélitas
   Grupo 1 - Avance 2
   Archivo: 01_tablas.sql
   Responsable: Emily Acuña
   Descripción: Crea las ocho tablas del modelo relacional, sus llaves
                primarias y foráneas, restricciones, identificadores
                automáticos, comentarios y datos de prueba.

   Orden de ejecución: este script se ejecuta PRIMERO. Los archivos
   02_clientes_servicios.sql, 03_trabajadores.sql y 04_citas.sql
   dependen de estas tablas.

   IMPORTANTE: nadie modifica la estructura por su cuenta. Si hace falta
   cambiar una columna, se acuerda en el grupo y se cambia aquí.
   ===================================================================== */

/* ---------------------------------------------------------------------
   0. LIMPIEZA (permite volver a ejecutar el script desde cero)
   Se borran en orden inverso a las dependencias. Los índices de la
   sección 9 se borran junto con su tabla.
   La primera vez que se ejecute, estos DROP darán error ORA-00942
   (la tabla no existe); es normal y el script continúa.
   --------------------------------------------------------------------- */
DROP TABLE historial_cita      CASCADE CONSTRAINTS;
DROP TABLE cita                CASCADE CONSTRAINTS;
DROP TABLE trabajador_servicio CASCADE CONSTRAINTS;
DROP TABLE horario_trabajador  CASCADE CONSTRAINTS;
DROP TABLE estado_cita         CASCADE CONSTRAINTS;
DROP TABLE servicio            CASCADE CONSTRAINTS;
DROP TABLE trabajador          CASCADE CONSTRAINTS;
DROP TABLE cliente             CASCADE CONSTRAINTS;

/* ---------------------------------------------------------------------
   1. CLIENTE
   --------------------------------------------------------------------- */
PROMPT ****** Creando tabla CLIENTE ...

CREATE TABLE cliente (
    id_cliente  NUMBER(10) GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1)
  , nombre      VARCHAR2(60) NOT NULL
  , apellidos   VARCHAR2(100) NOT NULL
  , telefono    VARCHAR2(20) NOT NULL
  , correo      VARCHAR2(120)
  , activo      CHAR(1)        DEFAULT 'S' NOT NULL
  , CONSTRAINT cli_id_pk      PRIMARY KEY (id_cliente)
  , CONSTRAINT cli_correo_uk  UNIQUE (correo)
  , CONSTRAINT cli_correo_ck  CHECK (correo IS NULL OR
        REGEXP_LIKE(correo, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'))
  , CONSTRAINT cli_activo_ck  CHECK (activo IN ('S', 'N'))
);

/* ---------------------------------------------------------------------
   2. TRABAJADOR
   --------------------------------------------------------------------- */
PROMPT ****** Creando tabla TRABAJADOR ...

CREATE TABLE trabajador (
    id_trabajador NUMBER(10) GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1)
  , nombre        VARCHAR2(60) NOT NULL
  , apellidos     VARCHAR2(100) NOT NULL
  , telefono      VARCHAR2(20) NOT NULL
  , correo        VARCHAR2(120)
  , activo        CHAR(1)        DEFAULT 'S' NOT NULL
  , CONSTRAINT tra_id_pk      PRIMARY KEY (id_trabajador)
  , CONSTRAINT tra_correo_uk  UNIQUE (correo)
  , CONSTRAINT tra_correo_ck  CHECK (correo IS NULL OR
        REGEXP_LIKE(correo, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'))
  , CONSTRAINT tra_activo_ck  CHECK (activo IN ('S', 'N'))
);

/* ---------------------------------------------------------------------
   3. SERVICIO
   --------------------------------------------------------------------- */
PROMPT ****** Creando tabla SERVICIO ...

CREATE TABLE servicio (
    id_servicio      NUMBER(10) GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1)
  , nombre           VARCHAR2(100) NOT NULL
  , descripcion      VARCHAR2(200)
  , duracion_minutos NUMBER(3) NOT NULL
  , precio           NUMBER(10,2) NOT NULL
  , activo           CHAR(1)       DEFAULT 'S' NOT NULL
  , CONSTRAINT ser_id_pk       PRIMARY KEY (id_servicio)
  , CONSTRAINT ser_nombre_uk   UNIQUE (nombre)
  , CONSTRAINT ser_duracion_ck CHECK (duracion_minutos > 0)
  , CONSTRAINT ser_precio_ck   CHECK (precio >= 0)
  , CONSTRAINT ser_activo_ck   CHECK (activo IN ('S', 'N'))
);

/* ---------------------------------------------------------------------
   4. ESTADO_CITA (catálogo)
   --------------------------------------------------------------------- */
PROMPT ****** Creando tabla ESTADO_CITA ...

CREATE TABLE estado_cita (
    id_estado NUMBER(2) GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1)
  , nombre    VARCHAR2(30) NOT NULL
  , CONSTRAINT est_id_pk     PRIMARY KEY (id_estado)
  , CONSTRAINT est_nombre_uk UNIQUE (nombre)
);

/* ---------------------------------------------------------------------
   5. HORARIO_TRABAJADOR
   Cada fila es un bloque de disponibilidad de un trabajador.
   --------------------------------------------------------------------- */
PROMPT ****** Creando tabla HORARIO_TRABAJADOR ...

CREATE TABLE horario_trabajador (
    id_horario        NUMBER(10) GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1)
  , id_trabajador     NUMBER(10) NOT NULL
  , fecha_hora_inicio DATE NOT NULL
  , fecha_hora_fin    DATE NOT NULL
  , CONSTRAINT hor_id_pk         PRIMARY KEY (id_horario)
  , CONSTRAINT hor_trabajador_fk FOREIGN KEY (id_trabajador)
                                 REFERENCES trabajador (id_trabajador)
  , CONSTRAINT hor_rango_ck      CHECK (fecha_hora_fin > fecha_hora_inicio)
  , CONSTRAINT hor_bloque_uk     UNIQUE (id_trabajador, fecha_hora_inicio)
);

/* ---------------------------------------------------------------------
   6. TRABAJADOR_SERVICIO (NUEVA)
   Relación muchos a muchos: qué servicios puede realizar cada trabajador.
   La llave primaria compuesta impide asignar dos veces el mismo servicio
   al mismo trabajador.
   --------------------------------------------------------------------- */
PROMPT ****** Creando tabla TRABAJADOR_SERVICIO ...

CREATE TABLE trabajador_servicio (
    id_trabajador    NUMBER(10) NOT NULL
  , id_servicio      NUMBER(10) NOT NULL
  , fecha_asignacion DATE       DEFAULT SYSDATE NOT NULL
  , CONSTRAINT tse_pk            PRIMARY KEY (id_trabajador, id_servicio)
  , CONSTRAINT tse_trabajador_fk FOREIGN KEY (id_trabajador)
                                 REFERENCES trabajador (id_trabajador)
  , CONSTRAINT tse_servicio_fk   FOREIGN KEY (id_servicio)
                                 REFERENCES servicio (id_servicio)
);

/* ---------------------------------------------------------------------
   7. CITA
   --------------------------------------------------------------------- */
PROMPT ****** Creando tabla CITA ...

CREATE TABLE cita (
    id_cita           NUMBER(10) GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1)
  , id_cliente        NUMBER(10) NOT NULL
  , id_horario        NUMBER(10) NOT NULL
  , id_servicio       NUMBER(10) NOT NULL
  , id_estado         NUMBER(2) NOT NULL
  , fecha_hora_inicio DATE NOT NULL
  , fecha_hora_fin    DATE NOT NULL
  , precio_acordado   NUMBER(10,2) NOT NULL
  , observaciones     VARCHAR2(250)
  , CONSTRAINT cit_id_pk       PRIMARY KEY (id_cita)
  , CONSTRAINT cit_cliente_fk  FOREIGN KEY (id_cliente)
                               REFERENCES cliente (id_cliente)
  , CONSTRAINT cit_horario_fk  FOREIGN KEY (id_horario)
                               REFERENCES horario_trabajador (id_horario)
  , CONSTRAINT cit_servicio_fk FOREIGN KEY (id_servicio)
                               REFERENCES servicio (id_servicio)
  , CONSTRAINT cit_estado_fk   FOREIGN KEY (id_estado)
                               REFERENCES estado_cita (id_estado)
  , CONSTRAINT cit_rango_ck    CHECK (fecha_hora_fin > fecha_hora_inicio)
  , CONSTRAINT cit_precio_ck   CHECK (precio_acordado >= 0)
);

/* ---------------------------------------------------------------------
   8. HISTORIAL_CITA (NUEVA)
   Registra cada cambio de una cita: creación, cambio de estado,
   reprogramación o cancelación. El estado anterior queda en NULL
   cuando la cita se acaba de crear.
   --------------------------------------------------------------------- */
PROMPT ****** Creando tabla HISTORIAL_CITA ...

CREATE TABLE historial_cita (
    id_historial        NUMBER(10) GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1)
  , id_cita             NUMBER(10) NOT NULL
  , id_estado_anterior  NUMBER(2)
  , id_estado_nuevo     NUMBER(2) NOT NULL
  , fecha_cambio        DATE          DEFAULT SYSDATE NOT NULL
  , descripcion         VARCHAR2(250)
  , CONSTRAINT his_id_pk              PRIMARY KEY (id_historial)
  , CONSTRAINT his_cita_fk            FOREIGN KEY (id_cita)
                                      REFERENCES cita (id_cita)
  , CONSTRAINT his_estado_anterior_fk FOREIGN KEY (id_estado_anterior)
                                      REFERENCES estado_cita (id_estado)
  , CONSTRAINT his_estado_nuevo_fk    FOREIGN KEY (id_estado_nuevo)
                                      REFERENCES estado_cita (id_estado)
);

/* ---------------------------------------------------------------------
   9. ÍNDICES SOBRE LLAVES FORÁNEAS
   Oracle no crea índices automáticamente para las FK; estos aceleran
   las consultas por trabajador, cliente, estado e historial (RF-10, RF-11).
   --------------------------------------------------------------------- */
PROMPT ****** Creando índices ...

CREATE INDEX tse_servicio_ix  ON trabajador_servicio (id_servicio);
CREATE INDEX cit_cliente_ix   ON cita (id_cliente);
CREATE INDEX cit_horario_ix   ON cita (id_horario);
CREATE INDEX cit_servicio_ix  ON cita (id_servicio);
CREATE INDEX cit_estado_ix    ON cita (id_estado);
CREATE INDEX his_cita_ix      ON historial_cita (id_cita);

/* ---------------------------------------------------------------------
   10. COMENTARIOS
   SQL Developer los incluye en el reporte del diccionario de datos.
   --------------------------------------------------------------------- */
COMMENT ON TABLE cliente IS 'Clientes que reservan citas en el negocio.';
COMMENT ON COLUMN cliente.id_cliente IS 'Identificador del cliente, generado automáticamente.';
COMMENT ON COLUMN cliente.nombre     IS 'Nombre del cliente.';
COMMENT ON COLUMN cliente.apellidos  IS 'Apellidos del cliente.';
COMMENT ON COLUMN cliente.telefono   IS 'Teléfono de contacto.';
COMMENT ON COLUMN cliente.correo     IS 'Correo electrónico; único y con formato válido.';
COMMENT ON COLUMN cliente.activo     IS 'S = activo, N = desactivado (no se borra para conservar el historial).';

COMMENT ON TABLE trabajador IS 'Personal del negocio que atiende las citas.';
COMMENT ON COLUMN trabajador.id_trabajador IS 'Identificador del trabajador, generado automáticamente.';
COMMENT ON COLUMN trabajador.nombre        IS 'Nombre del trabajador.';
COMMENT ON COLUMN trabajador.apellidos     IS 'Apellidos del trabajador.';
COMMENT ON COLUMN trabajador.telefono      IS 'Teléfono de contacto.';
COMMENT ON COLUMN trabajador.correo        IS 'Correo electrónico; único y con formato válido.';
COMMENT ON COLUMN trabajador.activo        IS 'S = activo, N = desactivado.';

COMMENT ON TABLE servicio IS 'Servicios que ofrece el negocio (corte, barba, tinte, etc.).';
COMMENT ON COLUMN servicio.id_servicio      IS 'Identificador del servicio, generado automáticamente.';
COMMENT ON COLUMN servicio.nombre           IS 'Nombre del servicio; único.';
COMMENT ON COLUMN servicio.descripcion      IS 'Descripción del servicio.';
COMMENT ON COLUMN servicio.duracion_minutos IS 'Duración estimada en minutos; mayor que cero.';
COMMENT ON COLUMN servicio.precio           IS 'Precio de lista del servicio en colones.';
COMMENT ON COLUMN servicio.activo           IS 'S = activo, N = desactivado.';

COMMENT ON TABLE estado_cita IS 'Catálogo de estados de una cita.';
COMMENT ON COLUMN estado_cita.id_estado IS 'Identificador del estado, generado automáticamente.';
COMMENT ON COLUMN estado_cita.nombre    IS 'Nombre del estado: Pendiente, Confirmada, Completada o Cancelada.';

COMMENT ON TABLE horario_trabajador IS 'Bloques de disponibilidad de cada trabajador.';
COMMENT ON COLUMN horario_trabajador.id_horario        IS 'Identificador del bloque, generado automáticamente.';
COMMENT ON COLUMN horario_trabajador.id_trabajador     IS 'Trabajador al que pertenece el bloque.';
COMMENT ON COLUMN horario_trabajador.fecha_hora_inicio IS 'Fecha y hora de inicio del bloque.';
COMMENT ON COLUMN horario_trabajador.fecha_hora_fin    IS 'Fecha y hora de fin del bloque; posterior al inicio.';

COMMENT ON TABLE trabajador_servicio IS 'Servicios que puede realizar cada trabajador (relación muchos a muchos).';
COMMENT ON COLUMN trabajador_servicio.id_trabajador    IS 'Trabajador asignado.';
COMMENT ON COLUMN trabajador_servicio.id_servicio      IS 'Servicio que puede realizar.';
COMMENT ON COLUMN trabajador_servicio.fecha_asignacion IS 'Fecha en que se asignó el servicio al trabajador.';

COMMENT ON TABLE cita IS 'Reservaciones de los clientes.';
COMMENT ON COLUMN cita.id_cita           IS 'Identificador de la cita, generado automáticamente.';
COMMENT ON COLUMN cita.id_cliente        IS 'Cliente que reserva.';
COMMENT ON COLUMN cita.id_horario        IS 'Bloque de horario del trabajador asignado.';
COMMENT ON COLUMN cita.id_servicio       IS 'Servicio solicitado.';
COMMENT ON COLUMN cita.id_estado         IS 'Estado actual de la cita.';
COMMENT ON COLUMN cita.fecha_hora_inicio IS 'Fecha y hora de inicio de la cita.';
COMMENT ON COLUMN cita.fecha_hora_fin    IS 'Fecha y hora de fin de la cita.';
COMMENT ON COLUMN cita.precio_acordado   IS 'Precio cobrado al reservar; puede diferir del precio de lista.';
COMMENT ON COLUMN cita.observaciones     IS 'Notas adicionales de la cita.';

COMMENT ON TABLE historial_cita IS 'Registro de los cambios realizados a cada cita.';
COMMENT ON COLUMN historial_cita.id_historial       IS 'Identificador del registro, generado automáticamente.';
COMMENT ON COLUMN historial_cita.id_cita            IS 'Cita que cambió.';
COMMENT ON COLUMN historial_cita.id_estado_anterior IS 'Estado antes del cambio; NULL si la cita se acaba de crear.';
COMMENT ON COLUMN historial_cita.id_estado_nuevo    IS 'Estado después del cambio.';
COMMENT ON COLUMN historial_cita.fecha_cambio       IS 'Fecha y hora del cambio.';
COMMENT ON COLUMN historial_cita.descripcion        IS 'Detalle del cambio (creación, reprogramación, cancelación, etc.).';

/* ---------------------------------------------------------------------
   11. DATOS INICIALES Y DE PRUEBA
   El catálogo de estados se inserta en este orden para que los ids
   queden: 1 Pendiente, 2 Confirmada, 3 Completada, 4 Cancelada.
   El resto son datos mínimos para que el equipo pruebe sus procedimientos.
   --------------------------------------------------------------------- */
PROMPT ****** Insertando datos ...

INSERT INTO estado_cita (nombre) VALUES ('Pendiente');
INSERT INTO estado_cita (nombre) VALUES ('Confirmada');
INSERT INTO estado_cita (nombre) VALUES ('Completada');
INSERT INTO estado_cita (nombre) VALUES ('Cancelada');

INSERT INTO cliente (nombre, apellidos, telefono, correo)
VALUES ('Laura', 'Mora Jiménez', '8888-1111', 'laura.mora@correo.com');
INSERT INTO cliente (nombre, apellidos, telefono, correo)
VALUES ('Andrés', 'Vargas Rojas', '8888-2222', 'andres.vargas@correo.com');
INSERT INTO cliente (nombre, apellidos, telefono, correo)
VALUES ('Sofía', 'Castro Solís', '8888-3333', NULL);

INSERT INTO trabajador (nombre, apellidos, telefono, correo)
VALUES ('Diego', 'Herrera Quesada', '7000-1111', 'diego@freshseat.com');
INSERT INTO trabajador (nombre, apellidos, telefono, correo)
VALUES ('Valeria', 'Ramírez Brenes', '7000-2222', 'valeria@freshseat.com');

INSERT INTO servicio (nombre, descripcion, duracion_minutos, precio)
VALUES ('Corte clásico', 'Corte de cabello con máquina y tijera', 30, 6000);
INSERT INTO servicio (nombre, descripcion, duracion_minutos, precio)
VALUES ('Arreglo de barba', 'Perfilado y arreglo de barba', 20, 4000);
INSERT INTO servicio (nombre, descripcion, duracion_minutos, precio)
VALUES ('Tinte', 'Aplicación de tinte completo', 90, 18000);

-- Diego hace corte y barba; Valeria hace corte y tinte
INSERT INTO trabajador_servicio (id_trabajador, id_servicio) VALUES (1, 1);
INSERT INTO trabajador_servicio (id_trabajador, id_servicio) VALUES (1, 2);
INSERT INTO trabajador_servicio (id_trabajador, id_servicio) VALUES (2, 1);
INSERT INTO trabajador_servicio (id_trabajador, id_servicio) VALUES (2, 3);

-- Bloques de una hora para el día siguiente a la ejecución
INSERT INTO horario_trabajador (id_trabajador, fecha_hora_inicio, fecha_hora_fin)
VALUES (1, TRUNC(SYSDATE) + 1 + 9/24,  TRUNC(SYSDATE) + 1 + 10/24);
INSERT INTO horario_trabajador (id_trabajador, fecha_hora_inicio, fecha_hora_fin)
VALUES (1, TRUNC(SYSDATE) + 1 + 10/24, TRUNC(SYSDATE) + 1 + 11/24);
INSERT INTO horario_trabajador (id_trabajador, fecha_hora_inicio, fecha_hora_fin)
VALUES (2, TRUNC(SYSDATE) + 1 + 9/24,  TRUNC(SYSDATE) + 1 + 11/24);

-- Una cita pendiente: Laura, corte con Diego a las 9:00
INSERT INTO cita (id_cliente, id_horario, id_servicio, id_estado,
                  fecha_hora_inicio, fecha_hora_fin, precio_acordado, observaciones)
VALUES (1, 1, 1, 1,
        TRUNC(SYSDATE) + 1 + 9/24, TRUNC(SYSDATE) + 1 + 9.5/24, 6000, 'Primera visita');

INSERT INTO historial_cita (id_cita, id_estado_anterior, id_estado_nuevo, descripcion)
VALUES (1, NULL, 1, 'Cita creada');

COMMIT;

/* ---------------------------------------------------------------------
   12. VERIFICACIÓN
   Comprueba que las tablas, restricciones y datos quedaron creados.
   --------------------------------------------------------------------- */
PROMPT ****** Verificando estructura ...

-- Debe devolver las 8 tablas
SELECT table_name
  FROM user_tables
 WHERE table_name IN ('CLIENTE', 'TRABAJADOR', 'SERVICIO', 'ESTADO_CITA',
                      'HORARIO_TRABAJADOR', 'TRABAJADOR_SERVICIO',
                      'CITA', 'HISTORIAL_CITA')
 ORDER BY table_name;

-- Restricciones por tabla (P = primaria, R = foránea, U = única, C = check / not null)
SELECT table_name, constraint_type, COUNT(*) AS cantidad
  FROM user_constraints
 WHERE table_name IN ('CLIENTE', 'TRABAJADOR', 'SERVICIO', 'ESTADO_CITA',
                      'HORARIO_TRABAJADOR', 'TRABAJADOR_SERVICIO',
                      'CITA', 'HISTORIAL_CITA')
 GROUP BY table_name, constraint_type
 ORDER BY table_name, constraint_type;

-- Llaves foráneas: qué tabla referencia a cuál
SELECT c.table_name   AS tabla,
       c.constraint_name AS llave_foranea,
       p.table_name   AS tabla_referenciada
  FROM user_constraints c
  JOIN user_constraints p ON p.constraint_name = c.r_constraint_name
 WHERE c.constraint_type = 'R'
 ORDER BY c.table_name;

-- Columnas con identificador automático (identity)
SELECT table_name, column_name, generation_type
  FROM user_tab_identity_cols
 ORDER BY table_name;

-- Cantidad de filas de prueba por tabla
SELECT 'CLIENTE' AS tabla, COUNT(*) AS filas FROM cliente
UNION ALL SELECT 'TRABAJADOR', COUNT(*) FROM trabajador
UNION ALL SELECT 'SERVICIO', COUNT(*) FROM servicio
UNION ALL SELECT 'ESTADO_CITA', COUNT(*) FROM estado_cita
UNION ALL SELECT 'HORARIO_TRABAJADOR', COUNT(*) FROM horario_trabajador
UNION ALL SELECT 'TRABAJADOR_SERVICIO', COUNT(*) FROM trabajador_servicio
UNION ALL SELECT 'CITA', COUNT(*) FROM cita
UNION ALL SELECT 'HISTORIAL_CITA', COUNT(*) FROM historial_cita;
