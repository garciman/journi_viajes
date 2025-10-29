import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:journi/crear_viaje.dart';
import 'package:journi/data/memory/in_memory_entry_repository.dart';
import 'package:journi/data/memory/in_memory_trip_repository.dart';
import 'package:journi/application/trip_service.dart';
import 'package:journi/application/entry_service.dart';
import 'package:journi/main.dart';

import 'entry_mock.dart';
import 'trip_mock.dart';

void main() {
  // 🔧 Inicializa el entorno de test (sustituye al antiguo IntegrationTestWidgetsFlutterBinding)
  TestWidgetsFlutterBinding.ensureInitialized();

  group('🧭 Pruebas de integración: Crear_Viaje', () {
    late InMemoryTripRepository tripRepo;
    late InMemoryEntryRepository entryRepo;
    late DefaultTripService tripService;
    late DefaultEntryService entryService;

    setUp(() {
      tripRepo = InMemoryTripRepository();
      entryRepo = InMemoryEntryRepository();
      tripService = DefaultTripService(repo: tripRepo);
      entryService = DefaultEntryService(repo: entryRepo);
    });

    testWidgets('✅ Crear viaje correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MyHomePage(
          title: 'JOURNI',
          viajes: [],
          repo: tripRepo,
          tripService: tripService,
          entryService: entryService,
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
      await tester.pumpAndSettle(const Duration(seconds: 1)); // Espera a que el SnackBar aparezca

      // ✅ Verificar éxito
      // Verifica que la pantalla principal está visible
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text('Error'), findsNothing);
    });

    testWidgets('❌ Error: fecha de inicio posterior a fecha final', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Crear_Viaje(
          selectedIndex: 2,
          viajes: [],
          num_viaje: -1,
          repo: tripRepo,
          tripService: tripService,
          entryService: entryService,
        ),
      ));

      await tester.pumpAndSettle();

      // 🧩 Campos con fechas inválidas
      await tester.enterText(
        find.byKey(const Key('tituloField')),
        'Viaje erróneo',
      );
      await tester.enterText(
        find.byKey(const Key('fechaIniField')),
        '10-01-2025',
      );
      await tester.enterText(
        find.byKey(const Key('fechaFinField')),
        '01-01-2025',
      );

      await tester.tap(find.byKey(const Key('guardarButton')));
      await tester.pumpAndSettle();

      // ❌ Verificar error
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('La fecha de inicio no puede ser posterior a la final'), findsOneWidget);
      expect(find.text('Viaje creado correctamente'), findsNothing);
    });
  });
}
