import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'map_stub.dart' if (dart.library.js_interop) 'map_web.dart';

import 'backend.dart';
import 'config.dart';
import 'brand_theme.dart';

part 'admin_inventory.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Backend.initialize();
  runApp(RenovaxApp());
}

class RenovaxApp extends StatelessWidget {
  const RenovaxApp({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: appTheme,
    builder: (context, mode, _) => MaterialApp(
      title: 'Renovax · Tecnología con otra oportunidad',
      debugShowCheckedModeBanner: false,
      theme: buildBrandTheme(false),
      darkTheme: buildBrandTheme(true),
      themeMode: mode,
      routes: {
        '/': (_) => PublicPage(),
        '/acopio': (_) => CenterPage(),
        '/admin': (_) => AdminPage(),
      },
    ),
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
    padding: EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: borderColor),
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
  static final labels = ['Inicio', 'Misión', 'Visión', 'Donaciones'];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: headerColors),
            ),
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 20,
              runSpacing: 12,
              children: [
                BrandLogo(),
                Wrap(
                  spacing: 6,
                  children: List.generate(
                    labels.length,
                    (i) => TextButton(
                      onPressed: () => setState(() => section = i),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: section == i
                            ? navSelectionColor
                            : Colors.transparent,
                      ),
                      child: Text(labels[i]),
                    ),
                  ),
                ),
                ThemeToggle(),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: borderColor),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/admin'),
                  icon: Icon(Icons.lock_outline, size: 18),
                  label: Text('Administración'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 1120),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!Backend.ready) ...[
                          Sheet(
                            child: Text(
                              Backend.startupError ?? 'Vista previa · La conexión con Google y el guardado se habilitarán al configurar Firebase.',
                            ),
                          ),
                          SizedBox(height: 24),
                        ],
                        if (section == 0) ...[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: heroColors),
                              border: Border.all(color: borderColor),
                              boxShadow: [
                                BoxShadow(
                                  color: glowColor,
                                  blurRadius: 24,
                                  offset: Offset(0, 8),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'RECUPERAR · TRANSFORMAR · CONECTAR',
                                  style: TextStyle(
                                    color: accentColor,
                                    letterSpacing: 2,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'Tu celular en desuso.\nUna nueva posibilidad.',
                                  style: TextStyle(
                                    color: headingColor,
                                    fontSize: 44,
                                    height: 1.1,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Recuperamos componentes de teléfonos para darles otra vida en proyectos útiles para nuestra comunidad.',
                                  style: TextStyle(
                                    color: mutedColor,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 28),
                                FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: accentColor,
                                    foregroundColor: buttonTextColor,
                                  ),
                                  onPressed: () => setState(() => section = 3),
                                  icon: Icon(Icons.arrow_forward),
                                  label: Text('Quiero donar un celular'),
                                ),
                                SizedBox(height: 28),
                                Wrap(
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
                          SizedBox(height: 32),
                          Text(
                            'Cada componente cuenta',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Estas son las piezas que recuperamos y registramos en nuestro inventario.',
                          ),
                          SizedBox(height: 18),
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
                          SizedBox(height: 28),
                          Sheet(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Así comienza una segunda vida',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: headingColor,
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
                          PurposePage(
                            vision: section == 2,
                            onDonate: () => setState(() => section = 3),
                          ),
                        if (section == 3) DonationPage(),
                        SizedBox(height: 40),
                        Divider(),
                        Text(
                          'RENOVAX  /  Tecnología con otra oportunidad',
                          style: TextStyle(color: accentColor),
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
      SizedBox(height: 10),
      Text('Registrá tu equipo y encontrá dónde entregarlo.'),
      SizedBox(height: 24),
      Sheet(
        child: Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '01 / Tus datos',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: headingColor,
                ),
              ),
              SizedBox(height: 16),
              if (!googleUser) ...[
                Text(
                  'Iniciá sesión con Google para completar automáticamente tu nombre y correo.',
                ),
                SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: Backend.ready && !busy ? signIn : null,
                  icon: Icon(Icons.account_circle_outlined),
                  label: Text(busy ? 'Conectando…' : 'Continuar con Google'),
                ),
                if (!Backend.ready)
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text('Google pendiente de configurar.'),
                  ),
              ] else ...[
                TextFormField(
                  key: ValueKey('name-${user!.uid}'),
                  initialValue: user!.displayName ?? '',
                  readOnly: true,
                  decoration: InputDecoration(labelText: 'Nombre de Google'),
                ),
                SizedBox(height: 14),
                TextFormField(
                  key: ValueKey('email-${user!.uid}'),
                  initialValue: user!.email ?? '',
                  readOnly: true,
                  decoration: InputDecoration(labelText: 'Correo de Google'),
                ),
                TextButton(
                  onPressed: busy
                      ? null
                      : () async {
                          await Backend.auth.signOut();
                          if (mounted) setState(() => consent = false);
                        },
                  child: Text('Usar otra cuenta'),
                ),
              ],
              SizedBox(height: 18),
              TextFormField(
                controller: model,
                maxLength: 120,
                enabled: !busy,
                decoration: InputDecoration(
                  labelText: 'Modelo del celular (opcional)',
                  hintText: 'Ej.: Samsung Galaxy A12',
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: note,
                maxLength: 1000,
                maxLines: 3,
                enabled: !busy,
                decoration: InputDecoration(
                  labelText: 'Nota (opcional)',
                  hintText: 'Contanos sobre el estado del equipo.',
                ),
              ),
              SizedBox(height: 24),
              Text(
                '02 / Tu centro de acopio',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: headingColor,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Seleccioná tu departamento o región. Por ahora solo Matagalpa tiene un centro habilitado.',
              ),
              SizedBox(height: 14),
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
              SizedBox(height: 20),
              if (department == 'Matagalpa') ...[
                AcopioMap(),
                SizedBox(height: 12),
                Text(Acopio.locationNote),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.school_outlined, color: accentColor),
                  title: Text(Acopio.name),
                  subtitle: Text('Matagalpa · Ver información del centro'),
                  trailing: Icon(Icons.open_in_new),
                  onTap: () => openCenter(context),
                ),
              ] else
                Text(
                  'Todavía no hay un centro de acopio disponible en este departamento o región. No se puede registrar una entrega aquí.',
                ),
              SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: consent,
                onChanged: busy
                    ? null
                    : (v) => setState(() => consent = v ?? false),
                title: Text(
                  'Autorizo guardar mi nombre, correo y los datos de esta donación para coordinar la entrega.',
                ),
              ),
              SizedBox(height: 12),
              FilledButton.icon(
                onPressed:
                    Backend.ready &&
                        googleUser &&
                        consent &&
                        department == 'Matagalpa' &&
                        !busy
                    ? save
                    : null,
                icon: Icon(Icons.volunteer_activism),
                label: Text(busy ? 'Procesando…' : 'Registrar donación'),
              ),
              SizedBox(height: 12),
              Text(
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
      actions: [ThemeToggle(compact: true)],
      title: Row(
        children: [
          BrandLogo(width: 135),
          SizedBox(width: 18),
          Flexible(child: Text('Centro de acopio')),
        ],
      ),
      leading: IconButton(
        icon: Icon(Icons.home_outlined),
        onPressed: () =>
            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
      ),
    ),
    body: SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 850),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Sheet(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.school_outlined, size: 48, color: accentColor),
                  SizedBox(height: 18),
                  Text(
                    Acopio.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text('Matagalpa, Nicaragua'),
                  SizedBox(height: 24),
                  ListTile(
                    leading: Icon(Icons.place_outlined),
                    title: Text('Dirección'),
                    subtitle: Text(Acopio.address),
                  ),
                  ListTile(
                    leading: Icon(Icons.calendar_today_outlined),
                    title: Text('Días de atención'),
                    subtitle: Text(Acopio.days),
                  ),
                  ListTile(
                    leading: Icon(Icons.schedule),
                    title: Text('Horas de atención'),
                    subtitle: Text(Acopio.hours),
                  ),
                  SizedBox(height: 20),
                  AcopioMap(),
                  SizedBox(height: 12),
                  Text(Acopio.locationNote),
                  SizedBox(height: 20),
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
                    icon: Icon(Icons.chat_outlined),
                    label: Text('Contactar por WhatsApp'),
                  ),
                  if (Acopio.whatsapp.isEmpty)
                    Padding(
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
      title: Row(
        children: [
          BrandLogo(width: 135),
          SizedBox(width: 18),
          Flexible(child: Text('Administración')),
        ],
      ),
      actions: [
        ThemeToggle(compact: true),
        if (authorized)
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () async {
              await Backend.auth.signOut();
              if (mounted) setState(() => authorized = false);
            },
            icon: Icon(Icons.logout),
            label: Text('Salir'),
          ),
      ],
    ),
    body: checking
        ? Center(child: CircularProgressIndicator())
        : authorized
        ? AdminInventoryPanel(fullScreen: true)
        : SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1120),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: authorized
                      ? AdminInventoryPanel()
                      : Column(
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 480),
                              child: Sheet(
                                child: Form(
                                  key: loginForm,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.lock_outline,
                                        color: accentColor,
                                        size: 40,
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        'Acceso de administrador',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Ingresá con el correo y la contraseña de tu cuenta autorizada.',
                                      ),
                                      SizedBox(height: 24),
                                      TextFormField(
                                        controller: email,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        autofillHints: [AutofillHints.username],
                                        enabled: !busy,
                                        decoration: InputDecoration(
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
                                      SizedBox(height: 16),
                                      TextFormField(
                                        controller: password,
                                        obscureText: hidePassword,
                                        autofillHints: [AutofillHints.password],
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
                                      SizedBox(height: 24),
                                      FilledButton(
                                        onPressed: Backend.ready && !busy
                                            ? login
                                            : null,
                                        child: Text(
                                          busy ? 'Verificando…' : 'Ingresar',
                                        ),
                                      ),
                                      if (!Backend.ready)
                                        Padding(
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
                              SizedBox(height: 32),
                              Text(
                                'Vista previa del inventario · Sin datos reales ni guardado',
                              ),
                              SizedBox(height: 16),
                              AdminInventoryPanel(preview: true),
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
    if (preview) return inventory(context, []);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: Backend.db
          .collection('movements')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Sheet(child: Text(Backend.message(snapshot.error!)));
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
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
                SizedBox(height: 8),
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
              icon: Icon(Icons.add),
              label: Text('Agregar pieza'),
            ),
          ],
        ),
        SizedBox(height: 24),
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
                              color: accentColor,
                              size: 28,
                            ),
                            SizedBox(height: 18),
                            Text(
                              '${totals[entry.key] ?? 0}',
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                                color: headingColor,
                              ),
                            ),
                            Text(
                              entry.value,
                              style: TextStyle(
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
  static final other = '__other__';
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
      title: Text('Agregar piezas al inventario'),
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
                  decoration: InputDecoration(labelText: 'Tipo de pieza'),
                  items: [
                    ...widget.existingNames.map(
                      (s) => DropdownMenuItem(value: s, child: Text(s)),
                    ),
                    DropdownMenuItem(
                      value: other,
                      child: Text('+ Añadir otra pieza'),
                    ),
                  ],
                  onChanged: busy ? null : (v) => setState(() => selected = v!),
                ),
                if (selected == other) ...[
                  SizedBox(height: 16),
                  TextFormField(
                    controller: custom,
                    enabled: !busy,
                    maxLength: 80,
                    decoration: InputDecoration(
                      labelText: 'Nombre de la nueva pieza',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Escribí el nombre de la pieza.'
                        : null,
                  ),
                ],
                SizedBox(height: 16),
                TextFormField(
                  controller: quantity,
                  enabled: !busy,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Cantidad que ingresa',
                  ),
                  validator: (v) {
                    final n = int.tryParse(v?.trim() ?? '');
                    return n == null || n < 1 || n > 1000000
                        ? 'Ingresá un entero entre 1 y 1000000.'
                        : null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: note,
                  enabled: !busy,
                  maxLength: 1000,
                  maxLines: 3,
                  decoration: InputDecoration(
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
          child: Text('Cancelar'),
        ),
        FilledButton(
          onPressed: busy ? null : save,
          child: Text(busy ? 'Guardando…' : 'Guardar ingreso'),
        ),
      ],
    ),
  );
}

