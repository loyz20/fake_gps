import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng targetLocation;

  const MapWidget({super.key, 
    required this.mapController,
    required this.targetLocation, required bool isFakeGpsActive, LatLng? fakeLocation,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      key: const ValueKey('mapWidget'),
      mapController: mapController,
      options: MapOptions(
        initialCenter : targetLocation,
        initialZoom : 14.0,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: targetLocation,
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
