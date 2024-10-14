import 'package:ecobin_app/user_management/cocnstants/colors.dart';
import 'package:ecobin_app/user_management/cocnstants/discription.dart';
import 'package:ecobin_app/user_management/cocnstants/styles.dart';
import 'package:ecobin_app/user_management/services/auth.dart';
import 'package:flutter/material.dart';

class Sign_In extends StatefulWidget {
  final Function toggle;
  const Sign_In({Key? key, required this.toggle}) : super(key: key);

  @override
  State<Sign_In> createState() => _Sign_InState();
}

class _Sign_InState extends State<Sign_In> {
  final AuthServices _auth = AuthServices();
  bool _obscurePassword = true;

  // Form key
  final _formKey = GlobalKey<FormState>();
  // Email password state
  String email = "";
  String password = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    // Get the screen width for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen =
        screenWidth < 600; // Example breakpoint for small screens

    return Scaffold(
      backgroundColor: const Color(0XffE7EBE8),
      appBar: AppBar(
        title: const Text("SIGN IN"),
        backgroundColor: const Color(0XffE7EBE8),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 10 : 40,
              vertical: isSmallScreen ? 10 : 20,
            ),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isSmallScreen
                    ? double.infinity
                    : 500, // Set max width for larger screens
              ),
              child: Column(
                children: [
                  const Text(
                    description,
                    style: descriptionStyle,
                    textAlign: TextAlign.center,
                  ),
                  Center(
                    child: Image.asset(
                      "assets/images/ecologo.png",
                      height: isSmallScreen ? 150 : 200,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 15.0 : 20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email
                          TextFormField(
                            style: const TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                            decoration: const InputDecoration(
                              hintText: "E-mail or Username",
                            ),
                            validator: (val) => val?.isEmpty == true
                                ? "Enter a valid username or email"
                                : null,
                            onChanged: (val) {
                              setState(() {
                                email = val;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          // Password
                          TextFormField(
                            style: const TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                            decoration: InputDecoration(
                              hintText: "Password",
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: (val) => val != null && val.length < 6
                                ? "Enter a valid password"
                                : null,
                            onChanged: (val) {
                              setState(() {
                                password = val;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          // Error message
                          Text(
                            error,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 10),
                          // Login with social accounts
                          const Text(
                            "Login with social accounts",
                            style: descriptionStyle,
                            textAlign: TextAlign.center,
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Center(
                              child: Image.asset(
                                "assets/images/google.png",
                                height: isSmallScreen ? 40 : 50,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Register
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account?",
                                style: descriptionStyle,
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  widget.toggle();
                                },
                                child: const Text(
                                  "Register",
                                  style: TextStyle(
                                    color: mainBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Login button
                          GestureDetector(
                            onTap: () async {
                              dynamic result = await _auth
                                  .signInUsingEmailAndPassword(email, password);
                              if (result == null) {
                                setState(() {
                                  error = "User not found";
                                });
                              }
                            },
                            child: Container(
                              height: 40,
                              width: isSmallScreen ? screenWidth * 0.8 : 200,
                              decoration: BoxDecoration(
                                color: const Color(0Xff5FAD46),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(width: 2, color: mainYellow),
                              ),
                              child: const Center(
                                child: Text(
                                  "LOG IN",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
