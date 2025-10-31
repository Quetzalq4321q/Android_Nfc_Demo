import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/persona.dart';
import '../services/persona_service.dart';

class PersonasPage extends StatefulWidget {
  const PersonasPage({super.key});

  @override
  State<PersonasPage> createState() => _PersonasPageState();
}

class _PersonasPageState extends State<PersonasPage> {
  late PersonaService _personaService;
  late Future<List<Persona>> _personasFuture;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _personaService = context.read<PersonaService>();
      _personasFuture = _personaService.allPersonas();
      _initialized = true;
    }
  }

  Future<void> _reload() async {
    final future = _personaService.allPersonas();
    if (!mounted) return;
    setState(() {
      _personasFuture = future;
    });
    await future;
  }

  Future<void> _refresh() async {
    await _reload();
  }

  Future<void> _showPersonaForm({Persona? persona}) async {
    final messenger = ScaffoldMessenger.of(context);
    final formKey = GlobalKey<FormState>();
    final idCtrl = TextEditingController(text: persona?.id ?? '');
    final nameCtrl = TextEditingController(text: persona?.nombre ?? '');
    final groupCtrl = TextEditingController(text: persona?.grupo ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(persona == null ? 'Registrar persona' : 'Editar persona'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: idCtrl,
                    decoration: const InputDecoration(labelText: 'ID (NFC)'),
                    autofocus: persona == null,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El ID es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: groupCtrl,
                    decoration: const InputDecoration(labelText: 'Grupo (opcional)'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final personaToSave = Persona(
                  id: idCtrl.text.trim(),
                  nombre: nameCtrl.text.trim(),
                  grupo: groupCtrl.text.trim(),
                );
                try {
                  await _personaService.insertOrReplacePersona(personaToSave);
                  if (!mounted) return;
                  Navigator.of(dialogContext).pop(true);
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Error al guardar: $e')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (saved == true) {
      await _reload();
      messenger.showSnackBar(
        SnackBar(
          content: Text(persona == null
              ? 'Persona registrada correctamente'
              : 'Persona actualizada correctamente'),
        ),
      );
    }
  }

  Future<void> _confirmDelete(Persona persona) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar persona'),
          content: Text('¿Eliminar a ${persona.nombre} (ID ${persona.id})?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _personaService.deletePersona(persona.id);
        await _reload();
        messenger.showSnackBar(
          SnackBar(content: Text('Se eliminó a ${persona.nombre}')),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('No se pudo eliminar: $e')),
        );
      }
    }
  }

  Widget _buildList(List<Persona> personas) {
    if (personas.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 80),
            Center(child: Text('No hay personas registradas.')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: personas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final persona = personas[index];
          final displayName = persona.nombre.trim();
          final displayGroup = persona.grupo.trim();
          final initialsSource =
              displayName.isNotEmpty ? displayName : persona.id.trim();
          final initials = initialsSource.isNotEmpty
              ? initialsSource[0].toUpperCase()
              : '?';
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(initials)),
              title: Text(displayName.isEmpty ? 'Sin nombre' : displayName),
              subtitle: Text(
                'ID: ${persona.id}\nGrupo: ${displayGroup.isEmpty ? 'Sin grupo' : displayGroup}',
              ),
              isThreeLine: true,
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    tooltip: 'Editar',
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showPersonaForm(persona: persona),
                  ),
                  IconButton(
                    tooltip: 'Eliminar',
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmDelete(persona),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('Añadir persona'),
              onPressed: () => _showPersonaForm(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Persona>>(
                future: _personasFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('No se pudieron cargar las personas.'),
                          const SizedBox(height: 8),
                          FilledButton(
                            onPressed: _refresh,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }
                  final personas = snapshot.data ?? <Persona>[];
                  return _buildList(personas);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
