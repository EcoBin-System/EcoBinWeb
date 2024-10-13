import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecobin_app/services/database.dart';
import 'package:ecobin_app/services/notification_service.dart';
import 'package:ecobin_app/pages/bin_web_add_bin.dart';
import 'package:ecobin_app/pages/notification.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MonitorBin extends StatefulWidget {
  @override
  _MonitorBinState createState() => _MonitorBinState();
}

class _MonitorBinState extends State<MonitorBin> {
  final DatabaseService _databaseService = DatabaseService();
  List<DocumentSnapshot> bins = [];

  // Method to retrieve bins for the current user
  Stream<QuerySnapshot> _getBinStream() {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return FirebaseFirestore.instance
        .collection('bins')
        .where('userId', isEqualTo: currentUserId)
        .snapshots();
  }

  // Method to show update bin dialog
  void _showUpdateDialog(String binId, String currentName, String currentType, String currentHeight,
      String currentAddress) {
    final TextEditingController nameController =
        TextEditingController(text: currentName);
    final TextEditingController binTypeController =
        TextEditingController(text: currentType);
    final TextEditingController binHeightController =
        TextEditingController(text: currentHeight);
    final TextEditingController addressController =
        TextEditingController(text: currentAddress);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Bin'),
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Bin Label :'),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: binTypeController,
                  decoration: const InputDecoration(labelText: 'Bin Type (Plastic, Organic, Recyclable, Other) :'),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: binHeightController,
                  decoration: const InputDecoration(labelText: 'Bin Height (cm) :'),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address :'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _databaseService.updateBinDetails(
                  binId: binId,
                  name: nameController.text,
                  binType: binTypeController.text,
                  binHeight: binHeightController.text,
                  address: addressController.text,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E9140),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  // Method to delete a bin with confirmation
  void _deleteBin(String binId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Bin'),
          content: Container(
            width: 400,
            child: const Text('Are you sure you want to delete this bin?'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _databaseService.deleteBin(binId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9F2D25),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchBins();
  }

  Future<void> _fetchBins() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('bins').get();
      setState(() {
        bins = querySnapshot.docs; // Update the bins list
      });
    } catch (e) {
      print('Error fetching bins: $e');
    }
  }

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Check if the screen is mobile or web based on width
          bool isMobile = constraints.maxWidth < 600;

          return Row(
            children: [
              // Sidebar menu (only for web)
              if (!isMobile)
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
                          // Handle navigation to monitoring section
                        },
                      ),
                      ListTile(
                        title: const Text('Alerts'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationPage(
                                notificationService:
                                    NotificationService(), // Pass the instance
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              // Main content
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: _getBinStream(), // Listen for changes
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      // Get the bins list from the snapshot
                      List<DocumentSnapshot> bins = snapshot.data!.docs;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header (Fixed at the top)
                          Container(
                            padding: const EdgeInsets.only(
                              top: 20.0,
                              left: 20.0,
                              right: 20.0,
                              bottom: 5.0,
                            ),
                            width: double.infinity,
                            child: const Text(
                              'Monitor Your Bins',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(
                              left: 20.0,
                              right: 20.0,
                              bottom: 10.0,
                            ),
                            child: Text(
                              'You can add & monitor your bins. Check the availability of your bins.',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20.0,
                              right: 20.0,
                              bottom: 10.0,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BinWebAddbin()),
                                );
                              },
                              child: const Text('Add Bin'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[800],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Carousel slider for bins
                          bins.isNotEmpty
                              ? CarouselSlider.builder(
                                  itemCount: bins.length,
                                  itemBuilder: (context, index, realIndex) {
                                    DocumentSnapshot bin =
                                        bins[index]; // Get the DocumentSnapshot
                                    return _buildBinCard(
                                        bin, isMobile); // Pass the DocumentSnapshot
                                  },
                                  options: CarouselOptions(
                                    height: isMobile ? 560.0 : 450.0,
                                    enlargeCenterPage: true,
                                    autoPlay: true,
                                    aspectRatio: 16 / 9,
                                    autoPlayInterval: const Duration(seconds: 3),
                                  ),
                                )
                              : const Center(child: CircularProgressIndicator()),
                        ],
                      );
                    }),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBinCard(DocumentSnapshot bin, bool isMobile) {
  Map<String, dynamic> data = bin.data() as Map<String, dynamic>;

  // Conditional image selection based on availability
  String imagePath = int.parse(data['availability'].replaceAll('%', '')) <= 10
      ? 'images/full.png'
      : 'images/empty.png';

  return Card(
    margin: const EdgeInsets.all(10),
    child: isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Bin Image
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  imagePath,
                  height: 150,  // Adjust the image size for mobile
                  fit: BoxFit.contain,
                ),
              ),

              // Bin Details
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      data['name'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      data['availability'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _getAvailabilityDescription(data['availability'] ?? 'N/A'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Bin Type: ${data['binType'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Bin Height: ${data['binHeight'] ?? 'N/A'} cm',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Address: ${data['address'] ?? 'N/A'}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => _showUpdateDialog(
                            bin.id,
                            data['name'] ?? '',
                            data['binType'] ?? '',
                            data['binHeight'] ?? '',
                            data['address'] ?? '',
                          ),
                          child: const Text('Update'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E9140),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => _deleteBin(bin.id),
                          child: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9F2D25),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side - Bin Image
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(
                    imagePath,
                    height: 300,
                  ),
                ),
              ),
              // Right side - Bin details
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        data['name'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        data['availability'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _getAvailabilityDescription(data['availability'] ?? 'N/A'),
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Bin Type: ${data['binType'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Bin Height: ${data['binHeight'] ?? 'N/A'} cm',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showUpdateDialog(
                                bin.id,
                                data['name'] ?? 'N/A',
                                data['binType'] ?? 'N/A',
                                data['binHeight'] ?? 'N/A',
                                data['address'] ?? 'N/A',
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteBin(bin.id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
  );
}

  // Function to return a text description based on the availability percentage
  String _getAvailabilityDescription(String availability) {
    int availabilityInt = int.parse(availability.replaceAll('%', ''));
    if (availabilityInt == 100) {
      return 'The bin is completely empty and has full capacity for waste. It is ready to be used.';
    } else if (availabilityInt >= 80 && availabilityInt < 100) {
      return 'The bin is almost empty, with plenty of space available for waste disposal.';
    } else if (availabilityInt >= 50 && availabilityInt < 80) {
      return 'The bin is about half full. There is still significant space available, but it may need monitoring.';
    } else if (availabilityInt >= 20 && availabilityInt < 50) {
      return 'The bin is filling up. It is advisable to monitor it closely as it will soon need to be emptied.';
    } else if (availabilityInt > 0 && availabilityInt < 20) {
      return 'The bin is nearly full. It should be emptied soon to avoid overflow.';
    } else if (availabilityInt == 0) {
      return 'The bin is completely full and needs to be emptied immediately to prevent any overflow.';
    } else {
      return 'Invalid availability data.';
    }
  }
}
