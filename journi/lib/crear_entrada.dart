// lib/crear_entrada.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'entrada.dart';

class CrearEntrada extends StatefulWidget {
  final int tripIndex;
  final Entrada? entrada; // si viene, estamos editando

  const CrearEntrada({
    Key? key,
    required this.tripIndex,
    this.entrada,
  }) : super(key: key);

  @override
  State<CrearEntrada> createState() => _CrearEntradaState();
}

class _CrearEntradaState extends State<CrearEntrada> {
  final _tituloCtrl = TextEditingController();
  final _textoCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _fmt = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    if (widget.entrada != null) {
      _tituloCtrl.text = widget.entrada!.titulo;
      _textoCtrl.text = widget.entrada!.texto;
      _fechaCtrl.text = _fmt.format(widget.entrada!.fecha.toLocal());
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _textoCtrl.dispose();
    _fechaCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    final titulo = _tituloCtrl.text.trim();
    final texto = _textoCtrl.text.trim();
    final fechaTxt = _fechaCtrl.text.trim();

    if (titulo.isEmpty || texto.isEmpty || fechaTxt.isEmpty) {
      _alert('Rellena título, texto y fecha.');
      return;
    }

    late DateTime fecha;
    try {
      fecha = _fmt.parseStrict(fechaTxt);
    } catch (_) {
      _alert('Fecha inválida. Usa DD-MM-YYYY');
      return;
    }

    final nueva = (widget.entrada ?? Entrada(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tripIndex: widget.tripIndex,
      titulo: titulo,
      texto: texto,
      fecha: fecha,
    )).copyWith(
      titulo: titulo,
      texto: texto,
      fecha: fecha,
    );

    Navigator.pop(context, nueva);
  }

  void _alert(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Atención'),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.entrada != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Editar entrada' : 'Nueva entrada',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal[200],
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.teal[200],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Field(label: 'Título', controller: _tituloCtrl),
          const SizedBox(height: 12),
          _Field(label: 'Texto', controller: _textoCtrl, maxLines: 6),
          const SizedBox(height: 12),
          _Field(label: 'Fecha (DD-MM-YYYY)', controller: _fechaCtrl),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _guardar,
              child: Text(editing ? 'Guardar cambios' : 'Crear entrada'),
            ),
          )
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;

  const _Field({
    Key? key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.black87,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    ]);
  }
}
