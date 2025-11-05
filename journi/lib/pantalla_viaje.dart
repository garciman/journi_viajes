import 'dart:io';

import 'package:flutter/material.dart';
import 'package:journi/application/trip_service.dart';
import 'package:journi/main.dart';
import 'package:journi/mi_perfil.dart';
import 'package:journi/login_screen.dart';
import 'application/trip_service.dart';
import 'application/entry_service.dart';
import 'application/use_cases/entry_use_cases.dart';
import 'data/memory/in_memory_trip_repository.dart';
import 'domain/entry.dart';
import 'domain/trip.dart';
import 'editar_viaje.dart';
import 'package:image_picker/image_picker.dart';
import 'video_player_widget.dart';



class Pantalla_Viaje extends StatefulWidget {
  int selectedIndex; // primer item de la bottom navigation bar seleccionado por defecto
  List<Trip> viajes;
  int num_viaje;
  InMemoryTripRepository repo;
  TripService tripService;
  EntryService entryService;


  Pantalla_Viaje(
      {required this.selectedIndex,
        required this.viajes,
        required this.num_viaje,
        required this.repo,
        required this.tripService,
        required this.entryService});

  @override
  _PantallaViajeState createState() => _PantallaViajeState();
}


class _PantallaViajeState extends State<Pantalla_Viaje> {

  List<Map<String, dynamic>> _imagenes = []; // cada elemento tendrá {file, fecha}
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> _textos = []; // {texto, fecha}
  final TextEditingController _textoController = TextEditingController();

