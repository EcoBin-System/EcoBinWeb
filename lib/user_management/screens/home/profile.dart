import 'package:ecobin_app/user_management/screens/home/addpayment.dart';
import 'package:ecobin_app/user_management/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart'; // Import logger
import 'update.dart'; // Import the update page

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthServices _auth = AuthServices();
  final Logger _logger = Logger(); // Instantiate logger

  String? name, email, nic, phone, addressNo, street, city;
  List<Map<String, dynamic>> cardDetails = [];

  @override
  void initState() {
    super.initState();
    _logger.i('Initializing Profile');
    _loadUserData();
    _loadCardDetails();
  }

  ///get user details from database
  Future<void> _loadUserData() async {
    _logger.i('Loading user data');
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
      } else {
        _logger.w('Failed to load user data');
      }
    } else {
      _logger.w('User ID is null, unable to load user data');
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
        _logger.i('Card details loaded successfully');
      } else {
        _logger.w('No card details found for user');
      }
    } else {
      _logger.w('User ID is null, unable to load card details');
    }
  }

//delete card details
  Future<void> _deleteCardDetails(String cardNumber) async {
    _logger.i('Attempting to delete card: $cardNumber');
    try {
      await _auth.deleteCard(cardNumber);
      setState(() {
        cardDetails.removeWhere((card) => card['cardNumber'] == cardNumber);
      });
      _logger.i('Card deleted successfully');
      _showSnackBar('Card deleted successfully');
    } catch (e) {
      _logger.e('Failed to delete card: $cardNumber', error: e);
      _showSnackBar('Failed to delete card');
    }
  }

//delete profile details
  Future<void> _deleteProfile(BuildContext context) async {
    _logger.i('Attempting to delete profile');
    String? password = await _showPasswordConfirmationDialog(context);

    if (password != null) {
      bool isPasswordCorrect = await _auth.reauthenticateUser(password);

      if (isPasswordCorrect) {
        await _auth.deleteUser();
        _logger.i('Profile deleted successfully');
        Navigator.pop(context, true);
      } else {
        _logger.w('Incorrect password entered for profile deletion');
        _showSnackBar('Incorrect password!');
      }
    } else {
      _logger.i('Profile deletion canceled by user');
    }
  }

//pop up window
  Future<String?> _showPasswordConfirmationDialog(BuildContext context) async {
    _logger.i('Displaying password confirmation dialog for profile deletion');
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
                _logger.i('Password entered for profile deletion');
              },
              child: const Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
                _logger.i('Profile deletion confirmation canceled');
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    _logger.i('Displaying snackbar: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
                    _buildProfileCard(),
                    const SizedBox(height: 30),
                    _buildPaymentMethodsCard(),
                    const SizedBox(height: 40),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: AssetImage("assets/images/man.png"),
              radius: 60,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 20),
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
            _buildProfileDetail("NIC", nic),
            _buildProfileDetail("Phone", phone),
            _buildProfileDetail("Address", "$addressNo, $street, $city"),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsCard() {
    _logger.i('Building Payment Methods Card UI');
    return Card(
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
            _buildCardDetails(),
          ],
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
    _logger.i('Building Card Details UI');
    if (cardDetails.isEmpty) {
      _logger.w('No card details available');
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
                  _deleteCardDetails(cardNumber);
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
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
              _logger.i('Profile updated successfully');
              _loadUserData();
            } else {
              _logger.i('Profile update canceled or failed');
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
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    _logger.i('Building Action Button UI for $text');
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
