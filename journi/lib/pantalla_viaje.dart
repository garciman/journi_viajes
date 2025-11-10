import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:journi/application/trip_service.dart';
import 'package:journi/application/entry_service.dart';
import 'package:journi/application/use_cases/entry_use_cases.dart';

import 'package:journi/domain/ports/trip_repository.dart';
import 'package:journi/domain/entry.dart';
import 'package:journi/domain/trip.dart' hide Ok;

import 'application/shared/result.dart';
import 'editar_viaje.dart';
import 'select_location_screen.dart';
import 'package:journi/login_screen.dart';

class Pantalla_Viaje extends StatefulWidget {
  int selectedIndex; // primer item de la bottom navigation bar seleccionado por defecto
  List<Trip> viajes;
  int num_viaje;
  final ImagePicker? picker;

  // 👉 Puerto (interfaz) en lugar del repo in-memory
  final TripRepository repo;
  final TripService tripService;
  final EntryService entryService;

  Pantalla_Viaje(
      {super.key,
      required this.selectedIndex,
      required this.viajes,
      required this.num_viaje,
      required this.repo,
      required this.tripService,
      required this.entryService,
      this.picker});

  @override
  _PantallaViajeState createState() => _PantallaViajeState();
}

class _PantallaViajeState extends State<Pantalla_Viaje> {
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> _textos = []; // {texto, fecha}
  final TextEditingController _textoController = TextEditingController();

