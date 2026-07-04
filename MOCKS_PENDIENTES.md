# Mocks y funcionalidad local — pendientes de backend

Inventario de todo lo que en la app Owner (`wheelspe_provider`) funciona en mock, solo localmente o con aproximaciones del lado cliente. Verificado contra el código el **2026-07-03**. Sirve para decidir qué mover al backend.

Prioridad sugerida: 🔴 bloquea el flujo real · 🟡 funciona pero incompleto · 🟢 aceptable para demo

## 🔴 Archivos que nunca llegan al backend

### 1. Fotos de vehículos
- **Dónde:** [add_vehicle_screen.dart](lib/features/fleet/presentation/add_vehicle_screen.dart) → `VehicleModel.toCreateJson` campo `images`
- **Qué pasa hoy:** se envían las **rutas locales del dispositivo** (`/data/user/0/...jpg`) como strings en el `POST /vehicles`. El vehículo se crea, pero ninguna otra app/dispositivo puede ver las fotos.
- **Qué necesita el backend:** endpoint de subida multipart (o URLs firmadas a un storage tipo S3/Cloudinary) y guardar las URLs resultantes en `images`.

### 2. Documentos de propiedad (US05)
- **Dónde:** paso "Documentos de propiedad" en [add_vehicle_screen.dart](lib/features/fleet/presentation/add_vehicle_screen.dart) → campo `documents` de `toCreateJson` (claves `propertyCardFront`, `propertyCardBack`, `soat`)
- **Qué pasa hoy:** la UI exige tarjeta de propiedad (ambas caras) + SOAT y los envía en el payload, pero como rutas locales. El backend no los persiste ni valida.
- **Qué necesita el backend:** aceptar los 3 archivos (multipart, como ya hace `POST /auth/kyc`), guardarlos asociados al vehículo y exponer un estado de acreditación (`pending/approved/rejected`).

### 3. Checklist fotográfico pre/post alquiler (US12)
- **Dónde:** [checklist_screen.dart](lib/features/fleet/presentation/checklist_screen.dart) → `LocalStorage.saveChecklist`
- **Qué pasa hoy:** las 10 fotos de inspección se guardan **solo en `shared_preferences`** del teléfono del owner. Si pierde el teléfono, pierde la evidencia.
- **Qué necesita el backend:** endpoint tipo `POST /rentals/{id}/inspections` (tipo PRE/POST + fotos multipart) para que la evidencia sea oponible en disputas.

## 🔴 Seguridad / sesión

### 4. Backend sin JWT
- **Dónde:** [api_constants.dart](lib/core/constants/api_constants.dart) (documentado en el header del archivo)
- **Qué pasa hoy:** la "sesión" es guardar el `userId` y mandarlo como query param (`?userId=`, `ownerId=`...). Cualquiera que conozca un id puede operar como ese usuario.
- **Qué necesita el backend:** emitir JWT en login y validar `Authorization: Bearer` en todos los endpoints. El `DioClient` ya está centralizado, agregar el header es trivial.

### 5. Bypass de KYC en modo prueba
- **Dónde:** [kyc_screen.dart](lib/features/auth/presentation/kyc_screen.dart) (`_skipForTesting`), flag `kyc_dev_bypass` en [local_storage.dart](lib/core/storage/local_storage.dart), consultado en splash y login
- **Qué pasa hoy:** el botón "Saltar verificación (modo prueba)" deja entrar al home sin KYC aprobado, con un flag local persistente.
- **Qué hacer:** eliminarlo (o esconderlo tras `kDebugMode`) antes de producción. Además el KYC del backend está en modo demo (aprueba sin revisión real).

