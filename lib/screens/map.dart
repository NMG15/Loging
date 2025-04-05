import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils/database_helper.dart';
import 'marker_form_screen.dart';

class MapScreen extends StatefulWidget {
  final String correo;

  const MapScreen({Key? key, required this.correo}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _initialPosition = LatLng(20.4217, -99.2118); // Ixmiquilpan
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadUserMarkers();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onLongPress(LatLng position) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarkerFormScreen(
          position: position,
          correo: widget.correo,
        ),
      ),
    ).then((result) {
      if (result != null) _loadUserMarkers();
    });
  }

  Future<void> _loadUserMarkers() async {
    final data = await DatabaseHelper.instance.getMarkersByCorreo(widget.correo);
    setState(() {
      _markers = data.map((item) {
        return Marker(
          markerId: MarkerId(item['id'].toString()),
          position: LatLng(item['latitud'], item['longitud']),
          infoWindow: InfoWindow(
            title: item['titulo'],
            snippet: item['descripcion'],
          ),
          onTap: () => _showMarkerOptions(item),
        );
      }).toSet();
    });
  }

  void _showMarkerOptions(Map<String, dynamic> markerData) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.edit),
            title: Text("Editar"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MarkerFormScreen(
                    position: LatLng(markerData['latitud'], markerData['longitud']),
                    correo: widget.correo,
                    isEditing: true,
                    markerId: markerData['id'],
                    initialTitle: markerData['titulo'],
                    initialDescription: markerData['descripcion'],
                  ),
                ),
              ).then((result) {
                if (result != null) _loadUserMarkers();
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text("Eliminar"),
            onTap: () async {
              await DatabaseHelper.instance.deleteMarker(markerData['id']);
              Navigator.pop(context);
              _loadUserMarkers();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 13.0,
        ),
        markers: _markers,
        onLongPress: _onLongPress,
      ),
    );
  }
}
