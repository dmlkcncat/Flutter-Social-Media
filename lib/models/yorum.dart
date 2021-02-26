import 'package:cloud_firestore/cloud_firestore.dart';

class Yorum {
  final String id;
  final String aciklama;
  final String yayinlayanId;
  final Timestamp olusturulmaZamani;

  Yorum({this.id, this.aciklama, this.yayinlayanId, this.olusturulmaZamani});

  factory Yorum.dokumandanUret(DocumentSnapshot doc){
    return Yorum(
      id: doc.documentID,
      aciklama: doc['aciklama'],
      yayinlayanId: doc['yayinlayanId'],
      olusturulmaZamani: doc['olusturulmaZamani'],
    );
  }

}