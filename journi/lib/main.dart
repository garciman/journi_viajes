import 'package:flutter/material.dart';

import 'package:journi/crear_viaje.dart';
import 'package:journi/pantalla_viaje.dart';
import 'application/use_cases/use_cases.dart';
import 'data/memory/in_memory_trip_repository.dart';
import 'domain/trip.dart';

void main() { 
  // ✅ Repositorio único de toda la app
  final repo = InMemoryTripRepository();
  runApp(MyApp(repo: repo));
}

class MyApp extends StatelessWidget {
  final InMemoryTripRepository repo;
  const MyApp({super.key, required this.repo});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JOURNI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      // ✅ Pasamos el repo al home
      home: MyHomePage(title: 'JOURNI', viajes: [], repo: repo),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.viajes,
    required this.repo,
  });

  final String title;
  final List<dynamic> viajes; // lista vacía, mantenida por compatibilidad
  final InMemoryTripRepository repo;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _createNewTravel() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Crear_Viaje(
          selectedIndex: _selectedIndex,
          viajes: [],
          num_viaje: -1,
          repo: widget.repo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos el stream del repo directamente
    return Scaffold(
      backgroundColor: Colors.teal[200],
      appBar: AppBar(
        backgroundColor: Colors.teal[200],
        centerTitle: true,
        title: const Text(
          'JOURNI',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // 🔽 Escucha los cambios del repo en tiempo real
      body: StreamBuilder<List<Trip>>(
        stream: widget.repo.watchAll(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final viajes = snapshot.data!;
          if (viajes.isEmpty) {
            return const Center(
              child: Text(
                'No tienes ningún viaje registrado.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: viajes.length,
            itemBuilder: (context, index) {
              final viaje = viajes[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.flight_takeoff, color: Colors.teal),
                  title: Text(
                    viaje.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (viaje.startDate != null)
                        Text('Inicio: ${viaje.startDate!.toLocal().toString().split(' ')[0]}'),
                      if (viaje.endDate != null)
                        Text('Fin: ${viaje.endDate!.toLocal().toString().split(' ')[0]}'),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Pantalla_Viaje(
                          selectedIndex: _selectedIndex,
                          viajes: [],
                          num_viaje: index,
                          repo: widget.repo,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _createNewTravel,
        tooltip: 'Nuevo viaje',
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
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
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
            if (_selectedIndex == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Crear_Viaje(
                    selectedIndex: _selectedIndex,
                    viajes: [],
                    num_viaje: -1,
                    repo: widget.repo,
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
