# WheelsPe / MOVEO — App Proveedor (Flutter) — Estado tras integración con el backend real

> App móvil del **Proveedor / Conductor** (rol `owner`): publicar y gestionar vehículos y rutas,
> aceptar/gestionar reservas, ingresos, reputación, chat y notificaciones.
>
> **Stack:** Flutter / Dart · Riverpod · go_router · Dio · Clean Architecture.
> **Backend:** `MOVEO-Backend` (.NET) — **SIN JWT** (sesión por `userId`). Base local:
> `http://localhost:8080/api/v1` (en emulador Android la app usa `http://10.0.2.2:8080/api/v1`).
> **Fecha:** 2026-06-13.

Leyenda: ✅ Conectado al backend real · 🟢 Conectado best-effort (sin endpoint dedicado, ver §3) ·
🔵 Solo UI / simulado (sin backend posible) · ⛔ No soportado por el backend.

---

## 0. Resumen

La app se **re-cableó por completo** del contrato viejo del backlog al **contrato real del backend**
(verificado contra Swagger). Cambios estructurales:

- **Se eliminó JWT.** No hay `Authorization: Bearer` ni refresh token. La sesión es el `userId`
  devuelto por `/auth/login` (guardado en secure storage) y enviado como `?ownerId=` / `recipientId=`
  / `userId=` según el endpoint.
- **Rol `owner`** en el registro (antes `PROVIDER`).
- **Endpoints renombrados** a los reales: `/rentals`, `/adventure-routes`, `/Payments`,
  `/user-reviews` + `/Reviews`, `/Notifications`, `/messages`, `/support-tickets`.
- **Modelos alineados** con los datos reales (estados en minúscula `pending/accepted/active/completed/cancelled`,
  campos `ownerId`, `seatsAvailable`, `onlyWomen`, `bodyType`, `district`, etc.).
- **Features nuevas implementadas:** chat 1-a-1 (`/messages`) y notificaciones reales (`/Notifications`).
- **Comprobantes (US25)** ahora se generan como **PDF en el dispositivo** (paquetes `pdf` + `printing`).
- `flutter analyze`: **sin issues**. `flutter pub get`: OK.

---

## 1. User Stories del proveedor — estado actual

| US | Función | Estado | Endpoint real |
|----|---------|--------|---------------|
| US01 | Registro (rol `owner`) | ✅ | `POST /auth/register` (devuelve usuario, sin token) |
| US03 | Login + sesión (`userId`) | ✅ | `POST /auth/login` |
| US04 | Cambiar contraseña | ✅ | `POST /auth/change-password` |
| US05 | Publicar / editar / eliminar vehículo | ✅ | `POST/PUT/PATCH/DELETE /vehicles` |
| — | Mis vehículos | ✅ | `GET /vehicles?ownerId=` |
| — | Disponibilidad por fechas | ✅ | `GET /vehicles/{id}/availability` |
| — | Ver reservas de mis autos | ✅ | `GET /rentals?ownerId=` / `?vehicleId=` |
| — | Aceptar / activar / completar / cancelar reserva | ✅ | `PATCH /rentals/{id}` (`accepted`/`active`/`completed`/`cancelled`) |
| US13 | Publicar / editar / eliminar ruta de carpool | ✅ | `POST/PUT/DELETE /adventure-routes` |
| — | Cambiar estado de ruta | ✅ | `PUT /adventure-routes/{id}` (`status`) |
| — | Panel de ingresos | ✅ | `GET /Payments/recipient/{id}` |
| US26/US33 | Reembolsos | ✅ | `PATCH /Payments/{id}` (`status:"refunded"`) |
| US19/US37 | Reputación / reseñas recibidas | ✅ | `GET /user-reviews?reviewedUserId=` |
| US28/US35 | Calificar al cliente/pasajero | ✅ | `POST /user-reviews` (`type:"owner_to_renter"`) |
| US18 | **Chat con clientes** | ✅ | `/messages` (conversaciones, hilo, enviar, marcar leído) |
| — | **Notificaciones** | ✅ | `/Notifications` (bandeja, no leídas, marcar, borrar) |
| US02 | Verificación KYC | 🟢 | Sin endpoint KYC → se marca verificación en `PATCH /users/{id}` y se lee de los flags del usuario |
| US08 | Reportar incidente | 🟢 | Sin `/incidents` → se crea un **ticket de soporte** real (`POST /support-tickets`, `type:"incident"`) |
| US25 | Comprobantes / contrato (PDF) | 🟢 | Sin `/invoices` → **PDF generado en el dispositivo** desde los datos del cobro |
| US36 | Badges / distintivos | 🟢 | Sin endpoint → derivados de las stats reales del usuario (`completedRentals`, `rating`) |
| US44 | Soporte / ayuda | ✅ | `/support-tickets` |

