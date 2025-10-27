// lib/entradas_list.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'entrada.dart';
import 'crear_entrada.dart';

class EntradasList extends StatefulWidget {
  final int tripIndex; // viaje seleccionado
  final List<Entrada> entradas; // estado compartido (mock)

  const EntradasList({
    super.key,
    required this.tripIndex,
    required this.entradas,
  });

  @override
  State<EntradasList> createState() => _EntradasListState();
}

class _EntradasListState extends State<EntradasList> {
  late List<Entrada> _items;

  @override
  void initState() {
    super.initState();
    _items =
        widget.entradas.where((e) => e.tripIndex == widget.tripIndex).toList();
  }

  void _addOrEdit({Entrada? original}) async {
    final nueva = await Navigator.push<Entrada>(
      context,
      MaterialPageRoute(
        builder: (_) => CrearEntrada(
          tripIndex: widget.tripIndex,
          entrada: original,
        ),
      ),
    );

    if (nueva == null) return;
    setState(() {
      if (original == null) {
        _items = [..._items, nueva];
      } else {
        _items = _items.map((e) => e.id == nueva.id ? nueva : e).toList();
      }
    });
  }

  void _delete(Entrada e) {
    setState(() {
      _items = _items.where((x) => x.id != e.id).toList();
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Entrada eliminada')));
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd-MM-yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entradas del viaje',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal[200],
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.teal[200],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEdit(),
        tooltip: 'Nueva entrada',
        child: const Icon(Icons.add),
      ),
      body: _items.isEmpty
          ? const Center(
              child:
                  Text('No hay entradas aún.', style: TextStyle(fontSize: 16)))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final e = _items[i];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.book),
                    title: Text(e.titulo,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${fmt.format(e.fecha)} · ${e.texto}',
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    onTap: () => _addOrEdit(original: e),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(e),
                      tooltip: 'Eliminar',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
