/// Datos públicos del centro. Completar con información confirmada.
abstract final class Acopio {
  static const id = 'matagalpa-cur-unan';
  static const name = 'CUR UNAN Matagalpa';
  static const department = 'Matagalpa';
  static const address = 'CUR UNAN Matagalpa, Matagalpa, Nicaragua';
  static const days = 'Días de atención pendientes de confirmar';
  static const hours = 'Horario pendiente de confirmar';
  // Referencia OSM: https://www.openstreetmap.org/node/4357997699
  // Confirmar con el responsable el recinto y el lugar exacto de recepción.
  static const latitude = 12.9237391;
  static const longitude = -85.9223240;
  static const locationNote =
      'Referencia del recinto UNAN/FAREM en OpenStreetMap. '
      'Punto exacto de recepción por confirmar.';
  // Número con código de país, solo dígitos. Ejemplo de formato: 505XXXXXXXX.
  static const whatsapp = '';
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
