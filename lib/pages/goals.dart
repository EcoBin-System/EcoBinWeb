// goals.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecobin_app/pages/binupdate.dart';
import 'package:ecobin_app/pages/goalsform.dart';
import 'package:ecobin_app/pages/editgoal.dart';
import 'package:ecobin_app/pages/useranalytics.dart';
import 'package:ecobin_app/services/database1.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Make sure you're using Provider
import 'package:ecobin_app/user_management/models/UserModel.dart'; // Import UserModel

class Goals extends StatefulWidget {
  const Goals({super.key});

  @override
  State<Goals> createState() => _GoalState();
}

class _GoalState extends State<Goals> {
  TextEditingController goalNameController = TextEditingController();
  TextEditingController goalController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  Stream? goalStream;

  @override
  void initState() {
    super.initState();
    // Load goals when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UserModel? user = Provider.of<UserModel?>(context, listen: false);
      String? userId = user?.uid;
      if (userId != null) {
        getontheload(userId);
      }
    });
  }

  // This method now requires the uid to filter the goals
  Future<void> getontheload(String uid) async {
    goalStream =
        await DatabaseMethods().getGoalDetails(uid); // Await the result
    setState(() {});
  }

  Widget allGoalDetails() {
    return StreamBuilder(
      stream: goalStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          return const Center(child: Text("No goals found."));
        } else {
          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                child: Material(
                  elevation: 3.0,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Goal Name: " + ds["Goal Name"],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Goal: " + ds["Goal"],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          "Start Date: " + ds["Starting Date"],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          "End Date: " + ds["Ending Date"],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green),
                          onPressed: () {
                            // Call the EditGoalDialog
                            showDialog(
                              context: context,
                              builder: (context) => EditGoalDialog(
                                goalId: ds.id,
                                goalName: ds["Goal Name"],
                                goal: ds["Goal"],
                                startDate: ds["Starting Date"],
                                endDate: ds["Ending Date"],
                              ),
                            );
                          },
                        ),
                        GestureDetector(
                          onTap: () {
                            // Show a confirmation dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Confirm Delete"),
                                  content: const Text(
                                      "Are you sure you want to delete this goal?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        // If user presses "Cancel", just close the dialog
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        // Perform delete action
                                        await DatabaseMethods()
                                            .deleteGoal(ds.id);
                                        Navigator.of(context)
                                            .pop(); // Close the dialog after deletion
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Goal deleted successfully"),
                                          ),
                                        );
                                      },
                                      child: const Text("Delete",
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the user model
    UserModel? user = Provider.of<UserModel?>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGoals()),
          );
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text(
          "Goals",
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: allGoalDetails(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UpdateBinPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E9140), // Custom color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8.0), // Rounded corners
                    ),
                  ),
                  child: const Text(
                    'Update Bin',
                    style: TextStyle(color: Colors.white), // Button text color
                  ),
                ),
                const SizedBox(height: 16), // Space between buttons

                // Add the button for analytics
                ElevatedButton(
                  onPressed: () {
                    if (user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserBinUpdatesPage(
                              userId: user.uid), // Pass the user ID
                        ),
                      );
                    } else {
                      // Handle the case where the user is not logged in
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("User not logged in.")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E9140), // Custom color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8.0), // Rounded corners
                    ),
                  ),
                  child: const Text(
                    'View Analytics',
                    style: TextStyle(color: Colors.white), // Button text color
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
