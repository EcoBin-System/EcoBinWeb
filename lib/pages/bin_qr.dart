import 'package:ecobin_app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:ecobin_app/pages/bin_details_page.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BinQr extends StatefulWidget {
  @override
  _BinQrState createState() => _BinQrState();
}

class _BinQrState extends State<BinQr> {
  final DatabaseService _databaseService = DatabaseService();

  void _handleBarcodeScan(String? binCode) async {
    if (binCode != null && binCode.isNotEmpty) {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fetching bin details...')),
      );

      // Fetch the bin details from the database
      final binDetails = await _databaseService.getBinDetailsByIdScan(binCode);

      if (binDetails != null) {
        // Navigate to the bin details page and pass the fetched data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BinDetailsPage(binData: binDetails),
          ),
        );
      } else {
        // Handle no data found case
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No bin found with this ID.')),
        );
      }
    } else {
      // Handle invalid scanned code
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scanned QR code is invalid.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BIN',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                width: 300,
                height: 400,
                child: MobileScanner(
                  onDetect: (BarcodeCapture barcodeCapture) {
                    // Check if there are any barcodes detected
                    if (barcodeCapture.barcodes.isNotEmpty) {
                      // Extract the raw value from the first barcode
                      final String? binCode = barcodeCapture
                          .barcodes.first.rawValue; // Get the first barcode
                      _handleBarcodeScan(binCode); // Call the handler function
                    } else {
                      // Handle the case when no barcodes are detected
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No barcodes detected.')),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 180.0),
            child: Text(
              'Scan QR code in here',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }
}
