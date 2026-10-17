part of 'main.dart';

enum AdminSection {
  parts('Inventario de piezas', Icons.memory_outlined),
  devices('Inventario de dispositivos', Icons.phone_android_outlined),
  history('Historial de ingresos', Icons.history);

  final String label;
  final IconData icon;
  const AdminSection(this.label, this.icon);
}

class AdminInventoryPanel extends StatefulWidget {
  final bool preview;
  const AdminInventoryPanel({super.key, this.preview = false});

  @override
  State<AdminInventoryPanel> createState() => _AdminInventoryPanelState();
}

class _AdminInventoryPanelState extends State<AdminInventoryPanel> {
  AdminSection selected = AdminSection.parts;
  bool expanded = true;

  Widget navigation() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final section in AdminSection.values)
            if (expanded)
              ListTile(
                key: ValueKey('admin-section-${section.name}'),
                leading: Icon(section.icon),
                title: Text(section.label),
                selected: selected == section,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () => setState(() => selected = section),
              )
            else
              IconButton.filledTonal(
                key: ValueKey('admin-section-${section.name}'),
                tooltip: section.label,
                isSelected: selected == section,
                onPressed: () => setState(() => selected = section),
                icon: Icon(section.icon),
              ),
        ],
      );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final content = switch (selected) {
            AdminSection.parts => InventoryPage(preview: widget.preview),
            AdminSection.devices =>
              DeviceInventoryPage(preview: widget.preview),
            AdminSection.history => IncomeHistoryPage(preview: widget.preview),
          };
          if (constraints.maxWidth < 850) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: ExpansionTile(
                    key: const ValueKey('admin-mobile-menu'),
                    leading: const Icon(Icons.menu),
                    title: const Text('Secciones de administración'),
                    subtitle: Text(selected.label),
                    children: [
                      for (final section in AdminSection.values)
                        ListTile(
                          key: ValueKey('admin-section-${section.name}'),
                          leading: Icon(section.icon),
                          title: Text(section.label),
                          selected: selected == section,
                          onTap: () => setState(() => selected = section),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                content,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: expanded ? 248 : 80,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            if (expanded)
                              const Expanded(child: Text('Administración')),
                            IconButton(
                              tooltip:
                                  expanded ? 'Contraer menú' : 'Expandir menú',
                              onPressed: () =>
                                  setState(() => expanded = !expanded),
                              icon:
                                  Icon(expanded ? Icons.menu_open : Icons.menu),
                            ),
                          ],
                        ),
                        const Divider(),
                        navigation(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(child: content),
            ],
          );
        },
      );
}

class InventoryRecords extends StatelessWidget {
  final String collection;
  final bool preview;
  final Widget Function(List<Map<String, dynamic>>) builder;
  const InventoryRecords({
    super.key,
    required this.collection,
    required this.preview,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (preview) return builder([]);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: Backend.db
          .collection(collection)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Sheet(child: Text(Backend.message(snapshot.error!)));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return builder(snapshot.data!.docs.map((doc) => doc.data()).toList());
      },
    );
  }
}

class DeviceInventoryPage extends StatelessWidget {
  final bool preview;
  const DeviceInventoryPage({super.key, this.preview = false});

  @override
  Widget build(BuildContext context) => InventoryRecords(
        collection: 'devices',
        preview: preview,
        builder: (entries) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inventario de dispositivos',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Registrá teléfonos completos y consultá su estado.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: preview
                  ? null
                  : () => showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const AddDeviceDialog(),
                      ),
              icon: const Icon(Icons.add),
              label: const Text('Agregar dispositivo'),
            ),
            const SizedBox(height: 24),
            DeviceInventoryTable(entries: entries),
          ],
        ),
      );
}

