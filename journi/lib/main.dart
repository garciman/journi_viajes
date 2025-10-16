import 'package:flutter/material.dart';

import 'package:journi/crear_viaje.dart';
import 'package:journi/pantalla_viaje.dart';
import 'package:journi/viaje.dart';

void main() {
  runApp(const MyApp());ff
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'JOURNI', viajes: []),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title, required this.viajes});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  List<Viaje> viajes;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0; // primer item de la bottom navigation bar seleccionado por defecto

  void _createNewTravel() {

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
        body: widget.viajes.isEmpty
            ? const Center(
          child: Text(
            'No tienes ningún viaje registrado.',
            style: TextStyle(fontSize: 18),
          ),
        )
            : ListView.builder(
          itemCount: widget.viajes.length,
          itemBuilder: (context, index) {
            final viaje = widget.viajes[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.flight_takeoff, color: Colors.teal),
                title: Text(
                  viaje.titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Inicio: ${viaje.fecha_ini.toLocal().toString().split(' ')[0]}'),
                    Text('Fin: ${viaje.fecha_fin.toLocal().toString().split(' ')[0]}'),
                    const SizedBox(height: 4),
                    const Text(
                      'Pendiente de sincronizar',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                isThreeLine: true,
                  onTap: () {
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            Pantalla_Viaje(selectedIndex: _selectedIndex, viajes: widget.viajes, num_viaje: index)),
                      );
                    });
                  }
              )
            );

          },
        ),


        floatingActionButton: FloatingActionButton(
        onPressed: _createNewTravel,
        tooltip: 'New travel',
        child: const Icon(Icons.add),

      ), // This trailing comma makes auto-formatting nicer for build methods.
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // le indicamos qué botón debe aparecer como seleccionado
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
            _selectedIndex = inIndex; // guardamos el boton que se pulsó y redibujamos la interfaz
            print(_selectedIndex);
            if (_selectedIndex == 2) {

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    Crear_Viaje(selectedIndex: _selectedIndex, viajes: widget.viajes, num_viaje: -1)),
              );
            }
          });
        })
    );
  }
}
