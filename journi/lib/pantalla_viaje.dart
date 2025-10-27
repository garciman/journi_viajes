import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:journi/application/trip_service.dart';
import 'package:journi/crear_viaje.dart';
import 'package:journi/editar_viaje.dart';
import 'package:journi/main.dart';
import 'package:journi/viaje.dart';
import 'data/memory/in_memory_trip_repository.dart';
import 'domain/trip.dart';

class Pantalla_Viaje extends StatefulWidget {
  int selectedIndex;
  List<Trip> viajes;
  int num_viaje;
  InMemoryTripRepository repo;
  TripService tripService;

  Pantalla_Viaje({
    super.key,
    required this.selectedIndex,
    required this.viajes,
    required this.num_viaje,
    required this.repo,
    required this.tripService,
  });

  

  @override
  _PantallaViajeState createState() => _PantallaViajeState();
}

class _PantallaViajeState extends State<Pantalla_Viaje> {
  final List<Map<String, dynamic>> _imagenes = []; // {file, fecha}
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

  @override
  Widget build(BuildContext context) {
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
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          final texto = _textoController.text.trim();
                          if (texto.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('El texto no puede estar vacío')),
                            );
                            return;
                          }
                          setState(() {
                            _textos.add({'texto': texto, 'fecha': DateTime.now()});
                          });
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
                    title: const Text('¿Cómo quieres subir la foto?'),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          final XFile? imagen =
                              await _picker.pickImage(source: ImageSource.gallery);
                          if (imagen != null) {
                            setState(() {
                              _imagenes.add({
                                'file': File(imagen.path),
                                'fecha': DateTime.now(),
                              });
                            });
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
                            setState(() {
                              _imagenes.add({
                                'file': File(imagen.path),
                                'fecha': DateTime.now(),
                              });
                            });
                          }
                        },
                        child: const Text('Hacer foto'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            tooltip: 'Editar viaje',
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
                  ),
                ),
              );
            },
          ),
        ],
      ),

      // 🔹 Aquí combinamos la parte de textos con el bloque de fotos simplificado
      body: widget.viajes.isEmpty
          ? const Center(
              child: Text(
                'No tienes entradas registradas.',
                style: TextStyle(fontSize: 20),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(8),
              children: [
                // 🔸 Bloque de textos
                ..._textos.map((t) {
                  final texto = t['texto'] as String;
                  final fecha = t['fecha'] as DateTime;
                  final fechaFormateada =
                      "${fecha.day.toString().padLeft(2, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";
                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.notes, color: Colors.teal),
                      title: Text(texto),
                      subtitle: Text('Añadido el $fechaFormateada'),
                      onTap: () => _mostrarDialogoEditarTexto(texto, fecha),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _mostrarDialogoEliminarTexto(texto, fecha),
                      ),
                    ),
                  );
                }),

                // 🔸 Bloque de fotos (versión simple que me pediste)
                if (_imagenes.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Aún no has añadido fotos.',
                          style: TextStyle(fontSize: 18)),
                    ),
                  )
                else
                  ..._imagenes.map((img) {
                    final file = img['file'] as File;
                    final fecha = img['fecha'] as DateTime;
                    final fechaFormateada =
                        "${fecha.day.toString().padLeft(2, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.year} "
                        "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";

                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15)),
                                child: GestureDetector(
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
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Eliminar foto'),
                                      content: const Text(
                                          '¿Seguro que quieres eliminar esta foto?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() => _imagenes.remove(img));
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text('Foto eliminada correctamente')));
                                          },
                                          child: const Text('Eliminar',
                                              style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text('Añadida el $fechaFormateada',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black54)),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.selectedIndex,
        backgroundColor: const Color(0xFFEDE5D0),
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.teal[500],
        iconSize: 35,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Mis viajes'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Nuevo viaje'),
          BottomNavigationBarItem(icon: Icon(Icons.equalizer), label: 'Datos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Mi perfil'),
        ],
        onTap: (int inIndex) {
          setState(() {
            widget.selectedIndex = inIndex;
            if (widget.selectedIndex == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyHomePage(
                    title: 'JOURNI',
                    viajes: widget.viajes,
                    repo: widget.repo,
                    tripService: widget.tripService,
                  ),
                ),
              );
            }
          });
        },
      ),
    );
  }
}
