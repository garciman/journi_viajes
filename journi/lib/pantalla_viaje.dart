import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'package:journi/application/trip_service.dart';
import 'package:journi/application/entry_service.dart';
import 'package:journi/application/use_cases/entry_use_cases.dart';
import 'package:journi/domain/ports/entry_repository.dart';

import 'package:journi/domain/ports/trip_repository.dart';
import 'package:journi/domain/entry.dart';
import 'package:journi/domain/trip.dart' hide Ok;

import 'application/shared/result.dart';
import 'crear_viaje.dart';
import 'editar_viaje.dart';
import 'map_screen.dart';
import 'mi_perfil.dart';
import 'select_location_screen.dart';
import 'package:journi/login_screen.dart';

class Pantalla_Viaje extends StatefulWidget {
  final bool inicionSesiada;
  int selectedIndex; // primer item de la bottom navigation bar seleccionado por defecto
  List<Trip> viajes;
  int num_viaje;
  final ImagePicker? picker;

  // 👉 Puerto (interfaz) en lugar del repo in-memory
  final TripRepository repo;
  final EntryRepository entryRepo;
  final TripService tripService;
  final EntryService entryService;

  Pantalla_Viaje(
      {super.key,
      required this.selectedIndex,
        required this.inicionSesiada,
      required this.viajes,
      required this.num_viaje,
      required this.repo,
        required this.entryRepo,
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

  Future<void> _editarTexto(Entry e, String textoSinUbicacion, String? ubicacionActual) async {
    final controller = TextEditingController(text: textoSinUbicacion);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar texto'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              final nuevoTexto = controller.text.trim();
              if (nuevoTexto.isEmpty) return;

              // Re-creamos la entrada manteniendo la ubicación si había
              await widget.entryService.deleteById(e.id);
              final cmd = CreateEntryCommand(
                id: UniqueKey().toString(),
                tripId: widget.viajes[widget.num_viaje].id,
                type: EntryType.note,
                text: ubicacionActual != null ? '$nuevoTexto\n$ubicacionActual' : nuevoTexto,
              );
              await widget.entryService.create(cmd);

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarAccionesEntradaTexto(Entry e) async {
    // Separa texto y ubicación si existe
    final partes = (e.text ?? '').split('📍');
    final textoSinUbicacion = partes.first.trim();
    final ubicacionActual = partes.length > 1 ? '📍${partes.last.trim()}' : null;

    await showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('¿Qué quieres editar?'),
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar texto'),
            onTap: () async {
              Navigator.pop(context);
              await _editarTexto(e, textoSinUbicacion, ubicacionActual);
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(ubicacionActual == null ? 'Añadir ubicación' : 'Editar ubicación'),
            onTap: () async {
              Navigator.pop(context);
              await _asignarUbicacionAEntrada(e); // reusa tu flujo de ubicación
            },
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarAccionesImagen(Entry e) async {
    // Si el texto contiene una ubicación tipo "📍 ..."
    final partes = (e.text ?? '').split('📍');
    final ubicacionActual = partes.length > 1 ? '📍${partes.last.trim()}' : null;

    await showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Opciones de imagen'),
        children: [
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('Ver imagen'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: InteractiveViewer(
                    panEnabled: true,
                    child: Image.file(File(e.mediaUri!), fit: BoxFit.contain),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(ubicacionActual == null ? 'Añadir ubicación' : 'Editar ubicación'),
            onTap: () async {
              Navigator.pop(context);
              await _asignarUbicacionAEntrada(e); // reusa tu método existente
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Eliminar imagen'),
            onTap: () async {
              Navigator.pop(context);
              await widget.entryService.deleteById(e.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Foto eliminada')),
              );
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Future<void> _asignarUbicacionAEntrada(Entry entry) async {
    // Abrimos la pantalla de selección de ubicación
    final result = await Navigator.push<SelectedLocation>(
      context,
      MaterialPageRoute(
        builder: (_) => const SelectLocationScreen(),
      ),
    );

    if (result != null) {
      // Creamos un texto de ubicación como hacías antes
      final ubicacionTexto =
          '${result.name} (${result.position.latitude.toStringAsFixed(4)}, ${result.position.longitude.toStringAsFixed(4)})';

      // Eliminamos la entrada anterior y la recreamos con la ubicación añadida
      // (más simple que crear un comando de actualización)
      await widget.entryService.deleteById(entry.id);

      final cmd = CreateEntryCommand(
        id: UniqueKey().toString(),
        tripId: widget.viajes[widget.num_viaje].id,
        type: entry.type,
        text: '${entry.text ?? ''}\n📍 $ubicacionTexto', // añadimos ubicación al texto existente
        mediaUri: entry.mediaUri,
      );

      await widget.entryService.create(cmd);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ubicación añadida a la entrada')),
        );
        setState(() {});
      }
    }
  }
  void _abrirUbicacionDesdeTexto(String ubicacionTexto) {
    // Intenta extraer latitud y longitud del texto (formato: 📍 Nombre (lat, lng))
    final regex = RegExp(r'\(([0-9\.\-]+),\s*([0-9\.\-]+)\)');
    final match = regex.firstMatch(ubicacionTexto);
    if (match != null) {
      final lat = double.tryParse(match.group(1)!);
      final lng = double.tryParse(match.group(2)!);
      if (lat != null && lng != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SelectLocationScreen(
              initialPosition: LatLng(lat, lng),
              initialName: ubicacionTexto.split('📍').last.trim(),
            ),
          ),
        );
      }
    }
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
            key: const Key('anadirEntrada'),
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
                      key: const Key('textoEntrada'),
                      controller: _textoController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Escribe aquí...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                          key: const Key('cancelarButton'),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar')),
                      TextButton(
                        key: const Key('aceptarButton'),
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
                          final XFile? pickedFile = await (widget.picker ?? _picker).pickImage(source: ImageSource.gallery);
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
                    inicionSesiada: widget.inicionSesiada,
                    viajes: widget.viajes,
                    num_viaje: widget.num_viaje,
                    repo: widget.repo, // TripRepository (puerto)
                    entryRepo: widget.entryRepo,
                    tripService: widget.tripService,
                    entryService: widget.entryService,
                  ),
                ),
              );
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

                // Detectamos si hay ubicación en el texto
                final partes = e.text!.split('📍');
                final textoSinUbicacion = partes.first.trim();
                final ubicacionActual = partes.length > 1 ? '📍${partes.last.trim()}' : null;

                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    key: ValueKey('eid$index'),
                    leading: const Icon(Icons.notes, color: Colors.teal),

                    // 👈 AQUÍ el onTap (en el ListTile, no fuera)
                    onTap: () => _mostrarAccionesEntradaTexto(e),

                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          textoSinUbicacion,
                          style: const TextStyle(fontSize: 16),
                        ),

                        // Ubicación clicable (abre mapa centrado)
                        if (ubicacionActual != null)
                          GestureDetector(
                            onTap: () => _abrirUbicacionDesdeTexto(ubicacionActual),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                ubicacionActual,
                                style: const TextStyle(
                                  color: Colors.teal,
                                  fontStyle: FontStyle.italic,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    subtitle: Text('Añadido el $fechaFormateada'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.location_on, color: Colors.teal),
                          tooltip: ubicacionActual == null ? 'Añadir ubicación' : 'Editar ubicación',
                          onPressed: () => _asignarUbicacionAEntrada(e),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            await widget.entryService.deleteById(e.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Texto eliminado')),
                            );
                          },
                        ),
                      ],
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
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  key: ValueKey('eid$index'),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          GestureDetector(
                            onTap: () => _mostrarAccionesImagen(e), // 👈 NUEVO: muestra el menú contextual
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                              child: Image.file(
                                file,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.location_on, color: Colors.teal),
                            tooltip: 'Añadir ubicación',
                            onPressed: () => _asignarUbicacionAEntrada(e),
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
            } else if (widget.selectedIndex == 1) {
              // Ir al mapa
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapaPaisScreen(
                    selectedIndex: widget.selectedIndex,
                    inicionSesiada: widget.inicionSesiada,
                    viajes: widget.viajes,
                    tripRepo: widget.repo,
                    entryRepo: widget.entryRepo,
                    tripService: widget.tripService,
                    entryService: widget.entryService,
                  ),
                ),
              );
            } else if (widget.selectedIndex == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Crear_Viaje(
                    selectedIndex: widget.selectedIndex,
                    inicionSesiada: widget.inicionSesiada,
                    viajes: widget.viajes,
                    num_viaje: -1,
                    repo: widget.repo,
                    entryRepo: widget.entryRepo,
                    tripService: widget.tripService,
                    entryService: widget.entryService,
                  ),
                ),
              );
            } else if (widget.selectedIndex == 4) {
              if (widget.inicionSesiada){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MiPerfil(
                      selectedIndex: widget.selectedIndex,
                      inicionSesiada: widget.inicionSesiada,
                      viajes: widget.viajes,
                      tripRepo: widget.repo,
                      entryRepo: widget.entryRepo,
                      tripService: widget.tripService,
                      entryService: widget.entryService,
                    ),
                  ),
                );
              }
              else{
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(
                      selectedIndex: widget.selectedIndex,
                      inicionSesiada: widget.inicionSesiada,
                      viajes: widget.viajes,
                      tripRepo: widget.repo,
                      entryRepo: widget.entryRepo,
                      tripService: widget.tripService,
                      entryService: widget.entryService,
                    ),
                  ),
                );
              }
            }
          });
        },
      ),
    );
  }
}
