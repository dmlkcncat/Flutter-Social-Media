import 'package:cloud_firestore/cloud_firestore.dart';

class New {
  final String id;
  final String hamleYapanId;
  final String hamleTipi;
  final String gonderiId;
  final String gonderiFoto;
  final String yorum;
  final Timestamp olusturulmaZamani;

  New({this.id, this.hamleYapanId, this.hamleTipi, this.gonderiId, this.gonderiFoto, this.yorum, this.olusturulmaZamani});

  factory New.dokumandanUret(DocumentSnapshot doc){
    return New(
      id: doc.documentID,
      hamleYapanId: doc['hamleYapanId'],
      hamleTipi: doc['hamleTipi'],
      gonderiId: doc['gonderiId'],
      gonderiFoto: doc['gonderiFoto'],
      yorum: doc['yorum'],
      olusturulmaZamani: doc['olusturulmaZamani'],
    );
  }
}