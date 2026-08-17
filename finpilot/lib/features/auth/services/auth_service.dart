import 'package:cloud_firestore/cloud_firestore.dart';
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
    required String name,
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    await userCredential.user?.updateDisplayName(name.trim());

    final user = userCredential.user;

    if (user != null) {
      final userReference = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      await userReference.set({
        'displayName': name.trim(),
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await userReference.collection('accounts').doc('main').set({
        'name': 'Ana Hesap',
        'type': 'cash',
        'balance': 0.0,
        'currency': 'TRY',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return userCredential;
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
