import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app7/AnaSayfa.dart';
import 'package:flutter_app7/GirisSayfasi.dart';
import 'package:flutter_app7/services/benimServisim.dart';
import 'package:provider/provider.dart';

import 'models/kullanici.dart';

class YonlendirmeSayfasi extends StatefulWidget {
  @override
  _YonlendirmeSayfasiState createState() => _YonlendirmeSayfasiState();
}

class _YonlendirmeSayfasiState extends State<YonlendirmeSayfasi> {

  @override
  Widget build(BuildContext context) {
    final _benimAuthServisim = Provider.of<BenimAuthServisim>(context, listen: false);

    return StreamBuilder(
        stream: Provider.of<BenimAuthServisim>(context, listen: false).durumTakipcisi,
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }
          if(snapshot.hasData){
            Kullanici aktifKullanici = snapshot.data;
            _benimAuthServisim.aktifKullaniciId = aktifKullanici.id;
            return AnaSayfa();
          }else {
            return GirisSayfasi();
          }
        }
    );
  }
}