### 6. Logout simbólico
- **Dónde:** [auth_remote_datasource.dart:87-93](lib/features/auth/data/auth_remote_datasource.dart#L87-L93)
- **Qué pasa hoy:** `POST /auth/logout` se ignora si falla; la sesión solo se borra del secure storage local. Sin JWT no hay nada que invalidar server-side.
- **Qué necesita el backend:** invalidación real de tokens cuando exista JWT (va junto con el punto 4).

## 🟡 Acciones que simulan el resultado

### 7. Retiro de fondos (wallet)
- **Dónde:** [profile_screen.dart:383-410](lib/features/profile/presentation/profile_screen.dart#L383-L410) (`_showWithdrawSheet`)
- **Qué pasa hoy:** el sheet Yape/Plin/Tarjeta solo muestra el snackbar "Solicitud de retiro enviada". **No hay ninguna llamada al backend.** Es el mock más visible de la app.
- **Qué necesita el backend:** endpoint tipo `POST /withdrawals` (monto, método, destino) + estados de la solicitud.

### 8. Balance y resumen financiero calculados en el cliente
- **Dónde:** `walletSummaryProvider` en [transactions_providers.dart:52-84](lib/features/transactions/presentation/transactions_providers.dart#L52-L84)
- **Qué pasa hoy:** balance, semana, mes y el gráfico de 7 días se calculan en la app sumando los pagos de `GET /Payments/recipient/{id}`. Los datos son reales, pero no descuenta retiros (porque no existen) y el "balance" es en realidad "ingresos acumulados netos".
- **Qué necesita el backend:** un `GET /wallet/{userId}` con balance real (ingresos − retiros − retenciones).

### 9. Reembolsos sin políticas (US26/US33)
- **Dónde:** [transactions_remote_datasource.dart:40-50](lib/features/transactions/data/transactions_remote_datasource.dart#L40-L50)
- **Qué pasa hoy:** "Solicitar reembolso" hace `PATCH /Payments/{id} {status:"refunded"}`. Es una llamada real, pero solo cambia el estado: no valida políticas de cancelación, no mueve dinero, no es automático.
- **Qué necesita el backend:** motor de reembolsos (verificar política según antelación de la cancelación, ejecutar contra la pasarela, notificar).

### 10. Comprobantes PDF generados en el dispositivo (US25)
- **Dónde:** [receipt_service.dart](lib/core/services/receipt_service.dart)
- **Qué pasa hoy:** el comprobante se arma con `pdf`/`printing` en el teléfono con numeración inventada (`WPE-{id del pago}`). No hay registro server-side ni validez tributaria.
- **Qué necesita el backend:** `GET /rentals/{id}/invoice` (o integración con facturación electrónica SUNAT si se busca comprobante real).

### 11. Badges calculados en el cliente (US36)
- **Dónde:** `ProviderBadges.fromUser` en [profile_providers.dart:19-45](lib/features/profile/presentation/profile_providers.dart#L19-L45)
- **Qué pasa hoy:** los 4 badges se derivan del perfil en la app. "Puntual" es una **aproximación** (reputación ≥ 4.5 + actividad) porque el backend no expone tasa de puntualidad.
- **Qué necesita el backend:** otorgar badges server-side (o al menos exponer las métricas reales: tasa de entregas a tiempo, etc.).

## 🟢 Aceptables para demo, mejorables

### 12. Notificaciones locales en vez de push
- **Dónde:** [notification_service.dart](lib/core/services/notification_service.dart)
- **Qué pasa hoy:** `flutter_local_notifications` simula el push de "nueva reserva"; solo dispara si la app está abierta y consulta datos.
- **Qué necesita:** FCM real + que el backend envíe el push al crearse la reserva.

### 13. Transiciones de estado de ruta sin endpoint dedicado
- **Dónde:** [routes_remote_datasource.dart:54](lib/features/routes/data/routes_remote_datasource.dart#L54)
- **Qué pasa hoy:** iniciar/finalizar/cancelar ruta se hace con un update genérico porque el backend no expone transiciones (`/start`, `/complete`). Funciona, pero sin validación de transiciones ilegales.

### 14. Datos del vehículo con defaults inventados
- **Dónde:** `VehicleModel.toCreateJson` en [vehicle_model.dart](lib/features/fleet/data/vehicle_model.dart)
- **Qué pasa hoy:** el formulario no captura color/transmisión/combustible/asientos, así que se envían defaults ("No especificado", manual, gasolina, 5). Decidir: agregar campos al formulario o hacerlos opcionales en el backend.

## Resumen para el backend

| # | Ítem | Endpoint sugerido | Prioridad |
|---|------|-------------------|-----------|
| 1 | Subida de fotos de vehículo | `POST /vehicles/{id}/images` (multipart) | 🔴 |
| 2 | Documentos de propiedad (US05) | `POST /vehicles/{id}/documents` (multipart) + estado de acreditación | 🔴 |
| 3 | Checklist de inspección (US12) | `POST /rentals/{id}/inspections` | 🔴 |
| 4 | Autenticación JWT | login devuelve token; middleware en todo | 🔴 |
| 5 | Quitar bypass KYC + KYC real | — (cambio de app y de backend) | 🔴 |
| 7 | Retiros de wallet | `POST /withdrawals` | 🟡 |
| 8 | Balance real | `GET /wallet/{userId}` | 🟡 |
| 9 | Motor de reembolsos (US26/33) | `POST /Payments/{id}/refund` con políticas | 🟡 |
| 10 | Comprobantes server-side (US25) | `GET /rentals/{id}/invoice` | 🟡 |
| 11 | Badges/reputación server-side (US36) | métricas en `GET /users/{id}` | 🟡 |
| 12 | Push real (FCM) | backend publica a FCM al crear reserva | 🟢 |
| 13 | Transiciones de ruta | `POST /adventure-routes/{id}/start\|complete` | 🟢 |