  void _mostrarDialogoEditarTexto(String textoOriginal, DateTime fechaOriginal) {
    final controller = TextEditingController(text: textoOriginal);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar texto'),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final nuevoTexto = controller.text.trim();
                if (nuevoTexto.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El texto no puede estar vacío')),
                  );
                  return;
                }
                setState(() {
                  final idx = _textos.indexWhere((t) =>
                  t['texto'] == textoOriginal &&
                      (t['fecha'] as DateTime).isAtSameMomentAs(fechaOriginal));
                  if (idx != -1) {
                    _textos[idx]['texto'] = nuevoTexto;
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Texto actualizado')));
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoEliminarTexto(String texto, DateTime fecha) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar texto'),
        content: const Text('¿Seguro que quieres eliminar este texto?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              setState(() {
                final idx = _textos.indexWhere((t) =>
                t['texto'] == texto && (t['fecha'] as DateTime).isAtSameMomentAs(fecha));
                if (idx != -1) _textos.removeAt(idx);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Texto eliminado')));
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _editarEntrada(Entry e) async {
    final controller = TextEditingController(text: e.text ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar texto'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Escribe el nuevo texto...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final nuevoTexto = controller.text.trim();
              if (nuevoTexto.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El texto no puede estar vacío')),
                );
                return;
              }

              // 1️⃣ Borrar la entrada antigua
              await widget.entryService.deleteById(e.id);

              // 2️⃣ Crear una nueva entrada con el texto actualizado
              final cmd = CreateEntryCommand(
                id: UniqueKey().toString(),
                tripId: e.tripId,
                type: EntryType.note,
                text: nuevoTexto,
              );
              await widget.entryService.create(cmd);

              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Texto actualizado')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(

        backgroundColor: Colors.teal[200],
        appBar: AppBar(
          backgroundColor: Colors.teal[200],
          title: Text(
            widget.viajes[widget.num_viaje].title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(key: Key('anadirEntrada'), Icons.add, color: Colors.black),
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
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          key: const Key('aceptarButton'),
                          onPressed: () async {
                            final texto = _textoController.text.trim();
                            if (texto.isEmpty) {
                              return;
                            }
                            setState(() {
                              _textos.add({'texto': texto, 'fecha': DateTime.now()});
                            });
                            final cmd = CreateEntryCommand(
                              id: UniqueKey().toString(),
                              tripId: widget.viajes[widget.num_viaje].id,
                              type: EntryType.note,
                              text: texto,
                            );
                            await widget.entryService.create(cmd);

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text('Texto añadido')));
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
              icon: const Icon(Icons.camera_alt, color: Colors.black),
              tooltip: 'Subir foto',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('¿Qué quieres subir?'),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            final XFile? pickedFile =
                            await _picker.pickImage(source: ImageSource.gallery);
                            if (pickedFile != null) {
                              final cmd = CreateEntryCommand(
                                id: UniqueKey().toString(),
                                tripId: widget.viajes[widget.num_viaje].id,
                                type: EntryType.photo,
                                mediaUri: pickedFile.path,
                              );
                              await widget.entryService.create(cmd);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Foto añadida correctamente')),
                              );
                            }
                          },
                          child: const Text('Adjuntar foto'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            final XFile? imagen =
                            await _picker.pickImage(source: ImageSource.camera);
                            if (imagen != null) {
                              final cmd = CreateEntryCommand(
                                id: UniqueKey().toString(),
                                tripId: widget.viajes[widget.num_viaje].id,
                                type: EntryType.photo,
                                mediaUri: imagen.path,
                              );
                              await widget.entryService.create(cmd);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Foto añadida correctamente')),
                              );
                            }
                          },
                          child: const Text('Hacer foto'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            final XFile? video =
                            await _picker.pickVideo(source: ImageSource.gallery);
                            if (video != null) {
                              final cmd = CreateEntryCommand(
                                id: UniqueKey().toString(),
                                tripId: widget.viajes[widget.num_viaje].id,
                                type: EntryType.video, // 👈 asegúrate de tenerlo en tu modelo
                                mediaUri: video.path,
                              );
                              await widget.entryService.create(cmd);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Video añadido correctamente')),
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
                        repo: widget.repo,
                        tripService: widget.tripService,
                        entryService: widget.entryService,)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.black),
              tooltip: 'Eliminar',
              onPressed: () {

                // Aquí puedes mostrar un diálogo de confirmación, por ejemplo:

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmar eliminación'),
                    content: const Text('¿Seguro que quieres eliminar este viaje?'),
                    actions: [
                      TextButton(
                        key: const Key('cancelarButton'),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        key: const Key('aceptarButton'),
                        onPressed: () async {
                          // Lógica para eliminar el viaje
                          final tripToDelete = widget.viajes[widget.num_viaje];

                          final result = await widget.tripService.deleteById(tripToDelete.id);
                          if (result is Ok<void>) {
                            print('✅ Viaje eliminado correctamente');

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(key: Key('mensajeEliminar'),content: Text('Viaje eliminado correctamente.')),
                            );

                            // Actualizamos la lista local
                            widget.viajes.removeAt(widget.num_viaje);

                            Navigator.pop(context);
                            Navigator.pop(context); // cerramos el diálogo

                          } else {
                            // Error al eliminar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error al eliminar el viaje')),
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
          stream: widget.entryService.watchByTrip(widget.viajes[widget.num_viaje].id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'Aún no has añadido contenido.',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            final entries = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final e = entries[index];

                // 🔹 Si es texto
                if (e.type == EntryType.note && e.text != null) {
                  final fecha = e.createdAt.toLocal();
                  final fechaFormateada =
                      "${fecha.day.toString().padLeft(2, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.year} "
                      "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";

                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      key: ValueKey('eid$index'),
                      leading: const Icon(Icons.notes, color: Colors.teal),
                      title: Text(e.text!),
                      subtitle: Text('Añadido el $fechaFormateada'),
                      onTap: () => _editarEntrada(e),
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

                // 🔹 Si es una imagen
                if (e.type == EntryType.photo && e.mediaUri != null) {
                  final file = File(e.mediaUri!);
                  final fecha = e.createdAt.toLocal();
                  final fechaFormateada =
                      "${fecha.day.toString().padLeft(2, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.year} "
                      "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";

                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                                        child: Image.file(file, fit: BoxFit.contain),
                                      ),
                                    );
                                  },
                                );
                              },
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
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // 🔹 Si es un video
                if (e.type == EntryType.video && e.mediaUri != null) {
                  final file = File(e.mediaUri!);
                  final fecha = e.createdAt.toLocal();
                  final fechaFormateada =
                      "${fecha.day.toString().padLeft(2, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.year} "
                      "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";

                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: VideoPlayerWidget(file: file), // 👇 widget auxiliar
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await widget.entryService.deleteById(e.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Video eliminado')),
                                );
                              },
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Añadido el $fechaFormateada',
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  );
                }


                return const SizedBox.shrink(); // En caso de tipo desconocido
              },
            );
          },
        ),



        // This trailing comma makes auto-formatting nicer for build methods.
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: widget
                .selectedIndex, // le indicamos qué botón debe aparecer como seleccionado
            backgroundColor: const Color(0xFFEDE5D0),
            unselectedItemColor: Colors.black,
            selectedItemColor: Colors.teal[500],
            iconSize: 35,
            type: BottomNavigationBarType
                .fixed, // Para que todas las etiquetas de todos los botones aparezcan siempre (no solo si se seleccionan)
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.folder), label: 'Mis viajes'),
              BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.add), label: 'Nuevo viaje'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.equalizer), label: 'Datos'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Mi perfil'),
            ],
            onTap: (int inIndex) {
              setState(() {
                widget.selectedIndex =
                    inIndex; // guardamos el boton que se pulsó y redibujamos la interfaz

                if (widget.selectedIndex == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyHomePage(
                          title: 'JOURNI',
                          viajes: widget.viajes,
                          repo: widget.repo,
                          tripService: widget.tripService,
                          entryService: widget.entryService,
                        )),
                  );
                }
                if (widget.selectedIndex == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // cuando este con sesion iniciada habra que cambiarlo para que vaya directamente a la pantalla del perfil
                      builder: (context) => const MiPerfil(),
                    ),
                  );
                }

                /*

                // Al llevar a la misma pantalla, nos vamos a ahorrar este trozo de codigo

                if (widget.selectedIndex == 2) {

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        Crear_Viaje(selectedIndex: widget.selectedIndex)),
                  );
                }
                */
              });
            }));
  }
}

class InputField extends StatelessWidget {
  final String hintText;
  final controller;

  const InputField({Key? key, required this.hintText, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hintText,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.black, // Color de fondo gris
              borderRadius: BorderRadius.circular(10.0), // Bordes redondeados
              border: Border.all(color: Colors.white), // Borde blanco
            ),
            child: TextFormField(
              style: const TextStyle(color: Colors.white),
              controller: controller,
              decoration: const InputDecoration(
                contentPadding:
                EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                hintText: '',
                filled: true,
                fillColor: Colors.transparent,
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoundedButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;

  const RoundedButton({
    Key? key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}


