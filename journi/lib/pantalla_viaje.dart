import 'dart:io';

import 'package:flutter/material.dart';
import 'package:journi/application/trip_service.dart';
import 'package:journi/crear_viaje.dart';
import 'package:journi/main.dart';
import 'package:journi/viaje.dart';

import 'data/memory/in_memory_trip_repository.dart';
import 'domain/trip.dart';
import 'editar_viaje.dart';
import 'package:image_picker/image_picker.dart';


class Pantalla_Viaje extends StatefulWidget {
  int selectedIndex; // primer item de la bottom navigation bar seleccionado por defecto
  List<Trip> viajes;
  int num_viaje;
  InMemoryTripRepository repo;
  TripService tripService;

  Pantalla_Viaje(
      {required this.selectedIndex,
        required this.viajes,
        required this.num_viaje,
        required this.repo,
        required this.tripService});

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
                            final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery);
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
                            final XFile? imagen = await _picker.pickImage(source: ImageSource.camera);
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
                          tripService: widget.tripService)),
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
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Lógica para eliminar el viaje
                          final tripToDelete = widget.viajes[widget.num_viaje];

                          final result = await widget.tripService.deleteById(tripToDelete.id);
                          if (result is Ok<void>) {
                            print('✅ Viaje eliminado correctamente');

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Viaje eliminado correctamente.')),
                            );

                            // Actualizamos la lista local
                            widget.viajes.removeAt(widget.num_viaje);

                            Navigator.pop(context); // cerramos el diálogo
                            Navigator.pop(context); // cerramos el diálogo

                            setState(() {
                              // redibujamos la pantalla con la lista actualizada
                            });
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
        body: widget.viajes.isEmpty
            ? const Center(
          child: Text(
            'No tienes entradas registradas.',
            style: TextStyle(fontSize: 20),
          ),
        )
            : _imagenes.isEmpty && _textos.isEmpty
    ? const Center(
        child: Text(
          'Aún no has añadido contenido.',
          style: TextStyle(fontSize: 18),
        ),
      )
    : ListView(
        padding: const EdgeInsets.all(8),
        children: [
          // 🔹 Bloque de textos
          ..._textos.map((t) {
            final texto = t['texto'] as String;
            final fecha = t['fecha'] as DateTime;
            final fechaFormateada =
                "${fecha.day.toString().padLeft(2, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.year} "
                "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";
            return Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.notes, color: Colors.teal),
                title: Text(texto),
                subtitle: Text('Añadido el $fechaFormateada'),
                onTap: () => _mostrarDialogoEditarTexto(texto, fecha),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () =>
                      _mostrarDialogoEliminarTexto(texto, fecha),
                ),
              ),
            );
          }),

          // 🔹 Y aquí metemos el ListView.builder original como hijo de este ListView
          SizedBox(
            height: 400, // altura fija para contener la lista de imágenes
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              itemCount: _imagenes.length,
              itemBuilder: (context, index) {
                final imagenData = _imagenes[index];
                final file = imagenData['file'] as File;
                final fecha = imagenData['fecha'] as DateTime;
                final fechaFormateada =
                    "${fecha.day.toString().padLeft(2, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.year} "
                    "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";

                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin:
                      const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius:
                                const BorderRadius.vertical(
                                    top: Radius.circular(15)),
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      child: InteractiveViewer(
                                        panEnabled: true,
                                        child: Image.file(
                                          file,
                                          fit: BoxFit.contain,
                                        ),
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

                          // Botón de eliminar
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title:
                                      const Text('Eliminar foto'),
                                  content: const Text(
                                      '¿Seguro que quieres eliminar esta foto?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _imagenes
                                              .removeAt(index);
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Foto eliminada correctamente')),
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'Eliminar',
                                        style: TextStyle(
                                            color: Colors.red),
                                      ),
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
                        child: Text(
                          'Añadida el $fechaFormateada',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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
                        )),
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