---

## 2. Notificaciones: real + push simulado

- **Bandeja real** desde `/Notifications` (pantalla `/notifications`, icono con badge de no leídas en el
  home, marcar leído/marcar todo/borrar).
- **Aviso local** (flutter_local_notifications) cuando llega una nueva reserva `pending` (polling cada
  30 s sobre `/rentals?ownerId=`). Es un push **simulado** local; el push real remoto requeriría FCM
  en el backend (fuera de alcance hoy).

---

## 3. Best-effort: US sin endpoint dedicado (conectadas con datos reales)

El backend NO tiene endpoints para KYC, incidentes, comprobantes ni badges. En vez de pantallas
falsas, se conectaron de la forma más real posible:

| US | Cómo se resolvió | Limitación |
|----|------------------|------------|
| US02 KYC | `PATCH /users/{id}` marca `verificationStatus=IN_REVIEW`; el estado se lee de los flags `dniVerified`/`licenseVerified`/`verificationStatus`. | No sube imágenes (no hay endpoint de almacenamiento). La verificación real la hace un admin. |
| US08 Incidentes | Se crea un **ticket de soporte** (`type:"incident"`) con descripción y reserva/ruta relacionada. | Las fotos de evidencia se referencian en el texto, no se suben. |
| US25 Comprobantes | **PDF generado en el dispositivo** (`pdf`+`printing`) y compartido/impreso. | No es comprobante electrónico SUNAT; el backend no lo persiste. |
| US36 Badges | Derivados de stats reales del `User`. | Sin lógica de canje/ranking en backend. |

---

## 4. Pendiente real (bloqueado por backend o configuración)

| Tema | Estado | Qué falta |
|------|--------|-----------|
| US16 Aprobar/quitar pasajeros | ⛔ | El backend solo tiene `POST /adventure-routes/{id}/book` (descuenta cupos). No hay lista de pasajeros ni aprobar/rechazar. La acción informa "no soportado" en la UI. |
| US06/US07 GPS en vivo | 🔵 | No hay `/trips`/ubicación. Mapas funcionarán al poner una **Google Maps API key real** (hoy placeholder). |
| US12 Checklist fotográfico | 🔵 | Sin endpoint de almacenamiento de fotos. Pantalla queda local. |
| Pasarela de pago real (SP01) | 🔵 | `/Payments` y `/rentals/{id}/pay` registran el pago, sin pasarela real. |
| US04 Recuperar contraseña (forgot/reset) | ⛔ | El backend solo tiene `change-password` (con la clave actual), no `forgot/reset`. |
| Push remoto (FCM) | 🔵 | Solo notificación local simulada; falta backend de push. |

---

## 5. Configuración para correr

```bash
# Apuntar a tu backend (emulador Android → host):
flutter run --dart-define=WHEELSPE_API_URL=http://10.0.2.2:8080/api/v1

# Dispositivo físico en la misma red (reemplaza por la IP del PC):
flutter run --dart-define=WHEELSPE_API_URL=http://192.168.x.x:8080/api/v1

# Web/desktop (localhost funciona directo):
flutter run --dart-define=WHEELSPE_API_URL=http://localhost:8080/api/v1
```

> **Google Maps:** reemplazar `PLACEHOLDER_GOOGLE_MAPS_API_KEY` en `AndroidManifest.xml` por una
> clave real para que carguen los tiles del mapa.

---

## 6. Notas de implementación (por si los nombres de campos del backend difieren)

Los modelos hacen parseo **tolerante** (aceptan varios nombres de clave). Si el Swagger usa nombres
distintos a los asumidos, ajustar en:
- `vehicle_model.dart` (`bodyType`/`district`/`lat`/`lng`/`photos`).
- `reservation_model.dart` (`renterId`/`startDate`/`endDate`/`totalAmount`/`status`).
- `route_model.dart` (`seatsAvailable`/`onlyWomen`/`community`/`pricePerSeat`).
- `transaction_model.dart` (`amount`/`type`/`status`/`payerId`).
- `chat_models.dart`, `notification_model.dart` (claves de mensaje/notificación).

La fuente única de verdad del contrato es **Swagger** (`/swagger/index.html`).