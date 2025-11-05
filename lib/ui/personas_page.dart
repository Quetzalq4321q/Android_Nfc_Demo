import 'package:flutter/material.dart';
import '../models/persona.dart';
import '../services/persona_service.dart';
import '../services/nfc_writer_service.dart';
import '../utils/colores.dart';
import '../utils/id_utils.dart';

class PersonasPage extends StatefulWidget {
  const PersonasPage({super.key});
  @override
  State<PersonasPage> createState() => _PersonasPageState();
}

class _PersonasPageState extends State<PersonasPage> {
  final _svc = PersonaService();
  final _writer = NfcWriterService();
  final _searchCtrl = TextEditingController();

  List<Persona> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final q = _searchCtrl.text.trim();
    final data = q.isEmpty ? await _svc.listarTodos() : await _svc.buscar(q);
    setState(() { _items = data; _loading = false; });
  }

  Future<void> _crearEditar({Persona? base}) async {
    final res = await showDialog<_PersonaFormResult>(
      context: context,
      builder: (_) => _PersonaDialog(base: base),
    );
    if (res == null) return;

    try {
      if (base == null) {
        await _svc.crear(studentId: res.studentId, nombre: res.nombre);
        _snack('Persona creada');
      } else {
        await _svc.editar(id: base.id!, studentId: res.studentId, nombre: res.nombre);
        _snack('Persona actualizada');
      }
      await _load();
    } catch (e) {
      _error(e.toString());
    }
  }

  Future<void> _eliminar(Persona p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar persona'),
        content: Text('¿Seguro que deseas eliminar a "${p.nombre}" (${p.studentId})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _svc.eliminarPorId(p.id!);
      _snack('Eliminado');
      await _load();
    } catch (e) {
      _error(e.toString());
    }
  }

  Future<void> _escribirNfc(Persona p) async {
    try {
      _snack('Acerca la tarjeta para escribir ${p.studentId}…');
      await _writer.writeStudentId(p.studentId);
      _snack('✅ StudentID escrito en la tarjeta');
    } catch (e) {
      _error('Error al escribir NFC: $e');
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  void _error(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.redAccent));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Personas'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Añadir persona',
            onPressed: () => _crearEditar(),
            icon: const Icon(Icons.person_add_alt_1_rounded),
          ),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          minimum: const EdgeInsets.all(20),
          child: Column(
            children: [
              GlassCard(
                child: Row(
                  children: [
                    const Icon(Icons.search),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Buscar por nombre o StudentID…',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _load(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _load,
                      icon: const Icon(Icons.search_rounded),
                      label: const Text('Buscar'),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(0),
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _items.isEmpty
                      ? const _Empty()
                      : ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: Colors.white.withOpacity(0.06)),
                    itemBuilder: (_, i) {
                      final p = _items[i];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(p.nombre.isNotEmpty ? p.nombre[0].toUpperCase() : '?'),
                        ),
                        title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('ID: ${p.studentId} • ${_fmt(p.createdAt)}'),
                        trailing: Wrap(
                          spacing: 6,
                          children: [
                            IconButton(
                              tooltip: 'Escribir en NFC',
                              onPressed: () => _escribirNfc(p),
                              icon: const Icon(Icons.contactless),
                            ),
                            IconButton(
                              tooltip: 'Editar',
                              onPressed: () => _crearEditar(base: p),
                              icon: const Icon(Icons.edit_rounded),
                            ),
                            IconButton(
                              tooltip: 'Eliminar',
                              onPressed: () => _eliminar(p),
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _crearEditar(),
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
    );
  }

  String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outline, size: 48, color: Colors.white.withOpacity(0.6)),
            const SizedBox(height: 8),
            const Text('Sin personas registradas', style: TextStyle(fontWeight: FontWeight.w600)),
            Text('Crea tu primer registro tocando “Nueva”.', style: TextStyle(color: Colors.white.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}

class _PersonaDialog extends StatefulWidget {
  const _PersonaDialog({required this.base});
  final Persona? base;

  @override
  State<_PersonaDialog> createState() => _PersonaDialogState();
}

class _PersonaDialogState extends State<_PersonaDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _idCtrl;
  late final TextEditingController _nomCtrl;

  @override
  void initState() {
    super.initState();
    _idCtrl = TextEditingController(text: widget.base?.studentId ?? '');
    _nomCtrl = TextEditingController(text: widget.base?.nombre ?? '');
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _nomCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.base == null ? 'Nueva persona' : 'Editar persona'),
      content: Form(
        key: _form,
        child: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _idCtrl,
                decoration: const InputDecoration(
                  labelText: 'Student ID',
                  hintText: 'Ej: A12B34C56',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa un StudentID';
                  if (!IdUtils.isValidStudentId(v.trim())) return 'Formato inválido (mín. 6, alfanumérico)';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nomCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa un nombre';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            Navigator.pop(context, _PersonaFormResult(
              studentId: _idCtrl.text.trim().toUpperCase(),
              nombre: _nomCtrl.text.replaceAll(RegExp(r'\s+'), ' ').trim(),
            ));
          },
          child: Text(widget.base == null ? 'Crear' : 'Guardar'),
        ),
      ],
    );
  }
}

class _PersonaFormResult {
  final String studentId;
  final String nombre;
  _PersonaFormResult({required this.studentId, required this.nombre});
}
