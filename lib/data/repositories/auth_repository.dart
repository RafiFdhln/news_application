import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../local/dao/user_dao.dart';
import 'auth_repository_interface.dart';

class AuthRepository implements AuthRepositoryInterface {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final UserDao _userDao;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    required UserDao userDao,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _userDao = userDao;

  @override
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<UserModel> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google Sign-In cancelled.');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final firebaseUser = userCredential.user!;

    final userModel = UserModel(
      uid: firebaseUser.uid,
      displayName: firebaseUser.displayName,
      email: firebaseUser.email,
      photoUrl: firebaseUser.photoURL,
      isGuest: false,
      createdAt: DateTime.now(),
    );

    await _userDao.insertOrUpdate(userModel);
    return userModel;
  }

  @override
  Future<UserModel> signInAsGuest() async {
    final userCredential = await _firebaseAuth.signInAnonymously();
    final firebaseUser = userCredential.user!;

    final userModel = UserModel(
      uid: firebaseUser.uid,
      displayName: 'Guest',
      email: null,
      photoUrl: null,
      isGuest: true,
      createdAt: DateTime.now(),
    );

    await _userDao.insertOrUpdate(userModel);
    return userModel;
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    return await _userDao.getUserById(firebaseUser.uid);
  }

  @override
  Future<UserModel?> getLastCachedUser() async {
    return await _userDao.getLastUser();
  }
}
