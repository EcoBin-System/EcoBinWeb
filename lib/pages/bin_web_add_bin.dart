import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  // TextEditingControllers for the form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController binHeightController = TextEditingController();
  String selectedBinType = 'Select Bin Type';

  // Instance of DatabaseService
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
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
      body: Row(
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
                    // Navigate to monitoring section
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
                    notificationService: NotificationService(), // Pass the instance
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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Move title to the top
                    const Padding(
                      padding: EdgeInsets.only(
                          bottom: 50.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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

                    // Form
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Column(
                        children: [
                          _buildTextField('Bin Lable :', nameController),
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Form text field
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
            isDense: true, // Reduces height of TextField
          ),
        ),
      ],
    );
  }

  //Bin type drop down
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
            DropdownMenuItem(value: 'General', child: Text('General')),
            DropdownMenuItem(value: 'Organic', child: Text('Organic')),
            DropdownMenuItem(value: 'Recycle', child: Text('Recycle')),
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
  // Validate fields
  if (nameController.text.isEmpty ||
      addressController.text.isEmpty ||
      selectedBinType == 'Select Bin Type' ||
      binHeightController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill in all fields.')),
    );
    return;
  }

  // Get the current user's ID
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  // Call the method in DatabaseService to add bin details
  try {
    String binId = await _databaseService.addBinDetails(
      name: nameController.text,
      address: addressController.text,
      binType: selectedBinType,
      binHeight: binHeightController.text,
      userId: userId!, // Pass the user ID
    );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bin details successfully added!')));

    // Clear form
    nameController.clear();
    addressController.clear();
    binHeightController.clear();
    setState(() {
      selectedBinType = 'Select Bin Type';
    });

    // Navigate to BinWebQr page with the bin ID
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BinWebQr(binId: binId)),
    );
  } catch (e) {
    // Handle error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error adding bin details: $e')),
    );
  }
}

}
