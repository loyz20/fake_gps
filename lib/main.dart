import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'map_widget.dart';
import 'search_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FakeGpsPage(),
    );
  }
}

class FakeGpsPage extends StatefulWidget {
  const FakeGpsPage({super.key});

  @override
  FakeGpsPageState createState() => FakeGpsPageState();
}

class FakeGpsPageState extends State<FakeGpsPage> {
  final TextEditingController _searchController = TextEditingController();
  final loc.Location _location = loc.Location();
  LatLng _targetLocation = const LatLng(-6.200000, 106.816666); // Jakarta as default location
  final MapController _mapController = MapController();
  LatLng? _fakeLocation;
  bool _isFakeGpsActive = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    final locationData = await _location.getLocation();
    setState(() {
      _targetLocation = LatLng(locationData.latitude!, locationData.longitude!);
      _mapController.move(_targetLocation, 14.0);
    });
  }

  Future<void> _onSearch() async {
    String query = _searchController.text;
    if (query.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(query);
        if (locations.isNotEmpty) {
          final result = locations.first;
          setState(() {
            _targetLocation = LatLng(result.latitude, result.longitude);
            _mapController.move(_targetLocation, 14.0);
          });
        }
      } catch (e) {
        debugPrint("Error in geocoding: $e");
      }
    }
  }

  void _toggleFakeGps() {
    setState(() {
      if (_isFakeGpsActive) {
        // Stop Fake GPS, revert to real location
        _isFakeGpsActive = false;
        _fakeLocation = null;
      } else {
        // Start Fake GPS, set location to marker's location
        _isFakeGpsActive = true;
        _fakeLocation = _targetLocation;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fake GPS'),
      ),
      body: Stack(
        children: [
          MapWidget(
            mapController: _mapController,
            targetLocation: _targetLocation,
            isFakeGpsActive: _isFakeGpsActive,
            fakeLocation: _fakeLocation,
          ),
          SearchWidget(
            searchController: _searchController,
            onSearch: _onSearch,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleFakeGps,
        child: Icon(_isFakeGpsActive ? Icons.stop : Icons.play_arrow),
      ),
    );
  }
}
