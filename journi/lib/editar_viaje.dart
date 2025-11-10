import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:journi/application/entry_service.dart';
import 'package:journi/application/shared/result.dart';
import 'package:journi/application/trip_service.dart';
import 'package:journi/domain/ports/trip_repository.dart';

import 'application/use_cases/use_cases.dart';
import 'domain/trip.dart';

class Editar_viaje extends StatefulWidget {
  int selectedIndex; // primer item de la bottom navigation bar seleccionado por defecto
  int num_viaje;
  List<Trip> viajes;

  // 👉 Puerto (interfaz) en lugar del repo in-memory
  final TripRepository repo;
  final TripService tripService;
  final EntryService entryService;

  final _titulo = TextEditingController();
  final _fecha_ini = TextEditingController();
  final _fecha_fin = TextEditingController();

  Editar_viaje({
    super.key,
    required this.selectedIndex,
    required this.viajes,
    required this.num_viaje,
    required this.repo,
    required this.tripService,
    required this.entryService,
  });

  @override
  State<Editar_viaje> createState() => _EditarViajeState();
}

class _EditarViajeState extends State<Editar_viaje> {
  DateTime? _parseDdMmYyyy(String input) {
    try {
      return DateFormat('dd-MM-yyyy').parseStrict(input);
    } catch (_) {
      return null;
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rellena campos si venimos en modo edición
    if (widget.num_viaje >= 0) {
      final trip = widget.viajes[widget.num_viaje];
      final fechaInicial =
          DateFormat('dd-MM-yyyy').format(trip.startDate ?? DateTime.now());
      final fechaFinal =
          DateFormat('dd-MM-yyyy').format(trip.endDate ?? DateTime.now());
      widget._titulo.text = trip.title;
      widget._fecha_ini.text = fechaInicial;
      widget._fecha_fin.text = fechaFinal;
    }

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
      body: Center(
        child: Column(
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              InputField(
                controller: widget._titulo,
                hintText: 'Titulo del viaje',
              ),
              const SizedBox(height: 10),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 10),
              InputField(
                controller: widget._fecha_ini,
                hintText: 'Fecha de inicio de viaje (DD-MM-YYYY)',
              ),
              const SizedBox(height: 10),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 10),
              InputField(
                controller: widget._fecha_fin,
                hintText: 'Fecha de fin de viaje (DD-MM-YYYY)',
              ),
              const SizedBox(height: 10),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              RoundedButton(
                text: 'Guardar',
                backgroundColor: Colors.white,
                textColor: Colors.black,
                onPressed: () async {
                  final titulo = widget._titulo.text.trim();
                  final ini = _parseDdMmYyyy(widget._fecha_ini.text.trim());
                  final fin = _parseDdMmYyyy(widget._fecha_fin.text.trim());

                  if (titulo.isEmpty || ini == null || fin == null) {
                    _showError(
                        'Rellena todos los campos con formato válido (DD-MM-YYYY).');
                    return;
                  }
                  if (ini.isAfter(fin)) {
                    _showError(
                        'La fecha de inicio no puede ser posterior a la final');
                    return;
                  }
                  if (titulo.length > Trip.titleMax) {
                    _showError(
                        'El título debe contener entre 1 y ${Trip.titleMax} caracteres');
                    return;
                  }

                  final cmd = UpdateTripCommand(
                    id: widget.viajes[widget.num_viaje].id, // no cambiamos id
                    title: Patch.value(titulo),
                    description: const Patch.value('Description'),
                    startDate: Patch.value(ini),
                    endDate: Patch.value(fin),
                  );

                  final result = await widget.tripService.patch(cmd);

                  if (result is Ok<Trip>) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Viaje actualizado correctamente')),
                    );
                    Navigator.pop(context); // volver a la lista
                  } else if (result is Err<Trip>) {
                    final errors =
                        result.errors.map((e) => e.message).join('\n');
                    _showError('Error al editar el viaje:\n$errors');
                  }
                },
              ),
            ]),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.selectedIndex,
        backgroundColor: const Color(0xFFEDE5D0),
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.teal[500],
        iconSize: 35,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.folder), label: 'Mis viajes'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Nuevo viaje'),
          BottomNavigationBarItem(icon: Icon(Icons.equalizer), label: 'Datos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Mi perfil'),
        ],
        onTap: (int inIndex) {
          setState(() {
            widget.selectedIndex = inIndex;
            if (widget.selectedIndex == 0) {
              // ✅ volver a la Home existente
              Navigator.pop(context);
            }
          });
        },
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;

  const InputField({
    super.key,
    required this.hintText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hintText, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Colors.white),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        ),
        child: Text(text, style: TextStyle(color: textColor)),
      ),
    );
  }
}