class PurposePage extends StatelessWidget {
  final bool vision;
  final VoidCallback onDonate;
  const PurposePage({super.key, required this.vision, required this.onDonate});

  @override
  Widget build(BuildContext context) {
    final title = vision ? 'Nuestra visión' : 'Nuestra misión';
    final headline = vision
        ? 'Imaginar un futuro.\nConstruirlo con lo que tenemos.'
        : 'La tecnología merece\nuna segunda oportunidad.';
    final statement = vision
        ? 'Construir una comunidad en Nicaragua donde la tecnología se reutilice de forma responsable y se transforme en oportunidades educativas, ambientales y sociales.'
        : 'Dar una segunda vida a los componentes de teléfonos en desuso, promoviendo la donación responsable, la innovación y el aprovechamiento tecnológico para beneficio de la comunidad.';
    final pillars = vision
        ? [
            (
              Icons.school_outlined,
              'Aprender haciendo',
              'Acercar la experimentación tecnológica a estudiantes y comunidades mediante proyectos que aprovechen componentes recuperados.',
            ),
            (
              Icons.hub_outlined,
              'Conectar a la comunidad',
              'Crear vínculos entre personas que donan, centros de acopio y quienes desarrollan nuevas aplicaciones para la tecnología.',
            ),
            (
              Icons.eco_outlined,
              'Reutilizar con propósito',
              'Promover una cultura en la que evaluar, recuperar y reutilizar sea parte del ciclo de vida de nuestros dispositivos.',
            ),
          ]
        : [
            (
              Icons.volunteer_activism_outlined,
              'Recibir con responsabilidad',
              'Facilitar la donación de celulares y orientar a las personas sobre el centro de acopio y el cuidado de sus datos.',
            ),
            (
              Icons.memory_outlined,
              'Evaluar y recuperar',
              'Identificar componentes aprovechables y registrar las piezas que ingresan para conocer su cantidad y estado.',
            ),
            (
              Icons.lightbulb_outline,
              'Transformar en posibilidades',
              'Explorar usos educativos y comunitarios para los componentes que superen la evaluación técnica.',
            ),
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          vision ? '02 / EL FUTURO QUE IMAGINAMOS' : '01 / LO QUE NOS MUEVE',
          style: TextStyle(
            color: accentColor,
            letterSpacing: 2,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 18),
        Container(
          padding: EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: heroColors),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final copy = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 16),
                  Text(
                    headline,
                    style: TextStyle(
                      fontSize: constraints.maxWidth > 650 ? 38 : 28,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      color: headingColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    statement,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.6,
                      color: mutedColor,
                    ),
                  ),
                  SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: onDonate,
                    icon: Icon(Icons.arrow_forward),
                    label: Text(
                      vision
                          ? 'Ser parte de este futuro'
                          : 'Quiero aportar con una donación',
                    ),
                  ),
                ],
              );
              final photo = ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  vision ? 'component_gps.jpg' : 'component_motion.jpg',
                  height: 320,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  semanticLabel: vision
                      ? 'Ilustración de un módulo GPS sobre fondo celeste'
                      : 'Ilustración de un sensor de movimiento MPU-6050 sobre fondo celeste',
                ),
              );
              if (constraints.maxWidth >= 800)
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 6, child: copy),
                    SizedBox(width: 32),
                    Expanded(flex: 5, child: photo),
                  ],
                );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [copy, SizedBox(height: 28), photo],
              );
            },
          ),
        ),
        SizedBox(height: 32),
        Text(
          vision
              ? 'Tres horizontes para crecer'
              : 'Cómo llevamos nuestra misión a la práctica',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth >= 850
                ? (constraints.maxWidth - 32) / 3
                : constraints.maxWidth;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: pillars
                  .map(
                    (p) => SizedBox(
                      width: width,
                      child: Sheet(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(p.$1, color: accentColor, size: 30),
                            SizedBox(height: 18),
                            Text(
                              p.$2,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(height: 12),
                            Text(
                              p.$3,
                              style: TextStyle(height: 1.6, color: mutedColor),
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
        SizedBox(height: 32),
        Text(
          vision
              ? 'Componentes pequeños. Ideas que pueden crecer.'
              : 'Una mirada a lo que podemos aprovechar',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: 10),
        Text(
          'Imágenes ilustrativas de componentes y usos posibles. Cada pieza requiere evaluación técnica antes de reutilizarse.',
          style: TextStyle(color: mutedColor, height: 1.5),
        ),
        SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 850
                ? 3
                : constraints.maxWidth >= 550
                ? 2
                : 1;
            final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
            final components = [
              (
                'component_gps.jpg',
                'GPS / Localización',
                'Explorar proyectos de orientación, registro de recorridos y ubicación de equipos.',
              ),
              (
                'component_motion.jpg',
                'Movimiento / Orientación',
                'Aprender sobre aceleración, inclinación y cambios de posición mediante experimentos.',
              ),
              (
                'component_camera.jpg',
                'Cámara / Observación',
                'Imaginar herramientas de observación y aprendizaje visual con respeto a la privacidad.',
              ),
            ];
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: components
                  .map(
                    (p) => SizedBox(
                      width: width,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              p.$1,
                              height: 230,
                              width: width,
                              fit: BoxFit.cover,
                              semanticLabel: 'Ilustración de ${p.$2}',
                            ),
                            Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.$2,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    p.$3,
                                    style: TextStyle(
                                      color: mutedColor,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
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
        SizedBox(height: 28),
        Sheet(
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 24,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'El siguiente paso puede empezar con vos.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text('Conocé el acopio disponible en CUR UNAN Matagalpa.'),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => openCenter(context),
                icon: Icon(Icons.place_outlined),
                label: Text('Ver centro de acopio'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
