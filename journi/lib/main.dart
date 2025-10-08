import 'package:flutter/material.dart';

import 'package:journi/crear_viaje.dart';

void main() {
  runApp(const MyApp());
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
      home: const MyHomePage(title: 'JOURNI'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

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
      body: const Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'No tienes ningún viaje registrado.',
            ),
          ],
        ),
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
                    Crear_Viaje(selectedIndex: _selectedIndex)),
              );
            }
          });
        })
    );
  }
}
