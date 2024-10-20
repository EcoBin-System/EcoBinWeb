import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateBinPage extends StatefulWidget {
  final FirebaseFirestore firestore;

  const UpdateBinPage({Key? key, required this.firestore}) : super(key: key);

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
  TextEditingController uidController = TextEditingController();

  List<DocumentSnapshot> bins = [];
  DocumentSnapshot? selectedBin;

  @override
  void initState() {
    super.initState();
    _fetchBins();
  }

  Future<void> _fetchBins() async {
    try {
      QuerySnapshot querySnapshot =
          await widget.firestore.collection('bins').get();
      setState(() {
        bins = querySnapshot.docs;
      });
    } catch (e) {
      print('Error fetching bins: $e');
    }
  }

  Future<void> _updateBinDetails() async {
    if (selectedBin == null) return;

    String currentAvailability = selectedBin!['availability'] as String;
    String newAvailability = availabilityController.text.trim();

    if (!newAvailability.endsWith('%')) {
      newAvailability += '%';
    }

    String numericPart = newAvailability.replaceAll('%', '').trim();
    if (double.tryParse(numericPart) == null) {
      print(
          'Error: Invalid availability format. Must be a number followed by %.');
      _showErrorDialog('Invalid input',
          'Please enter a valid availability percentage (e.g., "20%").');
      return;
    }

    try {
      await widget.firestore.collection('bins').doc(selectedBin!.id).update({
        'availability': newAvailability,
      });

      await widget.firestore.collection('binupdates').add({
        'binId': selectedBin!.id,
        'userId': uidController.text,
        'binType': selectedBin!['binType'],
        'timestamp': FieldValue.serverTimestamp(),
        'previousAvailabilityPercentage': currentAvailability,
        'newAvailabilityPercentage': newAvailability,
      });

      Navigator.of(context).pop();
    } catch (e) {
      print('Error updating bin: $e');
      _showErrorDialog(
          'Error', 'Failed to update the bin. Please try again later.');
    }
  }

  void _populateBinDetails(DocumentSnapshot bin) {
    setState(() {
      selectedBin = bin;
      nameController.text = bin['name'] ?? '';
      binTypeController.text = bin['binType'] ?? '';
      binHeightController.text = bin['binHeight'] ?? '';
      addressController.text = bin['address'] ?? '';
      availabilityController.text = bin['availability'] ?? '';
      uidController.text = bin['userId'] ?? '';
    });
  }

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
    // The build method remains the same
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select and Update Bin'),
        backgroundColor: const Color(0xFF3E9140),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (bins.isNotEmpty)
              DropdownButton<DocumentSnapshot>(
                hint: const Text('Select a bin to update'),
                value: selectedBin,
                onChanged: (DocumentSnapshot? bin) {
                  if (bin != null) {
                    _populateBinDetails(bin);
                  }
                },
                items: bins.map((bin) {
                  return DropdownMenuItem<DocumentSnapshot>(
                    value: bin,
                    child: Text(bin['name'] ?? 'Unnamed Bin'),
                  );
                }).toList(),
              ),
            if (selectedBin != null) ...[
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Bin Label:'),
                enabled: false,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: binTypeController,
                decoration: const InputDecoration(
                    labelText:
                        'Bin Type (Plastic, Organic, Recyclable, Other):'),
                enabled: false,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: binHeightController,
                decoration:
                    const InputDecoration(labelText: 'Bin Height (cm):'),
                enabled: false,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address:'),
                enabled: false,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: availabilityController,
                decoration: const InputDecoration(
                    labelText: 'Availability Percentage (e.g., "20%") :'),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: uidController,
                decoration: const InputDecoration(labelText: 'User ID:'),
                enabled: false,
              ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: _updateBinDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E9140),
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
    nameController.dispose();
    binTypeController.dispose();
    binHeightController.dispose();
    addressController.dispose();
    availabilityController.dispose();
    uidController.dispose();
    super.dispose();
  }
}
