import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:journi/crear_viaje.dart';
import 'package:journi/data/local/drift/app_database.dart';
import 'package:journi/data/local/drift/drift_entry_repository.dart';
import 'package:journi/data/local/drift/drift_trip_repository.dart';
import 'package:journi/data/memory/in_memory_entry_repository.dart';
import 'package:journi/data/memory/in_memory_trip_repository.dart';
import 'package:journi/application/trip_service.dart';
import 'package:journi/application/entry_service.dart';
import 'package:journi/domain/ports/entry_repository.dart';
import 'package:journi/domain/ports/trip_repository.dart';
import 'package:journi/main.dart';


void main() {
  // 🔧 Inicializa el entorno de test (sustituye al antiguo IntegrationTestWidgetsFlutterBinding)
  TestWidgetsFlutterBinding.ensureInitialized();

  group('🧭 Pruebas de integración: Crear_Text_Entry', () {
    late InMemoryTripRepository tripRepo;
    late InMemoryEntryRepository entryRepo;
    late DefaultTripService tripService;
    late DefaultEntryService entryService;
    late TripRepository tRepo;
    late EntryRepository eRepo;
    final db = AppDatabase();

    setUp(() {
      tripRepo = InMemoryTripRepository();
      entryRepo = InMemoryEntryRepository();
      tripService = DefaultTripService(repo: tripRepo);
      entryService = DefaultEntryService(repo: entryRepo);
      tRepo = DriftTripRepository(db);
      eRepo = DriftEntryRepository(db);
    });

    testWidgets('✅ Crear entrada correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MyHomePage(
          title: 'JOURNI',
          inicionSesiada: false,
          viajes: [],
          tripService: tripService,
          entryService: entryService,
          tripRepo: tripRepo,
          entryRepo: entryRepo,
        ),
      ));

// Pulsa el BottomNavigationBarItem "Nuevo viaje"
      await tester.tap(find.byKey(const Key('anadirButton')));
      await tester.pumpAndSettle();

      // 🧩 Rellenar los campos
      await tester.enterText(
        find.byKey(const Key('tituloField')),
        'Vacaciones 2025',
      );
      await tester.enterText(
        find.byKey(const Key('fechaIniField')),
        '01-01-2025',
      );
      await tester.enterText(
        find.byKey(const Key('fechaFinField')),
        '10-01-2025',
      );

      await tester.tap(find.byKey(const Key('guardarButton')));
      await tester.pumpAndSettle(
          const Duration(seconds: 1)); // Espera a que el SnackBar aparezca
      await tester.tap(find.byKey(const Key('id0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('anadirEntrada')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('textoEntrada')),
        'Que grande que eres Nano',
      );
      await tester.tap(find.byKey(const Key('aceptarButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('eid0')), findsOneWidget);
      // ✅ Verificar éxito
      // Verifica que la pantalla principal está visible
    });

    testWidgets('❌ Error: Entrada vacía', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MyHomePage(
          title: 'JOURNI',
          inicionSesiada: false,
          viajes: [],
          tripService: tripService,
          entryService: entryService,
          tripRepo: tripRepo,
          entryRepo: entryRepo,
        ),
      ));

// Pulsa el BottomNavigationBarItem "Nuevo viaje"
      await tester.tap(find.byKey(const Key('anadirButton')));
      await tester.pumpAndSettle();

      // 🧩 Campos con fechas inválidas
      await tester.enterText(
        find.byKey(const Key('tituloField')),
        'Nanoseco',
      );
      await tester.enterText(
        find.byKey(const Key('fechaIniField')),
        '10-01-2025',
      );
      await tester.enterText(
        find.byKey(const Key('fechaFinField')),
        '11-01-2025',
      );

      await tester.tap(find.byKey(const Key('guardarButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('id0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('anadirEntrada')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('textoEntrada')),
        '',
      );
      await tester.tap(find.byKey(const Key('aceptarButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('eid0')), findsNothing);
    });
  });
}
