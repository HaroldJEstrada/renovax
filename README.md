# Renovax

Proyecto inicial de Flutter con Material 3 y soporte web.

## Ejecutar

Con Flutter estable instalado:

```sh
flutter pub get
flutter run -d chrome
```

## Verificar

```sh
flutter analyze
flutter test
flutter build web
```

Estas verificaciones están pendientes: el entorno de creación bloqueó la ejecución de Flutter.

## Agregar plataformas móviles y de escritorio

```sh
flutter create --project-name renovax --platforms=android,ios,linux,macos,windows .
```

El código de la aplicación está en `lib/main.dart`.
