import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageServisi {
  StorageReference _storage = FirebaseStorage.instance.ref();
  String resimId;

  Future<String> gonderiResmiYukle(File resimDosyasi) async {
    resimId = Uuid().v4();
    StorageUploadTask yuklemeYoneticisi = _storage.child("resimler/gonderiler/gonderi_$resimId.jpg").putFile(resimDosyasi);
    StorageTaskSnapshot snapshot = await yuklemeYoneticisi.onComplete;
    String yuklenenResim = await snapshot.ref.getDownloadURL();
    return yuklenenResim;
  }
  Future<String> profilResmiYukle(File resimDosyasi) async {
    resimId = Uuid().v4();
    StorageUploadTask yuklemeYoneticisi = _storage.child("resimler/profile/profile_$resimId.jpg").putFile(resimDosyasi);
    StorageTaskSnapshot snapshot = await yuklemeYoneticisi.onComplete;
    String yuklenenResim = await snapshot.ref.getDownloadURL();
    return yuklenenResim;
  }

  void gonderiResmiSil(String gonderiResmiUrl){
    RegExp arama = RegExp(r"gonderi_.+\.jpg");
    var eslesme = arama.firstMatch(gonderiResmiUrl);
    String dosyaAdi = eslesme[0];

    if(dosyaAdi != null){
      _storage.child("resimler/gonderiler/$dosyaAdi").delete();
    }
  }
}