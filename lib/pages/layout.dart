import 'package:flutter/material.dart';
import 'package:ecobin_app/widgets/side_menu.dart'; // Import your side menu widget here

class AppLayout extends StatelessWidget {
  final Widget child;

  const AppLayout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideMenu(), // Your side menu widget
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(0.0), // Add padding if necessary
              child:
                  child, // This is where your Home page (or other pages) will be displayed
            ),
          ),
        ],
      ),
    );
  }
}
