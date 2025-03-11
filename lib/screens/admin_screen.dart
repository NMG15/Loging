import 'package:flutter/material.dart';
import '../utils/database_helper.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Map<String, dynamic>> _usuarios = [];

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    final usuarios = await DatabaseHelper().getAllUsers();
    setState(() {
      _usuarios = usuarios;
    });
  }

  Future<void> _eliminarUsuario(int id) async {
    await DatabaseHelper().deleteUser(id);
    _cargarUsuarios(); // Actualizar la lista después de eliminar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Usuario eliminado con éxito')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Panel de Administrador')),
      body: _usuarios.isEmpty
          ? Center(child: Text('No hay usuarios registrados'))
          : ListView.builder(
              itemCount: _usuarios.length,
              itemBuilder: (context, index) {
                final usuario = _usuarios[index];
                return ListTile(
                  title: Text(usuario['correo']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _eliminarUsuario(usuario['id']),
                  ),
                );
              },
            ),
    );
  }
}
