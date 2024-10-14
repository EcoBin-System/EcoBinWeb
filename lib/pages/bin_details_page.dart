import 'package:ecobin_app/pages/monitor_bin.dart';
import 'package:flutter/material.dart';

class BinDetailsPage extends StatelessWidget {
  final Map<String, dynamic> binData;

  BinDetailsPage({required this.binData});

  // Function to determine the color based on the availability percentage
  Color _getAvailabilityColor(String availability) {
    double availabilityPercentage =
        double.parse(availability.replaceAll('%', ''));

    if (availabilityPercentage >= 60) {
      return const Color(0xFF30AA34); // 100% - 60% is green
    } else if (availabilityPercentage >= 30) {
      return const Color(0xFFC1AF10); // 60% - 30% is yellow
    } else {
      return const Color(0xFFDE2012); // 30% - 0% is red
    }
  }

  // Function to determine the bin image path based on the bin type
  String getBinImage(String binType) {
    switch (binType) {
      case 'Recyclable':
        return 'images/recyclable.jpg';
      case 'Other':
        return 'images/other.jpg';
      case 'Plastic':
        return 'images/plastic.jpg';
      case 'Organic':
        return 'images/organic.jpg';
      default:
        return 'images/default.jpg';
    }
  }

  // Function to provide a description based on the bin type
  String getBinDescription(String binType) {
    switch (binType) {
      case 'Recyclable':
        return 'This bin is for recyclable materials, including glass bottles and jars. Please ensure they are clean and free of any residue before disposal to facilitate recycling.';
      case 'Other':
        return 'This bin is designated for metal items, such as cans and tins. Please make sure they are empty, clean, and free from food residue before disposing of them.';
      case 'Plastic':
        return 'This bin is for plastic waste, including bottles, containers, and bags. Please clean them thoroughly before discarding to aid in the recycling process.';
      case 'Organic':
        return 'Use this bin for organic waste such as food scraps, leaves, and other compostable materials. This helps in creating nutrient-rich compost.';
      default:
        return 'General waste bin. Use this bin for items that do not fit into other categories.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bin Details',
            style: TextStyle(fontSize: 24, color: Colors.white)),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.monitor), // Replace with your preferred icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MonitorBin()), // Navigate to MonitorBin page
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Check if the width is greater than a certain size (e.g., 600 for web)
            if (constraints.maxWidth > 600) {
              return Row(
                children: [
                  // Bin image on the left
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Image.asset(
                        getBinImage(binData['binType']),
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // Space between image and details
                  // Details on the right
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 80.0),
                        const Text(
                          'Bin Status',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          '${binData['availability']}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: _getAvailabilityColor(binData['availability']),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          getBinDescription(binData['binType']),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 40),
                        Text('Bin Label: ${binData['name']}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w200)),
                        const SizedBox(height: 10),
                        Text('Address: ${binData['address']}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.normal)),
                        const SizedBox(height: 10),
                        Text('Bin Type: ${binData['binType']}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.normal)),
                        const SizedBox(height: 10),
                        Text('Bin Height: ${binData['binHeight']}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.normal)),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              // Mobile view layout
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bin Status',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 25),
                  Center(
                    child: Image.asset(
                      getBinImage(binData['binType']),
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      '${binData['availability']}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getAvailabilityColor(binData['availability']),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      getBinDescription(binData['binType']),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text('Bin Label: ${binData['name']}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w200)),
                  const SizedBox(height: 10),
                  Text('Address: ${binData['address']}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.normal)),
                  const SizedBox(height: 10),
                  Text('Bin Type: ${binData['binType']}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.normal)),
                  const SizedBox(height: 10),
                  Text('Bin Height: ${binData['binHeight']}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.normal)),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
