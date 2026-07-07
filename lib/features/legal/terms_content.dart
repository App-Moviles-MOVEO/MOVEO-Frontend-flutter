/// Contenido de los Términos y Condiciones de WheelsPe / MOVEO.
///
/// Documento en español (aplica a Perú) compartido conceptualmente con la app
/// Renter (Kotlin). Se mantiene como datos estructurados para renderizarlo con
/// el estilo de la app en [TermsScreen].
///
/// AVISO: borrador base con fines de demo académica; no constituye asesoría
/// legal. Antes de operar con usuarios reales debe revisarlo un abogado.
library;

/// Fecha de última actualización mostrada en el encabezado.
const String termsLastUpdated = '7 de julio de 2026';

const String termsVersion = 'v1.0';

/// Una sección del documento: título y párrafos. Un párrafo que empieza con
/// '• ' se renderiza como viñeta.
class TermsSection {
  final String title;
  final List<String> paragraphs;

  const TermsSection(this.title, this.paragraphs);
}

/// Texto introductorio (antes del índice de secciones).
const String termsIntro =
    'Estos Términos y Condiciones ("T&C") regulan el acceso y uso de la '
    'plataforma WheelsPe / MOVEO ("la Plataforma"), tanto en su aplicación '
    'para Proveedores como en la aplicación para Pasajeros, disponibles para '
    'dispositivos Android e iOS. Lee este documento con atención: al crear una '
    'cuenta o usar la Plataforma declaras haberlo leído y aceptado.';

const String termsDisclaimer =
    'AVISO: Este documento es un borrador base con fines de prueba/demo '
    'académica. No constituye asesoría legal. El transporte entre particulares '
    '(carpooling) se encuentra en una zona regulatoria en desarrollo en el '
    'Perú; antes de usarse con usuarios reales o procesar pagos debe ser '
    'revisado y adaptado por un abogado colegiado.';

