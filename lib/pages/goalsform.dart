import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for formatting dates
import 'package:provider/provider.dart'; // Import Provider package
import 'package:random_string/random_string.dart';
import 'package:ecobin_app/services/database1.dart';
import 'package:ecobin_app/user_management/models/UserModel.dart'; // Import the UserModel if needed

class AddGoals extends StatefulWidget {
  const AddGoals({super.key});

  @override
  State<AddGoals> createState() => _AddGoalState();
}

class _AddGoalState extends State<AddGoals> {
  TextEditingController goalNameController = TextEditingController();
  TextEditingController goalController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  String?
      selectedGoalType; // Variable to store selected goal type (monthly or weekly)

  // Function to validate inputs
  bool validateInput() {
    if (goalNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a goal name'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    if (goalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a goal description'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    if (startDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a starting date'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    if (endDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an ending date'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    if (selectedGoalType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a goal type (Weekly or Monthly)'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  // Function to handle goal submission
  Future<void> submitGoal() async {
    if (validateInput()) {
      try {
        UserModel? user = Provider.of<UserModel?>(context, listen: false);
        String? userId = user?.uid;

        if (userId == null || userId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User not logged in'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        String id = randomAlphaNumeric(10);

        Map<String, dynamic> goalInfoMap = {
          "Goal Name": goalNameController.text,
          "Goal": goalController.text,
          "Starting Date": startDateController.text,
          "Ending Date": endDateController.text,
          "Goal Type": selectedGoalType, // Save goal type
          "UserID": userId,
          "Id": id,
        };

        await DatabaseMethods().addGoalDetails(goalInfoMap, id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal has been added successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear inputs after submission
        goalNameController.clear();
        goalController.clear();
        startDateController.clear();
        endDateController.clear();
        setState(() {
          selectedGoalType = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add goal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Function to show date picker and set selected date
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          selectedStartDate = pickedDate;
          startDateController.text = DateFormat('yyyy-MM-dd')
              .format(selectedStartDate!); // Format date as string
        } else {
          selectedEndDate = pickedDate;
          endDateController.text = DateFormat('yyyy-MM-dd')
              .format(selectedEndDate!); // Format date as string
        }
      });
    }
  }

  // Function to handle goal type selection and set default dates
  void _handleGoalTypeSelection(String? value) {
    setState(() {
      selectedGoalType = value;

      // Automatically set start date to the current date
      selectedStartDate = DateTime.now();
      startDateController.text =
          DateFormat('yyyy-MM-dd').format(selectedStartDate!);

      // Set end date based on goal type
      if (selectedGoalType == 'Weekly') {
        selectedEndDate =
            selectedStartDate!.add(const Duration(days: 7)); // One week
      } else if (selectedGoalType == 'Monthly') {
        selectedEndDate = DateTime(selectedStartDate!.year,
            selectedStartDate!.month + 1, selectedStartDate!.day); // One month
      }

      endDateController.text =
          DateFormat('yyyy-MM-dd').format(selectedEndDate!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Goals",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Goal Name",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: goalNameController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  hintText: "Enter Goal Name",
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Goal",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: goalController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  hintText: "Enter Your Goal",
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Goal Type",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Radio<String>(
                  value: 'Weekly',
                  groupValue: selectedGoalType,
                  onChanged: _handleGoalTypeSelection,
                ),
                const Text('Weekly'),
                Radio<String>(
                  value: 'Monthly',
                  groupValue: selectedGoalType,
                  onChanged: _handleGoalTypeSelection,
                ),
                const Text('Monthly'),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Starting Date",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectDate(context, true), // True for start date
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: startDateController,
                  enabled: true, // Allow editing
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    hintText: "Select Starting Date",
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Ending Date",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectDate(context, false), // False for end date
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: endDateController,
                  enabled: true, // Allow editing
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    hintText: "Select Ending Date",
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: submitGoal,
                child: const Text('Submit Goal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
