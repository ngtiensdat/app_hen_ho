import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<String?> signUp(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        return response.user!.id;
      }
      return null;
    } on AuthException catch (e) {
      return "Lỗi: ${e.message}";
    } catch (e) {
      return "Lỗi không xác định: ${e.toString()}";
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session != null) {
        return response.session!.user.id;
      }
      return null;
    } on AuthException catch (e) {
      return "Lỗi: ${e.message}";
    } catch (e) {
      return "Lỗi không xác định: ${e.toString()}";
    }
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void register() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin!")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mật khẩu nhập lại không khớp!")),
      );
      return;
    }

    String? result = await authService.signUp(email, password);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng ký thành công! Hãy đăng nhập.")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng ký thất bại! Hãy thử lại.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Đăng ký"), backgroundColor: Colors.pink),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
                controller: emailController,
                decoration: InputDecoration(
                    labelText: "Gmail",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.mail))),
            SizedBox(height: 15),
            TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Mật khẩu",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock))),
            SizedBox(height: 15),
            TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Nhập lại mật khẩu",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock))),
            SizedBox(height: 20),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white),
                onPressed: register,
                child: Text("Đăng ký")),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập email và mật khẩu!")),
      );
      return;
    }

    String? result = await authService.signIn(email, password);

    if (result != null && !result.startsWith("Lỗi")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng nhập thành công!")),
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(result ?? "Đăng nhập thất bại! Kiểm tra lại thông tin.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Đăng nhập"), backgroundColor: Colors.pink),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
                controller: emailController,
                decoration: InputDecoration(
                    labelText: "Gmail",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.mail))),
            SizedBox(height: 15),
            TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Mật khẩu",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock))),
            SizedBox(height: 20),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white),
                onPressed: login,
                child: Text("Đăng nhập")),
          ],
        ),
      ),
    );
  }
}