  void _editarUbicacion(Entry entry) async {
    final nameController = TextEditingController(text: entry.text);

    // Abre un cuadro de diálogo simple para cambiar el nombre
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar ubicación'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'Nuevo nombre de la ubicación',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final nuevoNombre = nameController.text.trim();
                if (nuevoNombre.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('El nombre no puede estar vacío')),
                  );
                  return;
                }

                // Simula "actualizar" la ubicación eliminando y recreando
                await widget.entryService.deleteById(entry.id);

                final cmd = CreateEntryCommand(
                  id: UniqueKey().toString(),
                  tripId: widget.viajes[widget.num_viaje].id,
                  type: EntryType.location,
                  text: nuevoNombre,
                );
                await widget.entryService.create(cmd);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ubicación actualizada')),
                  );
                  setState(() {});
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTrip = widget.viajes[widget.num_viaje];

    return Scaffold(
      backgroundColor: Colors.teal[200],
      appBar: AppBar(
        backgroundColor: Colors.teal[200],
        title: Text(
          currentTrip.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            tooltip: 'Añadir texto',
            onPressed: () {
              _textoController.clear();
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Introduce un texto'),
                    content: TextField(
                      controller: _textoController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Escribe aquí...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar')),
                      TextButton(
                        onPressed: () async {
                          final texto = _textoController.text.trim();
                          if (texto.isEmpty) return;

                          setState(() {
                            _textos
                                .add({'texto': texto, 'fecha': DateTime.now()});
                          });

                          final cmd = CreateEntryCommand(
                            id: UniqueKey().toString(),
                            tripId: currentTrip.id,
                            type: EntryType.note,
                            text: texto,
                          );
                          await widget.entryService.create(cmd);

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Texto añadido')));
                        },
                        child: const Text('Aceptar'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            key: const Key('anadirFoto'),
            icon: const Icon(Icons.camera_alt, color: Colors.black),
            tooltip: 'Subir foto',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('¿Cómo quieres subir la foto?'),
                    actions: [
                      TextButton(
                        key: const Key('adjuntarFoto'),
                        onPressed: () async {
                          Navigator.pop(context);
                          final XFile? pickedFile = await _picker.pickImage(
                              source: ImageSource.gallery);
                          if (pickedFile != null) {
                            final cmd = CreateEntryCommand(
                              id: UniqueKey().toString(),
                              tripId: currentTrip.id,
                              type: EntryType.photo,
                              mediaUri: pickedFile.path,
                            );
                            await widget.entryService.create(cmd);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Foto añadida correctamente')),
                            );
                          }
                        },
                        child: const Text('Adjuntar foto'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          final XFile? imagen = await _picker.pickImage(
                              source: ImageSource.camera);
                          if (imagen != null) {
                            final file = File(imagen.path);
                            final cmd = CreateEntryCommand(
                              id: UniqueKey().toString(),
                              tripId: currentTrip.id,
                              type: EntryType.photo,
                              mediaUri: file.path,
                            );
                            await widget.entryService.create(cmd);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Foto añadida correctamente')),
                            );
                          }
                        },
                        child: const Text('Hacer foto'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          final XFile? video = await _picker.pickVideo(
                              source: ImageSource.gallery);
                          if (video != null) {
                            final cmd = CreateEntryCommand(
                              id: UniqueKey().toString(),
                              tripId: widget.viajes[widget.num_viaje].id,
                              type: EntryType
                                  .video, // 👈 asegúrate de tenerlo en tu modelo
                              mediaUri: video.path,
                            );
                            await widget.entryService.create(cmd);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Video añadido correctamente')),
                            );
                          }
                        },
                        child: const Text('Adjuntar video'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            tooltip: 'Editar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Editar_viaje(
                    selectedIndex: 2,
                    viajes: widget.viajes,
                    num_viaje: widget.num_viaje,
                    repo: widget.repo, // TripRepository (puerto)
                    tripService: widget.tripService,
                    entryService: widget.entryService,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.black),
            tooltip: 'Añadir ubicación',
            onPressed: () async {
              final result = await Navigator.push<SelectedLocation>(
                context,
                MaterialPageRoute(
                  builder: (_) => const SelectLocationScreen(),
                ),
              );

              if (result != null) {
                // ✅ Guardamos como nueva Entry en la base de datos
                final cmd = CreateEntryCommand(
                  id: UniqueKey().toString(),
                  tripId: widget.viajes[widget.num_viaje].id,
                  type: EntryType.location,
                  text:
                      '${result.name} (${result.position.latitude.toStringAsFixed(4)}, ${result.position.longitude.toStringAsFixed(4)})',
                );

                await widget.entryService.create(cmd);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Ubicación añadida correctamente')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            tooltip: 'Eliminar',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar eliminación'),
                  content:
                      const Text('¿Seguro que quieres eliminar este viaje?'),
                  actions: [
                    TextButton(
                        key: const Key('cancelarButton'),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar')),
                    TextButton(
                      key: const Key('aceptarButton'),
                      onPressed: () async {
                        final tripToDelete = currentTrip;
                        final result = await widget.tripService
                            .deleteById(tripToDelete.id);

                        if (result is Ok<Unit>) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Viaje eliminado correctamente.')),
                          );
                          // Actualiza lista local
                          widget.viajes.removeAt(widget.num_viaje);

                          Navigator.pop(context); // cierra diálogo
                          Navigator.pop(context); // vuelve a lista
                          setState(() {});
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Error al eliminar el viaje')),
                          );
                        }
                      },
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Entry>>(
        stream: widget.entryService.watchByTrip(currentTrip.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Aún no has añadido contenido.',
                  style: TextStyle(fontSize: 18)),
            );
          }

          final entries = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final e = entries[index];

              // Texto
              if (e.type == EntryType.note && e.text != null) {
                final fecha = e.createdAt.toLocal();
                final fechaFormateada =
                    "${fecha.day.toString().padLeft(2, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.year} "
                    "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";

                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    key: ValueKey('eid$index'),
                    leading: const Icon(Icons.notes, color: Colors.teal),
                    title: Text(e.text!),
                    subtitle: Text('Añadido el $fechaFormateada'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        await widget.entryService.deleteById(e.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Texto eliminado')),
                        );
                      },
                    ),
                  ),
                );
              }

              // Ubicación
              if (e.type == EntryType.location && e.text != null) {
                final fecha = e.createdAt.toLocal();
                final fechaFormateada =
                    "${fecha.day.toString().padLeft(2, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.year} "
                    "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";

                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.teal),
                    title: Text(e.text!),
                    subtitle: Text('Añadida el $fechaFormateada'),
                    onTap: () =>
                        _editarUbicacion(e), // 👈 NUEVO: editar al tocar
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        await widget.entryService.deleteById(e.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ubicación eliminada')),
                        );
                      },
                    ),
                  ),
                );
              }

              // Imagen
              if (e.type == EntryType.photo && e.mediaUri != null) {
                final file = File(e.mediaUri!);
                final fecha = e.createdAt.toLocal();
                final fechaFormateada =
                    "${fecha.day.toString().padLeft(2, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.year} "
                    "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";

                return Card(
                  key: ValueKey('eid$index'),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: InteractiveViewer(
                                      panEnabled: true,
                                      child:
                                          Image.file(file, fit: BoxFit.contain),
                                    ),
                                  );
                                },
                              );
                            },
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15)),
                              child: Image.file(
                                file,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await widget.entryService.deleteById(e.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Foto eliminada')),
                              );
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Añadida el $fechaFormateada',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.selectedIndex,
        backgroundColor: const Color(0xFFEDE5D0),
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.teal[500],
        iconSize: 35,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.folder), label: 'Mis viajes'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Nuevo viaje'),
          BottomNavigationBarItem(icon: Icon(Icons.equalizer), label: 'Datos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Mi perfil'),
        ],
        onTap: (int inIndex) {
          setState(() {
            widget.selectedIndex = inIndex;
            if (widget.selectedIndex == 0) {
              // ✅ Volver a la home existente
              Navigator.pop(context);
            }
            if (widget.selectedIndex == 4) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // cuando este con sesion iniciada habra que cambiarlo para que vaya directamente a la pantalla del perfil
                  builder: (context) => const LoginScreen(),
                ),
              );
            }
          });
        },
      ),
    );
  }
}
