class AuthService {
  Future<bool> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 2)); // Fake API call
    return email == "test@gmail.com" && password == "123456";
  }

  static isLoggedIn() {}
}
