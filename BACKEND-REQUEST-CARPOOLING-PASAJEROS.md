# Solicitud al Backend — Gestión de Pasajeros de Carpooling (US16)

> **De:** Equipo App Proveedor (Flutter)
> **Para:** Equipo Backend (C# / ASP.NET Core)
> **Relacionado:** `ESTADO-APP-PROVEEDOR-FLUTTER.md` fila #13 (🟡) · backlog backend **P9**
> **Fuente de verdad del contrato:** Swagger (`/swagger/index.html`)
> **Base URL:** `http://<host>:8080/api/v1`

---

## 1. Problema / Por qué se pide

Hoy una ruta de carpooling solo se puede **reservar** con `POST /adventure-routes/{id}/book`,
que **descuenta cupos directamente** y no deja registro gestionable del pasajero. El proveedor
(conductor) **no puede**:

- Ver **quién** pidió un asiento en su ruta.
- **Aceptar / rechazar** solicitudes (control de quién sube a su auto).
- **Quitar** a un pasajero ya confirmado.

Sin esto no se cumple **US16** (gestión de solicitudes) y la pantalla de pasajeros del
proveedor queda sin backend real. **No queremos inventar el contrato** desde el frontend:
este documento propone uno y pide que se confirme/ajuste y se publique en Swagger.

---

## 2. Objetivo funcional

Pasar de "reserva que descuenta cupo al instante" a un **flujo de solicitud con aprobación**:

```
Pasajero pide asiento  →  PENDING  →  (owner acepta)  →  CONFIRMED
                                   └─ (owner rechaza) →  REJECTED
CONFIRMED  →  (owner o pasajero quita) →  REMOVED / CANCELLED
```

**Regla de cupos:** el asiento se **reserva tentativamente** al pasar a `PENDING` y se
**confirma** en `CONFIRMED`. Si se rechaza/quita, el cupo se **libera**. (Si prefieren no
bloquear cupo en `PENDING`, ver §6 *Decisiones a confirmar*.)

---

## 3. Modelo de datos propuesto — `RoutePassenger` (solicitud de asiento)

| Campo | Tipo | Notas |
|-------|------|-------|
| `id` | string/guid | id de la **solicitud** (no del usuario) |
| `passengerId` | string/guid | id del usuario pasajero |
| `routeId` | string/guid | id de la ruta |
| `fullName` | string | nombre del pasajero |
| `avatarUrl` | string? | foto, opcional |
| `reputation` | number | rating del pasajero (0–5) |
| `verificationStatus` | string | `"VERIFIED"` / `"UNVERIFIED"` (KYC) |
| `status` | string | `PENDING` · `CONFIRMED` · `REJECTED` · `CANCELLED` |
| `seats` | int | nº de asientos solicitados (default 1) |
| `requestedAt` | string (UTC ISO-8601) | fecha de la solicitud |

> ⚠️ **Compatibilidad con el frontend actual.** El parser ya existente
> (`RoutePassenger.fromJson`) lee estas claves, así que **respetar exactamente** estos
> nombres evita cambios de frontend:
> `id` / `passengerId`, `fullName` (o `name`), `avatarUrl`, `reputation`,
> `verificationStatus == "VERIFIED"`, y `status` con `PENDING` / `CONFIRMED`
> (en mayúsculas; otros valores se tratan como `PENDING`).

---

## 4. Endpoints solicitados

Todos **sin JWT**, autorizando por `?ownerId=` (debe coincidir con el `ownerId` de la ruta;
si no, **403**).

### 4.1 Listar pasajeros de una ruta
```
GET /adventure-routes/{routeId}/passengers?ownerId={ownerId}
```
**200 OK**
```json
{
  "routeId": "r-123",
  "seatsTotal": 4,
  "seatsAvailable": 2,
  "passengers": [
    {
      "id": "req-1",
      "passengerId": "u-55",
      "fullName": "Ana Torres",
      "avatarUrl": "https://...",
      "reputation": 4.8,
      "verificationStatus": "VERIFIED",
      "status": "PENDING",
      "seats": 1,
      "requestedAt": "2026-06-30T14:05:00Z"
    }
  ]
}
```
> **Alternativa preferida (menos requests):** incluir el array `passengers` **dentro de**
> `GET /adventure-routes/{id}`. El frontend ya intenta leer `json['passengers']` en el
> detalle de la ruta, así que con eso bastaría y este endpoint sería opcional.

### 4.2 Aceptar una solicitud
```
POST /adventure-routes/{routeId}/passengers/{passengerId}/accept?ownerId={ownerId}
```
- Pasa la solicitud a `CONFIRMED` y **confirma el cupo**.
- **409** si ya no hay cupos (`no_seats_available`).
- **200 OK** → devuelve la solicitud actualizada (mismo objeto de §3).

### 4.3 Rechazar una solicitud
```
POST /adventure-routes/{routeId}/passengers/{passengerId}/reject?ownerId={ownerId}
```
- Pasa a `REJECTED` y **libera el cupo** tentativo.
- **200 OK** → solicitud actualizada.

### 4.4 Quitar un pasajero confirmado
```
DELETE /adventure-routes/{routeId}/passengers/{passengerId}?ownerId={ownerId}
```
- Pasa de `CONFIRMED` a `REMOVED/CANCELLED` y **libera el cupo**.
- **200 OK** o **204 No Content**.

### 4.5 (Cambio en booking del pasajero)
```
POST /adventure-routes/{routeId}/book
```
- **Cambio pedido:** que **cree la solicitud en `PENDING`** (en vez de descontar cupo y
  marcar `full` de inmediato). El descuento definitivo ocurre al aceptar (§4.2).
- Validaciones al pedir asiento:
  - Ruta en estado `active`/`scheduled` (no `in_progress`/`completed`/`cancelled`).
  - Hay cupo disponible.
  - Si `onlyWomen == true`, el pasajero debe ser mujer → si no, **403** `women_only_route`.
  - Si la ruta tiene `community`/filtro institucional, validar pertenencia → **403** `community_restricted`.
  - No permitir solicitud duplicada del mismo `passengerId` → **409** `already_requested`.

---

## 5. Reglas de negocio

1. **Estados de ruta** (recordatorio del contrato actual del frontend):
   `active` (=programada) · `in_progress` · `completed` · `cancelled`.
   Gestionar pasajeros **solo** si la ruta está en `active`.
2. **Cupos:** `seatsAvailable = seatsTotal − asientos CONFIRMED (− PENDING si bloquean cupo)`.
   Nunca permitir `seatsAvailable < 0`.
3. **Al completar/cancelar la ruta:** congelar la lista (no más aceptar/rechazar).
4. **Notificaciones** (vía `/Notifications`, que ya existe): notificar al pasajero cuando su
   solicitud es **aceptada** o **rechazada**; notificar al owner cuando llega una **nueva
   solicitud**.
5. **Concurrencia:** dos solicitudes que compiten por el último cupo → la segunda que se
   acepte debe recibir **409** `no_seats_available`.

---

## 6. Decisiones a confirmar por backend

- [ ] ¿El cupo se bloquea en `PENDING` o solo al `CONFIRMED`? (afecta `seatsAvailable`).
- [ ] ¿Se embebe `passengers[]` en `GET /adventure-routes/{id}` (preferido) o se usa el
      endpoint dedicado §4.1?
- [ ] Nombres finales de campos/estados (confirmar que coinciden con §3 para no romper el frontend).
- [ ] Códigos y `error codes` exactos para los 403/409 (que sean strings estables, ej.
      `women_only_route`, `no_seats_available`).
- [ ] ¿`reject`/`remove` son `POST` + `DELETE` como aquí, o prefieren un único
      `PATCH /passengers/{id}` con `{ "status": "..." }`?

---

## 7. Criterios de aceptación (Definition of Done)

- [ ] El owner ve la lista de solicitudes (`PENDING`) y confirmados (`CONFIRMED`) de su ruta.
- [ ] Aceptar mueve a `CONFIRMED` y descuenta cupo; el pasajero recibe notificación.
- [ ] Rechazar mueve a `REJECTED`, libera cupo y notifica.
- [ ] Quitar confirmado libera cupo.
- [ ] Validaciones `onlyWomen` / `community` / duplicado / sin cupo devuelven el código y
      `error code` correctos.
- [ ] Todo documentado en **Swagger** con los nombres de campo de §3.

---

## 8. Lo que el frontend ya tiene listo (no requiere trabajo backend)

Para que dimensionen el impacto: la UI del proveedor **ya está construida** y solo espera
estos endpoints. Hoy las llamadas de aprobar/quitar lanzan un error controlado
("el backend aún no lo soporta"). En cuanto el contrato exista, se conectan directo:

- Pantalla de pasajeros: `lib/features/routes/presentation/passengers_screen.dart`
- Modelo/parser: `lib/features/routes/data/route_model.dart` (`RoutePassenger`)
- Datasource (métodos `acceptPassenger` / `removePassenger` ya stubbeados):
  `lib/features/routes/data/routes_remote_datasource.dart`

---

*Cualquier ajuste al contrato, comentarlo aquí o en el ticket P9 antes de implementar.
La fuente de verdad final es el Swagger del backend.*
