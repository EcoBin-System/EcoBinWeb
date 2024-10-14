import 'package:ecobin_app/pages/garbage_pickup_form.dart';
import 'package:ecobin_app/pages/pickup_records.dart';
import 'package:ecobin_app/user_management/screens/home/profile.dart';
import 'package:ecobin_app/user_management/services/auth.dart';
import 'package:ecobin_app/pages/monitor_bin.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Create an instance of AuthServices
  final AuthServices _auth = AuthServices();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0XffE7EBE8),
        appBar: AppBar(
          title: const Text(
            'Home',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0Xff27AE60),
          actions: [
            ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Color(0Xff27AE60)),
              ),
              onPressed: () async {
                await _auth.signOut();
              },
              child: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              children: [
                const Text(
                  "HOME",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 30),
                Center(
                    child: Image.asset(
                  "assets/images/man.png",
                  height: 200,
                )),
                const SizedBox(height: 60),

                // Row for buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Profile Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Profile()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5.0,
                              spreadRadius: 1.0,
                              offset: Offset(0.0, 3.0),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.person, color: Colors.green),
                            SizedBox(width: 10),
                            Text("Profile",
                                style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                    ),

                    // Monitor Bin Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MonitorBin()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5.0,
                              spreadRadius: 1.0,
                              offset: Offset(0.0, 3.0),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.monitor, color: Colors.green),
                            SizedBox(width: 10),
                            Text("Monitor Bin",
                                style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                    ),

                    // Pickup Form Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GarbagePickupFormPage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5.0,
                              spreadRadius: 1.0,
                              offset: Offset(0.0, 3.0),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.local_shipping, color: Colors.green),
                            SizedBox(width: 10),
                            Text("Pickups",
                                style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20), // Add space below the row

                // Optional: Additional buttons if needed
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserPickupRequestsPage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5.0,
                          spreadRadius: 1.0,
                          offset: Offset(0.0, 3.0),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.list, color: Colors.green),
                        SizedBox(width: 10),
                        Text("Pickup Records",
                            style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
