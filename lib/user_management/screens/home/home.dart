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
  //create a obj form Authservice
  final AuthServices _auth = AuthServices();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0XffE7EBE8),
        appBar: AppBar(
          title: const Text(
            'Home',
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          ),
          backgroundColor: const Color(0Xff27AE60),
          actions: [
            ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  Color(0Xff27AE60),
                ),
              ),
              onPressed: () async {
                await _auth.signOut();
              },
              child: const Icon(Icons.logout),
            )
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(20.0),
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
                const SizedBox(
                  height: 30,
                ),

                const SizedBox(
                  height: 60,
                ),
                Center(
                    child: Image.asset(
                  "assets/images/man.png",
                  height: 200,
                )),
                // Add a button to navigate to the profile page
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the Profile page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Profile()),
                    );
                  },
                  child: const Text("Go to Profile"),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the monitor bin page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MonitorBin()),
                    );
                  },
                  child: const Text("Go to Monitor bin"),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GarbagePickupFormPage()),
                    );
                  },
                  child: const Text("Pickups"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserPickupRequestsPage()),
                    );
                  },
                  child: const Text("Pickup records"),
                )
                // Add a button to navigate to the goals page
              ],
            ),
          ),
        ),
      ),
    );
  }
}
