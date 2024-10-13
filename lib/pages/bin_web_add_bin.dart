import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecobin_app/services/database.dart';
import 'package:ecobin_app/services/notification_service.dart';
import 'package:ecobin_app/pages/bin_web_qr.dart';
import 'package:ecobin_app/pages/monitor_bin.dart';
import 'package:ecobin_app/pages/notification.dart';

class BinWebAddbin extends StatefulWidget {
  @override
  _BinWebAddbinState createState() => _BinWebAddbinState();
}

class _BinWebAddbinState extends State<BinWebAddbin> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController binHeightController = TextEditingController();
  String selectedBinType = 'Select Bin Type';
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    // If the device is mobile or web
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'BIN',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (!isMobile) {
            // Web view with sidebar
            return Row(
              children: [
                // Sidebar menu
                Container(
                  width: 250,
                  color: Colors.green[100],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text('Monitoring'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MonitorBin()),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text('Alerts'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationPage(
                                notificationService: NotificationService(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Main content area with scrollable view
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildForm(isMobile),
                  ),
                ),
              ],
            );
          } else {
            // Mobile view without sidebar
            return SingleChildScrollView(
              child: _buildForm(isMobile),
            );
          }
        },
      ),
    );
  }

  // Method to build the form
  Widget _buildForm(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 30.0 : 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
             
              children: [
                SizedBox(height: 10),
                Text(
                  'Bin Selection & Add Details',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add Your Bin Details.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _buildTextField('Bin Label :', nameController),
              const SizedBox(height: 30),
              _buildTextField('Address :', addressController),
              const SizedBox(height: 30),
              _buildDropdown(),
              const SizedBox(height: 30),
              _buildTextField('Bin Height (cm) :', binHeightController),
              const SizedBox(height: 50),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 15.0),
                  ),
                  child: const Text(
                    'Generate QR & Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ],
      ),
    );
  }

  // Form text field
  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ],
    );
  }

  // Bin type drop down
  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bin Type :', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedBinType,
          items: const [
            DropdownMenuItem(
                value: 'Select Bin Type', child: Text('Select Bin Type')),
            DropdownMenuItem(value: 'Plastic', child: Text('Plastic')),
            DropdownMenuItem(value: 'Organic', child: Text('Organic')),
            DropdownMenuItem(value: 'Recyclable', child: Text('Recyclable')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),
          ],
          onChanged: (value) {
            setState(() {
              selectedBinType = value!;
            });
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ],
    );
  }

  // Function to submit the form and save the data to Firestore via the database service
  Future<void> _submitForm() async {
    if (nameController.text.isEmpty ||
        addressController.text.isEmpty ||
        selectedBinType == 'Select Bin Type' ||
        binHeightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    String? userId = FirebaseAuth.instance.currentUser?.uid;

    try {
      String binId = await _databaseService.addBinDetails(
        name: nameController.text,
        address: addressController.text,
        binType: selectedBinType,
        binHeight: binHeightController.text,
        userId: userId!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bin details successfully added!')));

      nameController.clear();
      addressController.clear();
      binHeightController.clear();
      setState(() {
        selectedBinType = 'Select Bin Type';
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BinWebQr(binId: binId)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding bin details: $e')),
      );
    }
  }
}
