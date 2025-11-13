import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {


  // Sign In Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser =
          await googleSignIn.signIn();

      if (googleUser == null) return null;

      // Obtain the auth details from the request
      // final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);

      // if (!context.mounted) return null;
      // Navigator.pushReplacementNamed(context, '/home');

      // return credential;
    } catch(e) {
      print("Error Google Sign-In: $e");
      // if (context.mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("Login dengan Google gagal: $e")),
      //   );
      // }
      // return null;
    }    
  }

  // Logout
  Future<void> signOut() async {
    // await _auth.signOut();
  }
}