# Estado de historias — MOVEO / WheelsPe

Consolidado verificado contra el código el **2026-07-05** (tras integrar el backend v2
desplegado en Railway en ambas apps).

Hay **dos apps frontend**:

- **App Renter** (arrendatario / pasajero): catálogo, alquiler, pago, tracking del viaje.
- **App Owner** (este repo, `wheelspe_provider`): flota, reservas recibidas, rutas de carpool como conductor, transacciones.

Leyenda: ✅ Hecho · ⚠️ Parcial (UI hecha, sin backend real o acción incompleta) · ❌ No hecho · — No aplica a esa app

## Sprint 3

| US | Historia | App responsable | Renter | Owner (este repo) | Nota |
|----|----------|-----------------|--------|-------------------|------|
| US55 | Gestionar estado de reservas recibidas como proveedor | Owner | — | ✅ | `ReservationDetailScreen`: confirmar, rechazar, registrar entrega y devolución contra la API (`lib/features/fleet/presentation/reservation_detail_screen.dart`) |
| US54 | Cancelar reserva de alquiler según políticas | Renter | ✅ | — | Botón "Cancelar reserva" con política (≥48h→100%, 24-48h→50%, <24h→0%) vía `PATCH /rentals/{id}` + reembolso automático server-side |
| US50 | Editar información y precio de vehículo publicado | Owner | — | ✅ | `EditVehicleScreen` hace `PUT /vehicles/{id}` con el precio nuevo |
| US05 | Acreditar propiedad de vehículo | Owner | — | ✅ | `AddVehicleScreen` tiene paso "Documentos de propiedad" (tarjeta frente/reverso + SOAT obligatorios) y `VehicleDetailScreen` muestra la acreditación con opción de completar/reemplazar documentos (copia local + envío al backend). Pendiente backend: almacenar/validar los archivos |
| US02 | Verificar identidad mediante KYC | Ambas | ✅ | ✅ | Renter: `KycScreen`. Owner: `kyc_screen.dart` + `kyc_status_screen.dart` (backend en modo demo) |
| US04 | Recuperar contraseña olvidada | Ambas | ✅ | ✅ | `ForgotPasswordScreen` conectada a `auth/forgot-password` en ambas |
| US06 | Monitorear ruta en tiempo real vía GPS | Renter | ✅ | — | Marcador en movimiento, cámara que sigue, progreso y ETA en `TripTrackingScreen` (fuente GPS simulada: backend aún sin endpoint de tracking) |
| US20 | Confirmar llegada al destino final | Renter | ✅ | — | Diálogo "He llegado" → `PATCH /rentals/{id}` status=completed + completedAt → calificación |
| US25 | Emitir comprobantes y contratos digitales | Ambas | ✅ | ✅ | Ambas usan `GET /rentals/{id}/invoice` (numeración oficial `WPE-{año}-{id}`); Owner además genera el PDF con ese correlativo |
| US26 | Procesar reembolsos automáticos | Ambas | ✅ | ✅ | `POST /payments/{id}/refund` server-side con política. Renter: automático al cancelar. Owner: desde el detalle de transacción |
| US33 | Ejecutar reembolsos automatizados | Ambas | ✅ | ✅ | Mismo flujo de US26; el backend aplica la política, marca refunded y notifica a ambas partes |
| SP01 | Investigar integraciones de pasarelas de pago | Renter | ✅ | — | Materializado en renter: tarjeta (Stripe demo) y Yape (`POST /rentals/{id}/pay`) |
| SP02 | Evaluar soluciones de GPS y mapas | Renter | ✅ | — | Materializado en renter: Google Maps (catálogo "más cercano", tracking) |

## Sprint 4 / TF

