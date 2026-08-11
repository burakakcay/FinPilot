import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Firebase Authentication işlemlerini arayüzden ayırır.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // E-posta ve şifre ile mevcut kullanıcı oturumunu açar.
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  // E-posta ve şifre ile yeni bir kullanıcı hesabı oluşturur.
  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  // Aktif Firebase oturumunu kapatır.
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Kullanıcının e-posta adresine şifre yenileme bağlantısı gönderir.
  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Giriş yapan kullanıcıyı döndürür; oturum yoksa null olur.
  User? get currentUser => _auth.currentUser;
}
