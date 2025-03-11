import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'datamanager.dart';

class ChangeCarScreen extends StatefulWidget {
  final int carId;

  const ChangeCarScreen({
    super.key,
    required this.carId,
  });

  @override
  State<ChangeCarScreen> createState() => _ChangeCarScreenState();
}

class _ChangeCarScreenState extends State<ChangeCarScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _mileageController;
  late final TextEditingController _lastOilChangeMileageController;
  late final TextEditingController _lastOilFilterMileageController;
  late final TextEditingController _lastAirFilterMileageController;
  DateTime? _lastOilChange;
  DateTime? _lastOilFilterChange;
  DateTime? _lastAirFilterChange;
  // ignore: unused_field
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _mileageController = TextEditingController();
    _lastOilChangeMileageController = TextEditingController();
    _lastOilFilterMileageController = TextEditingController();
    _lastAirFilterMileageController = TextEditingController();
    _loadCarDetails();
  }

  Future<void> _loadCarDetails() async {
    try {
      final carDetails =
          await context.read<DataManager>().getCarDetails(widget.carId);

      if (carDetails.isNotEmpty) {
        setState(() {
          _nameController.text = carDetails['name'];
          _mileageController.text = carDetails['currentMileage'].toString();
          _lastOilChangeMileageController.text = carDetails['lastOilChangeMileage'] != null
              ? carDetails['lastOilChangeMileage'].toString()
              : '';
          _lastOilFilterMileageController.text = carDetails['lastOilFilterMileage'] != null
              ? carDetails['lastOilFilterMileage'].toString()
              : '';
          _lastAirFilterMileageController.text = carDetails['lastAirFilterMileage'] != null
              ? carDetails['lastAirFilterMileage'].toString()
              : '';
          _lastOilChange = carDetails['lastOilChange'];
          _lastOilFilterChange = carDetails['lastOilFilterChange'];
          _lastAirFilterChange = carDetails['lastAirFilterChange'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load car details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildMaintenanceRow(String label, DateTime? date,
      TextEditingController mileageController, Function() onTap) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: TextFormField(
              controller: mileageController,
              decoration: const InputDecoration(
                labelText: 'Mileage',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                if (int.tryParse(value) == null) {
                  return 'Invalid';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color:
                      date != null ? Colors.blue.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: date != null
                        ? Colors.blue.shade200
                        : Colors.grey.shade400,
                  ),
                ),
                child: Text(
                  date != null
                      ? "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}"
                      : "Select Date",
                  style: TextStyle(
                    color: date != null ? Colors.black87 : Colors.grey.shade700,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleUpdateCar(BuildContext context) async {
    if (_formKey.currentState!.validate() && _lastOilChange != null && _lastOilFilterChange != null && _lastAirFilterChange != null) {
        try {
            await context.read<DataManager>().updateCar(
                widget.carId,
                _nameController.text,
                int.parse(_mileageController.text),
                _lastOilChange!,
                int.parse(_lastOilChangeMileageController.text),
                _lastOilFilterChange!,
                int.parse(_lastOilFilterMileageController.text),
                _lastAirFilterChange!,
                int.parse(_lastAirFilterMileageController.text),
            );
            
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Car updated successfully!')),
            );
        } catch (e) {
            print(e); // Log the actual exception
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Failed to update car. Check the logs for details.'),
                    backgroundColor: Colors.red,
                ),
            );
        }
    } else {    
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please fill in all required fields'),
                backgroundColor: Colors.orange,
            ),
        );
    }
    Navigator.of(context).pop(); 
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).popUntil((route) => route.isFirst);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Update Car Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car Details Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Car Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Car Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the car name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _mileageController,
                          decoration: const InputDecoration(
                            labelText: 'Current Mileage',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the mileage';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Maintenance Dates Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Maintenance History',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildMaintenanceRow(
                          'Oil Change',
                          _lastOilChange,
                          _lastOilChangeMileageController,
                          () async {
                            final pickedDate = await _pickDate(context);
                            if (pickedDate != null) {
                              setState(() => _lastOilChange = pickedDate);
                            }
                          },
                        ),
                        _buildMaintenanceRow(
                          'Oil Filter',
                          _lastOilFilterChange,
                          _lastOilFilterMileageController,
                          () async {
                            final pickedDate = await _pickDate(context);
                            if (pickedDate != null) {
                              setState(() => _lastOilFilterChange = pickedDate);
                            }
                          },
                        ),
                        _buildMaintenanceRow(
                          'Air Filter',
                          _lastAirFilterChange,
                          _lastAirFilterMileageController,
                          () async {
                            final pickedDate = await _pickDate(context);
                            if (pickedDate != null) {
                              setState(() => _lastAirFilterChange = pickedDate);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _handleUpdateCar(context),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Update Car',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<DateTime?> _pickDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mileageController.dispose();
    _lastOilChangeMileageController.dispose();
    _lastOilFilterMileageController.dispose();
    _lastAirFilterMileageController.dispose();
    super.dispose();
  }
}
