# =========================================================
# FRESHSEAT - CONEXION PYTHON CON ORACLE CLOUD
# SC-504 Lenguajes de Bases de Datos
# Grupo 1 - Avance 2
# Jose Daniel Pereira
# ========================================================

import getpass
from pathlib import Path

import oracledb


def titulo(texto):
    print("\n" + "=" * 50)
    print(texto)
    print("=" * 50)


def configurar_conexion():
    titulo("CONFIGURACION DE ORACLE")

    usuario = input("Usuario Oracle: ").strip()
    servicio = input("Servicio o DSN de Oracle: ").strip()
    usa_wallet = input("¿Tu base utiliza wallet? (s/n): ").strip().lower()

    if not usuario or not servicio:
        raise ValueError("Debes indicar el usuario y el servicio Oracle.")

    if usa_wallet not in ("s", "n"):
        raise ValueError("Respondé 's' o 'n' para el wallet.")

    parametros = {
        "user": usuario,
        "password": getpass.getpass("Contraseña Oracle: "),
        "dsn": servicio,
    }

    if usa_wallet == "s":
        ruta_wallet = input(
            "Ruta de la carpeta del wallet descomprimido: "
        ).strip().strip('"')

        carpeta = Path(ruta_wallet).expanduser()

        if not carpeta.is_dir():
            raise FileNotFoundError(
                f"No existe la carpeta del wallet: {carpeta}"
            )

        for archivo in ("tnsnames.ora", "ewallet.pem"):
            if not (carpeta / archivo).is_file():
                raise FileNotFoundError(
                    f"Falta el archivo {archivo} en el wallet."
                )

        parametros["config_dir"] = str(carpeta)
        parametros["wallet_location"] = str(carpeta)
        parametros["wallet_password"] = getpass.getpass(
            "Contraseña del wallet: "
        )

    return parametros


def listar_datos(conexion, cursor, procedimiento, nombre):
    titulo(nombre)

    with conexion.cursor() as resultado:
        cursor.callproc(procedimiento, [resultado])
        registros = resultado.fetchall()

    for registro in registros:
        print(registro)

    print(f"\nTotal de registros: {len(registros)}")

    return registros


def main():
    conexion = None

    try:
        parametros = configurar_conexion()

        titulo("CONECTANDO CON ORACLE")

        conexion = oracledb.connect(**parametros)

        print("Conexión con Oracle exitosa.")
        print(f"Usuario configurado: {parametros['user']}")

        with conexion.cursor() as cursor:

            clientes = listar_datos(
                conexion,
                cursor,
                "SP_LISTAR_CLIENTES",
                "LISTADO DE CLIENTES",
            )

            servicios = listar_datos(
                conexion,
                cursor,
                "SP_LISTAR_SERVICIOS",
                "LISTADO DE SERVICIOS",
            )

            estados = listar_datos(
                conexion,
                cursor,
                "SP_LISTAR_ESTADOS",
                "LISTADO DE ESTADOS DE CITA",
            )

            titulo("PRUEBA DE FUNCION PL/SQL")

            for estado in estados:
                id_estado = estado[0]

                nombre_estado = cursor.callfunc(
                    "FN_NOMBRE_ESTADO",
                    str,
                    [id_estado],
                )

                print(f"Estado {id_estado}: {nombre_estado}")

        titulo("RESUMEN DE VERIFICACION")

        print(f"Clientes encontrados: {len(clientes)}")
        print(f"Servicios encontrados: {len(servicios)}")
        print(f"Estados encontrados: {len(estados)}")

        print("\nProcedimientos ejecutados correctamente:")
        print("- SP_LISTAR_CLIENTES")
        print("- SP_LISTAR_SERVICIOS")
        print("- SP_LISTAR_ESTADOS")

        print("\nFuncion ejecutada correctamente:")
        print("- FN_NOMBRE_ESTADO")

        titulo("PRUEBAS FINALIZADAS CORRECTAMENTE")

    except (oracledb.Error, FileNotFoundError, ValueError) as error:
        titulo("ERROR EN LA VERIFICACION")
        print(error)
        print(
            "\nVerificá la conexión, las credenciales "
            "y que los objetos PL/SQL estén instalados."
        )

    finally:
        if conexion is not None:
            conexion.close()
            print("\nConexión Oracle cerrada.")


if __name__ == "__main__":
    main()