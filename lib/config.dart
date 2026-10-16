/// Datos públicos del centro. Completar con información confirmada.
abstract final class Acopio {
  static const name = 'Escuela El Progreso';
  static const department = 'Matagalpa';
  static const address = 'Dirección exacta pendiente de confirmar';
  static const days = 'Días de atención pendientes de confirmar';
  static const hours = 'Horario pendiente de confirmar';
  // Usar el Place ID de Google Maps para evitar señalar una escuela homónima.
  static const placeId = '';
  // Número con código de país, solo dígitos. Ejemplo de formato: 505XXXXXXXX.
  static const whatsapp = '';
  static const mapsKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
}

const departments = [
  'Matagalpa',
  'Managua',
  'Estelí',
  'Chontales',
  'Jinotega',
  'Boaco',
  'Carazo',
  'Chinandega',
  'Granada',
  'León',
  'Madriz',
  'Masaya',
  'Nueva Segovia',
  'Río San Juan',
  'Rivas',
  'Costa Caribe Norte',
  'Costa Caribe Sur',
];

const baseParts = [
  'Wi-Fi',
  'GPS',
  'Acelerómetro',
  'Motor vibrador',
  'Altavoz',
  'Sensor de proximidad',
  'Giroscopio',
];

String partKey(String name) =>
    name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
