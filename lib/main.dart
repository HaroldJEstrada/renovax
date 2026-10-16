import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'map_stub.dart' if (dart.library.js_interop) 'map_web.dart';

import 'backend.dart';
import 'config.dart';

const ink = Color(0xFF1D385C);
const brandBlue = Color(0xFF4068AA);
const paper = Color(0xFFEDF4FF);
const paleBlue = Color(0xFFE1EDFF);
const lineBlue = Color(0xFFBDD0EF);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Backend.initialize();
  runApp(const RenovaxApp());
}

class RenovaxApp extends StatelessWidget {
  const RenovaxApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Renovax · Tecnología con otra oportunidad',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: paper,
      colorScheme: ColorScheme.fromSeed(seedColor: brandBlue).copyWith(
        primary: brandBlue,
        onPrimary: Colors.white,
        secondary: const Color(0xFF7195CC),
        surface: const Color(0xFFF8FBFF),
        onSurface: ink,
        outline: lineBlue,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ink,
        foregroundColor: Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: paleBlue,
        selectedColor: lineBlue,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 44,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
        headlineMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    ),
    routes: {
      '/': (_) => const PublicPage(),
      '/acopio': (_) => const CenterPage(),
      '/admin': (_) => const AdminPage(),
    },
  );
}

void notify(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class Sheet extends StatelessWidget {
  final Widget child;
  const Sheet({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FBFF),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: lineBlue),
    ),
    child: child,
  );
}

/// El archivo original conserva su transparencia y márgenes. El recorte es solo
/// de presentación para que el logo horizontal se lea sin modificar la imagen.
class BrandLogo extends StatelessWidget {
  final double width;
  const BrandLogo({super.key, this.width = 200});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: width * .27,
    child: ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        minWidth: width * 1.28,
        maxWidth: width * 1.28,
        minHeight: width * 1.28,
        maxHeight: width * 1.28,
        child: Image.asset(
          'renovax_logo.png',
          width: width * 1.28,
          height: width * 1.28,
          fit: BoxFit.contain,
          semanticLabel: 'Renovax',
        ),
      ),
    ),
  );
}

class PublicPage extends StatefulWidget {
  const PublicPage({super.key});
  @override
  State<PublicPage> createState() => _PublicPageState();
}

