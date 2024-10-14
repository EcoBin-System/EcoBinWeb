import 'package:ecobin_app/user_management/screens/home/addpayment.dart';
import 'package:ecobin_app/user_management/services/auth.dart';
import 'package:flutter/material.dart';
import 'update.dart'; // Import the update page

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthServices _auth = AuthServices();
  String? name, email, nic, phone, addressNo, street, city;
  List<Map<String, dynamic>> cardDetails = []; // To hold card details

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCardDetails(); // Load card details
  }

  Future<void> _loadUserData() async {
    String? uid = _auth.currentUser?.uid;

    if (uid != null) {
      Map<String, dynamic>? userData = await _auth.getUserData(uid);

      if (userData != null) {
        setState(() {
          name = userData['name'];
          email = userData['email'];
          nic = userData['nic'];
          phone = userData['phone'];
          addressNo = userData['addressNo'];
          street = userData['street'];
          city = userData['city'];
        });
      }
    }
  }

  Future<void> _loadCardDetails() async {
    String? uid = _auth.currentUser?.uid;

    if (uid != null) {
      List<Map<String, dynamic>>? cards = await _auth.getCardDetails(uid);

      if (cards != null) {
        setState(() {
          cardDetails = cards;
        });
      }
    }
  }

  // Function to delete a specific card
  Future<void> _deleteCardDetails(String cardNumber) async {
    try {
      await _auth.deleteCard(cardNumber);
      setState(() {
        cardDetails.removeWhere((card) => card['cardNumber'] == cardNumber);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete card')),
      );
    }
  }

  Future<void> _deleteProfile(BuildContext context) async {
    String? password = await _showPasswordConfirmationDialog(context);

    if (password != null) {
      bool isPasswordCorrect = await _auth.reauthenticateUser(password);

      if (isPasswordCorrect) {
        await _auth.deleteUser();
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect password!')),
        );
      }
    }
  }

  Future<String?> _showPasswordConfirmationDialog(BuildContext context) async {
    String? password;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter your password to delete profile'),
          content: TextField(
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
            onChanged: (value) {
              password = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(password);
              },
              child: const Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XffE7EBE8),
      appBar: AppBar(
        title:
            const Text('User Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0Xff27AE60),
        centerTitle: true,
      ),
      body: email == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 40.0),
                child: Column(
                  children: [
                    // Profile card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Profile Image
                            CircleAvatar(
                              backgroundImage:
                                  AssetImage("assets/images/man.png"),
                              radius: 60,
                              backgroundColor: Colors.grey[200],
                            ),
                            const SizedBox(height: 20),

                            // Name and Email
                            Text(
                              name ?? "User",
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0Xff27AE60),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              email ?? "Email not available",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const Divider(
                              height: 30,
                              thickness: 1,
                              color: Colors.grey,
                            ),

                            // Personal details
                            _buildProfileDetail("NIC", nic),
                            _buildProfileDetail("Phone", phone),
                            _buildProfileDetail(
                                "Address", "$addressNo, $street, $city"),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Payment card details
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Payment Methods",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0Xff27AE60),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildCardDetails(), // Display card details
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Buttons for profile update, delete, add payment
                    _buildActionButton(
                      "Update Profile",
                      Colors.blue,
                      () async {
                        bool? updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateProfile(
                              userData: {
                                'name': name,
                                'email': email,
                                'nic': nic,
                                'phone': phone,
                                'addressNo': addressNo,
                                'street': street,
                                'city': city,
                              },
                            ),
                          ),
                        );

                        if (updated == true) {
                          _loadUserData();
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildActionButton(
                      "Delete Profile",
                      Colors.red,
                      () {
                        _deleteProfile(context);
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildActionButton(
                      "Add Payment Method",
                      Colors.orange,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddPaymentMethodPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileDetail(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$title:",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Flexible(
            child: Text(
              value ?? "Not available",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetails() {
    if (cardDetails.isEmpty) {
      return const Text(
        "No card details available",
        style: TextStyle(fontSize: 16, color: Colors.grey),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cardDetails.map((card) {
        String cardType = card['cardType'] ?? 'Unknown';
        String cardNumber = card['cardNumber'] ?? '**** **** **** ****';
        String cardId = card['cardId'] ?? '';

        // Mask card number except last 4 digits
        String maskedCardNumber = cardNumber.replaceRange(
            0, cardNumber.length - 4, '**** **** **** ');

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    "assets/images/${cardType.toLowerCase()}.png",
                    width: 50,
                    height: 30,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    maskedCardNumber,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _deleteCardDetails(cardNumber); // Call the delete function
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
