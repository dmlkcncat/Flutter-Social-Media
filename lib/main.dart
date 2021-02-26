import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app7/YonlendirmeSayfasi.dart';
import 'package:flutter_app7/models/kullanici.dart';
import 'package:flutter_app7/services/benimServisim.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<BenimAuthServisim>(
      create: (_) => BenimAuthServisim(),
      child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Damingoo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: YonlendirmeSayfasi(),
      ),
    );
  }
}

