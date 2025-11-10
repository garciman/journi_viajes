import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Lo que devolvemos a la pantalla anterior al guardar
class SelectedLocation {
  final String name;     // nombre que escribe el usuario
  final LatLng position; // latitud / longitud

  SelectedLocation({
    required this.name,
    required this.position,
  });
}

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  final TextEditingController _nameController = TextEditingController();

  // Centro inicial del mapa (Madrid por poner algo)
  LatLng _center = LatLng(40.4168, -3.7038);

  // Punto que elija el usuario
  LatLng? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elige ubicación'),
        actions: [
          TextButton(
            onPressed: _selected == null
                ? null
                : () {
              final name = _nameController.text.trim();
              Navigator.pop(
                context,
                SelectedLocation(
                  name: name.isEmpty ? 'Ubicación sin nombre' : name,
                  position: _selected!,
                ),
              );
            },
            child: const Text(
              'GUARDAR',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1) Campo para escribir el nombre que quieras
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la ubicación (opcional)',
                hintText: 'Ej: Casa de la abuela, Playa X...',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // 2) El mapa
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 5,
                onTap: (tapPos, latLng) {
                  setState(() {
                    _selected = latLng;
                  });
                },
              ),
              children: [
                // Capa de teselas de OpenStreetMap (la "API" de mapas)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.journi',
                ),

                // Marcador donde el usuario toca
                if (_selected != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selected!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
