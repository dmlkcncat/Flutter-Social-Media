import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app7/models/gonderi.dart';
import 'package:flutter_app7/models/kullanici.dart';
import 'package:flutter_app7/models/new.dart';
import 'package:flutter_app7/services/storageServisi.dart';

import '../news.dart';

class FireStoreServisi {
  final Firestore _firestore = Firestore.instance;
  final DateTime zaman = DateTime.now();

  Future<void> kullaniciOlustur({id, email, kullaniciAdi, foto = ""}) async {
    await _firestore.collection("kullanicilar").document(id).setData({
      "kullaniciAdi": kullaniciAdi,
      "email": email,
      "fotoUrl": foto,
      "hakkinda": "",
      "olusturulmaZamani": zaman
    });
  }

  Future<Kullanici> kullaniciGetir(id) async {
    DocumentSnapshot doc = await _firestore.collection("kullanicilar").document(
        id).get();
    if (doc.exists) {
      Kullanici kullanici = Kullanici.dokumandanUret(doc);
      return kullanici;
    }
    return null;
  }

  void kullaniciGuncelle({String kullaniciId, String kullaniciAdi, String foto = "", String hakkinda}){
    _firestore.collection("kullanicilar").document(kullaniciId).updateData({
      "kullaniciAdi": kullaniciAdi,
      "hakkinda": hakkinda,
      "fotoUrl": foto,
    });
  }
  Future<List<Kullanici>> kullaniciAra(String kelime) async {
    QuerySnapshot snapshot = await _firestore.collection("kullanicilar").where("kullaniciAdi", isGreaterThanOrEqualTo: kelime).getDocuments();

    List<Kullanici> kullanicilar = snapshot.documents.map((doc) => Kullanici.dokumandanUret(doc)).toList();
    return kullanicilar;
  }
  void takipEt({String aktifKullaniciId, String profilId}) {
    _firestore.collection("takipciler").document(profilId).collection("kullanicininTakipcileri").document(aktifKullaniciId).setData({});
    _firestore.collection("takipedilenler").document(aktifKullaniciId).collection("kullanicininTakipleri").document(profilId).setData({});

  newEkle(
    hamleTipi: "takip",
    hamleYapanId: aktifKullaniciId,
    profilId: profilId,
  );
  }
  void takiptenCik({String aktifKullaniciId, String profilId}){
    _firestore.collection("takipciler").document(profilId).collection("kullanicininTakipcileri").document(aktifKullaniciId).get().then((DocumentSnapshot doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });

    _firestore.collection("takipedilenler").document(aktifKullaniciId).collection("kullanicininTakipleri").document(profilId).get().then((DocumentSnapshot doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });
  }

  Future<bool> takipKontrol({String aktifKullaniciId, String profilId}) async {
    DocumentSnapshot doc = await _firestore.collection("takipedilenler").document(aktifKullaniciId).collection("kullanicininTakipleri").document(profilId).get();
    if(doc.exists){
      return true;
    }
    return false;
  }

