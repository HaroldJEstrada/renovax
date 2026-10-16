# Renovax

Aplicación Flutter web para donaciones de celulares y recuperación de componentes en Nicaragua.

## Proyecto Firebase de Renovax

La aplicación web `renovax-web` está registrada en el proyecto `renovax-5196d` (plan Spark). Su configuración pública se incluye en `config/firebase.renovax.json`. No contiene contraseñas ni claves de cuentas de servicio.

Para ejecutar contra este proyecto desde Edge:

```sh
flutter pub get
flutter run -d edge --web-port=5000 --dart-define-from-file=config/firebase.renovax.json
```

La disponibilidad de cada función depende de que sus proveedores y reglas estén habilitados en la consola. El acceso con Google requiere seleccionar el correo de soporte del proyecto. La cuenta de administrador y su permiso `admins/{uid}` se crean por separado; nunca se incluyen contraseñas en el repositorio.

## Identidad visual

Paleta basada en la referencia enviada: azul principal `#4068AA`, azul oscuro `#1D385C`, fondo `#EDF4FF`, celeste `#E1EDFF` y bordes `#BDD0EF`. El logo original transparente está en `renovax_logo.png` y se declara como asset en `pubspec.yaml`.

## Qué incluye

- Inicio, misión y visión (textos iniciales propuestos, editables en `lib/main.dart`).
- Donaciones: acceso real con Google, nombre y correo de solo lectura, modelo y nota opcionales, consentimiento y registro en Firestore.
- Selector de los 15 departamentos y las 2 regiones autónomas. Solo Matagalpa permite registrar entregas.
- CUR UNAN Matagalpa: página independiente, datos de atención, mapa mediante Leaflet con OpenStreetMap y contacto por WhatsApp.
- Administración: acceso por correo y contraseña; autorización comprobada en Firestore.
- Inventario: cantidades grandes de Wi-Fi, GPS, acelerómetro, motor vibrador, altavoz, sensor de proximidad y giroscopio; ingreso de cantidades y notas opcionales; tipos adicionales e historial.
- Los ingresos son documentos inmutables y las cantidades se calculan sumándolos. Dos administradores pueden registrar ingresos sin sobrescribir un contador compartido.

## 1. Ver la interfaz en Edge

```sh
flutter pub get
flutter run -d edge
```

Sin configuración de Firebase, la interfaz pública funciona como vista previa. Google, el guardado y el acceso administrador quedan deshabilitados. En administración se muestra un inventario de ejemplo con cantidades cero y sin permiso para escribir. No hay usuarios ni contraseñas predeterminadas.

## 2. Crear y conectar Firebase, paso a paso

1. Entrá a https://console.firebase.google.com/ con tu cuenta de Google.
2. Creá un proyecto para Renovax. Google Analytics no es necesario para esta aplicación.
3. En la descripción general del proyecto, agregá una aplicación **web** usando el icono `</>`. Poné el nombre `renovax-web`. No hace falta habilitar Hosting para trabajar localmente.
4. Firebase mostrará un objeto `firebaseConfig`. Es configuración pública de la app web; no uses una clave privada ni un archivo de cuenta de servicio.
5. En VS Code copiá `config/firebase.example.json` como `config/firebase.local.json`. Completá estos campos usando los valores del objeto:

| Campo del JSON local | Campo de Firebase |
| --- | --- |
| FIREBASE_API_KEY | apiKey |
| FIREBASE_APP_ID | appId |
| FIREBASE_MESSAGING_SENDER_ID | messagingSenderId |
| FIREBASE_PROJECT_ID | projectId |
| FIREBASE_AUTH_DOMAIN | authDomain |

6. En **Authentication → Sign-in method**, habilitá **Google** (seleccioná el correo de soporte) y **Email/Password**.
7. En **Authentication → Settings → Authorized domains**, agregá `localhost` si todavía no aparece. Al publicar, agregá el dominio donde esté la aplicación.
8. En **Firestore Database**, creá la base de datos predeterminada `(default)` en modo producción. Elegí la región antes de crearla.
9. En la pestaña **Rules** de Firestore, reemplazá el contenido con `firestore.rules` de este repositorio y pulsá **Publicar**. El archivo `firebase.json` permite publicarlas también con Firebase CLI, si luego lo instalás.
10. Detené la ejecución actual con `q` y arrancá otra vez:

```sh
flutter run -d edge --web-port=5000 --dart-define-from-file=config/firebase.local.json
```

Los valores de `--dart-define` se leen al iniciar/compilar: si los cambiás, detené y volvé a ejecutar la aplicación. No basta con hot reload.

## 3. Crear el administrador

