import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app7/models/kullanici.dart';

class BenimAuthServisim {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String aktifKullaniciId;

  Kullanici _kullaniciOlustur(FirebaseUser firebaseKullanici){
    return firebaseKullanici == null ? null: Kullanici.firebasedenUret(firebaseKullanici);
  }

  Stream<Kullanici> get durumTakipcisi {
    return _firebaseAuth.onAuthStateChanged.map(_kullaniciOlustur);
  }

  Future<Kullanici> mailleKayit(String eposta, String sifre) async {
    var girisKarti = await _firebaseAuth.createUserWithEmailAndPassword(email: eposta, password: sifre);
    return _kullaniciOlustur(girisKarti.user);
  }

  Future<Kullanici> mailleGiris(String eposta, String sifre) async {
    var girisKarti = await _firebaseAuth.signInWithEmailAndPassword(email: eposta, password: sifre);
    return _kullaniciOlustur(girisKarti.user);
  }


  Future<void> cikisYap(){
    return _firebaseAuth.signOut();
  }
}