import 'package:ecobin_app/pages/goals.dart';
import 'package:ecobin_app/pages/pickup_records.dart';
import 'package:ecobin_app/user_management/screens/home/profile.dart';
import 'package:flutter/material.dart';
import 'package:ecobin_app/pages/monitor_bin.dart';
import 'package:ecobin_app/pages/notification.dart';
import 'package:ecobin_app/services/notification_service.dart';
import 'package:ecobin_app/user_management/services/auth.dart';

class SideMenu extends StatefulWidget {
  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  bool isCollapsed = false; // Tracks if the menu is collapsed or not
  final AuthServices _auth = AuthServices(); // Instantiate AuthService

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 60 : 250,
      color: Colors.green[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collapse/Expand button
          IconButton(
            icon: Icon(isCollapsed ? Icons.arrow_right : Icons.arrow_left),
            onPressed: () {
              setState(() {
                isCollapsed = !isCollapsed; // Toggle collapsed state
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: isCollapsed
                ? SizedBox.shrink() // Return an empty widget when collapsed
                : const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
          ),
          ListTile(
            leading: Icon(Icons.monitor), // Icon for Monitoring
            title: isCollapsed ? null : const Text('Monitoring'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MonitorBin()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications), // Icon for Alerts
            title: isCollapsed ? null : const Text('Alerts'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationPage(
                    notificationService: NotificationService(),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.local_shipping), // Icon for Pickups
            title: isCollapsed ? null : const Text('Pickups'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserPickupRequestsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.flag), // Icon for Goals
            title: isCollapsed ? null : const Text('Goals'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Goals()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person), // Icon for Profile
            title: isCollapsed ? null : const Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile()),
              );
            },
          ),
          const Spacer(), // This creates space between the menu items and the logout button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[100],
            ),
            onPressed: () async {
              await _auth.signOut(); // Use the instantiated _auth
            },
            child: const Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