| US | Historia | App responsable | Renter | Owner (este repo) | Nota |
|----|----------|-----------------|--------|-------------------|------|
| US32 | Liquidar cuota de carpooling digitalmente | Owner | — | ✅ | Wallet real (`GET /wallet/{id}`) + retiros (`POST /withdrawals` con método y destino) |
| US23 | Pagar cuota de asiento compartido de forma digital | Renter | ⚠️ | — | El book ya crea solicitud PENDING con `passengerId` (modelo correcto de aforo); el cobro de la cuota al confirmarse sigue pendiente |
| US08 | Activar alerta de emergencia durante viaje | Ambas | ⚠️ | ✅ | Owner: botón SOS en ruta en curso (`RouteDetailScreen`) → crea ticket de emergencia de alta prioridad en `/support-tickets` con ubicación aproximada. Renter: botón sin acción todavía |
| US12 | Registrar checklist fotográfico del vehículo | Owner | — | ✅ | `ChecklistScreen` PRE/POST sube las fotos a `POST /rentals/{id}/inspections` (multipart) con copia local de respaldo |
| US21 | Vincular métodos de pago electrónicos | Ambas | ⚠️ | ✅ | Owner: `PayoutMethodsScreen` guarda métodos de cobro (Yape/Plin/banco) reutilizables en el retiro. Renter: lista de pago aún mock |
| US09 | Validar inicio de viaje con código PIN | Ambas | ❌ | ✅ | Owner pide el PIN de 4 dígitos al registrar la entrega (`ReservationDetailScreen`); `TripPin` lo deriva del id del alquiler (misma fórmula en ambas apps). Pendiente: mostrarlo en la app Renter |
| US11 | Filtrar rutas por preferencia de género | Ambas | ✅ | ✅ | Owner publica rutas "Solo mujeres"; Renter tiene el filtro en la búsqueda, género en el registro y validación al reservar (bloqueo/confirmación). Pendiente backend: campo género en User para validar server-side |
| US16 | Aprobar solicitudes de pasajeros y controlar aforo | Owner | — | ✅ | `PassengersScreen`: aceptar/rechazar solicitudes vía `/adventure-routes/{id}/passengers/{pid}/accept|reject`, quitar confirmados |
| US51 | Retirar temporalmente vehículo del catálogo público | Owner | — | ✅ | `VehicleDetailScreen._toggleStatus`: marca disponible / no disponible vía API |
| US30 | Configurar umbrales de reputación mínimos | Owner | — | ✅ | `ReputationThresholdScreen` (perfil): slider 0–5. Al aceptar un pasajero por debajo del umbral, `PassengerTile` pide confirmación manual (US16 + US30) |
| US10 | Gestionar contactos de confianza | Renter | ⚠️ | — | UI en `SafetyScreen` pero solo local, sin backend |
| US17 | Automatizar rutas recurrentes semanales | Owner | — | ❌ | `AddRouteScreen` crea rutas puntuales, sin recurrencia |
| US27 | Aplicar cupones y beneficios promocionales | Ambas | ❌ | ✅ | Owner: `ApplyCouponScreen` valida un cupón (código, vigencia, reputación) y calcula el descuento con el motor puro `PromoOffer.apply` — la misma lógica que usaría el Renter al pagar. Pendiente backend: endpoint de promociones |
| US29 | Recompensar usuarios con alta reputación | Ambas | ⚠️ | ✅ | Owner: las promociones admiten `minReputation` — un cupón con reputación mínima > 0 es una recompensa que solo aplica a clientes de alta reputación (`PromoForm` + motor lo valida). Renter: `RewardsScreen` sigue estática |
| US34 | Gestionar ofertas promocionales temporales | Owner | — | ✅ | `PromotionsScreen` (perfil): crear cupones con % o monto fijo, vigencia (inicio/fin), activar/desactivar y eliminar. Estado calculado (vigente/programada/expirada). Persistencia local; pendiente endpoint de backend |
| US36 | Reconocer comportamiento positivo con distintivos | Ambas | ✅ | ✅ | El backend otorga badges server-side (`stats.badges`: VERIFIED, PUNCTUAL, TOP_RENTER, FIVE_STARS) y ambas apps los muestran, con cálculo local de respaldo |
| US38 | Filtrar solicitudes por umbral de confianza | Owner | — | ❌ | En `PassengersScreen` se ve el rating del pasajero pero no hay filtro por umbral |
| US07 | Rastrear viaje activo para seguridad de pasajero | Renter | ⚠️ | — | Mismo `TripTrackingScreen` de US06 con datos demo |
| US40 | Monitorear anomalías financieras (Admin) | Ninguna (admin) | — | — | No existe app/rol admin |
| US41 | Mediar disputas de reputación (Admin) | Ninguna (admin) | — | — | No existe app/rol admin |
| US45 | Solicitar baja voluntaria y eliminación de datos | Ambas | ❌ | ✅ | Owner: `DeleteAccountScreen` (perfil) con confirmación escrita → `DELETE /users/{id}` inmediato (sin aprobación de admin) + cierre de sesión |
| US46 | Enviar solicitud de alianza corporativa | Ambas | ❌ | ❌ | |
| SP03 | Analizar opciones de KYC mediante IA | Backend | ❌ | ❌ | El KYC actual es subida manual de fotos |
| SP04 | Investigar arquitectura de microservicios y contenedorización | Backend | ❌ | ❌ | No corresponde a los repos frontend |

## Extras implementados en la app Owner (no figuraban en el backlog original)

- **Calificar arrendatario** al completar el alquiler (`POST /user-reviews` type `owner_to_renter` desde `ReservationDetailScreen`) — cierra el ciclo de reputación: alimenta el `renter.reputation` que se ve en las próximas solicitudes.
- **Chat 1-a-1** con arrendatarios (`/messages`, `ConversationsScreen` + `ChatScreen`).
- **Notificaciones** conectadas al backend (`/Notifications`, marcar leídas).
- **Reporte de incidencias** (`ReportIncidentScreen` → `/support-tickets`).
- **Cambiar contraseña** (`ChangePasswordScreen` → `POST /auth/change-password`) desde el perfil.
- **Transacciones e ingresos** (`TransactionsScreen`, detalle, comisión de plataforma, filtros).

## Resumen de cambios respecto a la tabla anterior (verificada solo contra la app renter)

| US | Antes | Ahora (consolidado) | Motivo |
|----|-------|---------------------|--------|
| US55 | ❌ | ✅ | Vive en la app owner y está completa |
| US50 | ❌ | ✅ | Edición de precio real en owner |
| US51 | ❌ | ✅ | Toggle de disponibilidad en owner |
| US16 | ❌ | ✅ | Aceptar/rechazar pasajeros en owner |
| US25 | ❌ | ✅ | PDF de comprobante generado en owner |
| US26/US33 | ❌ | ⚠️ | Reembolso manual real vía API en owner |
| US12 | ❌ | ⚠️ | Checklist con cámara en owner, solo local |
| US36 | ❌ | ⚠️ | Badges calculados en cliente en owner |
| US05 | ❌ | ✅ | Implementado el 2026-07-03: paso de documentos de propiedad en `AddVehicleScreen` |
| US11 | ❌ | ⚠️ | Owner ya publica rutas "Solo mujeres"; falta el filtro en renter |
