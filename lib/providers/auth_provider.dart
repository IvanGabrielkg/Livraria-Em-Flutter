import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _auth;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _profile;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get profile => _profile;

  AuthProvider({AuthService? authService}) : _auth = authService ?? AuthService() {
    init();
  }

  Future<void> init() async {
    _isLoggedIn = await _auth.isLoggedIn();
    if (_isLoggedIn) {
      await loadProfile();
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final token = await _auth.login(email, password);
    _isLoggedIn = token != null;
    if (_isLoggedIn) {
      await loadProfile();
    }
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    final msg = await _auth.register(name, email, password);

    notifyListeners();
   }

  Future<void> loadProfile() async {
    _profile = await _auth.fetchProfile();

    _profile ??= await _auth.decodeLocalTokenClaims();
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.logout();
    _isLoggedIn = false;
    _profile = null;
    notifyListeners();
  }
}