class _PublicPageState extends State<PublicPage> {
  int section = 0;
  static const labels = ['Inicio', 'Misión', 'Visión', 'Donaciones'];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF294F90), Color(0xFF1D385C)],
              ),
            ),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 20,
              runSpacing: 12,
              children: [
                const BrandLogo(),
                Wrap(
                  spacing: 6,
                  children: List.generate(
                    labels.length,
                    (i) => TextButton(
                      onPressed: () => setState(() => section = i),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: section == i
                            ? brandBlue
                            : Colors.transparent,
                      ),
                      child: Text(labels[i]),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFAEC4E6)),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/admin'),
                  icon: const Icon(Icons.lock_outline, size: 18),
                  label: const Text('Administración'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!Backend.ready) ...[
                          Sheet(
                            child: Text(
                              Backend.startupError ?? 'Vista previa · La conexión con Google y el guardado se habilitarán al configurar Firebase.',
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (section == 0) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD9E8FF), Color(0xFFF5F9FF)],
                              ),
                              border: Border.all(color: lineBlue),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x144068AA),
                                  blurRadius: 24,
                                  offset: Offset(0, 8),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'RECUPERAR · TRANSFORMAR · CONECTAR',
                                  style: TextStyle(
                                    color: brandBlue,
                                    letterSpacing: 2,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Tu celular en desuso.\nUna nueva posibilidad.',
                                  style: TextStyle(
                                    color: ink,
                                    fontSize: 44,
                                    height: 1.1,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Recuperamos componentes de teléfonos para darles otra vida en proyectos útiles para nuestra comunidad.',
                                  style: TextStyle(
                                    color: Color(0xFF526F99),
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: brandBlue,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => setState(() => section = 3),
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text('Quiero donar un celular'),
                                ),
                                const SizedBox(height: 28),
                                const Wrap(
                                  spacing: 24,
                                  runSpacing: 12,
                                  children: [
                                    Chip(
                                      label: Text('Economía circular'),
                                      avatar: Icon(Icons.recycling),
                                    ),
                                    Chip(
                                      label: Text('Impacto local'),
                                      avatar: Icon(Icons.volunteer_activism),
                                    ),
                                    Chip(
                                      label: Text('Matagalpa, Nicaragua'),
                                      avatar: Icon(Icons.place_outlined),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Cada componente cuenta',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Estas son las piezas que recuperamos y registramos en nuestro inventario.',
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: baseParts
                                .map(
                                  (s) => Chip(
                                    label: Text(s),
                                    avatar: Icon(partIcon(s), size: 18),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 28),
                          const Sheet(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Así comienza una segunda vida',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: ink,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  '01  Iniciá sesión con Google y registrá tu donación.\n\n02  Consultá el centro de acopio disponible.\n\n03  Entregá tu equipo para su evaluación y recuperación.',
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (section == 1 || section == 2)
                          Sheet(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  section == 1
                                      ? Icons.spa_outlined
                                      : Icons.public,
                                  size: 48,
                                  color: brandBlue,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  section == 1
                                      ? 'Nuestra misión'
                                      : 'Nuestra visión',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  section == 1
                                      ? 'Dar una segunda vida a los componentes de teléfonos en desuso, promoviendo la donación responsable, la innovación y el aprovechamiento tecnológico para beneficio de la comunidad.'
                                      : 'Construir una comunidad en Nicaragua donde la tecnología se reutilice de forma responsable y se transforme en oportunidades educativas, ambientales y sociales.',
                                  style: const TextStyle(
                                    fontSize: 21,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                FilledButton(
                                  onPressed: () => setState(() => section = 3),
                                  child: const Text('Sumarme con una donación'),
                                ),
                              ],
                            ),
                          ),
                        if (section == 3) const DonationPage(),
                        const SizedBox(height: 40),
                        const Divider(),
                        const Text(
                          'RENOVAX  /  Tecnología con otra oportunidad',
                          style: TextStyle(color: brandBlue),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

IconData partIcon(String name) => switch (name) {
  'Wi-Fi' => Icons.wifi,
  'GPS' => Icons.gps_fixed,
  'Acelerómetro' => Icons.speed,
  'Motor vibrador' => Icons.vibration,
  'Altavoz' => Icons.volume_up_outlined,
  'Sensor de proximidad' => Icons.sensors,
  'Giroscopio' => Icons.screen_rotation,
  _ => Icons.memory,
};

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});
  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final form = GlobalKey<FormState>();
  final model = TextEditingController();
  final note = TextEditingController();
  StreamSubscription<User?>? subscription;
  User? user;
  bool busy = false;
  bool consent = false;
  String department = 'Matagalpa';
  @override
  void initState() {
    super.initState();
    if (Backend.ready) {
      user = Backend.auth.currentUser;
      subscription = Backend.auth.authStateChanges().listen((value) {
        if (mounted) setState(() => user = value);
      });
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    model.dispose();
    note.dispose();
    super.dispose();
  }

  bool get googleUser =>
      user?.providerData.any((p) => p.providerId == 'google.com') ?? false;
  Future<void> signIn() async {
    setState(() => busy = true);
    try {
      await Backend.auth.signInWithPopup(
        GoogleAuthProvider()..setCustomParameters({'prompt': 'select_account'}),
      );
    } catch (e) {
      if (mounted) notify(context, Backend.message(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> save() async {
    if (!form.currentState!.validate() || !consent) return;
    setState(() => busy = true);
    try {
      await Backend.db.collection('donations').add({
        'uid': user!.uid,
        'name': user!.displayName ?? '',
        'email': user!.email ?? '',
        'model': model.text.trim(),
        'note': note.text.trim(),
        'department': department,
        'center': Acopio.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
      model.clear();
      note.clear();
      if (mounted) {
        setState(() => consent = false);
        notify(
          context,
          'Donación registrada. Consultá los datos del acopio antes de entregar tu equipo.',
        );
      }
    } catch (e) {
      if (mounted) notify(context, Backend.message(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Una donación. Muchas posibilidades.',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 10),
      const Text('Registrá tu equipo y encontrá dónde entregarlo.'),
      const SizedBox(height: 24),
      Sheet(
        child: Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '01 / Tus datos',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
              const SizedBox(height: 16),
              if (!googleUser) ...[
                const Text(
                  'Iniciá sesión con Google para completar automáticamente tu nombre y correo.',
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: Backend.ready && !busy ? signIn : null,
                  icon: const Icon(Icons.account_circle_outlined),
                  label: Text(busy ? 'Conectando…' : 'Continuar con Google'),
                ),
                if (!Backend.ready)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text('Google pendiente de configurar.'),
                  ),
              ] else ...[
                TextFormField(
                  key: ValueKey('name-${user!.uid}'),
                  initialValue: user!.displayName ?? '',
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de Google',
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  key: ValueKey('email-${user!.uid}'),
                  initialValue: user!.email ?? '',
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Correo de Google',
                  ),
                ),
                TextButton(
                  onPressed: busy
                      ? null
                      : () async {
                          await Backend.auth.signOut();
                          if (mounted) setState(() => consent = false);
                        },
                  child: const Text('Usar otra cuenta'),
                ),
              ],
              const SizedBox(height: 18),
              TextFormField(
                controller: model,
                maxLength: 120,
                enabled: !busy,
                decoration: const InputDecoration(
                  labelText: 'Modelo del celular (opcional)',
                  hintText: 'Ej.: Samsung Galaxy A12',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: note,
                maxLength: 1000,
                maxLines: 3,
                enabled: !busy,
                decoration: const InputDecoration(
                  labelText: 'Nota (opcional)',
                  hintText: 'Contanos sobre el estado del equipo.',
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '02 / Tu centro de acopio',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Seleccioná tu departamento o región. Por ahora solo Matagalpa tiene un centro habilitado.',
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: departments
                    .map(
                      (d) => ChoiceChip(
                        label: Text(d),
                        selected: department == d,
                        onSelected: busy
                            ? null
                            : (_) => setState(() => department = d),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              if (department == 'Matagalpa') ...[
                const AcopioMap(),
                const SizedBox(height: 12),
                const Text(Acopio.locationNote),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.school_outlined, color: brandBlue),
                  title: const Text(Acopio.name),
                  subtitle: const Text(
                    'Matagalpa · Ver información del centro',
                  ),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => openCenter(context),
                ),
              ] else
                const Text(
                  'Todavía no hay un centro de acopio disponible en este departamento o región. No se puede registrar una entrega aquí.',
                ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: consent,
                onChanged: busy
                    ? null
                    : (v) => setState(() => consent = v ?? false),
                title: const Text(
                  'Autorizo guardar mi nombre, correo y los datos de esta donación para coordinar la entrega.',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed:
                    Backend.ready &&
                        googleUser &&
                        consent &&
                        department == 'Matagalpa' &&
                        !busy
                    ? save
                    : null,
                icon: const Icon(Icons.volunteer_activism),
                label: Text(busy ? 'Procesando…' : 'Registrar donación'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Antes de entregar el teléfono, respaldá tu información y retirala del dispositivo.',
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Future<void> openCenter(BuildContext context) async {
  final uri = Uri.base.replace(fragment: '/acopio');
  if (!await launchUrl(uri, webOnlyWindowName: '_blank') && context.mounted) {
    Navigator.pushNamed(context, '/acopio');
  }
}

class AcopioMap extends StatelessWidget {
  const AcopioMap({super.key});
  @override
  Widget build(BuildContext context) {
    return buildEmbeddedMap();
  }
}

class CenterPage extends StatelessWidget {
  const CenterPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Row(
        children: [
          BrandLogo(width: 135),
          SizedBox(width: 18),
          Flexible(child: Text('Centro de acopio')),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.home_outlined),
        onPressed: () =>
            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
      ),
    ),
    body: SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Sheet(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.school_outlined, size: 48, color: brandBlue),
                  const SizedBox(height: 18),
                  Text(
                    Acopio.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Text('Matagalpa, Nicaragua'),
                  const SizedBox(height: 24),
                  const ListTile(
                    leading: Icon(Icons.place_outlined),
                    title: Text('Dirección'),
                    subtitle: Text(Acopio.address),
                  ),
                  const ListTile(
                    leading: Icon(Icons.calendar_today_outlined),
                    title: Text('Días de atención'),
                    subtitle: Text(Acopio.days),
                  ),
                  const ListTile(
                    leading: Icon(Icons.schedule),
                    title: Text('Horas de atención'),
                    subtitle: Text(Acopio.hours),
                  ),
                  const SizedBox(height: 20),
                  const AcopioMap(),
                  const SizedBox(height: 12),
                  const Text(Acopio.locationNote),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: Acopio.whatsapp.isEmpty
                        ? null
                        : () async {
                            final uri = Uri.https(
                              'wa.me',
                              '/${Acopio.whatsapp}',
                              {
                                'text': 'Hola, quisiera información para donar un celular a Renovax.',
                              },
                            );
                            if (!await launchUrl(
                                  uri,
                                  webOnlyWindowName: '_blank',
                                ) &&
                                context.mounted)
                              notify(context, 'No se pudo abrir WhatsApp.');
                          },
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('Contactar por WhatsApp'),
                  ),
                  if (Acopio.whatsapp.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text('WhatsApp pendiente de confirmar.'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final loginForm = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool authorized = false;
  bool busy = false;
  bool checking = true;
  bool hidePassword = true;
  @override
  void initState() {
    super.initState();
    check();
  }

  Future<void> check() async {
    try {
      final allowed = Backend.ready && await Backend.isAdmin();
      if (mounted) setState(() => authorized = allowed);
    } catch (e) {
      if (mounted) notify(context, Backend.message(e));
    } finally {
      if (mounted) setState(() => checking = false);
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!loginForm.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      await Backend.adminLogin(email.text, password.text);
      password.clear();
      if (mounted) setState(() => authorized = true);
    } catch (e) {
      if (mounted) notify(context, Backend.message(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Row(
        children: [
          BrandLogo(width: 135),
          SizedBox(width: 18),
          Flexible(child: Text('Administración')),
        ],
      ),
      actions: [
        if (authorized)
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () async {
              await Backend.auth.signOut();
              if (mounted) setState(() => authorized = false);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Salir'),
          ),
      ],
    ),
    body: checking
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: authorized
                      ? const InventoryPage()
                      : Column(
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 480),
                              child: Sheet(
                                child: Form(
                                  key: loginForm,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.lock_outline,
                                        color: brandBlue,
                                        size: 40,
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        'Acceso de administrador',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Ingresá con el correo y la contraseña de tu cuenta autorizada.',
                                      ),
                                      const SizedBox(height: 24),
                                      TextFormField(
                                        controller: email,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        autofillHints: const [
                                          AutofillHints.username,
                                        ],
                                        enabled: !busy,
                                        decoration: const InputDecoration(
                                          labelText: 'Correo electrónico',
                                        ),
                                        validator: (s) =>
                                            s == null ||
                                                !RegExp(
                                                  r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                                ).hasMatch(s.trim())
                                            ? 'Ingresá un correo válido.'
                                            : null,
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: password,
                                        obscureText: hidePassword,
                                        autofillHints: const [
                                          AutofillHints.password,
                                        ],
                                        enabled: !busy,
                                        decoration: InputDecoration(
                                          labelText: 'Contraseña',
                                          suffixIcon: IconButton(
                                            tooltip:
                                                'Mostrar u ocultar contraseña',
                                            onPressed: () => setState(
                                              () =>
                                                  hidePassword = !hidePassword,
                                            ),
                                            icon: Icon(
                                              hidePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                        .visibility_off_outlined,
                                            ),
                                          ),
                                        ),
                                        validator: (s) => s == null || s.isEmpty
                                            ? 'Ingresá tu contraseña.'
                                            : null,
                                        onFieldSubmitted: (_) {
                                          if (Backend.ready && !busy) login();
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                      FilledButton(
                                        onPressed: Backend.ready && !busy
                                            ? login
                                            : null,
                                        child: Text(
                                          busy ? 'Verificando…' : 'Ingresar',
                                        ),
                                      ),
                                      if (!Backend.ready)
                                        const Padding(
                                          padding: EdgeInsets.only(top: 16),
                                          child: Text(
                                            'Acceso pendiente de configurar Firebase. No hay cuentas de prueba ni contraseñas predeterminadas.',
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (!Backend.ready) ...[
                              const SizedBox(height: 32),
                              const Text(
                                'Vista previa del inventario · Sin datos reales ni guardado',
                              ),
                              const SizedBox(height: 16),
                              const InventoryPage(preview: true),
                            ],
                          ],
                        ),
                ),
              ),
            ),
          ),
  );
}

class InventoryPage extends StatelessWidget {
  final bool preview;
  const InventoryPage({super.key, this.preview = false});
  @override
  Widget build(BuildContext context) {
    if (preview) return inventory(context, const []);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: Backend.db
          .collection('movements')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Sheet(child: Text(Backend.message(snapshot.error!)));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        return inventory(
          context,
          snapshot.data!.docs.map((d) => d.data()).toList(),
        );
      },
    );
  }

  Widget inventory(BuildContext context, List<Map<String, dynamic>> movements) {
    final names = {for (final name in baseParts) partKey(name): name};
    final totals = <String, int>{};
    for (final row in movements) {
      final name = row['name'] as String;
      final key = partKey(name);
      names.putIfAbsent(key, () => name);
      totals[key] = (totals[key] ?? 0) + (row['quantity'] as num).toInt();
    }
    final sum = totals.values.fold<int>(0, (a, b) => a + b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 24,
          runSpacing: 16,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inventario de piezas',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '$sum piezas registradas · ${names.length} tipos de componentes',
                ),
              ],
            ),
            FilledButton.icon(
              onPressed: preview
                  ? null
                  : () => showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          AddPartDialog(existingNames: names.values.toList()),
                    ),
              icon: const Icon(Icons.add),
              label: const Text('Agregar pieza'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 850
                ? 4
                : constraints.maxWidth >= 560
                ? 3
                : constraints.maxWidth >= 360
                ? 2
                : 1;
            final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: names.entries
                  .map(
                    (entry) => SizedBox(
                      width: width,
                      child: Sheet(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              partIcon(entry.value),
                              color: brandBlue,
                              size: 28,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              '${totals[entry.key] ?? 0}',
                              style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                                color: ink,
                              ),
                            ),
                            Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 28),
        Text(
          'Historial de ingresos',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (movements.isEmpty)
          const Sheet(
            child: Text(
              'Aún no hay ingresos registrados. Las cantidades comienzan en cero.',
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Pieza')),
                DataColumn(label: Text('Cantidad'), numeric: true),
                DataColumn(label: Text('Estado / notas')),
                DataColumn(label: Text('Fecha')),
              ],
              rows: movements.map((row) {
                final stamp = row['createdAt'] as Timestamp?;
                final date = stamp?.toDate().toLocal();
                final label = date == null
                    ? 'Guardando…'
                    : '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                return DataRow(
                  cells: [
                    DataCell(Text(row['name'] as String)),
                    DataCell(Text('${row['quantity']}')),
                    DataCell(
                      SizedBox(
                        width: 250,
                        child: Text(
                          (row['note'] as String).isEmpty
                              ? 'Sin notas'
                              : row['note'] as String,
                        ),
                      ),
                    ),
                    DataCell(Text(label)),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class AddPartDialog extends StatefulWidget {
  final List<String> existingNames;
  const AddPartDialog({super.key, required this.existingNames});
  @override
  State<AddPartDialog> createState() => _AddPartDialogState();
}

class _AddPartDialogState extends State<AddPartDialog> {
  final form = GlobalKey<FormState>();
  final custom = TextEditingController();
  final quantity = TextEditingController();
  final note = TextEditingController();
  String selected = baseParts.first;
  bool busy = false;
  static const other = '__other__';
  @override
  void dispose() {
    custom.dispose();
    quantity.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    final name = selected == other
        ? custom.text.trim().replaceAll(RegExp(r'\s+'), ' ')
        : selected;
    final canonical =
        widget.existingNames
            .where((s) => partKey(s) == partKey(name))
            .firstOrNull ??
        name;
    try {
      await Backend.db.collection('movements').add({
        'name': canonical,
        'quantity': int.parse(quantity.text.trim()),
        'note': note.text.trim(),
        'createdBy': Backend.auth.currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        notify(context, 'Ingreso registrado correctamente.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) notify(context, Backend.message(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: AlertDialog(
      title: const Text('Agregar piezas al inventario'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selected,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Tipo de pieza'),
                  items: [
                    ...widget.existingNames.map(
                      (s) => DropdownMenuItem(value: s, child: Text(s)),
                    ),
                    const DropdownMenuItem(
                      value: other,
                      child: Text('+ Añadir otra pieza'),
                    ),
                  ],
                  onChanged: busy ? null : (v) => setState(() => selected = v!),
                ),
                if (selected == other) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: custom,
                    enabled: !busy,
                    maxLength: 80,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la nueva pieza',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Escribí el nombre de la pieza.'
                        : null,
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: quantity,
                  enabled: !busy,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad que ingresa',
                  ),
                  validator: (v) {
                    final n = int.tryParse(v?.trim() ?? '');
                    return n == null || n < 1 || n > 1000000
                        ? 'Ingresá un entero entre 1 y 1000000.'
                        : null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: note,
                  enabled: !busy,
                  maxLength: 1000,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Estado de las piezas / notas (opcional)',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: busy ? null : save,
          child: Text(busy ? 'Guardando…' : 'Guardar ingreso'),
        ),
      ],
    ),
  );
}
