import 'package:flutter/material.dart';

class MiPerfil extends StatelessWidget {
  const MiPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[200],
      appBar: AppBar(
        backgroundColor: Colors.teal[200],
        title: const Text('Mi perfil'),
      ),
      body: const Center(
        child: Text('Aquí irá la información de tu perfil'),
      ),
    );
  }
}
