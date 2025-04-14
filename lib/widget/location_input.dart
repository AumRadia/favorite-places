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
  placelocation? _pickedLocation;
  var _isGettingLocation = false;

  String get _locationImage {
    if (_pickedLocation == null) return '';
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x300&maptype=roadmap&markers=color:blue%7Clabel:A%7C$lat,$lng&key=AIzaSyBMTxuLSctF8wG3xaEpN6Fk52IcdgrmSus';
  }

  Future<void> _getLocationPreview(double lat, double lng) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=AIzaSyBMTxuLSctF8wG3xaEpN6Fk52IcdgrmSus');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      final address = (data['results'] as List).isNotEmpty
          ? data['results'][0]['formatted_address']
          : 'Unknown location';

      setState(() {
        _pickedLocation =
            placelocation(address: address, latitude: lat, longitude: lng);
        _isGettingLocation = false;
      });

      widget.onselectlocation(_pickedLocation!);
    } catch (e) {
      _isGettingLocation = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    final location = Location();

    try {
      setState(() => _isGettingLocation = true);

      if (!await location.serviceEnabled() &&
          !await location.requestService()) {
        return;
      }

      PermissionStatus permission = await location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await location.requestPermission();
        if (permission != PermissionStatus.granted) return;
      }

      final locData = await location.getLocation();

      if (locData.latitude == null || locData.longitude == null) {
        return;
      }

      await _getLocationPreview(locData.latitude!, locData.longitude!);
    } catch (e) {
      _isGettingLocation = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() {});
    }
  }

  Future<void> _selectOnMap() async {
    setState(() => _isGettingLocation = true);
    final pickedLoc = await Navigator.of(context)
        .push<LatLng>(MaterialPageRoute(builder: (ctx) => const mapscreen()));

    if (pickedLoc == null) {
      setState(() => _isGettingLocation = false);
      return;
    }

    await _getLocationPreview(pickedLoc.latitude, pickedLoc.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 180,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              width: 2,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            color: theme.colorScheme.surface.withOpacity(0.05),
          ),
          alignment: Alignment.center,
          child: _isGettingLocation
              ? const CircularProgressIndicator()
              : _pickedLocation != null && _locationImage.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.network(
                        _locationImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : Text(
                      'No location selected',
                      style: theme.textTheme.bodyLarge!.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.8),
                foregroundColor: Colors.white,
                elevation: 5,
              ),
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.my_location_rounded),
              label: const Text('Current Location'),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(
                    color: theme.colorScheme.primary.withOpacity(0.6)),
              ),
              onPressed: _selectOnMap,
              icon: const Icon(Icons.map_outlined),
              label: const Text('Select on Map'),
            ),
          ],
        ),
      ],
    );
  }
}
