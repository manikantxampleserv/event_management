// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';

class AuthService extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Rx<User?> _user = Rx<User?>(null);

  User? get user => _user.value;
  bool get isLoggedIn => _user.value != null;

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_auth.authStateChanges());
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in with email: $e');
      rethrow;
    }
  }

  Future<UserCredential?> registerWithEmail(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error registering with email: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  String? getCurrentUserDisplayName() {
    return _auth.currentUser?.displayName;
  }

  String? getCurrentUserPhotoURL() {
    return _auth.currentUser?.photoURL;
  }

  bool get isGuest => _auth.currentUser == null;
}
