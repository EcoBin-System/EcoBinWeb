import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateBinPage extends StatefulWidget {
  @override
  _UpdateBinPageState createState() => _UpdateBinPageState();
}

class _UpdateBinPageState extends State<UpdateBinPage> {
  // Controllers for text fields
  TextEditingController nameController = TextEditingController();
  TextEditingController binTypeController = TextEditingController();
  TextEditingController binHeightController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController availabilityController = TextEditingController();
  TextEditingController uidController =
      TextEditingController(); // Controller for user ID

  List<DocumentSnapshot> bins = []; // List of bins fetched from Firestore
  DocumentSnapshot? selectedBin; // Currently selected bin

  @override
  void initState() {
    super.initState();
    _fetchBins(); // Fetch bins when the page loads
  }

  // Fetch all bins from Firestore
  Future<void> _fetchBins() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('bins').get();
      setState(() {
        bins = querySnapshot.docs;
      });
    } catch (e) {
      print('Error fetching bins: $e');
    }
  }

  // Method to update bin details in Firestore
  Future<void> _updateBinDetails() async {
    if (selectedBin == null) return; // Ensure a bin is selected

    // Get the current bin's availability before updating
    String currentAvailability = selectedBin!['availability'] as String;

    // Get new availability percentage from the controller
    String newAvailability = availabilityController.text.trim();

    // Check if the new availability includes '%' sign
    if (!newAvailability.endsWith('%')) {
      // If not, append it to the new availability
      newAvailability += '%';
    }

    // Validate the format (ensure it's a number before the '%' sign)
    String numericPart = newAvailability.replaceAll('%', '').trim();
    if (double.tryParse(numericPart) == null) {
      print(
          'Error: Invalid availability format. Must be a number followed by %.');
      _showErrorDialog('Invalid input',
          'Please enter a valid availability percentage (e.g., "20%").');
      return;
    }

    try {
      // Update the bin details
      await FirebaseFirestore.instance
          .collection('bins')
          .doc(selectedBin!.id)
          .update({
        'availability': newAvailability, // Store as string with '%'
      });

      // Log the update in the binupdates collection
      await FirebaseFirestore.instance.collection('binupdates').add({
        'binId': selectedBin!.id,
        'userId': uidController.text, // Include user ID
        'binType': selectedBin!['binType'],
        'timestamp': FieldValue.serverTimestamp(),
        'previousAvailabilityPercentage': currentAvailability,
        'newAvailabilityPercentage': newAvailability,
      });

      Navigator.of(context).pop(); // Return to the previous screen after update
    } catch (e) {
      print('Error updating bin: $e');
      _showErrorDialog(
          'Error', 'Failed to update the bin. Please try again later.');
    }
  }

  // Populate text fields with the selected bin's data
  void _populateBinDetails(DocumentSnapshot bin) {
    setState(() {
      selectedBin = bin; // Set the selected bin
      nameController.text = bin['name'] ?? '';
      binTypeController.text = bin['binType'] ?? '';
      binHeightController.text = bin['binHeight'] ?? '';
      addressController.text = bin['address'] ?? '';
      availabilityController.text = bin['availability'] ?? '';
      uidController.text = bin['userId'] ?? ''; // Set user ID
    });
  }

  // Show error dialog for invalid input
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select and Update Bin'),
        backgroundColor: const Color(0xFF3E9140), // Custom color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown to select a bin
            if (bins.isNotEmpty)
              DropdownButton<DocumentSnapshot>(
                hint: const Text('Select a bin to update'),
                value: selectedBin,
                onChanged: (DocumentSnapshot? bin) {
                  if (bin != null) {
                    _populateBinDetails(
                        bin); // Populate form with selected bin's details
                  }
                },
                items: bins.map((bin) {
                  return DropdownMenuItem<DocumentSnapshot>(
                    value: bin,
                    child: Text(bin['name'] ??
                        'Unnamed Bin'), // Display the bin's name in the dropdown
                  );
                }).toList(),
              ),
            if (selectedBin != null) ...[
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Bin Label:'),
                enabled: false, // Make field uneditable
              ),
              const SizedBox(height: 20),
              TextField(
                controller: binTypeController,
                decoration: const InputDecoration(
                    labelText:
                        'Bin Type (Plastic, Organic, Recyclable, Other):'),
                enabled: false, // Make field uneditable
              ),
              const SizedBox(height: 20),
              TextField(
                controller: binHeightController,
                decoration:
                    const InputDecoration(labelText: 'Bin Height (cm):'),
                enabled: false, // Make field uneditable
              ),
              const SizedBox(height: 20),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address:'),
                enabled: false, // Make field uneditable
              ),
              const SizedBox(height: 20),
              TextField(
                controller: availabilityController,
                decoration: const InputDecoration(
                    labelText: 'Availability Percentage (e.g., "20%") :'),
                keyboardType: TextInputType.text, // Allow text input
              ),
              const SizedBox(height: 20),
              TextField(
                controller: uidController,
                decoration: const InputDecoration(labelText: 'User ID:'),
                enabled: false, // Make field uneditable
              ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: _updateBinDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF3E9140), // Custom button color
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Update Bin'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    nameController.dispose();
    binTypeController.dispose();
    binHeightController.dispose();
    addressController.dispose();
    availabilityController.dispose();
    uidController.dispose(); // Dispose user ID controller
    super.dispose();
  }
}
