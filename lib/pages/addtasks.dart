import 'package:flutter/material.dart';
import 'package:ecobin_app/services/database1.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart'; // Import UUID package

class TaskFormPage extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskFormPage({Key? key, required this.task}) : super(key: key);

  @override
  _TaskFormPageState createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  late String _uid;
  late DateTime _createdAt;
  String _progress = '0';

  @override
  void initState() {
    super.initState();

    // Set default start date to the current date
    _startDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Automatically calculate the end date based on task type and start date
    _calculateEndDate();

    // Get the current user's UID
    _uid = FirebaseAuth.instance.currentUser!.uid;

    // Set the createdAt time
    _createdAt = DateTime.now();
  }

  // Function to calculate the end date based on the task type and start date
  void _calculateEndDate() {
    DateTime startDate = DateTime.now();
    try {
      startDate = DateFormat('yyyy-MM-dd').parse(_startDateController.text);
    } catch (e) {}

    if (widget.task["Task Type"].toLowerCase() == 'weekly') {
      final endDate = startDate.add(const Duration(days: 7));
      _endDateController.text = DateFormat('yyyy-MM-dd').format(endDate);
    } else if (widget.task["Task Type"].toLowerCase() == 'monthly') {
      final endDate = startDate.add(const Duration(days: 30));
      _endDateController.text = DateFormat('yyyy-MM-dd').format(endDate);
    }
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Generate a unique task ID
      String taskId = Uuid().v4();

      final taskData = {
        'id': taskId, // Change 'taskId' to 'id'
        'title': widget.task["Task Name"],
        'description': widget.task["Task"],
        'taskType': widget.task["Task Type"],
        'startDate': _startDateController.text,
        'endDate': _endDateController.text,
        'uid': _uid,
        'createdAt': _createdAt.toIso8601String(),
        'progress': _progress,
      };

      // Save the task data to the usertasks collection
      await DatabaseMethods().addUserTask(taskData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task has been saved successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Start a task', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF27AE60),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                '${widget.task["Task Name"]}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Text(
                '${widget.task["Task"]}',
                style: const TextStyle(fontSize: 16),
              ),

              Text(
                '${widget.task["Task Type"]}',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Start Date picker
              TextFormField(
                controller: _startDateController,
                decoration: const InputDecoration(labelText: 'Start Date'),
                readOnly: true,
                onTap: () async {
                  DateTime currentDate = DateTime.now();
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: currentDate,
                    firstDate: currentDate, // Prevent selection of past dates
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _startDateController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                      _calculateEndDate(); // Recalculate the end date based on the new start date
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the start date';
                  }
                  return null;
                },
              ),

              // End Date (Read-only)
              TextFormField(
                controller: _endDateController,
                decoration: const InputDecoration(labelText: 'End Date'),
                readOnly: true,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Start Task',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