  Future<int> takipciSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore.collection("takipciler").document(
        kullaniciId).collection("kullanicininTakipcileri").getDocuments();
    return snapshot.documents.length;
  }

  Future<int> takipedilenSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore.collection("takipedilenler")
        .document(kullaniciId).collection("kullanicininTakipleri")
        .getDocuments();
    return snapshot.documents.length;
  }

  void newEkle({String hamleYapanId, String profilId, String hamleTipi, String yorum, Gonderi gonderi}){
    if(hamleYapanId == profilId){
      return;
    }

    _firestore.collection("new").document(profilId).collection("kullanicininNews").add({
      "hamleYapanId": hamleYapanId,
      "hamleTipi": hamleTipi,
      "gonderiId": gonderi?.id,
      "gonderiFoto": gonderi?.gonderiResmiUrl,
      "yorum": yorum,
      "olusturulmaZamani": zaman
    });
  }

  Future<List<New>> newGetir (String profilId) async{
    QuerySnapshot snapshot = await _firestore.collection("new").document(profilId).collection("kullanicininNews").orderBy("olusturulmaZamani", descending: true).limit(20).getDocuments();
    List<New> haberler = [];

    snapshot.documents.forEach((DocumentSnapshot doc) {
      New duyuru = New.dokumandanUret(doc);
      haberler.add(duyuru);
    });
    return haberler;
  }

    Future<void> gonderiOlustur(
      {gonderiResmiUrl, aciklama, yayinlayanId, konum}) async {
    await _firestore.collection("gonderiler").document(yayinlayanId).collection(
        "kullaniciGonderileri").add({
      "gonderiResmiUrl": gonderiResmiUrl,
      "aciklama": aciklama,
      "yayinlayanId": yayinlayanId,
      "begeniSayisi": 0,
      "konum": konum,
      "olusturulmaZamani": zaman
    });
  }

  Future<List<Gonderi>> gonderileriGetir(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore.collection("gonderiler").document(
        kullaniciId).collection("kullaniciGonderileri").orderBy(
        "olusturulmaZamani", descending: true).getDocuments();
    List<Gonderi> gonderiler = snapshot.documents.map((doc) =>
        Gonderi.dokumandanUret(doc)).toList();
    return gonderiler;
  }

  Future<void> gonderiSil({String aktifKullaniciId, Gonderi gonderi}) async{
    _firestore.collection("gonderiler").document(aktifKullaniciId).collection("kullaniciGonderileri").document(gonderi.id).get().then((DocumentSnapshot doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });
    QuerySnapshot yorumlarSnapshot = await _firestore.collection("yorumlar").document(gonderi.id).collection("gonderiYorumlari").getDocuments();
    yorumlarSnapshot.documents.forEach((DocumentSnapshot doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });
    QuerySnapshot newSnapshot = await _firestore.collection("new").document(gonderi.yayinlayanId).collection("kullanicininNews").where("gonderiId", isEqualTo: gonderi.id).getDocuments();
      newSnapshot.documents.forEach((DocumentSnapshot doc){
        if(doc.exists){
          doc.reference.delete();
        }
      });

      StorageServisi().gonderiResmiSil(gonderi.gonderiResmiUrl);
  }

  Future<Gonderi> tekliGonderiGetir(String gonderiId, String gonderiSahibiId) async{
    DocumentSnapshot doc = await _firestore.collection("gonderiler").document(gonderiSahibiId).collection("kullaniciGonderileri").document(gonderiId).get();
    Gonderi gonderi = Gonderi.dokumandanUret(doc);
    return gonderi;
  }

  Future<void> gonderiBegen(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentSnapshot doc = await _firestore.collection("gonderiler").document(
        gonderi.yayinlayanId).collection("kullaniciGonderileri").document(
        gonderi.id).get();

    if (doc.exists) {
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      int yeniBegeniSayisi = gonderi.begeniSayisi + 1;
      await _firestore.collection("gonderiler").document(gonderi.yayinlayanId)
          .collection("kullaniciGonderileri").document(gonderi.id)
          .updateData({
        "begeniSayisi": yeniBegeniSayisi
      });
      _firestore.collection("begeniler").document(gonderi.id).collection("gonderiBegenileri").document(aktifKullaniciId).setData({});

      newEkle(
        hamleTipi: "begeni",
        hamleYapanId: aktifKullaniciId,
        gonderi: gonderi,
        profilId: gonderi.yayinlayanId
      );
    }
  }

  Future<void> gonderiBegeniKaldir(Gonderi gonderi,
      String aktifKullaniciId) async {
    DocumentSnapshot doc = await _firestore.collection("gonderiler").document(
        gonderi.yayinlayanId).collection("kullaniciGonderileri").document(
        gonderi.id).get();

    if (doc.exists) {
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      int yeniBegeniSayisi = gonderi.begeniSayisi - 1;
      await _firestore.collection("gonderiler").document(gonderi.yayinlayanId)
          .collection("kullaniciGonderileri").document(gonderi.id)
          .updateData({
        "begeniSayisi": yeniBegeniSayisi
      });
      DocumentSnapshot docBegeni = await _firestore.collection("begeniler")
          .document(gonderi.id).collection("gonderiBegenileri").document(
          aktifKullaniciId)
          .get();
      if (docBegeni.exists) {
        docBegeni.reference.delete();
      }
    }
  }

  begeniVarmi(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentSnapshot docBegeni = await _firestore.collection("begeniler")
        .document(gonderi.id).collection("gonderiBegenileri").document(
        aktifKullaniciId)
        .get();
    if (docBegeni.exists) {
      return true;
    }
    return false;
  }

  Stream<QuerySnapshot> yorumlariGetir(String gonderiId){
    return _firestore.collection("yorumlar").document(gonderiId).collection("gonderiYorumlari").orderBy("olusturulmaZamani", descending: true).snapshots();
  }

  void yorumEkle({String aktifKullaniciId, Gonderi gonderi, String aciklama}){
    _firestore.collection("yorumlar").document(gonderi.id).collection("gonderiYorumlari").add({
      "aciklama": aciklama,
      "yayinlayanId": aktifKullaniciId,
      "olusturulmaZamani": zaman,
    });

    newEkle(
      hamleTipi: "yorum",
      hamleYapanId: aktifKullaniciId,
      gonderi: gonderi,
      profilId: gonderi.yayinlayanId,
      yorum: aciklama,
    );
  }
}

