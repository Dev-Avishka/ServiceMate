// Suggested code may be subject to a license. Learn more: ~LicenseLog:287654323.
import 'package:flutter/material.dart';
import 'changecar.dart';
import 'datamanager.dart';

class CarCard extends StatelessWidget {
  final int id; // Added id field
  final String name;
  final int mileage;
  final DateTime lastOilChange;
  final DateTime lastOilFilterChange;
  final DateTime lastAirFilterChange;
  final DataManager dataManager; // Added dataManager instance

  const CarCard({
    super.key,
    required this.id, // Added to constructor
    required this.name,
    required this.mileage,
    required this.lastOilChange,
    required this.lastOilFilterChange,
    required this.lastAirFilterChange,
    required this.dataManager, // Added to constructor
  });

  void _navigateToChangeCard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeCarScreen(
          carId: id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          _navigateToChangeCard(context);
        },
          onLongPress: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Confirm Delete"),
                  content:
                  const Text("Are you sure you want to delete this car?"),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Cancel")),
                    TextButton(
                        onPressed: () {
                          dataManager.deleteCar(id);
                          Navigator.of(context).pop();
                        },
                        child: const Text("Delete")),
                  ],
                );
              },
            );
          },

        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMaintenanceItem('Mileage', '$mileage'),
                _buildMaintenanceItem(
                  'Last Oil Change',
                  "${lastOilChange.year}-${lastOilChange.month.toString().padLeft(2, '0')}-${lastOilChange.day.toString().padLeft(2, '0')}",
                ),
                _buildMaintenanceItem(
                  'Last Oil Filter Change',
                  "${lastOilFilterChange.year}-${lastOilFilterChange.month.toString().padLeft(2, '0')}-${lastOilFilterChange.day.toString().padLeft(2, '0')}",
                ),
                _buildMaintenanceItem(
                  'Last Air Filter Change',
                  "${lastAirFilterChange.year}-${lastAirFilterChange.month.toString().padLeft(2, '0')}-${lastAirFilterChange.day.toString().padLeft(2, '0')}",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
