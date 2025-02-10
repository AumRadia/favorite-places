import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/screens/map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onselectlocation});

  final void Function(placelocation location) onselectlocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  placelocation? _pickedlocation;
  var _isettinglocation = false;

  String get locationimage {
    if (_pickedlocation == null) {
      return '';
    }
    final lat = _pickedlocation!.latitude;
    final lng = _pickedlocation!.longitude;

    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x300&maptype=roadmap&markers=color:blue%7Clabel:A%7C$lat,$lng&key=AIzaSyA2vHkCkvN0dG8eauJdWEC3eOJr4li1yUw';
  }

  Future<void> _saveplace(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=AIzaSyA2vHkCkvN0dG8eauJdWEC3eOJr4li1yUw');
    final response = await http.get(url);
    final resdata = json.decode(response.body);
    final address = resdata['results'][0]['formatted_address'];

    setState(() {
      _pickedlocation = placelocation(
          address: address, latitude: latitude, longitude: longitude);
      _isettinglocation = false;
    });

    widget.onselectlocation(_pickedlocation!);
  }

  void _getcurrentlocation() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _isettinglocation = false;
        });
        return;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          _isettinglocation = false;
        });
        return;
      }
    }

    setState(() {
      _isettinglocation = true;
    });

    try {
      LocationData locationData = await location.getLocation();

      if (locationData.latitude != null && locationData.longitude != null) {
        _saveplace(locationData.latitude!, locationData.longitude!);
      } else {
        setState(() {
          _isettinglocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location unavailable. Try again!')),
        );
      }
    } catch (error) {
      setState(() {
        _isettinglocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $error')),
      );
    }
  }

  void _selectonmap() async {
    final pickedlocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(builder: (ctx) => const mapscreen()),
    );

    if (pickedlocation == null) {
      return;
    }

    _saveplace(pickedlocation.latitude, pickedlocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewcontent = Text(
      'No location chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context)
          .textTheme
          .bodyLarge!
          .copyWith(color: Theme.of(context).colorScheme.onSurface),
    );

    if (_pickedlocation != null) {
      previewcontent = Image.network(
        locationimage,
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
      );
    }

    if (_isettinglocation) {
      previewcontent = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
            height: 170,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: previewcontent),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text('Get current location'),
              onPressed: _getcurrentlocation,
            ),
            TextButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
              onPressed: _selectonmap,
            ),
          ],
        )
      ],
    );
  }
}
