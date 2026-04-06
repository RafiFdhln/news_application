import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

abstract class AuthRepositoryInterface {
  User? get currentFirebaseUser;
  Stream<User?> get authStateChanges;
  Future<UserModel?> getCachedUser();
  Future<UserModel?> getLastCachedUser();
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInAsGuest();
  Future<void> signOut();
}
