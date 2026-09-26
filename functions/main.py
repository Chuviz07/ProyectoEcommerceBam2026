"""Cloud Functions del flujo automático de compras y notificaciones."""

from typing import Any

from firebase_admin import firestore, initialize_app, messaging
from firebase_functions.firestore_fn import DocumentSnapshot, Event, on_document_created
from google.cloud.firestore_v1.transaction import transactional


initialize_app()

ORDERS_COLLECTION = "orders"
USERS_COLLECTION = "users"
TOKENS_FIELD = "fcmTokens"


def _clean_tokens(value: Any) -> list[str]:
    """Devuelve tokens FCM válidos, sin vacíos ni duplicados."""
    if not isinstance(value, list):
        return []

    return list(
        dict.fromkeys(
            token.strip()
            for token in value
            if isinstance(token, str) and token.strip()
        )
    )


def _claim_notification(
    database: Any,
    order_reference: Any,
    event_id: str,
) -> bool:
    """Marca la venta de forma atómica para ignorar entregas duplicadas."""
    transaction = database.transaction()

    @transactional
    def claim(current_transaction: Any) -> bool:
        current_snapshot = order_reference.get(transaction=current_transaction)
        if not current_snapshot.exists:
            return False

        current_data = current_snapshot.to_dict() or {}
        current_status = current_data.get("notificationStatus")
        if current_status in {"processing", "sent"}:
            return False

        current_transaction.update(
            order_reference,
            {
                "notificationStatus": "processing",
                "notificationEventId": event_id,
                "notificationError": firestore.DELETE_FIELD,
            },
        )
        return True

    return bool(claim(transaction))


@on_document_created(document=f"{ORDERS_COLLECTION}/{{saleId}}")
def send_purchase_notification(event: Event[DocumentSnapshot]) -> None:
    """Envía FCM al propietario cuando se crea una compra en Firestore."""
    snapshot = event.data
    sale_id = event.params["saleId"]

    if snapshot is None:
        print(f"[OMITIDA] orders/{sale_id}: el evento no contiene datos.")
        return

    order = snapshot.to_dict() or {}
    customer_id = str(order.get("customerId") or "").strip()
    total = order.get("total")

    if not customer_id or not isinstance(total, (int, float)):
        snapshot.reference.update(
            {
                "notificationStatus": "failed",
                "notificationError": "La venta no contiene customerId o total válido.",
                "notificationProcessedAt": firestore.SERVER_TIMESTAMP,
            }
        )
        print(f"[ERROR] orders/{sale_id}: customerId o total inválido.")
        return

    database = firestore.client()

    if not _claim_notification(database, snapshot.reference, event.id):
        print(f"[OMITIDA] orders/{sale_id}: la notificación ya fue procesada.")
        return
    user_reference = database.collection(USERS_COLLECTION).document(customer_id)
    user_snapshot = user_reference.get()

    if not user_snapshot.exists:
        snapshot.reference.update(
            {
                "notificationStatus": "failed",
                "notificationError": f"No existe users/{customer_id}.",
                "notificationProcessedAt": firestore.SERVER_TIMESTAMP,
            }
        )
        print(f"[ERROR] orders/{sale_id}: no existe users/{customer_id}.")
        return

    user_data = user_snapshot.to_dict() or {}
    tokens = _clean_tokens(user_data.get(TOKENS_FIELD))

    if not tokens:
        snapshot.reference.update(
            {
                "notificationStatus": "skipped_no_tokens",
                "notificationError": "El usuario no tiene tokens FCM registrados.",
                "notificationProcessedAt": firestore.SERVER_TIMESTAMP,
            }
        )
        print(f"[OMITIDA] orders/{sale_id}: users/{customer_id} no tiene tokens.")
        return

    # Todos los valores de data deben enviarse como texto.
    message = messaging.MulticastMessage(
        notification=messaging.Notification(
            title="Compra confirmada ✅",
            body=f"Tu compra por Q {float(total):.2f} fue registrada correctamente.",
        ),
        data={
            "feature": "sale_detail",
            "sale_id": sale_id,
            "total": str(total),
        },
        android=messaging.AndroidConfig(
            priority="high",
            notification=messaging.AndroidNotification(
                channel_id="purchase_notifications",
                click_action="FLUTTER_NOTIFICATION_CLICK",
            ),
        ),
        tokens=tokens,
    )

    try:
        response = messaging.send_each_for_multicast(message)
    except Exception as error:
        snapshot.reference.update(
            {
                "notificationStatus": "failed",
                "notificationError": str(error)[:500],
                "notificationProcessedAt": firestore.SERVER_TIMESTAMP,
            }
        )
        print(f"[ERROR] orders/{sale_id}: no se pudo enviar FCM: {error}")
        return

    invalid_tokens: list[str] = []
    errors: list[str] = []

    for token, result in zip(tokens, response.responses):
        if result.success:
            continue

        errors.append(str(result.exception))
        if isinstance(
            result.exception,
            (messaging.UnregisteredError, messaging.SenderIdMismatchError),
        ):
            invalid_tokens.append(token)

    if invalid_tokens:
        user_reference.update(
            {TOKENS_FIELD: firestore.ArrayRemove(invalid_tokens)}
        )

    final_status = "sent" if response.success_count > 0 else "failed"
    result_data: dict[str, Any] = {
        "notificationStatus": final_status,
        "notificationSuccessCount": response.success_count,
        "notificationFailureCount": response.failure_count,
        "notificationProcessedAt": firestore.SERVER_TIMESTAMP,
        "notificationError": firestore.DELETE_FIELD,
        "notificationLastErrors": firestore.DELETE_FIELD,
    }
    if errors:
        result_data["notificationLastErrors"] = errors[:5]

    snapshot.reference.update(result_data)
    print(
        f"[RESULTADO] orders/{sale_id}: "
        f"correctos={response.success_count}, fallidos={response.failure_count}"
    )
