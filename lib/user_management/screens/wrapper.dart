import 'package:ecobin_app/pages/pickup_records.dart';
import 'package:ecobin_app/user_management/models/UserModel.dart';
import 'package:ecobin_app/user_management/screens/authentication/authenticate.dart';
import 'package:ecobin_app/user_management/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecobin_app/pages/layout.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    // If the user is not logged in, show the authentication screen
    if (user == null) {
      return Authenticate();
    } else {
      // If the user is logged in, wrap the home page with the layout that includes the side menu
      return AppLayout(child: UserPickupRequestsPage());
    }
  }
}
