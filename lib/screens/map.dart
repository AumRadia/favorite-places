import 'package:flutter/material.dart';
import 'package:favorite_places/models/place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class mapscreen extends StatefulWidget {
  const mapscreen(
      {super.key,
      this.location = const placelocation(
          address: '', latitude: 37.422, longitude: -122.084),
      this.isselecting = true});

  final placelocation location;
  final bool isselecting;

  @override
  State<mapscreen> createState() => _mapscreenState();
}

class _mapscreenState extends State<mapscreen> {
  LatLng? _pickedlocation;
  late GoogleMapController _mapController;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    LocationData locationData = await location.getLocation();
    setState(() {
      _currentLocation =
          LatLng(locationData.latitude!, locationData.longitude!);
      if (_pickedlocation == null) {
        _pickedlocation = _currentLocation;
      }
    });
  }

  void _moveToCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLng(_currentLocation!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isselecting ? 'Pick your location' : 'Your location'),
        actions: [
          if (widget.isselecting)
            IconButton(
                onPressed: () {
                  Navigator.of(context).pop(_pickedlocation);
                },
                icon: const Icon(Icons.save))
        ],
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onTap: !widget.isselecting
                  ? null
                  : (position) {
                      setState(() {
                        _pickedlocation = position;
                      });
                    },
              initialCameraPosition: CameraPosition(
                target: _pickedlocation ?? _currentLocation!,
                zoom: 16,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('m1'),
                  position: _pickedlocation ?? _currentLocation!,
                  draggable: widget.isselecting,
                  onDragEnd: (newPosition) {
                    setState(() {
                      _pickedlocation = newPosition;
                    });
                  },
                  onTap: _moveToCurrentLocation,
                ),
              },
            ),
    );
  }
}
