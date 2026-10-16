import 'package:web/web.dart' as web;

bool readDarkMode() {
  try {
    return web.window.localStorage.getItem('renovax.darkMode') == 'true';
  } catch (_) {
    return false;
  }
}

void saveDarkMode(bool value) {
  try {
    web.window.localStorage.setItem('renovax.darkMode', value.toString());
  } catch (_) {
    /* El tema sigue funcionando si el navegador bloquea el almacenamiento. */
  }
}
