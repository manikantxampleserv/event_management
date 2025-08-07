// ignore_for_file: avoid_print
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import '../services/profile_service.dart';

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

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _handleProfileCreation(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _handleProfileCreation(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with email: $e');
      rethrow;
    }
  }

  Future<UserCredential?> registerWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName);
      }

      if (userCredential.user != null) {
        await _handleProfileCreation(userCredential.user!, isNewUser: true);
      }

      return userCredential;
    } catch (e) {
      print('Error registering with email: $e');
      rethrow;
    }
  }

  Future<void> _handleProfileCreation(
    User firebaseUser, {
    bool isNewUser = false,
  }) async {
    try {
      ProfileService profileService;
      if (Get.isRegistered<ProfileService>()) {
        profileService = Get.find<ProfileService>();
      } else {
        profileService = Get.put(ProfileService());
      }

      if (isNewUser) {
        await profileService.createProfileOnSignUp(
          firebaseUser.uid,
          firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'New User',
          photoUrl: firebaseUser.photoURL,
        );
        print('Profile created for new user: ${firebaseUser.uid}');
      } else {
        await profileService.fetchProfile(firebaseUser.uid);
        print('Profile fetched/created for user: ${firebaseUser.uid}');
      }
    } catch (e) {
      print('Error handling profile creation: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();

      if (Get.isRegistered<ProfileService>()) {
        final profileService = Get.find<ProfileService>();
        profileService.profile.value = null;
      }
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

  Future<void> syncProfile() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _handleProfileCreation(currentUser);
    }
  }
}
