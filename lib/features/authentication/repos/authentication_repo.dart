import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthenticationRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool get isLoggedIn => user != null;
  User? get user => _firebaseAuth.currentUser;

  // 監聽用戶狀態
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  // 註冊
  Future<void> signUp(String email, String password) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  // 登出
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

final authRepo = Provider((ref) => AuthenticationRepository());

final authState = StreamProvider((ref) {
  final repo = ref.read(authRepo);
  return repo.authStateChanges();
});
