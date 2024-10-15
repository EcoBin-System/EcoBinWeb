import 'package:flutter/material.dart';
import 'package:ecobin_app/services/database1.dart'; // Make sure this path is correct
import 'package:firebase_auth/firebase_auth.dart';

class UserTasksPage extends StatefulWidget {
  @override
  _UserTasksPageState createState() => _UserTasksPageState();
}

class _UserTasksPageState extends State<UserTasksPage> {
  late Future<List<Map<String, dynamic>>> _userTasks;

  @override
  void initState() {
    super.initState();
    _userTasks = _fetchUserTasks();
  }

  Future<List<Map<String, dynamic>>> _fetchUserTasks() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return await DatabaseMethods().getUserTasks(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Tasks'),
        backgroundColor: const Color(0xFF27AE60),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _userTasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tasks = snapshot.data!;

          if (tasks.isEmpty) {
            return const Center(child: Text('No tasks found.'));
          }

          // Sort tasks by createdAt in ascending order
          tasks.sort((a, b) => DateTime.parse(a['createdAt'])
              .compareTo(DateTime.parse(b['createdAt'])));

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task['taskName'],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(task['task'], style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Type: ${task['taskType']}',
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text('Start Date: ${task['startDate']}',
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text('End Date: ${task['endDate']}',
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text('Progress: ${task['progress']}%',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
