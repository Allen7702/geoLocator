import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const LocationApp());
}

class LocationApp extends StatelessWidget {
  const LocationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LocationScreen(),
    );
  }
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  // Text controller for the location input field
  final TextEditingController _locationController = TextEditingController();
  // State variable for auto updating location
  bool _autoUpdateLocation = true;
  // State variable to hold current location
  final List<String> _savedLocations = [];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

// Function to get the current location
  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String newLocation = "${position.latitude}, ${position.longitude}";

      setState(() {
        if (_autoUpdateLocation) {
          _locationController.text = newLocation;
        }
      });
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
    }
  }

  // Function to toggle auto location updates
  void _toggleAutoUpdate(bool value) {
    setState(() {
      _autoUpdateLocation = value;
      if (_autoUpdateLocation) {
        _getLocation();
      }
    });
  }

// Function to save the location to the list
  void _saveLocation() {
    setState(() {
      _savedLocations.add(_locationController.text);
    });
  }

  // Function to open the map screen for selecting a location
  void _openMapForLocation() async {
    final position = await Navigator.push<Position>(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(locationText: _locationController.text),
      ),
    );
    if (position != null) {
      setState(() {
        _locationController.text =
            "${position.latitude}, ${position.longitude}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _locationController,
              enabled: true,
              decoration: InputDecoration(
                labelText: 'Location',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: _openMapForLocation,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Toggle switch for auto location updates
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Auto Update'),
                Switch(
                  value: _autoUpdateLocation,
                  onChanged: _toggleAutoUpdate,
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _getLocation,
              child: const Text('Update Location'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveLocation,
              child: const Text('Save Location'),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Saved Locations:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:
                  _savedLocations.map((location) => Text(location)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  final String locationText;

  const MapScreen({Key? key, required this.locationText}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Position? _selectedPosition;
  Marker? _userLocationMarker;

 void _onMapTap(TapPosition point, LatLng latlng) {
  setState(() {
    _userLocationMarker = Marker(
      width: 80.0,
      height: 80.0,
      point: latlng,
      builder: (ctx) => const Icon(
        Icons.location_pin,
        color: Colors.blue,
        size: 40.0,
      ),
    );
    _selectedPosition = Position(
      latitude: latlng.latitude,
      longitude: latlng.longitude,
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      timestamp: DateTime.now(),
    );
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: widget.locationText.isNotEmpty
              ? LatLng(
                  double.parse(widget.locationText.split(',')[0]),
                  double.parse(widget.locationText.split(',')[1]),
                )
              : const LatLng(
                  -6.76456, 39.2484481), // Default if input field is empty
          maxZoom: 18,
          zoom: 17.0,
          onTap: _onMapTap,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              if (_userLocationMarker != null)
                _userLocationMarker!, 
            ],
          ),
        ],
      ),
      floatingActionButton: _selectedPosition != null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pop(context, _selectedPosition);
              },
              child: const Icon(Icons.check),
            )
          : null,
    );
  }
}
