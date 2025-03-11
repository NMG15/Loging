import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final correo = _correoController.text;
    final password = _passwordController.text;

    final user = await DatabaseHelper().getUser(correo, password);
    if (user != null) {
      String nombre = user['nombre'];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(nombre: nombre, correo: correo)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Correo o password incorrectos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inicio de Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _correoController, decoration: InputDecoration(labelText: 'Correo electrónico')),
            SizedBox(height: 10),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text('Iniciar sesión', style: TextStyle(fontSize: 18))),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
              },
              child: Text('¿No tienes cuenta? Regístrate aquí', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }
}
