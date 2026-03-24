// lib/features/auth/auth_service.dart

class AuthService {
  static bool login(String user, String pass) {
    return user == "admin" && pass == "1234";
  }
}