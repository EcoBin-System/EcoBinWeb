import 'package:ecobin_app/user_management/services/auth.dart';
import 'package:flutter/material.dart';

class UpdateProfile extends StatefulWidget {
  final Map<String, dynamic> userData; // Pass user data to pre-fill the form

  UpdateProfile({required this.userData});

  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final AuthServices _auth = AuthServices();

  // Create TextEditingControllers for form fields
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController nicController;
  late TextEditingController phoneController;
  late TextEditingController addressNoController;
  late TextEditingController streetController;
  late TextEditingController cityController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with the existing data
    nameController = TextEditingController(text: widget.userData['name']);
    emailController = TextEditingController(text: widget.userData['email']);
    nicController = TextEditingController(text: widget.userData['nic']);
    phoneController = TextEditingController(text: widget.userData['phone']);
    addressNoController =
        TextEditingController(text: widget.userData['addressNo']);
    streetController = TextEditingController(text: widget.userData['street']);
    cityController = TextEditingController(text: widget.userData['city']);
  }

  Future<void> _saveProfile() async {
    String? uid = _auth.currentUser?.uid;

    if (uid != null) {
      try {
        // Update user profile in Firestore
        await _auth.updateUserProfile(
          uid,
          nameController.text,
          emailController.text,
          nicController.text,
          phoneController.text,
          addressNoController.text,
          streetController.text,
          cityController.text,
        );

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );

        // Navigate back to Profile page with updated data
        Navigator.pop(
            context, true); // true indicates the update was successful
      } catch (e) {
        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
        backgroundColor: const Color(0Xff27AE60),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Container(
              width: MediaQuery.of(context).size.width > 600
                  ? 600
                  : double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Update Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0Xff27AE60),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField('Name', nameController),
                  const SizedBox(height: 10),
                  _buildTextField('Email', emailController),
                  const SizedBox(height: 10),
                  _buildTextField('NIC', nicController),
                  const SizedBox(height: 10),
                  _buildTextField('Phone', phoneController),
                  const SizedBox(height: 10),
                  _buildTextField('Address No', addressNoController),
                  const SizedBox(height: 10),
                  _buildTextField('Street', streetController),
                  const SizedBox(height: 10),
                  _buildTextField('City', cityController),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0Xff27AE60),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 16, color: Colors.white),
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

  // Helper function to build text fields
  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0XFFF0F0F0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
