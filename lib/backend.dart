import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

abstract final class Backend {
  static bool ready = false;
  static String? startupError;
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get db => FirebaseFirestore.instance;

  static Future<void> initialize() async {
    const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
    const appId = String.fromEnvironment('FIREBASE_APP_ID');
    const sender = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
    const project = String.fromEnvironment('FIREBASE_PROJECT_ID');
    const domain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
    if ([apiKey, appId, sender, project, domain].any((s) => s.isEmpty)) return;
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: sender,
          projectId: project,
          authDomain: domain,
        ),
      );
      ready = true;
    } catch (_) {
      startupError = 'No se pudo conectar Firebase. Revisá su configuración.';
    }
  }

  static Future<bool> isAdmin() async {
    final user = auth.currentUser;
    if (user == null) return false;
    return (await db.collection('admins').doc(user.uid).get()).exists;
  }

  static Future<void> adminLogin(String email, String password) async {
    await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    try {
      if (!await isAdmin()) {
        throw StateError('Esta cuenta no tiene permisos de administrador.');
      }
    } catch (_) {
      await auth.signOut();
      rethrow;
    }
  }

  static String message(Object error) {
    if (error is StateError) return error.message.toString();
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'popup-closed-by-user' ||
        'cancelled-popup-request' => 'Se canceló el acceso con Google.',
        'popup-blocked' =>
          'Permití las ventanas emergentes para iniciar sesión.',
        'unauthorized-domain' =>
          'Agregá este dominio a los dominios autorizados de Firebase.',
        'operation-not-allowed' =>
          'Habilitá este proveedor de acceso en Firebase.',
        'too-many-requests' => 'Demasiados intentos. Probá de nuevo más tarde.',
        'network-request-failed' => 'Revisá tu conexión a internet.',
        _ => 'No se pudo iniciar sesión. Revisá las credenciales y la configuración.',
      };
    }
    return 'No se pudo completar la operación. Revisá tu conexión y los permisos de Firebase.';
  }
}
