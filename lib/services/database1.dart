import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  //Adding goals to firebase
  Future<void> addGoalDetails(
      Map<String, dynamic> goalInfoMap, String id) async {
    try {
      goalInfoMap['created_at'] =
          FieldValue.serverTimestamp(); // Add server timestamp
      await FirebaseFirestore.instance
          .collection("Goals")
          .doc(id)
          .set(goalInfoMap);
    } catch (e) {
      print("Error adding goal details: $e");
      throw e;
    }
  }

  //Retrieving goals from firebase based on user UID
  Future<Stream<QuerySnapshot>> getGoalDetails(String uid) async {
    try {
      return FirebaseFirestore.instance
          .collection('Goals')
          .where("UserID", isEqualTo: uid)
          .where('created_at',
              isNotEqualTo: null) // Only fetch goals with a created_at field
          .orderBy('created_at', descending: true) // Order by creation date
          .snapshots();
    } catch (e) {
      print("Error fetching goal details: $e");
      throw e;
    }
  }

  //Updating goals in firebase
  Future<void> updateGoalDetails(
      String id, Map<String, dynamic> updateInfo) async {
    try {
      await FirebaseFirestore.instance
          .collection("Goals")
          .doc(id)
          .update(updateInfo);
    } catch (e) {
      print("Error updating goal details: $e");
      throw e;
    }
  }

  //Deleting goals from firebase
  Future<void> deleteGoal(String id) async {
    try {
      await FirebaseFirestore.instance.collection("Goals").doc(id).delete();
    } catch (e) {
      print("Error deleting goal: $e");
      throw e;
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to get user bin updates
  Stream<QuerySnapshot> getUserBinUpdates(String userId) {
    return _firestore
        .collection('binUpdates')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // Method to fetch task details from Firestore
  Future<List<Map<String, dynamic>>> getTaskDetails() async {
    List<Map<String, dynamic>> taskList = [];
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('tasks').get();

      for (var doc in snapshot.docs) {
        taskList.add({
          "Task Name": doc['Task Name'] ?? "No Task Name",
          "Task": doc['Task'] ?? "No Task Description",
          "Task Type": doc['Task Type'] ?? "No Task Type",
          "UserID": doc['UserID'] ?? "No User ID",
          "Id": doc['Id'] ?? "No ID",
        });
      }
    } catch (e) {
      print("Error fetching tasks: $e");
      throw e;
    }
    return taskList;
  }

  // Function to get task details by ID
  Future<Map<String, dynamic>> getTaskDetailById(String taskId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('tasks').doc(taskId).get();
      return snapshot.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Error fetching task details: $e");
    }
  }

  // Function to update task details
  Future<void> updateTaskDetails(
      String taskId, String taskName, String task, String taskType) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        "Task Name": taskName,
        "Task": task,
        "Task Type": taskType,
      });
    } catch (e) {
      throw Exception("Error updating task: $e");
    }
  }

  // Add user tasks
  Future<void> addUserTask(Map<String, dynamic> taskData) async {
    String id = taskData['id'];
    await _firestore.collection('usertasks').doc(id).set(taskData);
  }

  // Fetch all user tasks
  Future<List<Map<String, dynamic>>> getUserTasks(String uid) async {
    QuerySnapshot snapshot = await _firestore
        .collection('usertasks')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Ensure the ID is included in the returned data
      return data;
    }).toList();
  }

  // Update the progress of a task
  Future<void> updateTaskProgress(String taskId, double progress) async {
    try {
      if (taskId.isEmpty) {
        throw Exception("Task ID is missing or invalid.");
      }

      await _firestore
          .collection('usertasks')
          .doc(taskId)
          .update({'progress': progress});
    } catch (e) {
      print("Error updating progress in database: $e");
      throw e;
    }

    // Fetch user tasks function
    Future<List<Map<String, dynamic>>> fetchUserTasks(String userId) async {
      try {
        QuerySnapshot snapshot = await _firestore
            .collection('userTasks')
            .where('userId', isEqualTo: userId)
            .get();

        return snapshot.docs
            .map((doc) => {
                  'TaskId': doc.id,
                  'Task Name': doc['title'],
                  'Task': doc['description'],
                  'progress': doc['progress'],
                })
            .toList();
      } catch (e) {
        print("Failed to fetch user tasks: $e");
        return [];
      }
    }
  }
}
