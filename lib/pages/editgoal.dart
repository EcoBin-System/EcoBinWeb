import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:ecobin_app/services/database1.dart';

class EditGoalDialog extends StatelessWidget {
  final String goalId;
  final String goalName;
  final String goal;
  final String startDate;
  final String endDate;

  final TextEditingController goalNameController = TextEditingController();
  final TextEditingController goalController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  EditGoalDialog({
    Key? key,
    required this.goalId,
    required this.goalName,
    required this.goal,
    required this.startDate,
    required this.endDate,
  }) : super(key: key) {
    goalNameController.text = goalName;
    goalController.text = goal;
    startDateController.text = startDate;
    endDateController.text = endDate;
  }

  // Function to select a date for starting and ending date
  Future<void> selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now, // Prevent past dates
      lastDate: DateTime(2101), // Limit the maximum selectable date
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      controller.text = formattedDate; // Set the selected date as a string
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.cancel),
                ),
                const SizedBox(width: 60.0),
                const Text(
                  "Edit Goal",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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
              "Starting Date",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () =>
                  selectDate(context, startDateController), // Open date picker
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: startDateController,
                  readOnly: true, // Make it read-only
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
              onTap: () =>
                  selectDate(context, endDateController), // Open date picker
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: endDateController,
                  readOnly: true, // Make it read-only
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    hintText: "Select Ending Date",
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Call your update function here, passing the ID and new data
                await DatabaseMethods().updateGoalDetails(goalId, {
                  "Goal Name": goalNameController.text,
                  "Goal": goalController.text,
                  "Starting Date": startDateController.text,
                  "Ending Date": endDateController.text,
                });
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}
