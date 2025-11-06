import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapaPaisScreen extends StatefulWidget {
  const MapaPaisScreen({Key? key}) : super(key: key);

  @override
  State<MapaPaisScreen> createState() => _MapaPaisScreenState();
}

class _MapaPaisScreenState extends State<MapaPaisScreen> {
  LatLng? _posicionUsuario;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacion();
  }

  Future<void> _obtenerUbicacion() async {
    bool permiso = await Geolocator.isLocationServiceEnabled();
    if (!permiso) return;

    LocationPermission permisoAcceso = await Geolocator.checkPermission();
    if (permisoAcceso == LocationPermission.denied) {
      permisoAcceso = await Geolocator.requestPermission();
      if (permisoAcceso == LocationPermission.denied) return;
    }

    Position posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _posicionUsuario = LatLng(posicion.latitude, posicion.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa del país')),
      body: _posicionUsuario == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
        options: MapOptions(
          initialCenter: _posicionUsuario!,
          initialZoom: 6,
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80,
                height: 80,
                point: _posicionUsuario!,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
