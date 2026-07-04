# Estado de historias — MOVEO / WheelsPe

Consolidado verificado contra el código el **2026-07-03**.

Hay **dos apps frontend**:

- **App Renter** (arrendatario / pasajero): catálogo, alquiler, pago, tracking del viaje.
- **App Owner** (este repo, `wheelspe_provider`): flota, reservas recibidas, rutas de carpool como conductor, transacciones.

Leyenda: ✅ Hecho · ⚠️ Parcial (UI hecha, sin backend real o acción incompleta) · ❌ No hecho · — No aplica a esa app

## Sprint 3

| US | Historia | App responsable | Renter | Owner (este repo) | Nota |
|----|----------|-----------------|--------|-------------------|------|
| US55 | Gestionar estado de reservas recibidas como proveedor | Owner | — | ✅ | `ReservationDetailScreen`: confirmar, rechazar, registrar entrega y devolución contra la API (`lib/features/fleet/presentation/reservation_detail_screen.dart`) |
| US54 | Cancelar reserva de alquiler según políticas | Renter | ❌ | — | Sin botón ni llamada de cancelación en la app renter |
| US50 | Editar información y precio de vehículo publicado | Owner | — | ✅ | `EditVehicleScreen` hace `PUT /vehicles/{id}` con el precio nuevo |
| US05 | Acreditar propiedad de vehículo | Owner | — | ✅ | `AddVehicleScreen` tiene paso "Documentos de propiedad": tarjeta de propiedad (frente y reverso) + SOAT obligatorios, enviados en `documents` del `POST /vehicles`. Pendiente backend: almacenar/validar los archivos |
| US02 | Verificar identidad mediante KYC | Ambas | ✅ | ✅ | Renter: `KycScreen`. Owner: `kyc_screen.dart` + `kyc_status_screen.dart` (backend en modo demo) |
| US04 | Recuperar contraseña olvidada | Ambas | ✅ | ✅ | `ForgotPasswordScreen` conectada a `auth/forgot-password` en ambas |
| US06 | Monitorear ruta en tiempo real vía GPS | Renter | ⚠️ | — | `TripTrackingScreen` con Google Maps funciona, pero con puntos demo locales (backend sin tracking) |
| US20 | Confirmar llegada al destino final | Renter | ⚠️ | — | Botón lleva a calificación pero no registra la llegada en backend |
| US25 | Emitir comprobantes y contratos digitales | Owner | — | ✅ | `ReceiptService` genera el comprobante PDF en el dispositivo y abre compartir/imprimir (backend sin `/invoices`) |
| US26 | Procesar reembolsos automáticos | Owner | — | ⚠️ | "Solicitar reembolso" en `TransactionDetailScreen` hace `PATCH /Payments/{id}` real, pero es acción manual del proveedor, no automática |
| US33 | Ejecutar reembolsos automatizados | Owner | — | ⚠️ | Mismo flujo que US26; falta la parte "automatizada" (sería lógica de backend) |
| SP01 | Investigar integraciones de pasarelas de pago | Renter | ✅ | — | Materializado en renter: tarjeta (Stripe demo) y Yape (`POST /rentals/{id}/pay`) |
| SP02 | Evaluar soluciones de GPS y mapas | Renter | ✅ | — | Materializado en renter: Google Maps (catálogo "más cercano", tracking) |

## Sprint 4 / TF

| US | Historia | App responsable | Renter | Owner (este repo) | Nota |
|----|----------|-----------------|--------|-------------------|------|
| US32 | Liquidar cuota de carpooling digitalmente | Owner | — | ❌ | Solo se ve el resumen de ingresos por ruta; no hay acción de liquidación |
| US23 | Pagar cuota de asiento compartido de forma digital | Renter | ⚠️ | — | "Pagar con Yape" en `CarpoolConfirmScreen` solo reserva asientos, no procesa pago real |
| US08 | Activar alerta de emergencia durante viaje | Renter | ⚠️ | — | Botón SOS existe pero sin acción (`onClick` vacío) |
| US12 | Registrar checklist fotográfico del vehículo | Owner | — | ⚠️ | `ChecklistScreen` PRE/POST con 10 puntos de inspección y cámara; las fotos se guardan solo localmente, no se suben al backend |
| US21 | Vincular métodos de pago electrónicos | Renter | ⚠️ | — | `PaymentMethodsScreen` existe pero la lista es mock |
| US09 | Validar inicio de viaje con código PIN | Ambas | ❌ | ❌ | Sin rastro de PIN en ninguna de las dos |
| US11 | Filtrar rutas por preferencia de género | Ambas | ❌ | ⚠️ | Owner ya publica rutas con "Solo mujeres" (`onlyWomen` en `AddRouteScreen`) y lo muestra en el detalle; falta el filtro al buscar rutas en la app renter |
| US16 | Aprobar solicitudes de pasajeros y controlar aforo | Owner | — | ✅ | `PassengersScreen`: aceptar/rechazar solicitudes vía `/adventure-routes/{id}/passengers/{pid}/accept|reject`, quitar confirmados |
| US51 | Retirar temporalmente vehículo del catálogo público | Owner | — | ✅ | `VehicleDetailScreen._toggleStatus`: marca disponible / no disponible vía API |
| US30 | Configurar umbrales de reputación mínimos | Owner | — | ❌ | |
| US10 | Gestionar contactos de confianza | Renter | ⚠️ | — | UI en `SafetyScreen` pero solo local, sin backend |
| US17 | Automatizar rutas recurrentes semanales | Owner | — | ❌ | `AddRouteScreen` crea rutas puntuales, sin recurrencia |
| US27 | Aplicar cupones y beneficios promocionales | Renter | ❌ | ❌ | |
| US29 | Recompensar usuarios con alta reputación | Renter | ⚠️ | — | `RewardsScreen` es UI estática sin backend |
| US34 | Gestionar ofertas promocionales temporales | Owner | — | ❌ | |
| US36 | Reconocer comportamiento positivo con distintivos | Owner | — | ⚠️ | `BadgesScreen` muestra badges calculados en el cliente desde datos reales del perfil (verificado, reputación, alquileres completados); el backend no los otorga |
| US38 | Filtrar solicitudes por umbral de confianza | Owner | — | ❌ | En `PassengersScreen` se ve el rating del pasajero pero no hay filtro por umbral |
| US07 | Rastrear viaje activo para seguridad de pasajero | Renter | ⚠️ | — | Mismo `TripTrackingScreen` de US06 con datos demo |
| US40 | Monitorear anomalías financieras (Admin) | Ninguna (admin) | — | — | No existe app/rol admin |
| US41 | Mediar disputas de reputación (Admin) | Ninguna (admin) | — | — | No existe app/rol admin |
| US45 | Solicitar baja voluntaria y eliminación de datos | Ambas | ❌ | ❌ | Sin opción de eliminar cuenta en ninguna |
| US46 | Enviar solicitud de alianza corporativa | Ambas | ❌ | ❌ | |
| SP03 | Analizar opciones de KYC mediante IA | Backend | ❌ | ❌ | El KYC actual es subida manual de fotos |
| SP04 | Investigar arquitectura de microservicios y contenedorización | Backend | ❌ | ❌ | No corresponde a los repos frontend |

## Extras implementados en la app Owner (no figuraban en el backlog original)

- **Chat 1-a-1** con arrendatarios (`/messages`, `ConversationsScreen` + `ChatScreen`).
- **Notificaciones** conectadas al backend (`/Notifications`, marcar leídas).
- **Reporte de incidencias** (`ReportIncidentScreen` → `/support-tickets`).
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
