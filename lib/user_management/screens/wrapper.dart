import 'package:ecobin_app/user_management/models/UserModel.dart';
import 'package:ecobin_app/user_management/screens/authentication/authenticate.dart';
import 'package:ecobin_app/user_management/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}
