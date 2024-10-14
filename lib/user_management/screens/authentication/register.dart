import 'package:ecobin_app/user_management/cocnstants/colors.dart';
import 'package:ecobin_app/user_management/cocnstants/discription.dart';
import 'package:ecobin_app/user_management/cocnstants/styles.dart';
import 'package:ecobin_app/user_management/services/auth.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  final Function toggle;
  const Register({Key? key, required this.toggle}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthServices _auth = AuthServices();

  // Form key
  final _formKey = GlobalKey<FormState>();
  // Email, password, phone, and address state
  String name = "";
  String email = "";
  String nic = "";
  String password = "";
  String phone = "";
  String addressNo = "";
  String street = "";
  String city = "";
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
        title: const Text("REGISTER"),
        elevation: 0,
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
                      "assets/images/ecologo2.png",
                      height: isSmallScreen ? 80 : 100,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 15.0 : 20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Name field
                          TextFormField(
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              hintText: "Name",
                            ),
                            validator: (val) =>
                                val!.isEmpty ? "Please Enter your name" : null,
                            onChanged: (val) {
                              setState(() {
                                name = val;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          // Email field
                          TextFormField(
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              hintText: "Email",
                            ),
                            validator: (val) => val!.isEmpty
                                ? "Enter a valid username or email"
                                : null,
                            onChanged: (val) {
                              setState(() {
                                email = val;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          // NIC field
                          TextFormField(
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              hintText: "NIC",
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return "Enter a valid NIC";
                              } else if (!RegExp(r'^[0-9]{9}[VXvx]$')
                                      .hasMatch(val) &&
                                  !RegExp(r'^[0-9]{12}$').hasMatch(val)) {
                                return "Enter a valid NIC (e.g., 123456789V or 199023456789)";
                              }
                              return null;
                            },
                            onChanged: (val) {
                              setState(() {
                                nic = val;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          // Password field
                          TextFormField(
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              hintText: "Password",
                            ),
                            validator: (val) => val!.length < 6
                                ? "Enter a password 6+ chars long"
                                : null,
                            onChanged: (val) {
                              setState(() {
                                password = val;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          // Phone number field
                          TextFormField(
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              hintText: "Phone Number",
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return "Enter a valid phone number";
                              } else if (val.length != 10) {
                                return "Phone number must be 10 digits";
                              } else if (!RegExp(r'^[0-9]{10}$')
                                  .hasMatch(val)) {
                                return "Enter only digits";
                              }
                              return null;
                            },
                            onChanged: (val) {
                              setState(() {
                                phone = val;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          // Address fields (No, Street, City)
                          TextFormField(
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              hintText: "Address No.",
                            ),
                            validator: (val) => val!.isEmpty
                                ? "Enter a valid address number"
                                : null,
                            onChanged: (val) {
                              setState(() {
                                addressNo = val;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              hintText: "Street",
                            ),
                            validator: (val) =>
                                val!.isEmpty ? "Enter a valid street" : null,
                            onChanged: (val) {
                              setState(() {
                                street = val;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              hintText: "City",
                            ),
                            validator: (val) =>
                                val!.isEmpty ? "Enter a valid city" : null,
                            onChanged: (val) {
                              setState(() {
                                city = val;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          // Error text
                          Text(
                            error,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 14),
                          ),
                          const SizedBox(height: 20),
                          // Switch to login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account?",
                                style: descriptionStyle,
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  widget.toggle();
                                },
                                child: const Text(
                                  "LOGIN",
                                  style: TextStyle(
                                    color: mainBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Register button
                          GestureDetector(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                dynamic result =
                                    await _auth.registerWithEmailAndPassword(
                                        name,
                                        email,
                                        nic,
                                        password,
                                        phone,
                                        addressNo,
                                        street,
                                        city);
                                if (result == null) {
                                  setState(() {
                                    error = "Please enter a valid email";
                                  });
                                }
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
                                  "REGISTER",
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
