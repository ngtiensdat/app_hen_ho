import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Đăng nhập
  Future<String?> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user != null ? response.user!.id : null;
    } catch (error) {
      print("Lỗi đăng nhập: $error");
      return null;
    }
  }

  // Đăng ký
  Future<String?> signUp(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response.user != null ? response.user!.id : null;
    } catch (error) {
      print("Lỗi đăng ký: $error");
      return null;
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
