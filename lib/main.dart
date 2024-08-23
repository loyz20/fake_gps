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
  loc.LocationData? _currentLocation;
  bool _isFakeLocation = false;
  LatLng? _fakeLocation;

  @override
  void initState() {
    super.initState();
    _location.getLocation().then((location) {
      setState(() {
        _currentLocation = location;
        _targetLocation = _formatCoordinates(
          location.latitude!,
          location.longitude!,
        );
        _mapController.move(_targetLocation, 14.0);
      });
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
            _targetLocation = _formatCoordinates(
              result.latitude,
              result.longitude,
            );
            _mapController.move(_targetLocation, 14.0);
          });
        }
      } catch (e) {
        debugPrint("Error in geocoding: $e");
      }
    }
  }

  LatLng _formatCoordinates(double latitude, double longitude) {
    return LatLng(
      double.parse(latitude.toStringAsFixed(7)),
      double.parse(longitude.toStringAsFixed(7)),
    );
  }

  void _onMarkerDragEnd(LatLng newLocation) {
    setState(() {
      _fakeLocation = LatLng(
        double.parse(newLocation.latitude.toStringAsFixed(7)),
        double.parse(newLocation.longitude.toStringAsFixed(7)),
      );
    });
  }

  void _toggleLocation() {
    setState(() {
      if (_isFakeLocation) {
        _targetLocation = _formatCoordinates(
          _currentLocation!.latitude!,
          _currentLocation!.longitude!,
        );
      } else if (_fakeLocation != null) {
        _targetLocation = _fakeLocation!;
      }
      _isFakeLocation = !_isFakeLocation;
      _mapController.move(_targetLocation, 14.0);
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
            onMarkerDragEnd: _onMarkerDragEnd, // Pass the callback for dragging
          ),
          SearchWidget(
            searchController: _searchController,
            onSearch: _onSearch,
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _mapController.move(_targetLocation, 14.0);
            },
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 16.0),
          FloatingActionButton(
            onPressed: _toggleLocation,
            child: Icon(
              _isFakeLocation ? Icons.stop : Icons.play_arrow,
            ),
          ),
        ],
      ),
    );
  }
}
