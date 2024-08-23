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

  @override
  void initState() {
    super.initState();
    _location.getLocation().then((location) {
      setState(() {
        _targetLocation = LatLng(
          double.parse(location.latitude!.toStringAsFixed(7)),
          double.parse(location.longitude!.toStringAsFixed(7)),
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
            _targetLocation = LatLng(
              double.parse(result.latitude.toStringAsFixed(7)),
              double.parse(result.longitude.toStringAsFixed(7)),
            );
            _mapController.move(_targetLocation, 14.0);
          });
        }
      } catch (e) {
        debugPrint("Error in geocoding: $e");
      }
    }
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
          ),
          SearchWidget(
            searchController: _searchController,
            onSearch: _onSearch,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController.move(_targetLocation, 14.0);
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
