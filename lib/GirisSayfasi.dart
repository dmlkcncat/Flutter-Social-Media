import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app7/services/benimServisim.dart';
import 'package:provider/provider.dart';

import 'HesapOlustur.dart';
import 'models/kullanici.dart';

class GirisSayfasi extends StatefulWidget {
  @override
  _GirisSayfasiState createState() => _GirisSayfasiState();
}
class _GirisSayfasiState extends State<GirisSayfasi>{
  BuildContext scaffoldContext;
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();
  bool yukleniyor = false;
  String email, sifre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldAnahtari,
        body: Stack(
          children: <Widget>[
            _sayfaDuzeni(),
            _yukleniyorAnimasyonu(),
          ],
        ));
  }

  Widget _yukleniyorAnimasyonu() {
    if (yukleniyor) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Center();
    }
  }

  Widget _sayfaDuzeni() {
    return Form(
      key: _formAnahtari,
      child: ListView(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 60.0),
        children: <Widget>[
          FlutterLogo(size: 90.0,),
          SizedBox(height: 20.0,),
          Center(child: Text("Damingo",
              style: TextStyle(
                  color: Colors.indigo,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold
              )),
          ),
          SizedBox(height: 35.0,),
          TextFormField(
            autocorrect: true,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "E-mail",
              labelText: "Mail adresinizi girin",
              prefixIcon: Icon(Icons.mail),
            ),
            validator: (girilenMail) {
              if (girilenMail.isEmpty) {
                return "Email alanı boş bırakılamaz!";
              } else if (!girilenMail.contains("@")) {
                return "Girilen değer mail formatında olmalı!";
              }
              return null;
            },
            onSaved: (girilenMail) => email = girilenMail,
          ),
          SizedBox(height: 40.0,),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Şifre",
              labelText: "Şifrenizi girin",
              prefixIcon: Icon(Icons.lock),
            ),
            validator: (girilenMail) {
              if (girilenMail.isEmpty) {
                return "Şifre alanı boş bırakılamaz!";
              } else if (girilenMail.trim().length < 7) {
                return "Şifre 7 karakterden az olamaz!";
              }
              return null;
            },
            onSaved: (girilenMail) => sifre = girilenMail,
          ),
          SizedBox(height: 40.0,),
          //Center(child: InkWell(onTap: () => anonimGirisYap(context),
          FlatButton(
            onPressed: _girisYap,
            child: Text(
              "Giriş Yap",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ),

          SizedBox(height: 20.0,),
          Row(children: [
            Expanded(
              child: FlatButton(onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => HesapOlustur()));
              },
                child: Text(
                  "Hesap Oluştur",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                color: Colors.indigo,
              ),
            ),
            SizedBox(width: 10.0,),

          ],),
          SizedBox(height: 20.0,),
          Center(child: Text("Şifremi Unuttum")),

        ],
      ),
    );
  }

  void _girisYap() async {
    final _benimAuthServisim = Provider.of<BenimAuthServisim>(context, listen: false);

    var _formState = _formAnahtari.currentState;

    if (_formAnahtari.currentState.validate()) {
      _formAnahtari.currentState.save();

      setState(() {
        yukleniyor = true;
      });
      try {
        await _benimAuthServisim.mailleGiris(email, sifre);
      } catch (hata) {
        setState(() {
          yukleniyor = false;
        });
        hataGoster(hataKodu: hata.code);
      }
    }
  }
  hataGoster({hataKodu}){
    String hataMesaj;
    if(hataKodu == "ERROR_USER_NOT_FOUND"){
        hataMesaj = "Böyle bir kullanıcı bulunamadı!";
    }else if (hataKodu == "ERROR_INVALID_EMAİL"){
      hataMesaj = "Girilen mail adresi geçersizdir!";
    }else if (hataKodu == "ERROR_WRONG_PASSWORD") {
      hataMesaj = "Hatalı şifre girdiniz!";
    }else if (hataKodu == "ERROR_USER_DISABLED") {
      hataMesaj = "Artık böyle bir kullanıcı bulunamamaktadır!";
    }else {
      hataMesaj = "Hata Oluştu! $hataKodu";
    }

    var snackBar = SnackBar(content: Text(hataMesaj));
    _scaffoldAnahtari.currentState.showSnackBar(snackBar);
  }
}