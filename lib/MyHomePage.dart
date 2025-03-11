import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'datamanager.dart';
import 'addcar.dart';
import 'card.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Mate"),
      ),
      body: Consumer<DataManager>(
        builder: (context, dataManager, child) {
          final cars = dataManager.cars;

          if (cars.isEmpty) {
            return const Center(
              child: Text("No cars available. Add a car to get started!"),
            );
          }

          return ListView(
            children: cars.map((car) {
              return CarCard(
                id: car['id'] ?? 0,
                name: car['name'] ?? 'Unknown',
                mileage: car['currentMileage'] ?? 0,
                lastOilChange: car['lastOilChange'] != null
                    ? DateTime.fromMillisecondsSinceEpoch(car['lastOilChange'])
                    : DateTime.now(), // Default to current date
                lastOilFilterChange: car['lastOilFilterChange'] != null
                    ? DateTime.fromMillisecondsSinceEpoch(
                        car['lastOilFilterChange'])
                    : DateTime.now(), // Default to current date
                lastAirFilterChange: car['lastAirFilterChange'] != null
                    ? DateTime.fromMillisecondsSinceEpoch(
                        car['lastAirFilterChange'])
                    : DateTime.now(), // Default to current date
                dataManager: dataManager,
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCarScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
