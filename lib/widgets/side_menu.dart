import 'package:ecobin_app/pages/bin_qr.dart';
import 'package:ecobin_app/pages/goals.dart';
import 'package:ecobin_app/pages/pickup_records.dart';
import 'package:ecobin_app/user_management/screens/home/profile.dart';
import 'package:flutter/material.dart';
import 'package:ecobin_app/pages/monitor_bin.dart';
import 'package:ecobin_app/pages/notification.dart';
import 'package:ecobin_app/services/notification_service.dart';
import 'package:ecobin_app/user_management/services/auth.dart';
import 'package:ecobin_app/user_management/screens/home/home.dart'; // Import your home page

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
            icon: Icon(isCollapsed ? Icons.close : Icons.menu),
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
          // Home button
          ListTile(
            leading: Icon(Icons.home),
            title: isCollapsed ? null : const Text('Home'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Home()), // Navigate to Home
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.local_shipping),
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
            leading: Icon(Icons.monitor),
            title: isCollapsed ? null : const Text('Monitoring'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MonitorBin()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
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
            leading: Icon(Icons.qr_code),
            title: isCollapsed ? null : const Text('Scan QR Code'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BinQr()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.flag),
            title: isCollapsed ? null : const Text('Goals'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Goals()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: isCollapsed ? null : const Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile()),
              );
            },
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[100],
              elevation: 0, // Remove shadow
            ),
            onPressed: () async {
              await _auth.signOut();
            },
            child: const Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