class DeviceInventoryTable extends StatelessWidget {
  final List<Map<String, dynamic>> entries;
  const DeviceInventoryTable({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final groups = <(String, String, String), Map<String, dynamic>>{};
    var total = 0;
    for (final entry in entries) {
      final brand = entry['brand'] as String;
      final model = entry['model'] as String;
      final condition = entry['condition'] as String;
      final quantity = (entry['quantity'] as num).toInt();
      final key = (partKey(brand), partKey(model), condition);
      final group = groups.putIfAbsent(key, () => {...entry, 'quantity': 0});
      group['quantity'] = (group['quantity'] as int) + quantity;
      total += quantity;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$total teléfonos registrados',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          const Sheet(child: Text('Aún no hay dispositivos registrados.'))
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Marca')),
                DataColumn(label: Text('Modelo')),
                DataColumn(label: Text('Estado')),
                DataColumn(label: Text('Cantidad'), numeric: true),
              ],
              rows: groups.values
                  .map(
                    (entry) => DataRow(
                      cells: [
                        DataCell(Text(entry['brand'] as String)),
                        DataCell(Text(entry['model'] as String)),
                        DataCell(Text(entry['condition'] as String)),
                        DataCell(Text('${entry['quantity']}')),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class IncomeHistoryPage extends StatelessWidget {
  final bool preview;
  const IncomeHistoryPage({super.key, this.preview = false});

  @override
  Widget build(BuildContext context) => InventoryRecords(
        collection: 'movements',
        preview: preview,
        builder: (parts) => InventoryRecords(
          collection: 'devices',
          preview: preview,
          builder: (devices) =>
              IncomeHistoryTable(parts: parts, devices: devices),
        ),
      );
}

class IncomeHistoryTable extends StatelessWidget {
  final List<Map<String, dynamic>> parts;
  final List<Map<String, dynamic>> devices;
  const IncomeHistoryTable({
    super.key,
    required this.parts,
    required this.devices,
  });

  @override
  Widget build(BuildContext context) {
    final entries = [
      for (final part in parts) {...part, 'type': 'Pieza', 'condition': '—'},
      for (final device in devices)
        {
          ...device,
          'type': 'Dispositivo',
          'name': '${device['brand']} ${device['model']}',
        },
    ]..sort((a, b) {
        final first = a['createdAt'] as Timestamp?;
        final second = b['createdAt'] as Timestamp?;
        if (first == null) return second == null ? 0 : -1;
        if (second == null) return 1;
        return second.compareTo(first);
      });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historial de ingresos',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text(
            'Ingresos de piezas y teléfonos, del más reciente al más antiguo.'),
        const SizedBox(height: 24),
        if (entries.isEmpty)
          const Sheet(child: Text('Aún no hay ingresos registrados.'))
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Tipo')),
                DataColumn(label: Text('Pieza / dispositivo')),
                DataColumn(label: Text('Cantidad'), numeric: true),
                DataColumn(label: Text('Estado')),
                DataColumn(label: Text('Notas')),
                DataColumn(label: Text('Fecha')),
              ],
              rows: entries.map((entry) {
                final date =
                    (entry['createdAt'] as Timestamp?)?.toDate().toLocal();
                final label = date == null
                    ? 'Guardando…'
                    : '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                final note = entry['note'] as String? ?? '';
                return DataRow(
                  cells: [
                    DataCell(Text(entry['type'] as String)),
                    DataCell(Text(entry['name'] as String)),
                    DataCell(Text('${entry['quantity']}')),
                    DataCell(Text(entry['condition'] as String)),
                    DataCell(SizedBox(
                        width: 220,
                        child: Text(note.isEmpty ? 'Sin notas' : note))),
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

const deviceConditions = [
  'Pendiente de evaluación',
  'Funcional',
  'Para reparar',
  'Para recuperar piezas',
];

class AddDeviceDialog extends StatefulWidget {
  const AddDeviceDialog({super.key});

  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  final form = GlobalKey<FormState>();
  final brand = TextEditingController();
  final model = TextEditingController();
  final quantity = TextEditingController(text: '1');
  final note = TextEditingController();
  String condition = deviceConditions.first;
  bool busy = false;

  @override
  void dispose() {
    brand.dispose();
    model.dispose();
    quantity.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      await Backend.db.collection('devices').add({
        'brand': brand.text.trim().replaceAll(RegExp(r'\s+'), ' '),
        'model': model.text.trim().replaceAll(RegExp(r'\s+'), ' '),
        'quantity': int.parse(quantity.text.trim()),
        'condition': condition,
        'note': note.text.trim(),
        'createdBy': Backend.auth.currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        notify(context, 'Ingreso de dispositivos registrado correctamente.');
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) notify(context, Backend.message(error));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !busy,
        child: AlertDialog(
          title: const Text('Agregar dispositivo'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Form(
                key: form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: brand,
                      enabled: !busy,
                      maxLength: 80,
                      decoration: const InputDecoration(labelText: 'Marca'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Escribí la marca del teléfono.'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: model,
                      enabled: !busy,
                      maxLength: 120,
                      decoration: const InputDecoration(labelText: 'Modelo'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Escribí el modelo del teléfono.'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: quantity,
                      enabled: !busy,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Cantidad que ingresa'),
                      validator: (value) {
                        final count = int.tryParse(value?.trim() ?? '');
                        return count == null || count < 1 || count > 1000000
                            ? 'Ingresá un entero entre 1 y 1000000.'
                            : null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: condition,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: [
                        for (final value in deviceConditions)
                          DropdownMenuItem(value: value, child: Text(value)),
                      ],
                      onChanged: busy
                          ? null
                          : (value) => setState(() => condition = value!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: note,
                      enabled: !busy,
                      maxLength: 1000,
                      maxLines: 3,
                      decoration:
                          const InputDecoration(labelText: 'Notas (opcional)'),
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
