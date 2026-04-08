import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository_interface.dart';
import '../../core/constants/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepositoryInterface _authRepository;

  AuthController({required AuthRepositoryInterface authRepository})
      : _authRepository = authRepository;

  // Observables
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  bool get isLoggedIn => currentUser.value != null;
  bool get isGuest => currentUser.value?.isGuest ?? false;

  @override
  void onInit() {
    super.onInit();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    isLoading.value = true;
    try {
      final user = await _authRepository.getCachedUser();
      if (user != null) {
        currentUser.value = user;
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await _authRepository.signInWithGoogle();
      currentUser.value = user;
      _navigateSafely(AppRoutes.news);
    } catch (e) {
      errorMessage.value = _formatError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInAsGuest() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await _authRepository.signInAsGuest();
      currentUser.value = user;
      _navigateSafely(AppRoutes.news);
    } catch (e) {
      errorMessage.value = _formatError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    isLoading.value = true;
    try {
      await _authRepository.signOut();
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      errorMessage.value = _formatError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _navigateSafely(String route) {
    try {
      Get.offAllNamed(route);
    } catch (_) {
    }
  }

  String _formatError(String error) {
    if (error.contains('cancelled') || error.contains('cancel')) {
      return 'Sign-in was cancelled.';
    } else if (error.contains('network')) {
      return 'Network error. Please check your connection.';
    } else if (error.contains('credential')) {
      return 'Authentication failed. Please try again.';
    }
    return 'An error occurred. Please try again.';
  }
}
