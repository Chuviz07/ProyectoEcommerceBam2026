"""Envía manualmente una notificación FCM para una venta de Firestore."""

from pathlib import Path
import sys

import firebase_admin
from firebase_admin import credentials, firestore, messaging


# 1) Copia aquí el ID real de un documento de la colección "orders".
SALE_ID = "REEMPLAZAR_CON_UN_SALE_ID"

ORDERS_COLLECTION = "orders"
USERS_COLLECTION = "users"
USER_ID_FIELD = "customerId"
TOTAL_FIELD = "total"
TOKENS_FIELD = "fcmTokens"
SERVICE_ACCOUNT_PATH = Path(__file__).with_name("serviceAccountKey.json")


def stop(message: str) -> None:
    sys.exit(f"[ERROR] {message}")


def initialize_firebase() -> None:
    if SALE_ID == "REEMPLAZAR_CON_UN_SALE_ID":
        stop("Debes colocar manualmente un SALE_ID en el archivo.")
    if not SERVICE_ACCOUNT_PATH.exists():
        stop(
            "Falta backend/serviceAccountKey.json. Descárgalo desde Firebase "
            "Console > Configuración del proyecto > Cuentas de servicio."
        )

    firebase_admin.initialize_app(
        credentials.Certificate(str(SERVICE_ACCOUNT_PATH))
    )


def main() -> None:
    initialize_firebase()
    db = firestore.client()

    # 2) Consultar la SALE y extraer TOTAL y USER_ID.
    sale_snapshot = db.collection(ORDERS_COLLECTION).document(SALE_ID).get()
    if not sale_snapshot.exists:
        stop(f"No existe orders/{SALE_ID}.")

    sale = sale_snapshot.to_dict() or {}
    total = sale.get(TOTAL_FIELD)
    user_id = sale.get(USER_ID_FIELD)
    if total is None:
        stop(f"La venta no contiene el campo '{TOTAL_FIELD}'.")
    if not user_id:
        stop(f"La venta no contiene el campo '{USER_ID_FIELD}'.")

    # 3) Consultar el USER y extraer sus TOKENS.
    user_reference = db.collection(USERS_COLLECTION).document(str(user_id))
    user_snapshot = user_reference.get()
    if not user_snapshot.exists:
        stop(f"No existe users/{user_id}.")

    user = user_snapshot.to_dict() or {}
    raw_tokens = user.get(TOKENS_FIELD, [])
    tokens = list(dict.fromkeys(
        token for token in raw_tokens if isinstance(token, str) and token.strip()
    ))
    if not tokens:
        stop(f"users/{user_id} no tiene tokens en '{TOKENS_FIELD}'.")

    # 4) Construir title, body y data. En FCM, todos los valores de data son String.
    message = messaging.MulticastMessage(
        notification=messaging.Notification(
            title="Venta confirmada ✅",
            body=f"Tu compra por Q {float(total):.2f} ya está procesada",
        ),
        data={
            "feature": "sale_detail",
            "sale_id": SALE_ID,
            "total": str(total),
        },
        tokens=tokens,
    )

    # 5) Enviar a todos los dispositivos registrados por el usuario.
    response = messaging.send_each_for_multicast(message)
    print(f"Envíos correctos: {response.success_count}")
    print(f"Envíos fallidos: {response.failure_count}")

    invalid_tokens = []
    for token, result in zip(tokens, response.responses):
        if result.success:
            print(f"[OK] {token[:20]}... -> {result.message_id}")
        else:
            print(f"[ERROR] {token[:20]}... -> {result.exception}")
            if isinstance(
                result.exception,
                (messaging.UnregisteredError, messaging.SenderIdMismatchError),
            ):
                invalid_tokens.append(token)

    # Limpieza opcional para no volver a enviar a instalaciones inválidas.
    if invalid_tokens:
        user_reference.update({
            TOKENS_FIELD: firestore.ArrayRemove(invalid_tokens),
        })
        print(f"Tokens inválidos eliminados: {len(invalid_tokens)}")


if __name__ == "__main__":
    main()
