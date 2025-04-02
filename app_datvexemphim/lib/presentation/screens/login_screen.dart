import 'package:app_datvexemphim/const.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:go_router/go_router.dart';
import 'package:app_datvexemphim/api/api_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/storage_service.dart'; // File quản lý lưu trữ

const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

GoogleSignIn _googleSignIn = GoogleSignIn(
  serverClientId: CLIENT_KEY,
  scopes: scopes,
);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late String? _currentAccount;
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false; // has granted permissions?
  final String _contactText = '';

  Future<void> _login() async {
    setState(() => _errorMessage = null);

    if (_currentUser != null) {
    } else {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        setState(() => _errorMessage = "Vui lòng nhập đầy đủ thông tin!");
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      if (_currentUser != null) {
        final emailUser = _currentUser?.email;
        //----------------------------------------------

        final response =
            await ApiService.post("/auth/loginGoogle", {"email": '$emailUser'});

        if (response == null) {
          setState(() => _errorMessage = "⚠️ Lỗi kết nối đến server!");
          return;
        }

        if (response.statusCode == 200) {
          print("✅ Đăng nhập thành công!");

          String token = response.data['token'];
          String userId = response.data['data']['_id'];

          // Lưu vào SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', emailUser ?? '');

          await StorageService.saveUserData(token, userId);

          // Chuyển hướng đến màn hình chính
          GoRouter.of(context).go('/home');
        } else {
          setState(() => _errorMessage = "❌ Sai tài khoản hoặc mật khẩu!");
        }
      } else {
        final response = await ApiService.post("/auth/loginUser", {
          "email": _emailController.text.trim(),
          "matKhau": _passwordController.text.trim(),
        });

        if (response == null) {
          setState(() => _errorMessage = "⚠️ Lỗi kết nối đến server!");
          return;
        }

        if (response.statusCode == 200) {
          print("✅ Đăng nhập thành công!");

          String token = response.data['token'];
          String userId = response.data['data']['_id'];

          // Lưu vào SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('emailAcc', _emailController.text.trim());
          await prefs.setString('passAcc', _passwordController.text.trim());

          await StorageService.saveUserData(token, userId);

          // Chuyển hướng đến màn hình chính
          GoRouter.of(context).go('/home');
          if (context.mounted) {
            context.pop(true); // Trả về true sau khi đăng nhập thành công
          }
        } else {
          setState(() => _errorMessage = "❌ Sai tài khoản hoặc mật khẩu!");
        }
      }
    } catch (e) {
      setState(() => _errorMessage = "⚠️ Lỗi đăng nhập, thử lại!");
    }

    setState(() => _isLoading = false);
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: hint,
        labelStyle: const TextStyle(color: Color(0xFF545454)),
        prefixIcon: Icon(icon, color: Color(0xFFee0033)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Color(0xFFee0033),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFC20077)),
        ),
      ),
    );
  }

  Future<void> _handleGetSignInGoogle() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('email');
      if (email == null) {
        final emailUser = _currentUser?.email;
        final response =
            await ApiService.post('/google/signin', {"email": '$emailUser'});

        print("Response Status Code: ${response?.statusCode}");
        print("Response Body: ${response?.data}");

        if (response != null && response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đăng nhập thành công!")),
          );
        } else if (response!.statusCode == 400) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', emailUser ?? '');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đăng nhập thành công!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Đăng nhập thất bại! (${response.statusCode})")),
          );
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Lỗi server, thử lại sau!")),
      );
    }
  }

  //-------------------------------
  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();

      // _handleSignOut();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.signOut();
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.remove('email');
    // setState(() => _currentUser = null);
    print("🚪 Đã đăng xuất và xóa email khỏi SharedPreferences!");
  }

  Future<void> _loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    String? emailAcc = prefs.getString('emailAcc');
    String? passAcc = prefs.getString('passAcc');

    if (email != null) {
      print("📌 Email đã lưu: $email");
      // setState(() => _currentAccount = email);
    } else {
      print("⚠️ Không tìm thấy email, thử đăng nhập lại...");
      await _handleSignOut(); // Chỉ đăng xuất khi không có email
      setState(() {
        _emailController.text = emailAcc ?? "";
        _passwordController.text = passAcc ?? "";
      });
      return;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // _handleSignOut();
    _loadEmail();

    _googleSignIn.onCurrentUserChanged.listen((
      GoogleSignInAccount? account,
    ) async {
      bool isAuthorized = account != null;

      if (kIsWeb && account != null) {
        isAuthorized = await _googleSignIn.canAccessScopes(scopes);
      }

      setState(() {
        _currentUser = account;
        _isAuthorized = isAuthorized;
      });
      if (_currentUser != null) {
        _handleGetSignInGoogle();
      }
      if (isAuthorized) {
        // unawaited(_handleGetContact(account!));
      }
    });
    _googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => GoRouter.of(context).go('/home'),
        ),
        //title: Text("Đăng nhập", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child:
                        Image.asset('assets/images/logofull2.png', width: 500),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Đăng nhập',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(_emailController, "Email", Icons.email),
                  const SizedBox(height: 15),
                  _buildTextField(_passwordController, "Mật khẩu", Icons.lock,
                      isPassword: true),
                  const SizedBox(height: 10),
                  _errorMessage != null
                      ? Text(_errorMessage!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 14))
                      : const SizedBox.shrink(),
                  const SizedBox(height: 25),
                  if (_currentUser != null)
                    Column(
                      children: const [
                        Center(
                            child: Text(
                          'Đăng nhập Google thành công',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 15,
                            //
                          ),
                        )),
                        // ElevatedButton(
                        //   onPressed: _handleSignOut,
                        //   child: const Text('SIGN OUT'),
                        // ),
                      ],
                    )
                  else
                    Center(
                      child: SignInButton(
                        Buttons.Google,
                        onPressed: _handleSignIn,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        color: const Color.fromARGB(255, 255, 243, 243),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Đăng nhập',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => GoRouter.of(context).go('/register'),
              child: const Text(
                "Chưa có tài khoản? Đăng ký ngay",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
