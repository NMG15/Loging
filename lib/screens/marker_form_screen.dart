import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inicio_registro/utils/database_helper.dart';

class MarkerFormScreen extends StatefulWidget {
  final LatLng position;
  final String correo;
  final bool isEditing;
  final int? markerId;
  final String? initialTitle;
  final String? initialDescription;

  const MarkerFormScreen({
    Key? key,
    required this.position,
    required this.correo,
    this.isEditing = false,
    this.markerId,
    this.initialTitle,
    this.initialDescription,
  }) : super(key: key);

  @override
  _MarkerFormScreenState createState() => _MarkerFormScreenState();
}

class _MarkerFormScreenState extends State<MarkerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;

  @override
  void initState() {
    super.initState();
    _title = widget.initialTitle ?? '';
    _description = widget.initialDescription ?? '';
  }

  void _saveMarker() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (widget.isEditing && widget.markerId != null) {
        // Actualizar marcador
        await DatabaseHelper.instance.updateMarker(widget.markerId!, _title, _description);
      } else {
        // Insertar nuevo marcador
        await DatabaseHelper.instance.insertMarker(
          _title,
          _description,
          widget.position.latitude,
          widget.position.longitude,
          widget.correo,
        );
      }

      Navigator.pop(context, true); // Indicamos éxito
    } else {
      print("Formulario no válido");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Marcador' : 'Agregar Marcador'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMarker,
                child: Text(widget.isEditing ? 'Guardar Cambios' : 'Guardar Marcador'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
