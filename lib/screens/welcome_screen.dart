import 'package:flutter/material.dart';
import 'login_screen.dart';
//import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade100,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo App
            Image.asset(
              'assets/logo.png', // Thay bằng logo
              height: 120,
            ),
            const SizedBox(height: 30),
            // Nút Đăng nhập
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: const Text("Đăng nhập", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 15),
            // Nút Đăng ký
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.pink,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                side: const BorderSide(color: Colors.pink, width: 2),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: const Text("Đăng ký", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
