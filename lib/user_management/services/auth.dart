import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ecobin_app/user_management/models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthServices extends ChangeNotifier {
  //firebase instance
  late final FirebaseAuth firebaseAuth;

  AuthServices({FirebaseAuth? firebaseAuth})
      : firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //create a user from firebase user with uid
  UserModel? _userWithFirebaeUserUid(User? user) {
    return user != null ? UserModel(uid: user.uid) : null;
  }

  // create the stram for checking the auth cahnges in the user
  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userWithFirebaeUserUid);
  }

  //register using email and password
  // Register using email and password and save additional details
  Future registerWithEmailAndPassword(
      String name,
      String email,
      String nic,
      String password,
      String phone,
      String addressNo,
      String street,
      String city) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      // Save additional user details in Firestore
      await _firestore.collection('users').doc(user!.uid).set({
        'name': name,
        'email': email,
        'nic': nic,
        'phone': phone,
        'addressNo': addressNo,
        'street': street,
        'city': city,
      });

      return _userWithFirebaeUserUid(user);
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      return userDoc.data() as Map<String, dynamic>?;
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  // Getter for current user
  User? get currentUser {
    return _auth.currentUser;
  }

  //sign in using email and password

  Future signInUsingEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userWithFirebaeUserUid(user);
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  //sign in using gmail

  // Get the current user's email
  String? getCurrentUserEmail() {
    User? user = _auth.currentUser;
    return user?.email;
  }

  //sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  Future<void> updateUserProfile(
    String uid,
    String name,
    String email,
    String nic,
    String phone,
    String addressNo,
    String street,
    String city,
  ) async {
    try {
      // Update the user's document in Firestore
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'email': email,
        'nic': nic,
        'phone': phone,
        'addressNo': addressNo,
        'street': street,
        'city': city,
      });
      print("Profile updated successfully");
    } catch (e) {
      print("Failed to update profile: $e");
      throw e;
    }
  }

  Future<bool> reauthenticateUser(String password) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );

        // Reauthenticate the user with the provided credential
        await user.reauthenticateWithCredential(credential);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Reauthentication failed: $e");
      return false;
    }
  }

  Future<void> deleteUser() async {
    try {
      User? user = _auth.currentUser;
      String? uid = user?.uid;

      if (user != null && uid != null) {
        // Delete user data from Firestore
        await _firestore.collection('users').doc(uid).delete();

        // Delete user from Firebase Authentication
        await user.delete();

        print("User profile deleted successfully");
      }
    } catch (e) {
      print("Error deleting user: $e");
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getCardDetails(String uid) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('users') // Access 'users' collection
          .doc(uid) // Get the specific user's document using uid
          .collection(
              'carddetails') // Access 'carddetails' subcollection inside the user document
          .get();

      return snapshot.docs.map((doc) {
        return {
          'cardType': doc['cardType'],
          'cardNumber': doc['cardNumber'],
        };
      }).toList();
    } catch (e) {
      print('Error fetching card details: $e');
      return []; // Return an empty list on error
    }
  }

  // Function to delete a specific card detail from Firestore
  Future<void> deleteCard(String cardNumber) async {
    try {
      String? uid = currentUser?.uid;

      if (uid != null) {
        // Reference to the user's 'carddetails' collection
        CollectionReference cardCollection =
            _db.collection('users').doc(uid).collection('carddetails');

        // Query to find the card by 'cardNumber' field
        QuerySnapshot querySnapshot = await cardCollection
            .where('cardNumber', isEqualTo: cardNumber)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentReference cardRef = querySnapshot.docs.first.reference;

          // Delete the card document
          await cardRef.delete();
          print('Card deleted successfully: $cardNumber');
        } else {
          print('Card not found: $cardNumber');
        }
      } else {
        print('No current user logged in.');
      }
    } catch (e) {
      print("Error deleting card: $e");
      throw e; // Rethrow the error to be caught by the calling function
    }
  }
}