1. En **Authentication → Users → Add user**, creá una cuenta con correo y contraseña elegidos por vos.
2. Copiá el **UID** de esa cuenta.
3. En Firestore creá la colección `admins` y un documento cuyo **ID sea exactamente ese UID**. Podés agregar el campo de texto `label` con valor `Administrador`.
4. Desde Renovax abrí **Administración** e ingresá ese correo y contraseña.

Solo un propietario autorizado del proyecto Firebase puede otorgar este permiso desde la consola. La aplicación no puede crear documentos `admins`. Una cuenta de Google de donante no recibe permisos de administrador por iniciar sesión.

## 4. Acopio: CUR UNAN Matagalpa y mapa Leaflet

La dirección se corrigió a **CUR UNAN Matagalpa, Matagalpa, Nicaragua**.
El mapa usa **Leaflet 1.9.4** y las teselas estándar de OpenStreetMap. No necesita una clave de Google Maps ni configurar facturación de Google para el mapa. El acceso con Google para donaciones continúa usando Firebase.

Las coordenadas de referencia son `12.9237391, -85.9223240`, correspondientes a UNAN/FAREM Matagalpa en https://www.openstreetmap.org/node/4357997699. Confirmá que ese sea el recinto elegido y el punto exacto de recepción. La interfaz advierte que se trata de una referencia del recinto.

Editá `lib/config.dart` para completar o ajustar:

- `latitude` y `longitude`: ubicación exacta si el acopio está en otro recinto o entrada.
- `address`: dirección detallada para llegar al punto de recepción.
- `days` y `hours`: días y horas de atención del acopio (siguen pendientes; no se toman del horario general de la universidad).
- `whatsapp`: teléfono confirmado con código de país y solo dígitos.

El marcador abre `/#/acopio` en una nueva pestaña. También se puede usar el enlace debajo del mapa. WhatsApp se habilita al completar el número.

El mapa mantiene los enlaces **Leaflet** y **© OpenStreetMap contributors** visibles. Solo carga las teselas necesarias para la vista actual: no ofrece descarga masiva ni mapas sin conexión. Para un despliegue con tráfico alto, evaluá un proveedor de teselas apropiado y revisá https://operations.osmfoundation.org/policies/tiles/.

La biblioteca se descarga de un CDN con versión e integridad fijadas. Si el CDN o el mapa fallan, se muestra un aviso y un enlace alternativo a OpenStreetMap. No se envían datos del donante al mapa ni se solicita su ubicación personal.

## 5. Comprobar el comportamiento

```sh
flutter analyze
flutter test
flutter build web --dart-define-from-file=config/firebase.local.json
```

La sintaxis de los archivos Dart fue comprobada con el formateador. No se ejecutaron análisis completo, pruebas Flutter, compilación ni pruebas reales de Google/Firebase en el entorno de preparación: la ejecución de Flutter fue bloqueada por una consulta a metadatos internos del entorno.

Después de conectar Firebase, verificá:

1. Google completa nombre/correo y cancelar el popup muestra un mensaje.
2. Los otros departamentos no permiten registrar una entrega.
3. Una donación de Matagalpa aparece en `donations` y el formulario se limpia.
4. Una cuenta sin documento `admins/{uid}` no entra al panel.
5. Un ingreso de 3 piezas y otro de 2 del mismo tipo muestran 5; cero, negativos y decimales se rechazan.
6. Una pieza nueva aparece en el panel y en el menú de ingresos siguientes.
7. Las reglas rechazan lecturas de inventario y escrituras de donaciones sin autenticar; rechazan modificar roles e ingresos desde el cliente.
8. Abrir `/#/admin` directamente sigue exigiendo autenticación y autorización.

## Estructura y límites actuales

- `lib/main.dart`: pantallas y formularios.
- `lib/backend.dart`: inicialización, autenticación y comprobación de rol.
- `lib/config.dart`: piezas, departamentos y datos del acopio.
- `firestore.rules`: permisos y validación en el servidor.
- `config/firebase.example.json`: plantilla de configuración pública.

Los totales usan todos los ingresos y no hay salidas, correcciones ni paginación todavía. Para un inventario grande conviene agregar agregación en el servidor y paginación. Registrar una donación no incrementa inventario automáticamente: las piezas se ingresan después de evaluarlas. Esta versión está dirigida a navegador; no incluye integración de autenticación o mapas para aplicaciones nativas.

Documentación oficial:
- https://firebase.google.com/docs/auth/flutter/federated-auth
- https://firebase.google.com/docs/auth/flutter/password-auth
- https://firebase.google.com/docs/firestore/security/rules-conditions
- https://leafletjs.com/examples/quick-start/index.html
- https://www.openstreetmap.org/copyright
