import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (name != null && name.isNotEmpty) {
      await userCredential.user?.updateDisplayName(name);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> updateUserProfile({
    String? name,
    String? email,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      if (name != null && name.isNotEmpty && name != user.displayName) {
        await user.updateDisplayName(name);
      }
      if (email != null && email.isNotEmpty && email != user.email) {
        await user.verifyBeforeUpdateEmail(email);
      }
    } on FirebaseAuthException catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }
}