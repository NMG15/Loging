import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'admin_screen.dart';
import 'map.dart'; // Asegúrate de tener esta importación

class HomeScreen extends StatelessWidget {
  final String nombre;
  final String correo;

  const HomeScreen({required this.nombre, required this.correo, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bienvenido')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hola, $nombre 👋', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            // Botón para admin
            if (correo == "admin@gmail.com") 
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminScreen()));
                },
                child: Text('Panel de Administrador'),
              ),

            SizedBox(height: 10),

            // Botón para ver el mapa
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen()));
              },
              child: Text('Ver Mapa'),
            ),

            SizedBox(height: 10),

            // Botón para cerrar sesión
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
              child: Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
