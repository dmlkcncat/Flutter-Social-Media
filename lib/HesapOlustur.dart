import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app7/AnaSayfa.dart';
import 'package:flutter_app7/models/kullanici.dart';
import 'package:flutter_app7/services/benimServisim.dart';
import 'package:flutter_app7/services/firestore.dart';
import 'package:provider/provider.dart';

class HesapOlustur extends StatefulWidget {
  @override
  _HesapOlusturState createState() => _HesapOlusturState();
}

class _HesapOlusturState extends State<HesapOlustur> {
  bool yukleniyor = false;
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();
  String kullaniciAdi, email, sifre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldAnahtari,
      appBar: AppBar(
        title: Text("Hesap Oluştur"),
      ),
        body: ListView(
          children: [
            yukleniyor ? LinearProgressIndicator() : SizedBox(height: 0.0,),
           Padding(
           padding: const EdgeInsets.all(20.0),
           child: Form(
             key: _formAnahtari,
              child: Column(
                children: [
                  SizedBox(height: 20.0,),
                  FlutterLogo(size: 90.0,),
                  SizedBox(height: 20.0,),
                  Center(child: Text("Damingo",
                      style: TextStyle(
                          color: Colors.indigo,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold
                      )),
                  ),
                  SizedBox(height: 20.0,),
                  TextFormField(
                    autocorrect: true,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Kullanıcı Adı",
                      labelText: "Kullanıcı adınızı girin",
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (girilenMail) {
                      if (girilenMail.isEmpty) {
                        return "Kullanıcı adı alanı boş bırakılamaz!";
                      } else if (girilenMail.trim().length > 20) {
                        return "Kullanıcı adı en fazla 20 karakter olabilirS!";
                      }
                      return null;
                    },
                    onSaved: (girilenMail) => kullaniciAdi = girilenMail,
                  ),
                  SizedBox(height: 20.0,),
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
                  SizedBox(height: 20.0,),
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
                      } else if (girilenMail
                          .trim()
                          .length < 7) {
                        return "Şifre 7 karakterden az olamaz!";
                      }
                      return null;
                    },
                    onSaved: (girilenMail) => sifre = girilenMail,
                  ),
                  SizedBox(height: 20.0,),
                  FlatButton(onPressed: _kullaniciOlustur,
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
                ],
              ),
            ),
           ),
          ],
        )
    );
  }
  void _kullaniciOlustur() async{

    final _benimAuthServisim = Provider.of<BenimAuthServisim>(context, listen: false);

    var _formState = _formAnahtari.currentState;

    if(_formAnahtari.currentState.validate()) {
      _formAnahtari.currentState.save();
      setState(() {
        yukleniyor = true;
      });
      try {
        Kullanici kullanici = await _benimAuthServisim.mailleKayit(email, sifre);
        if(kullanici != null){
          FireStoreServisi().kullaniciOlustur(id: kullanici.id, email: email, kullaniciAdi: kullaniciAdi);
        }
        Navigator.pop(context);
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
    if(hataKodu == "ERROR_INVALID_EMAIL"){
      hataMesaj = "Geçersiz bir mail adresi girdiniz!";
    }else if (hataKodu == "ERROR_EMAIL_ALREADY_IN_USE"){
      hataMesaj = "Girilen mail adresi zaten başka bir kullanıcı tarafından kullanılıyor!";
    }else if (hataKodu == "ERROR_WEAK_PASSWORD") {
      hataMesaj = "Güvensiz şifre girdiniz. Daha güçlü bir şifre tercih ediniz!";
    }
    var snackBar = SnackBar(content: Text(hataMesaj));
    _scaffoldAnahtari.currentState.showSnackBar(snackBar);
  }
}