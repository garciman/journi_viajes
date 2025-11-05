import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:journi/application/entry_service.dart';
import 'package:journi/application/trip_service.dart';
import 'package:journi/data/memory/in_memory_trip_repository.dart';
import 'package:journi/main.dart';
import 'package:journi/mi_perfil.dart';
import 'package:journi/login_screen.dart';

import 'application/use_cases/use_cases.dart';
import 'domain/trip.dart';

class Crear_Viaje extends StatefulWidget {
  int selectedIndex; // primer item de la bottom navigation bar seleccionado por defecto
  int num_viaje;
  List<Trip> viajes;
  InMemoryTripRepository repo;
  TripService tripService;
  EntryService entryService;
  final _titulo = TextEditingController();
  final _fecha_ini = TextEditingController();
  final _fecha_fin = TextEditingController();

  Crear_Viaje(
      {super.key, required this.selectedIndex,
      required this.viajes,
      required this.num_viaje,
      required this.repo,
      required this.tripService,
      required this.entryService});

  @override
  _CrearViajeState createState() => _CrearViajeState();
}

class _CrearViajeState extends State<Crear_Viaje> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    if (widget.num_viaje >= 0) {
      String fechaInicial = DateFormat('dd-MM-yyyy')
          .format(widget.viajes[widget.num_viaje].startDate?? DateTime.now());
      String fechaFinal = DateFormat('dd-MM-yyyy')
          .format(widget.viajes[widget.num_viaje].endDate?? DateTime.now());
      widget._titulo.text = widget.viajes[widget.num_viaje].title;
      widget._fecha_ini.text = fechaInicial;
      widget._fecha_fin.text = fechaFinal;
    }

    final createTrip = CreateTripUseCase(widget.repo);

    return Scaffold(
        backgroundColor: Colors.teal[200],
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Colors.teal[200],
          centerTitle: true,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          leading: IconButton(
            key: const Key('volver'),
            icon: const Icon(Icons.arrow_back_ios_new), // o el icono que quieras
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'JOURNI',
            style: TextStyle(
                color: Colors.black, // color del texto
                fontSize: 22, // tamaño del texto
                fontWeight: FontWeight.bold // negrita
                ),
          ),
        ),
        body: Center(
          child: Column(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Campo de Titulo del viaje
              InputField(
                key: const Key('tituloField'),
                controller: widget._titulo,
                hintText: 'Titulo del viaje',
              ),

              const SizedBox(height: 10),
            ]),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Campo de fecha inicial
                InputField(
                  key: const Key('fechaIniField'),
                  controller: widget._fecha_ini,
                  hintText: 'Fecha de inicio de viaje (DD-MM-YYYY)',
                ),

                const SizedBox(height: 10),
              ],
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 10),

              // Campo de Fecha de final de viaje
              InputField(
                key: const Key('fechaFinField'),
                controller: widget._fecha_fin,
                hintText: 'Fecha de fin de viaje (DD-MM-YYYY)',
              ),

              const SizedBox(height: 10),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              RoundedButton(
                key: const Key('guardarButton'),
                text: 'Guardar',
                backgroundColor: Colors.white,
                textColor: Colors.black,
                onPressed: () async {
                  DateFormat formato = DateFormat('dd-MM-yyyy');
                  DateTime d1 = formato.parse("00-00-0000");
                  DateTime d2 = formato.parse("00-00-0000");

                  if (widget._titulo.text.isNotEmpty &&
                      widget._fecha_ini.text.isNotEmpty &&
                      widget._fecha_fin.text.isNotEmpty) {
                    d1 = formato.parse(widget._fecha_ini.text);
                    d2 = formato.parse(widget._fecha_fin.text);
                  }
                  if (d1.isAfter(d2)) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text(
                              'La fecha de inicio no puede ser posterior a la final'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Cerrar el diálogo
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else if (widget._titulo.text.isNotEmpty &&
                      widget._titulo.text.length > 100) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text(
                              'El título debe contener entre 1 y 100 caracteres'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Cerrar el diálogo
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else if (widget._titulo.text == '' ||
                      widget._fecha_ini.text == '' ||
                      widget._fecha_fin.text == '') {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text(
                              'Rellena todos los campos para continuar'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Cerrar el diálogo
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    final nuevoId = DateTime.now().millisecondsSinceEpoch.toString();

                      final cmd = CreateTripCommand(
                        id: nuevoId,
                        title: widget._titulo.text,
                        description: 'Description',
                        startDate: d1,
                        endDate: d2,
                      );

                      widget.tripService.create(cmd);

                      // ⿤ Ejecutamos el caso de uso
                      final result = await createTrip(cmd);

                      // ⿥ Interpretamos el resultado (Ok o Err)
                      if (result is Ok<Trip>) {
                        final trip = result.value;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Viaje creado correctamente')),
                        );
                        print('✅ Trip creado con éxito: ${trip.title}');
                        print('   ID: ${trip.id}');
                        print('   Fechas: ${trip.startDate} → ${trip.endDate}');
                      } else if (result is Err<Trip>) {
                        final errors =
                            result.errors.map((e) => e.message).join(', ');
                        print('Error al crear trip: $errors');
                      }

                      const Text(
                        '',
                        textAlign: TextAlign.center,
                      );
                    Navigator.pop(context); // recargamos la pagina para que se actualicen los viajes

                  }
                },
              ),
            ]),
          ]),
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
          onTap: (int index) async {
            if (index == 2) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Crear_Viaje(
                    selectedIndex: index,
                    viajes: widget.viajes,
                    num_viaje: -1,
                    repo: widget.repo,
                    tripService: widget.tripService,
                    entryService: widget.entryService,
                  ),
                ),
              );
            } else if (index == 4) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            } else {
              setState(() {
                widget.selectedIndex = index;
              });
            }
          }));
  }
}

class InputField extends StatelessWidget {
  final String hintText;
  final controller;

  const InputField({super.key, required this.hintText, required this.controller});

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
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
