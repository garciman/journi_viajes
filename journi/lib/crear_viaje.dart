import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:journi/main.dart';
import 'package:journi/viaje.dart';

class Crear_Viaje extends StatefulWidget {
  int selectedIndex; // primer item de la bottom navigation bar seleccionado por defecto
  int num_viaje;
  List<Viaje> viajes;
  final _titulo = TextEditingController();
  final _fecha_ini = TextEditingController();
  final _fecha_fin = TextEditingController();

  Crear_Viaje({required this.selectedIndex, required this.viajes, required this.num_viaje});

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

    if (widget.num_viaje >= 0){

      String fecha_inicial = DateFormat('dd-MM-yyyy').format(widget.viajes[widget.num_viaje].fecha_ini);
      String fecha_final = DateFormat('dd-MM-yyyy').format(widget.viajes[widget.num_viaje].fecha_fin);
      widget._titulo.text = widget.viajes[widget.num_viaje].titulo;
      widget._fecha_ini.text = fecha_inicial;
      widget._fecha_fin.text = fecha_final;
    }

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
          title: const Text('JOURNI',
            style: TextStyle(
                color: Colors.black,       // color del texto
                fontSize: 22,              // tamaño del texto
                fontWeight: FontWeight.bold // negrita
            ),),
        ),
        body: Center(
          child: Column(
              children: [
                Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    // Campo de Titulo del viaje
                    InputField(
                      controller: widget._titulo,
                      hintText: 'Titulo del viaje',
                    ),

                    const SizedBox(height: 10),
                  ]
                ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const SizedBox(height: 10),

                      // Campo de Contraseña
                      InputField(
                        controller: widget._fecha_ini,
                        hintText: 'Fecha de inicio de viaje (DD/MM/YYYY)',
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),

                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const SizedBox(height: 10),

                        // Campo de Fecha de final de viaje
                        InputField(
                          controller: widget._fecha_fin,
                          hintText: 'Fecha de fin de viaje (DD/MM/YYYY)',
                        ),

                        const SizedBox(height: 10),
                      ]
                  ),

                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      RoundedButton(

                        text: 'Guardar',
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        onPressed: () {
                          DateFormat formato = DateFormat('dd-MM-yyyy');
                          DateTime d1 = formato.parse("00-00-0000");
                          DateTime d2 = formato.parse("00-00-0000");

                          if (widget._titulo.text.isNotEmpty && widget._fecha_ini.text.isNotEmpty && widget._fecha_fin.text.isNotEmpty){
                            d1 = formato.parse(widget._fecha_ini.text);
                            d2 = formato.parse(widget._fecha_fin.text);
                          }
                          if (d1.isAfter(d2)){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text('La fecha de inicio no puede ser posterior a la final'),
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
                          }
                          else if (widget._titulo.text.isNotEmpty && widget._titulo.text.length > 100) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text('El título debe contener entre 1 y 100 caracteres'),
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

                          }
                          else if (widget._titulo.text == '' || widget._fecha_ini.text == '' || widget._fecha_fin.text == '') {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text('Rellena todos los campos para continuar'),
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

                          }
                          else {
                            Viaje v = Viaje(titulo: widget._titulo.text, fecha_ini: d1, fecha_fin: d2);
                            widget.viajes.add(v);
                            const Text(
                              '',
                              textAlign: TextAlign.center,

                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MyHomePage(title:'JOURNI', viajes: widget.viajes)),
                            );
                          }
                        },

                      ),
                    ]
                ),


          ]),



        ),
         // This trailing comma makes auto-formatting nicer for build methods.
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: widget.selectedIndex, // le indicamos qué botón debe aparecer como seleccionado
            backgroundColor: const Color(0xFFEDE5D0),
            unselectedItemColor: Colors.black,
            selectedItemColor: Colors.teal[500],
            iconSize: 35,
            type: BottomNavigationBarType.fixed, // Para que todas las etiquetas de todos los botones aparezcan siempre (no solo si se seleccionan)
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.folder),
                  label: 'Mis viajes'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: 'Mapa'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: 'Nuevo viaje'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.equalizer),
                  label: 'Datos'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Mi perfil'),
            ],
            onTap: (int inIndex) {
              setState(() {
                widget.selectedIndex = inIndex; // guardamos el boton que se pulsó y redibujamos la interfaz
                if (widget.selectedIndex == 0) {

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        MyHomePage(title: 'JOURNI' ,viajes: widget.viajes)),
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
            })
    );
  }
}
class InputField extends StatelessWidget {
  final String hintText;
  final controller;

  const InputField({
    Key? key,
    required this.hintText,
    required this.controller
  }) : super(key: key);

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


                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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