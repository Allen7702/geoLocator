import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'map_screen.dart';
import 'dart:convert';

class LocationScreen extends StatefulWidget {
  // State variable to hold the format of the location
  final bool useGeoJsonFormat;
   // State variable for auto updating location
  final bool autoUpdateLocation;

  const LocationScreen({Key? key, this.useGeoJsonFormat = false,this.autoUpdateLocation = true})
      : super(key: key);
  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  // Text controller for the location input field
  final TextEditingController _locationController = TextEditingController();
 
  // State variable to hold current location
  final List<String> savedLocations = [];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

// Function to get the current location
  Future<void> _getLocation() async {
    bool locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled) {
      // Handle if location services are disabled
      debugPrint("Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("User denied permissions to access the device's location.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle the scenario where user has permanently denied location access
      debugPrint(
          "User denied permissions forever to access the device's location.");
      return;
    }
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      String newLocation = "${position.latitude}, ${position.longitude}";

      setState(() {
        if (widget.autoUpdateLocation) {
          _locationController.text = newLocation;
        }
      });
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
    }
  }

  // Function to toggle auto location updates
  // void _toggleAutoUpdate(bool value) {
  //   setState(() {
  //     _autoUpdateLocation = value;
  //     if (_autoUpdateLocation) {
  //       _getLocation();
  //     }
  //   });
  // }

  Map<String, dynamic> _getGeoJsonCoordinates(
      double latitude, double longitude) {
    return {
      "type": "Point",
      "coordinates": [longitude, latitude]
    };
  }

  void saveLocation(bool useGeoJsonFormat) {
    if (useGeoJsonFormat) {
      double latitude = double.parse(_locationController.text.split(',')[0]);
      double longitude = double.parse(_locationController.text.split(',')[1]);

      Map<String, dynamic> geoJsonCoordinates =
          _getGeoJsonCoordinates(latitude, longitude);

      setState(() {
        savedLocations.add(jsonEncode(geoJsonCoordinates));
      });
    } else {
      setState(() {
        savedLocations.add(_locationController.text);
      });
    }
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
       return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
      TextField(
        controller: _locationController,
        enabled: true,
        decoration: InputDecoration(
          labelText: 'Location',
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.autoUpdateLocation)
                IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: _getLocation,
                ),
              IconButton(
                icon: const Icon(Icons.map),
                onPressed: _openMapForLocation,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                saveLocation(widget.useGeoJsonFormat);
              },
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
                  savedLocations.map((location) => Text(location)).toList(),
            ),
          ],
      ),
    );
  }
}
