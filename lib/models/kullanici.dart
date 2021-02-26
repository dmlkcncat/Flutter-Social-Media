import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class Kullanici {
  final String id;
  final String kullaniciAdi;
  final String foto;
  final String email;
  final String hakkinda;

  Kullanici({@required this.id, this.kullaniciAdi, this.foto, this.email, this.hakkinda});

  factory Kullanici.dokumandanUret(DocumentSnapshot doc){
    return Kullanici(
      id: doc.documentID,
      kullaniciAdi : doc.data['kullaniciAdi'],
      email: doc.data['email'],
      foto : doc.data['fotoUrl'],
      hakkinda : doc.data['hakkinda'],
    );
  }
  factory Kullanici.firebasedenUret(FirebaseUser kullanici){
    return Kullanici(
      id: kullanici.uid,
      kullaniciAdi: kullanici.displayName,
      email: kullanici.email,
      foto: kullanici.photoUrl,
    );
  }
}