import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:favorite_places/models/place.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:uuid/uuid.dart'; // To generate unique IDs for places

Future<sql.Database> _getdatabase() async {
  final dbpath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbpath, 'places.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT)',
      );
    },
    version: 1,
  );
  return db;
}

class UserplacesNotfier extends StateNotifier<List<Place>> {
  UserplacesNotfier() : super(const []) {
    loadplaces();
  }

  Future<void> loadplaces() async {
    final db = await _getdatabase();
    final data = await db.query('user_places');
    final places = data.map((row) {
      return Place(
        id: row['id'] as String,
        title: row['title'] as String,
        image: File(row['image'] as String),
        location: placelocation(
          address: row['address'] as String,
          latitude: (row['lat'] as num?)?.toDouble() ?? 0.0,
          longitude: (row['lng'] as num?)?.toDouble() ?? 0.0,
        ),
      );
    }).toList();

    print('Loaded places from DB: $places');
    state = places;
  }

  void addplace(String title, File image, placelocation location) async {
    final appdir = await syspaths.getApplicationDocumentsDirectory();
    final filename = path.basename(image.path);
    final copiedimage = await image.copy('${appdir.path}/$filename');
    final newplace = Place(
      id: Uuid().v4(),
      title: title,
      image: copiedimage,
      location: location,
    );

    final db = await _getdatabase();
    await db.insert('user_places', {
      'id': newplace.id,
      'title': newplace.title,
      'image': newplace.image.path,
      'lat': newplace.location.latitude,
      'lng': newplace.location.longitude,
      'address': newplace.location.address,
    });

    print(await db.query('user_places'));
    state = [newplace, ...state];
  }

  void deletePlace(String id) async {
    final db = await _getdatabase();
    final placeToDelete = state.firstWhere((place) => place.id == id);

    // Delete the image file
    if (File(placeToDelete.image.path).existsSync()) {
      await File(placeToDelete.image.path).delete();
    }

    // Delete the place from the database
    await db.delete('user_places', where: 'id = ?', whereArgs: [id]);

    // Update the state
    state = state.where((place) => place.id != id).toList();
  }
}

final userplacesprovider =
    StateNotifierProvider<UserplacesNotfier, List<Place>>(
  (ref) => UserplacesNotfier(),
);
