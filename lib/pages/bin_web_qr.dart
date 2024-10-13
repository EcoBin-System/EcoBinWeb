import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:ecobin_app/services/database.dart';
import 'package:ecobin_app/services/notification_service.dart';
import 'package:ecobin_app/pages/monitor_bin.dart';
import 'package:ecobin_app/pages/notification.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:ui' as ui;

class BinWebQr extends StatelessWidget {
  final String binId;

  BinWebQr({required this.binId});

  final DatabaseService _databaseService = DatabaseService();

  Future<void> _downloadQRCodeAsPdf(String binId) async {
    // Create the QR code using QrPainter
    final qrPainter = QrPainter(
      data: binId,
      version: QrVersions.auto,
      gapless: true,
      color: const Color(0xFF000000),
      embeddedImage: null,
      embeddedImageStyle: null,
    );

    // Render the QR code to an image
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(200, 200);
    qrPainter.paint(canvas, size);
    final picture = recorder.endRecording();
    final img = await picture.toImage(200, 200);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // Create a PDF document
    final pdf = pw.Document();
    final pdfImage = pw.MemoryImage(pngBytes);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text('Bin ID: $binId',
                  style: const pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Image(pdfImage), // Add QR code image to PDF
            ],
          ),
        ),
      ),
    );

    // Save the PDF document
    final pdfBytes = await pdf.save();

    // Trigger download of the PDF
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'qr_code_$binId.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'QR code',
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // This is the header section fixed at the top
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bin Selection & Add Details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'You can see yor Bin details from this QR code.',
                            style: TextStyle(fontSize: 16),
                          ),
                          ElevatedButton(
                            onPressed: () => _downloadQRCodeAsPdf(binId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[800],
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                            ),
                            child: const Text(
                              'Download QR Code as PDF',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main section
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: FutureBuilder(
                        future: _databaseService.getBinDetailsById(binId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return const Center(
                                child: Text('Error loading bin details'));
                          }

                          if (!snapshot.hasData ||
                              snapshot.data?.data() == null) {
                            return const Center(
                                child: Text('No bin details found'));
                          }

                          // Bin data retrieved from Firestore
                          final binData =
                              snapshot.data!.data() as Map<String, dynamic>;

                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 70.0, bottom: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Bin ID: $binId',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),

                                // Centering the QR code
                                Center(
                                  child: SizedBox(
                                    width: 300.0,
                                    height: 300.0,
                                    child: QrImageView(
                                      data: binId,
                                      version: QrVersions.auto,
                                      size: 200.0,
                                      gapless: false,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),
                                Text('Name: ${binData['name']}'),
                                Text('Address: ${binData['address']}'),
                                Text('Bin Type: ${binData['binType']}'),
                                Text('Bin Height: ${binData['binHeight']}'),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
