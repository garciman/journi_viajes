import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:journi/data/local/drift/app_database.dart';
import 'package:journi/data/local/drift/drift_entry_repository.dart';
import 'package:journi/data/local/drift/drift_trip_repository.dart';
import 'package:journi/data/memory/in_memory_entry_repository.dart';
import 'package:journi/data/memory/in_memory_trip_repository.dart';
import 'package:journi/application/trip_service.dart';
import 'package:journi/application/entry_service.dart';
import 'package:journi/domain/ports/entry_repository.dart';
import 'package:journi/domain/ports/trip_repository.dart';
import 'package:journi/domain/trip.dart';
import 'package:journi/main.dart';
import 'package:journi/mockImagePicker.dart';
import 'package:journi/pantalla_viaje.dart';

void main() {
  // 🔧 Inicializa el entorno de test (sustituye al antiguo IntegrationTestWidgetsFlutterBinding)
  TestWidgetsFlutterBinding.ensureInitialized();


  group('🧭 Pruebas de integración: Crear_Foto_Entry', () {
    late InMemoryTripRepository tripRepo;
    late InMemoryEntryRepository entryRepo;
    late DefaultTripService tripService;
    late DefaultEntryService entryService;
    late TripRepository tRepo;
    late EntryRepository eRepo;
    final db = AppDatabase();
    MockImagePicker? mPicker;

    setUp(() {
      mPicker = MockImagePicker();
      tripRepo = InMemoryTripRepository();
      entryRepo = InMemoryEntryRepository();
      tripService = DefaultTripService(repo: tripRepo);
      entryService = DefaultEntryService(repo: entryRepo);
      tRepo = DriftTripRepository(db);
      eRepo = DriftEntryRepository(db);

    });

    final trip = Trip(
      id: 'id0',
      title: 'TestTrip',
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    testWidgets('✅ Añadir foto correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Pantalla_Viaje(
          selectedIndex: 0,
          num_viaje: 0,
          inicionSesiada: false,
          viajes: [trip],
          tripService: tripService,
          entryService: entryService,
          repo: tripRepo,
          entryRepo: entryRepo,
          picker: mPicker,
        ),
      ));

      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('anadirFoto')));
      await tester.pumpAndSettle();
      // Pulsar botón de añadir foto
      await tester.tap(find.byKey(const Key('adjuntarFoto')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('eid0')), findsOneWidget);
      // ✅ Verificar éxito
      // Verifica que la pantalla principal está visible
    });

    testWidgets('❌ Error: Cancela operación de añadir foto',
        (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Pantalla_Viaje(
              selectedIndex: 0,
              num_viaje: 0,
              inicionSesiada: false,
              viajes: [trip],
              tripService: tripService,
              entryService: entryService,
              repo: tripRepo,
              entryRepo: entryRepo,
              picker: mPicker,
            ),
          ));

          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('anadirFoto')));
          await tester.pumpAndSettle();
          Navigator.of(tester.element(find.byType(AlertDialog)), rootNavigator: true).pop();
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('eid0')), findsNothing);
    });
  });
}
