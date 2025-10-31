import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/persona.dart';
import '../services/log_service.dart';
import '../services/persona_service.dart';
import '../utils/colores.dart';

class PersonasPage extends StatefulWidget {
  const PersonasPage({super.key});

  @override
  State<PersonasPage> createState() => _PersonasPageState();
}

class _PersonasPageState extends State<PersonasPage> {
  late Future<List<Persona>> _personasFuture;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _personasFuture = _loadPersonas();
  }

  Future<List<Persona>> _loadPersonas() {
    final personaService = context.read<PersonaService>();
    return personaService.allPersonas();
  }

  Future<void> _refreshList() async {
    setState(() {
      _personasFuture = _loadPersonas();
    });
    await _personasFuture;
  }

  Future<void> _showPersonaForm({Persona? persona}) async {
    final personaService = context.read<PersonaService>();
    final logService = context.read<LogService>();
    final idController = TextEditingController(text: persona?.id ?? '');
    final nombreController = TextEditingController(text: persona?.nombre ?? '');
    final grupoController = TextEditingController(text: persona?.grupo ?? '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(persona == null ? 'Nueva persona' : 'Editar persona'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: idController,
                    decoration: const InputDecoration(labelText: 'ID (NFC)'),
                    readOnly: persona != null,
                    autofocus: persona == null,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El ID es obligatorio';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: grupoController,
                    decoration: const InputDecoration(labelText: 'Rol / Grupo'),
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
                if (!formKey.currentState!.validate()) {
                  return;
                }
                try {
                  final nuevaPersona = Persona(
                    id: idController.text.trim(),
                    nombre: nombreController.text.trim(),
                    grupo: grupoController.text.trim(),
                  );
                  await personaService.insertOrReplacePersona(nuevaPersona);
                  await logService.insertLog(
                    nuevaPersona.id,
                    persona == null
                        ? 'Persona registrada manualmente'
                        : 'Persona actualizada manualmente',
                  );
                  if (!mounted) {
                    return;
                  }
                  Navigator.of(dialogContext).pop(true);
                } catch (e) {
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No se pudo guardar: $e')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _refreshList();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            persona == null
                ? 'Persona registrada correctamente'
                : 'Persona actualizada correctamente',
          ),
        ),
      );
    }

    idController.dispose();
    nombreController.dispose();
    grupoController.dispose();
  }

  Future<void> _confirmDelete(Persona persona) async {
    final personaService = context.read<PersonaService>();
    final logService = context.read<LogService>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar persona'),
          content: Text('¿Deseas eliminar a ${persona.nombre}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: () async {
                try {
                  await personaService.deletePersona(persona.id);
                  await logService.insertLog(
                    persona.id,
                    'Persona eliminada manualmente',
                  );
                  if (!mounted) {
                    return;
                  }
                  Navigator.of(dialogContext).pop(true);
                } catch (e) {
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No se pudo eliminar: $e')),
                  );
                }
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _refreshList();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Persona ${persona.nombre} eliminada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Persona>>(
      future: _personasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('No se pudieron cargar las personas: ${snapshot.error}'),
            ),
          );
        }

        final personas = snapshot.data ?? [];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => _showPersonaForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar persona'),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshList,
                child: personas.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: Text('No hay personas registradas')), 
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: personas.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final persona = personas[index];
                          final role = persona.grupo.trim();
                          final color = colorPorTipo(role.toLowerCase());
                          final trimmedName = persona.nombre.trim();
                          final inicial =
                              trimmedName.isNotEmpty ? trimmedName[0].toUpperCase() : '?';

                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: color,
                                child: Text(
                                  inicial,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(persona.nombre),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ID: ${persona.id}'),
                                  const SizedBox(height: 4),
                                  Chip(
                                    label: Text(role.isEmpty ? 'Sin grupo' : role),
                                    backgroundColor: color.withOpacity(0.15),
                                    labelStyle: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    tooltip: 'Editar',
                                    onPressed: () => _showPersonaForm(persona: persona),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    tooltip: 'Eliminar',
                                    onPressed: () => _confirmDelete(persona),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
