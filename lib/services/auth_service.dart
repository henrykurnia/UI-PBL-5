import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
// import '../config/firebase_config.dart';
import 'api_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // clientId: FirebaseConfig.wbclien
  );
  final ApiService _apiService = ApiService();

  // Stream untuk monitor auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // get current user
  User? get curentUser => _auth.currentUser;

  // Sign In Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      // final GoogleSignIn googleSignIn = GoogleSignIn();
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      // Obtain the auth details from the request
      // final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        final String? idToken = await user.getIdToken();

        // verifiy token
        final bool verified = await _apiService.verifyToken(idToken!);

        if (verified) {
          final userModel = UserModel(
            uid: user.uid,
            email: user.email!,
            displayName: user.displayName ?? '',
            photoUrl: user.photoURL,
            idToken: idToken,
          );

          await _saveUserData(userModel);

          return userModel;
        }
      }
    } catch (e) {
      print("Error Google Sign-In: $e");

      rethrow;
    }
  }

  // Logout
  Future<bool> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      await _clearUserData();

      return true;
    } catch (e) {
      print('Error signing out: $e');
      return false;
    }
  }

  // get stored user data
  Future<UserModel?> getStoredUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Selalu dapatkan ID Token terbaru, karena mungkin sudah expired
      final String? idToken = await user.getIdToken(); 
      
      // Ambil data lain dari SharedPreferences (yang sudah tersimpan saat login)
      final prefs = await SharedPreferences.getInstance();
      
      // Membuat UserModel dari data Firebase User dan SharedPreferences
      final UserModel userData = UserModel(
        uid: user.uid,
        email: user.email!, // Email selalu ada jika login Google
        displayName: prefs.getString('user_name') ?? user.displayName ?? '',
        photoUrl: prefs.getString('user_photo') ?? user.photoURL,
        idToken: idToken,
      );
      
      // Perbarui data di SharedPreferences jika ada perubahan
      await _saveUserData(userData); 

      return userData;
    }
    return null;
    // try {
    //   final prefs = await SharedPreferences.getInstance();
    //   // final String? userJson = prefs.getString('user_data');
    //   final userJson = prefs.getString('user_data');

    //   if (userJson != null) {
    //     final user = curentUser;
    //     if (user != null) {
    //       // final String? idToken = await user.getIdToken();
    //       final String idToken = await user.getIdToken() ?? "";
    //       // final userData = UserModel.fromJson(
    //       //   Map<String, dynamic>.from(
    //       //     // Parse stored JSON
    //       //     {}
    //       //   )
    //       // );
    //       UserModel userData = UserModel(
    //         // uid: prefs.getString('user_uid') ?? '',
    //         uid: user.uid,
    //         email: user.email!,
    //         // email: prefs.getString('user_email')!,
    //         displayName: prefs.getString('user_name') ?? user.displayName ?? '',
    //         photoUrl: prefs.getString('user_photo') ?? user.photoURL,
    //         idToken: idToken,
    //       );

    //       await _saveUserData(userData);

    //       return userData;
    //     }
    //   }
    //   return null;
    // } catch (e) {
    //   print('Error getting stored user: $e');
    //   return null;
    // }
  }

  Future<void> _saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_uid', user.uid);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_name', user.displayName);
    if (user.photoUrl != null) {
      await prefs.setString('user_photo', user.photoUrl!);
    }
    if (user.idToken != null) {
      await prefs.setString('id_token', user.idToken!);
    }
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_uid');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_photo');
    await prefs.remove('id_token');
  }
}
