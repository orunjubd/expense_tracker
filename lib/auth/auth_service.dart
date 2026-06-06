// ===========================================================
// Step 1: Create the Cloud Authentication Service
// ===========================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // 📝 NOTE / HINTS:
  // 1) Firebase Engine Instances Initialization:
  // What it does: This initializes the connection pathways to your Firebase cloud account backend framework.
  // - '_auth': Accesses the server module that handles security tokens, password checking, and account keys [INDEX].
  // - '_firestore': Accesses your cloud NoSQL document database to store extra customer details like user roles [INDEX].
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 📝 NOTE / HINTS:
  // 2) Cloud Registration & Role Assignment Pipeline (signUpAdmin):
  // What it does: This handles creating brand-new accounts inside the cloud system server.
  // 1. 'createUserWithEmailAndPassword': Creates the profile login inside Firebase Authentication [INDEX].
  // 2. '.collection('users').doc(...).set(...)': Creates a document row matching the user's secret ID
  //    inside the Firestore cloud database [INDEX]. It stamps them explicitly with the 'admin' role designation value [INDEX].
  // 3. 'on FirebaseAuthException': Catches network validation rejections (like 'email already in use')
  //    and throws a clean exception message upward for your UI screen file to display inside a SnackBar [INDEX].
  // [1. REGISTER NEW USER / ADMIN PROFILES IN THE CLOUD]
  // Future<UserCredential?> signUpAdmin({
  //   required String email,
  //   required String password,
  //   required String username,
  // }) async {
  //   try {
  //     // Create user credential node in Firebase Authentication
  //     UserCredential userCredential = await _auth
  //         .createUserWithEmailAndPassword(email: email, password: password);

  //     // Save additional role-based metadata inside the Firestore Cloud Database
  //     if (userCredential.user != null) {
  //       await _firestore.collection('users').doc(userCredential.user!.uid).set({
  //         'uid': userCredential.user!.uid,
  //         'username': username,
  //         'email': email,
  //         'role': 'admin', // Hardcoded role designation for this control script
  //         'createdAt': Timestamp.now(),
  //       });
  //     }
  //     return userCredential;
  //   } on FirebaseAuthException catch (e) {
  //     // Pass the explicit error message upward to be caught by the UI overlay snackbars
  //     throw Exception(e.message ?? 'An error occurred during registration.');
  //   }
  // }

  // 1. UPDATED: Accepts a dynamic role string variable ('user' or 'admin')
  Future<UserCredential?> signUpUser({
    required String email,
    required String password,
    required String username,
    required String role, // 👈 ADD THIS PARAMETER
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'username': username,
          'email': email,
          'role':
              role, // 👈 FIXED: No longer hardcoded! Assigns 'user' or 'admin' dynamically
          'createdAt': Timestamp.now(),
        });
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'An error occurred during registration.');
    }
  }

  // 📝 NOTE / HINTS:
  //  Secure Profile Sign In Controller (signInUser):
  // What it does: This handles logging existing accounts back into the tracker platform workspace.
  // - It runs an asynchronous verification script check ('signInWithEmailAndPassword') [INDEX].
  // - If the cloud database matches the email and password parameters, it passes the security access tokens back down [INDEX].
  // - If wrong parameters are typed, it automatically catches the server error string to push onto your front-end warning blocks [INDEX].
  // [2. SIGN IN EXISTING PROFILES]
  Future<UserCredential?> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'An error occurred during authentication.');
    }
  }

  // 📝 NOTE / HINTS:
  // 4) Access Token Revocation Engine (signOut):
  // What it does: This is your secure log out function pipeline [INDEX]. It tells the background cloud servers
  // to permanently erase the device's temporary authentication token keys from its hardware storage lines [INDEX].
  // How it connects: Your sidebar navigation drawer or profile button calls this function to reset the app
  // view state and kick the viewport safely back to the login forms on click [INDEX].
  // [3. SECURE SYSTEM SIGN OUT]
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
