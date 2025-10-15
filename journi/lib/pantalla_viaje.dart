import 'package:flutter/material.dart';
import 'package:journi/main.dart';
import 'package:journi/viaje.dart';

class Crear_Viaje extends StatefulWidget {
  int selectedIndex; // primer item de la bottom navigation bar seleccionado por defecto
  List<Viaje> viajes;

  Crear_Viaje({required this.selectedIndex, required this.viajes});

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
        body: const Center(
          child: Text(
            'No tienes entradas registradas.',
            style: TextStyle(fontSize: 20),
          ),
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