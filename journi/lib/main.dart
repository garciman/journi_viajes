import 'package:flutter/material.dart';

import 'package:journi/mi_perfil.dart';
import 'package:journi/login_screen.dart';
import 'package:journi/crear_viaje.dart';
import 'package:journi/pantalla_viaje.dart';

// Infra BD (Drift)
import 'package:journi/data/local/drift/app_database.dart';
import 'package:journi/data/local/drift/drift_entry_repository.dart';
import 'package:journi/data/local/drift/drift_trip_repository.dart';

// Puertos (interfaces)
import 'package:journi/domain/ports/entry_repository.dart';
import 'package:journi/domain/ports/trip_repository.dart';

// Dominio / aplicación
import 'package:journi/domain/trip.dart';
import 'package:journi/application/trip_service.dart';
import 'package:journi/application/entry_service.dart';

bool sesionIniciada = false; // cambiarás a true cuando el usuario inicie sesión
void main() {
  // ✅ Instancia única de BD + repositorios Drift
  final db = AppDatabase();
  final TripRepository tripRepo = DriftTripRepository(db);
  final EntryRepository entryRepo = DriftEntryRepository(db);

  // ✅ Servicios de aplicación
  final tripService = makeTripService(tripRepo);
  final entryService = makeEntryService(entryRepo);

  runApp(MyApp(
    tripRepo: tripRepo,
    tripService: tripService,
    entryRepo: entryRepo,
    entryService: entryService,
  ));
}

class MyApp extends StatelessWidget {
  final TripRepository tripRepo;
  final TripService tripService;

  final EntryRepository entryRepo;
  final EntryService entryService;

  const MyApp({
    super.key,
    required this.tripRepo,
    required this.tripService,
    required this.entryRepo,
    required this.entryService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JOURNI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: MyHomePage(
        title: 'JOURNI',
        viajes: const [],
        tripRepo: tripRepo,
        tripService: tripService,
        entryRepo: entryRepo,
        entryService: entryService,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    super.key,
    required this.title,
    required this.viajes,
    required this.tripRepo,
    required this.tripService,
    required this.entryRepo,
    required this.entryService,
  });

  final String title;

  // 👉 Ahora usamos interfaces (no clases in-memory)
  final TripRepository tripRepo;
  final TripService tripService;

  final EntryRepository entryRepo;
  final EntryService entryService;

  List<Trip> viajes = [];

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
          viajes: const [],
          num_viaje: -1,
          // 👉 Pasa el repo a través de la interfaz
          repo: widget.tripRepo,
          tripService: widget.tripService,
          entryService: widget.entryService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

      // 🔽 Escucha los cambios del repo (Drift) en tiempo real
      body: StreamBuilder<List<Trip>>(
        stream: widget.tripRepo.watchAll(), // <- interfaz
        builder: (context, snapshot) {

          print('🟢 Snapshot data: ${snapshot.data}');
          print('📡 Connection state: ${snapshot.connectionState}');
          print('📦 Has data: ${snapshot.hasData}');
          print('❌ Has error: ${snapshot.hasError}');


          // 1️⃣ Error
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los viajes'));
          }

          // 2️⃣ Aún no ha llegado ningún dato -> puede estar esperando
          if (snapshot.connectionState == ConnectionState.waiting && snapshot.data != null) {
            return const Center(
              child: CircularProgressIndicator()
            );
          }

          final trips = snapshot.data ?? [];

          // 3️⃣ Datos recibidos
          if (trips.isEmpty) {
            return const Center(
              child: Text(
                'No tienes ningún viaje registrado.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          widget.viajes = snapshot.data!;
          return ListView.builder(
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
                  key: ValueKey('id$index'),
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
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Pantalla_Viaje(
                          selectedIndex: _selectedIndex,
                          viajes: widget.viajes,
                          num_viaje: index,
                          // 👉 Igual aquí: interfaz
                          repo: widget.tripRepo,
                          tripService: widget.tripService,
                          entryService: widget.entryService,
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
        child: const Icon(key: Key('anadirButton'), Icons.add),
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
          }
          else if (index == 1) {
            // Ir al mapa
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MapaPaisScreen(),
              ),
            );
          }
          // 👤 Mi perfil (index 4)
          else if (index == 4) {
            if (sesionIniciada) {
              // Sesión iniciada → ir directamente a MiPerfil
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Crear_Viaje(
                    selectedIndex: _selectedIndex,
                    viajes: widget.viajes,
                    num_viaje: -1,
                    repo: widget.tripRepo,              // <- interfaz
                    tripService: widget.tripService,
                    entryService: widget.entryService,
                  ),
                ),
              );
            }
          } else {
            // Para Mis viajes, Mapa, Datos solo cambiamos el índice seleccionado
            setState(() {
              _selectedIndex = index;
            });
          }
        },
      ),
    );
  }
}
