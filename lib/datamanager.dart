import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataManager extends ChangeNotifier {
  static final DataManager _instance = DataManager._internal();
  static Database? _database;

  factory DataManager() {
    return _instance;
  }

  DataManager._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  // Add this method to your DataManager class
  Future<Map<String, dynamic>> getCarDetails(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'cars',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return {
        'name': result.first['name'],
        'currentMileage': result.first['currentMileage'],
        'lastOilChange':
            DateTime.fromMillisecondsSinceEpoch(result.first['lastOilChange']),
        'lastOilChangeMileage': result.first['lastOilChangeMileage'],
        'lastOilFilterChange': DateTime.fromMillisecondsSinceEpoch(
            result.first['lastOilFilterChange']),
        'lastOilFilterMileage': result.first['lastOilFilterMileage'],
        'lastAirFilterChange': DateTime.fromMillisecondsSinceEpoch(
            result.first['lastAirFilterChange']),
        'lastAirFilterMileage': result.first['lastAirFilterMileage'],
      };
    }
    return {};
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'car_maintenance.db');

    return await openDatabase(
      path,
      version: 3, // Increment version for new migration
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cars(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            currentMileage INTEGER,
            lastMileage INTEGER,
            lastMileageUpdate INTEGER,
            lastOilChange INTEGER,
            lastOilChangeMileage INTEGER,
            lastOilFilterChange INTEGER,
            lastOilFilterMileage INTEGER,
            lastAirFilterChange INTEGER,
            lastAirFilterMileage INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              'ALTER TABLE cars ADD COLUMN lastMileage INTEGER DEFAULT 0');
          await db.execute(
              'ALTER TABLE cars ADD COLUMN lastMileageUpdate INTEGER DEFAULT 0');
          await db.execute(
              'UPDATE cars SET lastMileage = currentMileage, lastMileageUpdate = ${DateTime.now().millisecondsSinceEpoch}');
        }
        if (oldVersion < 3) {
          // Add new maintenance mileage columns
          await db.execute(
              'ALTER TABLE cars ADD COLUMN lastOilChangeMileage INTEGER DEFAULT 0');
          await db.execute(
              'ALTER TABLE cars ADD COLUMN lastOilFilterMileage INTEGER DEFAULT 0');
          await db.execute(
              'ALTER TABLE cars ADD COLUMN lastAirFilterMileage INTEGER DEFAULT 0');
        }
      },
    );
  }

  List<Map<String, dynamic>> _cars = [];

  List<Map<String, dynamic>> get cars => _cars;

  Future<void> fetchCars() async {
    final db = await database;
    _cars = await db.query('cars');
    notifyListeners();
  }

  Future<void> addCar(
    String name,
    int currentMileage,
    DateTime lastOilChange,
    DateTime lastOilFilterChange,
    DateTime lastAirFilterChange,
  ) async {
    final db = await database;
    await db.insert('cars', {
      'name': name,
      'currentMileage': currentMileage,
      'lastMileage': currentMileage,
      'lastMileageUpdate': DateTime.now().millisecondsSinceEpoch,
      'lastOilChange': lastOilChange.millisecondsSinceEpoch,
      'lastOilChangeMileage': currentMileage,
      'lastOilFilterChange': lastOilFilterChange.millisecondsSinceEpoch,
      'lastOilFilterMileage': currentMileage,
      'lastAirFilterChange': lastAirFilterChange.millisecondsSinceEpoch,
      'lastAirFilterMileage': currentMileage,
    });
    await fetchCars();
  }

  Future<void> updateCar(
    int id,
    String name,
    int currentMileage,
    DateTime lastOilChange,
    int lastOilChangeMileage,
    DateTime lastOilFilterChange,
    int lastOilFilterMileage,
    DateTime lastAirFilterChange,
    int lastAirFilterMileage,
  ) async {
    final db = await database;

    // Get the current car data
    final List<Map<String, dynamic>> currentCar = await db.query(
      'cars',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (currentCar.isNotEmpty) {
      final int oldMileage = currentCar.first['currentMileage'] as int;

      // Only update lastMileage if currentMileage has changed
      if (oldMileage != currentMileage) {
        await db.update(
          'cars',
          {
            'name': name,
            'currentMileage': currentMileage,
            'lastMileage': oldMileage,
            'lastMileageUpdate': DateTime.now().millisecondsSinceEpoch,
            'lastOilChange': lastOilChange.millisecondsSinceEpoch,
            'lastOilChangeMileage': lastOilChangeMileage,
            'lastOilFilterChange': lastOilFilterChange.millisecondsSinceEpoch,
            'lastOilFilterMileage': lastOilFilterMileage,
            'lastAirFilterChange': lastAirFilterChange.millisecondsSinceEpoch,
            'lastAirFilterMileage': lastAirFilterMileage,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      } else {
        // If mileage hasn't changed, update other fields only
        await db.update(
          'cars',
          {
            'name': name,
            'lastOilChange': lastOilChange.millisecondsSinceEpoch,
            'lastOilChangeMileage': lastOilChangeMileage,
            'lastOilFilterChange': lastOilFilterChange.millisecondsSinceEpoch,
            'lastOilFilterMileage': lastOilFilterMileage,
            'lastAirFilterChange': lastAirFilterChange.millisecondsSinceEpoch,
            'lastAirFilterMileage': lastAirFilterMileage,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    }

    await fetchCars();
  }

  Future<Map<String, dynamic>> getMileageHistory(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'cars',
      columns: [
        'currentMileage',
        'lastMileage',
        'lastMileageUpdate',
        'lastOilChangeMileage',
        'lastOilFilterMileage',
        'lastAirFilterMileage'
      ],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return {
        'currentMileage': result.first['currentMileage'],
        'lastMileage': result.first['lastMileage'],
        'lastMileageUpdate': DateTime.fromMillisecondsSinceEpoch(
            result.first['lastMileageUpdate']),
        'mileageDifference':
            result.first['currentMileage'] - result.first['lastMileage'],
        'lastOilChangeMileage': result.first['lastOilChangeMileage'],
        'lastOilFilterMileage': result.first['lastOilFilterMileage'],
        'lastAirFilterMileage': result.first['lastAirFilterMileage'],
      };
    }
    return {};
  }

  Future<void> deleteCar(int id) async {
    final db = await database;
    await db.delete('cars', where: 'id = ?', whereArgs: [id]);
    await fetchCars();
  }
}
