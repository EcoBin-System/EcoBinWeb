import 'package:flutter/material.dart';
import 'package:ecobin_app/services/database1.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecobin_app/pages/addtasks.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({Key? key}) : super(key: key);

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Map<String, dynamic>>> _allTasks;
  late Future<List<Map<String, dynamic>>> _userTasks;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _allTasks = DatabaseMethods()
        .getTaskDetails(); // Retrieve all tasks from the database
    _userTasks = _fetchUserTasks(); // Retrieve user tasks from the database
  }

  Future<List<Map<String, dynamic>>> _fetchUserTasks() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return await DatabaseMethods().getUserTasks(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.center,
          child: const Text(
            "Tasks",
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: const Color(0xFF27AE60),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          tabs: const [
            Tab(text: "All Tasks"),
            Tab(text: "Your Tasks"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllTasksTab(),
          _buildUserTasksTab(),
        ],
      ),
    );
  }

  Widget _buildAllTasksTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _allTasks,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.data!.isEmpty) {
          return const Center(child: Text("No tasks found."));
        }

        final taskList = snapshot.data!;

        // Sort tasks by createdAt in ascending order
        taskList.sort((a, b) {
          String createdAtA = a['createdAt'] ?? '';
          String createdAtB = b['createdAt'] ?? '';

          if (createdAtA.isEmpty || createdAtB.isEmpty) {
            return 0;
          }

          try {
            return DateTime.parse(createdAtA)
                .compareTo(DateTime.parse(createdAtB));
          } catch (e) {
            print("Date parsing error: $e");
            return 0;
          }
        });

        return ListView.builder(
          itemCount: taskList.length,
          itemBuilder: (context, index) {
            final task = taskList[index];

            // Handle null values for task fields
            final taskName = task["Task Name"] ?? "No Task Name";
            final taskDescription = task["Task"] ?? "No Task Description";
            final taskType = task["Task Type"] ?? "No Task Type";

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              elevation: 4,
              child: ListTile(
                title: Text(taskName, overflow: TextOverflow.ellipsis),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Task: $taskDescription",
                        overflow: TextOverflow.ellipsis),
                    Text("Type: $taskType", overflow: TextOverflow.ellipsis),
                  ],
                ),
                onTap: () {
                  // Navigate to TaskFormPage when task is clicked
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskFormPage(task: task),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  double parseProgress(dynamic progress) {
    if (progress == null) return 0.0;
    if (progress is num) return progress.toDouble();
    if (progress is String) {
      try {
        return double.parse(progress.replaceAll('%', ''));
      } catch (e) {
        print("Error parsing progress: $e");
        return 0.0;
      }
    }
    return 0.0;
  }

  Widget _buildUserTasksTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _userTasks,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final tasks = snapshot.data ?? [];

        if (tasks.isEmpty) {
          return const Center(child: Text('No tasks found.'));
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];

            // Debugging: Print task details
            print("Task $index: ${task.toString()}");

            // Check if id is null
            if (task['id'] == null) {
              print("Warning: Task at index $index has no ID");
            }

            // Handle null values for task fields
            final taskId = task['id'];
            final taskName = task['title'] ?? "No Task Name";
            final taskDescription =
                task['description'] ?? "No Task Description";
            final progress = parseProgress(task['progress']);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(taskName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Description: $taskDescription"),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    Text("${progress.toStringAsFixed(0)}% Completed"),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: (taskId != null && progress < 100)
                          ? () {
                              print("Updating progress for task ID: $taskId");
                              _showProgressUpdateDialog(taskId, progress / 100);
                            }
                          : null, // Disable the button if progress is 100%
                      child: const Text("Update Progress"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showProgressUpdateDialog(String taskId, double currentProgress) {
    showDialog(
      context: context,
      builder: (context) {
        double updatedProgress = currentProgress;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Update Task Progress"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Current Progress: ${updatedProgress.toStringAsFixed(0)}%",
                  ),
                  Slider(
                    value: updatedProgress,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: "${updatedProgress.toStringAsFixed(0)}%",
                    onChanged: (value) {
                      setState(() {
                        updatedProgress = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _updateTaskProgress(taskId, updatedProgress);
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateTaskProgress(String taskId, double progress) async {
    try {
      // Progress is already a percentage (0-100), no need to multiply
      await DatabaseMethods().updateTaskProgress(taskId, progress);
      setState(() {
        _userTasks = _fetchUserTasks();
      });
    } catch (e) {
      print("Error updating task progress: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating task progress: $e")),
      );
    }
  }
}