const List<TermsSection> termsSections = [
  TermsSection('1. Objeto y Aceptación', [
    'WheelsPe (en adelante, "la Plataforma") es una aplicación tecnológica que '
        'actúa como intermediaria entre Usuarios que ofrecen vehículos en '
        'alquiler o viajes compartidos ("Proveedores") y Usuarios que buscan '
        'alquilar un vehículo o compartir un viaje ("Pasajeros"). La Plataforma '
        'no es propietaria de los vehículos, no presta servicios de transporte '
        'y no tiene la calidad de transportista, conforme al Código Civil y a '
        'la Ley N.° 27181, Ley General de Transporte y Tránsito Terrestre.',
    'El uso de la Plataforma implica la aceptación plena de estos T&C y de la '
        'Política de Privacidad. Si el Usuario no está de acuerdo, debe '
        'abstenerse de usar la aplicación.',
  ]),
  TermsSection('2. Definiciones', [
    '• Plataforma: aplicación móvil y/o web WheelsPe / MOVEO, incluyendo el '
        'cliente para Pasajeros y el aplicativo para Proveedores.',
    '• Proveedor: persona natural que registra su vehículo para alquiler o para '
        'compartir un trayecto (carpooling) a cambio de una contraprestación.',
    '• Pasajero: persona natural que solicita el alquiler de un vehículo o un '
        'cupo en un viaje compartido.',
    '• Servicio: la intermediación tecnológica que conecta a Proveedores y '
        'Pasajeros, sin incluir el transporte en sí mismo.',
    '• Viaje compartido / Carpooling: modalidad en la que un Proveedor comparte '
        'un trayecto que ya iba a realizar, cobrando una compensación por '
        'gastos compartidos (combustible, peaje, desgaste), no un servicio '
        'remunerado de transporte público.',
    '• Cuenta: registro personal e intransferible del Usuario en la Plataforma.',
  ]),
  TermsSection('3. Registro y Elegibilidad', [
    '3.1 Requisitos generales:',
    '• Ser mayor de 18 años y tener capacidad legal para contratar.',
    '• Proporcionar datos veraces: nombre completo, DNI, teléfono y correo '
        'electrónico.',
    '• Aceptar la verificación de identidad mediante los mecanismos que la '
        'Plataforma disponga.',
    '3.2 Requisitos adicionales para Proveedores:',
    '• Contar con licencia de conducir vigente y categoría acorde al vehículo '
        'ofrecido.',
    '• El vehículo debe contar con SOAT vigente y revisión técnica vigente '
        '(cuando corresponda por antigüedad, conforme al Reglamento Nacional de '
        'Vehículos).',
    '• Ser propietario del vehículo o contar con autorización expresa y '
        'documentada del propietario.',
    '• Declarar bajo responsabilidad que el vehículo no realiza actividad de '
        'transporte público remunerado no autorizado.',
    'La Cuenta es personal e intransferible. El Usuario es responsable de la '
        'confidencialidad de sus credenciales y de toda actividad realizada '
        'desde su Cuenta.',
  ]),
  TermsSection(
      '4. Naturaleza del Servicio y Deslinde de Responsabilidad como '
      'Transportista', [
    'La Plataforma únicamente pone a disposición una herramienta tecnológica de '
        'intermediación. El contrato de alquiler o el acuerdo de viaje '
        'compartido se celebra directamente entre el Proveedor y el Pasajero. '
        'WheelsPe no participa como parte de dicho contrato, no garantiza la '
        'idoneidad del vehículo ni la conducta del Proveedor o Pasajero, sin '
        'perjuicio de los mecanismos de verificación y calificación que ofrezca.',
    'En el caso de viajes compartidos (carpooling), el Usuario reconoce que la '
        'contraprestación pagada corresponde a un reparto de gastos del '
        'trayecto y no a una tarifa de transporte público, por lo que dicha '
        'modalidad no sustituye ni compite con los servicios de taxi o '
        'transporte regulado por el Ministerio de Transportes y Comunicaciones '
        '(MTC) o las municipalidades.',
  ]),
  TermsSection('5. Verificación de Identidad (KYC)', [
    'Para habilitar ciertas funciones (publicar vehículos, ofrecer o reservar '
        'viajes, retirar fondos), la Plataforma podrá exigir un proceso de '
        'verificación de identidad (KYC) que incluye la carga de documento de '
        'identidad y, cuando corresponda, una fotografía de rostro (selfie).',
    'El Usuario garantiza que los documentos e imágenes que carga son '
        'auténticos y le pertenecen. La suplantación de identidad o el uso de '
        'documentos falsos es causal de suspensión inmediata y podrá ser '
        'denunciada a las autoridades competentes.',
    'La verificación puede tardar o ser rechazada si la información no es '
        'legible o consistente. La Plataforma podrá almacenar el resultado del '
        'proceso para fines de seguridad y prevención de fraude.',
  ]),
  TermsSection('6. Obligaciones del Proveedor', [
    '• Mantener la documentación del vehículo y su licencia de conducir '
        'vigentes durante todo el servicio.',
    '• Entregar el vehículo en condiciones óptimas de funcionamiento y '
        'seguridad.',
    '• Cumplir las normas de tránsito vigentes (Reglamento Nacional de '
        'Tránsito).',
    '• No discriminar a los Pasajeros por motivos de raza, género, religión, '
        'orientación sexual, discapacidad u origen, conforme a la Constitución '
        'Política del Perú y la Ley N.° 27049.',
    '• Informar de forma veraz el estado del vehículo, la ruta y las '
        'condiciones del viaje o alquiler.',
    '• Registrar la información y las fotografías de inspección que la '
        'Plataforma solicite para respaldar el estado del vehículo.',
  ]),
  TermsSection('7. Obligaciones del Pasajero / Arrendatario', [
    '• Usar el vehículo conforme a su destino y a las condiciones pactadas con '
        'el Proveedor.',
    '• Responder por los daños causados al vehículo por uso indebido o '
        'negligente, en caso de alquiler.',
    '• Mantener un comportamiento respetuoso durante el viaje compartido.',
    '• Presentar el código PIN de inicio cuando corresponda y no compartirlo '
        'con terceros ajenos a la operación.',
    '• No usar la Plataforma para fines distintos a los previstos en estos T&C.',
  ]),
  TermsSection('8. Alquiler de Vehículos: Entrega, Inspección y Devolución', [
    'El Proveedor y el Pasajero acuerdan las fechas, el punto de entrega y las '
        'condiciones de uso del vehículo dentro de la Plataforma.',
    'Inspección: la entrega y la devolución pueden registrarse mediante una '
        'inspección con evidencia fotográfica del estado del vehículo. Esta '
        'evidencia sirve como respaldo ante eventuales reclamos por daños.',
    'Código PIN de inicio: para validar el inicio del viaje/entrega, la '
        'Plataforma puede generar un PIN que el Pasajero muestra y el Proveedor '
        'verifica. Su finalidad es confirmar que la entrega ocurre entre las '
        'partes correctas.',
    'La devolución debe realizarse en el estado y plazo acordados. Los daños, '
        'faltantes o infracciones de tránsito generadas durante el alquiler son '
        'responsabilidad del Pasajero, conforme al acuerdo entre las partes.',
  ]),
  TermsSection('9. Viajes Compartidos (Carpooling)', [
    'El carpooling permite a un Proveedor compartir un trayecto que ya iba a '
        'realizar y repartir sus gastos entre los Pasajeros que reserven un '
        'cupo. La contribución solicitada no constituye una tarifa de '
        'transporte público.',
    'Cupos: la disponibilidad de asientos se descuenta con cada reserva '
        'confirmada. Un Proveedor no puede ofrecer más cupos que la capacidad '
        'real y segura del vehículo.',
    'Comunidad por correo: algunas rutas pueden segmentarse por el dominio del '
        'correo con el que el Usuario se registró (por ejemplo, una comunidad '
        'institucional). Un Usuario solo verá y participará en las rutas de su '
        'propia comunidad según dicho criterio.',
    'Rutas exclusivas para mujeres: para mayor seguridad, un Proveedor puede '
        'publicar rutas solo para pasajeras. La Plataforma podrá validar el '
        'género declarado por el Usuario para el acceso a estas rutas. La '
        'declaración falsa de datos para acceder a ellas es causal de sanción.',
  ]),
  TermsSection('10. Tarifas, Pagos y Comisiones', [
    'Las tarifas de alquiler o la contribución de gastos en viajes compartidos '
        'son definidas por el Proveedor dentro de los rangos que la Plataforma '
        'establezca, o libremente cuando la Plataforma no imponga rangos.',
    'WheelsPe podrá cobrar una comisión por el uso de la Plataforma, la cual '
        'será informada de forma clara antes de la confirmación de cada '
        'operación, conforme al deber de información del Código de Protección y '
        'Defensa del Consumidor (Ley N.° 29571).',
    'Los pagos se procesan a través de las pasarelas de pago integradas. '
        'WheelsPe no almacena datos completos de tarjetas de crédito o débito; '
        'dicho procesamiento se rige por los estándares de seguridad del '
        'proveedor de pagos correspondiente (PCI-DSS).',
  ]),
  TermsSection('11. Billetera, Retiros y Liquidaciones', [
    'Los ingresos del Proveedor se acreditan en una billetera dentro de la '
        'Plataforma. El Proveedor puede solicitar el retiro de su saldo '
        'disponible hacia los métodos de cobro que registre (por ejemplo, '
        'Yape, Plin o cuenta bancaria).',
    'Los retiros pueden estar sujetos a validaciones de seguridad, montos '
        'mínimos o plazos de procesamiento informados en la Plataforma. El '
        'Proveedor es responsable de la exactitud de los datos de destino que '
        'proporcione.',
    'La Plataforma podrá aplicar mecanismos automáticos de detección de '
        'anomalías financieras (montos atípicos, cobros duplicados, exceso de '
        'reembolsos) con fines de prevención de fraude.',
  ]),
  TermsSection('12. Cancelaciones y Reembolsos', [
    '• El Usuario puede cancelar una reserva dentro del plazo señalado en la '
        'Plataforma antes del inicio del servicio, sin penalidad.',
    '• Las cancelaciones fuera de dicho plazo podrán generar una penalidad '
        'informada previamente al Usuario (por ejemplo, escalonada según la '
        'anticipación de la cancelación).',
    '• Los reembolsos, cuando correspondan, se procesarán en un plazo razonable '
        'a través del mismo medio de pago utilizado, conforme al derecho de '
        'reclamo del consumidor.',
  ]),
  TermsSection('13. Seguros y Responsabilidad Civil', [
    'Todo vehículo registrado debe contar con el Seguro Obligatorio de '
        'Accidentes de Tránsito (SOAT) vigente, conforme a la Ley N.° 27181 y '
        'su reglamento.',
    'WheelsPe recomienda a los Proveedores contar con seguros adicionales de '
        'responsabilidad civil frente a terceros. La Plataforma no asume '
        'responsabilidad por accidentes, daños personales o materiales '
        'ocurridos durante el alquiler o el viaje compartido, salvo lo '
        'dispuesto por norma imperativa.',
  ]),
  TermsSection('14. Seguridad durante el Viaje', [
    'Alerta de emergencia (SOS): durante un viaje activo, el Usuario puede '
        'activar una alerta que notifica al equipo de soporte con su ubicación. '
        'Debe usarse únicamente ante una situación real de riesgo; el uso '
        'indebido de la alerta podrá ser sancionado.',
    'Compartir ubicación en vivo y contactos de confianza: el Usuario puede '
        'compartir su viaje en tiempo real con contactos de confianza. Estas '
        'funciones operan solo durante el uso activo del Servicio.',
    'Estas herramientas son de apoyo y no reemplazan a los servicios de '
        'emergencia oficiales (Policía Nacional, SAMU, bomberos), a los que el '
        'Usuario debe acudir ante cualquier emergencia real.',
  ]),
  TermsSection('15. Reputación, Calificaciones y Distintivos', [
    'Al finalizar un alquiler o viaje, las partes pueden calificarse '
        'mutuamente. Las calificaciones alimentan la reputación pública del '
        'Usuario y pueden condicionar el acceso a ciertas funciones o rutas.',
    'La manipulación de calificaciones (reseñas falsas, coordinadas o '
        'infladas) está prohibida. La Plataforma podrá aplicar mecanismos '
        'automáticos de mediación para excluir reseñas atípicas o injustas y '
        'otorgar distintivos por buen comportamiento.',
  ]),
  TermsSection('16. Promociones, Cupones y Recompensas', [
    'La Plataforma o los Proveedores podrán ofrecer promociones, cupones y '
        'programas de recompensas sujetos a sus propias condiciones de '
        'vigencia, tope y elegibilidad, informadas al momento de aplicarlos.',
    'Las promociones no son canjeables por dinero salvo indicación expresa, y '
        'la Plataforma podrá modificarlas o cancelarlas ante usos fraudulentos '
        'o abusivos.',
  ]),
  TermsSection('17. Mensajería y Comunicaciones', [
    'La Plataforma ofrece un chat para coordinar la operación entre Proveedor y '
        'Pasajero. Está prohibido usarlo para acoso, spam, contenido ilícito o '
        'para evadir a la Plataforma.',
    'Al registrarte, autorizas a la Plataforma a enviarte notificaciones '
        'operativas (reservas, mensajes, pagos, alertas). Podrás gestionar las '
        'notificaciones no esenciales desde la configuración de la app o de tu '
        'dispositivo.',
  ]),
  TermsSection('18. Protección de Datos Personales', [
    'WheelsPe trata los datos personales de sus Usuarios conforme a la Ley '
        'N.° 29733, Ley de Protección de Datos Personales, y su Reglamento '
        '(Decreto Supremo N.° 003-2013-JUS). Los datos recopilados (identidad, '
        'ubicación, historial de viajes, medios de pago) se utilizan únicamente '
        'para la prestación del Servicio, verificación de identidad y '
        'seguridad, salvo consentimiento expreso para otras finalidades.',
    '• El Usuario puede ejercer sus derechos ARCO (acceso, rectificación, '
        'cancelación y oposición) mediante los canales que la Plataforma '
        'habilite.',
    '• Los datos de ubicación se recopilan solo durante el uso activo del '
        'Servicio, salvo que el Usuario autorice lo contrario.',
    '• WheelsPe no vende datos personales a terceros no autorizados.',
    '• El Usuario puede solicitar la baja de su cuenta y la eliminación de sus '
        'datos desde la propia aplicación, conforme a la ley aplicable.',
  ]),
  TermsSection('19. Permisos y Uso en Dispositivos Móviles (Android e iOS)', [
    'La Plataforma se distribuye a través de Google Play (Android) y App Store '
        '(iOS). El Usuario debe descargarla únicamente desde las tiendas '
        'oficiales y aceptar además las condiciones de dichas tiendas.',
    'Para funcionar, la app solicita permisos que el Usuario puede conceder o '
        'revocar en cualquier momento desde la configuración del sistema. '
        'Revocar un permiso puede limitar funciones:',
    '• Cámara: para la verificación de identidad (KYC), la inspección '
        'fotográfica del vehículo y las fotos de perfil o de publicación.',
    '• Ubicación: para el seguimiento del viaje en tiempo real, mostrar '
        'vehículos o rutas cercanas y calcular trayectos. En iOS se solicita '
        'como "Mientras se usa la app"; el uso en segundo plano, cuando exista, '
        'requiere autorización explícita y se limita al viaje activo.',
    '• Notificaciones: para avisos de reservas, mensajes, pagos y alertas de '
        'seguridad. En Android 13+ e iOS se requiere tu autorización.',
    '• Fotos/almacenamiento: para adjuntar documentos e imágenes desde la '
        'galería del dispositivo.',
    'Requisitos técnicos: se recomienda un dispositivo con una versión de '
        'sistema operativo soportada (Android e iOS recientes), conexión a '
        'internet y servicios de mapas/localización activos. El uso intensivo '
        'de GPS puede aumentar el consumo de batería y datos.',
    'Actualizaciones: el Usuario debe mantener la app actualizada. Las '
        'versiones desactualizadas pueden dejar de funcionar o perder soporte. '
        'El Usuario es responsable de la seguridad de su dispositivo, del '
        'bloqueo de pantalla y de sus credenciales de acceso.',
  ]),
  TermsSection('20. Conducta Prohibida y Suspensión de Cuentas', [
    'Está prohibido: usar la Plataforma para transporte de mercancías '
        'ilícitas, registrar vehículos sin la documentación exigida, suplantar '
        'identidad, manipular calificaciones, y usar la modalidad de carpooling '
        'para encubrir un servicio de transporte remunerado no autorizado.',
    'También está prohibido intentar vulnerar la seguridad de la Plataforma, '
        'usar bots o automatismos no autorizados, o dañar la experiencia de '
        'otros Usuarios.',
    'WheelsPe podrá suspender o eliminar cuentas que incumplan estos T&C, '
        'previa notificación al Usuario, salvo casos de riesgo inminente para '
        'la seguridad de terceros.',
  ]),
  TermsSection('21. Propiedad Intelectual', [
    'El software, marca, logotipos, diseño y contenidos de la Plataforma son de '
        'propiedad de WheelsPe o de sus licenciantes, y están protegidos por la '
        'Ley sobre el Derecho de Autor (Decreto Legislativo N.° 822) y la '
        'Decisión 486 de la Comunidad Andina sobre propiedad industrial. Queda '
        'prohibida su reproducción total o parcial sin autorización expresa.',
  ]),
  TermsSection('22. Limitación de Responsabilidad', [
    'En la máxima medida permitida por la ley, WheelsPe no será responsable por '
        'daños indirectos, lucro cesante, ni por hechos derivados de la '
        'relación contractual directa entre Proveedor y Pasajero. La '
        'responsabilidad de la Plataforma se limita a la correcta operatividad '
        'de la herramienta tecnológica de intermediación.',
  ]),
  TermsSection('23. Disponibilidad del Servicio y Cambios Técnicos', [
    'La Plataforma se ofrece "tal cual" y "según disponibilidad". WheelsPe '
        'procura la continuidad del Servicio, pero no garantiza que esté libre '
        'de interrupciones, errores o mantenimientos. Podrá agregar, modificar '
        'o descontinuar funciones por razones técnicas, de seguridad o '
        'regulatorias.',
    'Algunas funciones pueden depender de servicios de terceros (mapas, '
        'pasarelas de pago, notificaciones). La indisponibilidad de dichos '
        'terceros puede afectar temporalmente el Servicio.',
  ]),
  TermsSection('24. Modificaciones de los Términos', [
    'WheelsPe podrá modificar estos T&C en cualquier momento, notificando los '
        'cambios a través de la Plataforma con una antelación razonable. El uso '
        'continuado del Servicio tras la publicación de los cambios implica su '
        'aceptación.',
  ]),
  TermsSection('25. Resolución de Conflictos y Ley Aplicable', [
    'Estos T&C se rigen por las leyes de la República del Perú. Cualquier '
        'controversia se intentará resolver primero de forma directa entre las '
        'partes o mediante el Libro de Reclamaciones de la Plataforma; en caso '
        'de no llegar a un acuerdo, las partes se someten a los jueces y '
        'tribunales del distrito judicial de Lima, sin perjuicio del derecho '
        'del consumidor a acudir a INDECOPI.',
  ]),
  TermsSection('26. Disposiciones Finales', [
    'Si alguna cláusula de estos T&C fuera declarada nula o inaplicable, las '
        'demás mantendrán plena vigencia. Estos T&C constituyen el acuerdo '
        'íntegro entre el Usuario y WheelsPe respecto al uso de la Plataforma.',
  ]),
  TermsSection('27. Contacto', [
    'Para consultas sobre estos T&C, ejercicio de derechos ARCO o reclamos, el '
        'Usuario puede escribir al canal de soporte disponible dentro de la '
        'aplicación (sección "Ayuda y soporte") o al correo de contacto que la '
        'Plataforma publique.',
  ]),
];
