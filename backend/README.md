# Backend manual de notificaciones por venta

Este ejemplo sigue el flujo usado por el profesor, adaptado al esquema real de
este proyecto: `orders/{saleId}.customerId` apunta a `users/{uid}` y los tokens
se guardan en `users/{uid}.fcmTokens`.

## Preparación

1. En Firebase Console abre **Configuración del proyecto > Cuentas de servicio**.
2. Genera una clave privada y guárdala únicamente como
   `backend/serviceAccountKey.json`. Nunca la subas a Git ni la copies a Flutter.
3. Abre una terminal en la raíz del proyecto.
4. Crea y activa un entorno virtual:

   Windows PowerShell:

   ```powershell
   py -m venv backend/.venv
   backend\.venv\Scripts\Activate.ps1
   ```

5. Instala la dependencia:

   ```powershell
   pip install -r backend/requirements.txt
   ```

6. En `backend/send_sale_notification.py`, reemplaza el valor de `SALE_ID` por
   el ID de un documento existente en la colección `orders`.
7. Ejecuta:

   ```powershell
   python backend/send_sale_notification.py
   ```

Antes de ejecutar el backend, inicia sesión en Flutter y pulsa el botón de la
campana para permitir notificaciones. Eso obtiene el token FCM y lo agrega al
arreglo `fcmTokens` del documento del usuario.
