import 'package:favorite_places/providers/userplaces.dart';
import 'package:favorite_places/screens/add_place.dart';
import 'package:favorite_places/widget/places_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Placesscreen extends ConsumerStatefulWidget {
  const Placesscreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _PlacesscreenState();
  }
}

class _PlacesscreenState extends ConsumerState<Placesscreen> {
  late Future<void> _placesfuture;

  @override
  void initState() {
    super.initState();
    _placesfuture = ref.read(userplacesprovider.notifier).loadplaces();
  }

  @override
  Widget build(BuildContext context) {
    final userplaces = ref.watch(userplacesprovider);

    print('UI Places: $userplaces');
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your places'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => const AddPlacescreen()));
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder(
              future: _placesfuture,
              builder: (context, snapshot) =>
                  snapshot.connectionState == ConnectionState.waiting
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : PlacesList(places: userplaces)),
        ));
  }
}
