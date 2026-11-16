/* 
   FreshSeat - Sistema de Gestión de Reservas para Barberías y Salones
   Curso: SC-504 Lenguajes de Base de Datos - Universidad Fidélitas
   Grupo 1 - Avance 2
   Archivo: 01_tablas.sql
 */


-- LIMPIEZA 

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

CREATE TABLE estado_cita (
    id_estado NUMBER(2) GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1)
  , nombre    VARCHAR2(30) NOT NULL
  , CONSTRAINT est_id_pk     PRIMARY KEY (id_estado)
  , CONSTRAINT est_nombre_uk UNIQUE (nombre)
);

/* ---------------------------------------------------------------------
   5. HORARIO_TRABAJADOR
   --------------------------------------------------------------------- */


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
   6. TRABAJADOR_SERVICIO
   --------------------------------------------------------------------- */

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
   8. HISTORIAL_CITA
   --------------------------------------------------------------------- */

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
   las consultas por trabajador, cliente, estado e historial 
   --------------------------------------------------------------------- */

CREATE INDEX tse_servicio_ix  ON trabajador_servicio (id_servicio);
CREATE INDEX cit_cliente_ix   ON cita (id_cliente);
CREATE INDEX cit_horario_ix   ON cita (id_horario);
CREATE INDEX cit_servicio_ix  ON cita (id_servicio);
CREATE INDEX cit_estado_ix    ON cita (id_estado);
CREATE INDEX his_cita_ix      ON historial_cita (id_cita);
