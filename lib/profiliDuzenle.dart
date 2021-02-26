
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app7/services/benimServisim.dart';
import 'package:flutter_app7/services/firestore.dart';
import 'package:flutter_app7/services/storageServisi.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'models/kullanici.dart';

class ProfiliDuzenle extends StatefulWidget {
  final Kullanici profile;
  const ProfiliDuzenle({Key key, this.profile}) : super(key: key);

  @override
  _ProfiliDuzenleState createState() => _ProfiliDuzenleState();
}

class _ProfiliDuzenleState extends State<ProfiliDuzenle> {
  var _formKey = GlobalKey<FormState>();
  String _kullaniciAdi;
  String _hakkinda;
  File _secilenFoto;
  bool _yukleniyor= false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Profili Düzenle", style: TextStyle(color: Colors.indigo),),
          leading: IconButton(icon: Icon(Icons.close, color: Colors.indigo,), onPressed: ()=> Navigator.pop(context)),
          actions: [
            IconButton(icon: Icon(Icons.check, color: Colors.indigo,), onPressed: _kaydet),
          ],
    ),
      body: ListView(
        children: [
          _yukleniyor ? LinearProgressIndicator() : SizedBox(height: 0.0,),
         _profilFoto(),
          _profilinBilgileri(),
        ],
      ),
    );
  }

  _kaydet() async{
    if(_formKey.currentState.validate()){
      setState(() {
        _yukleniyor = true;
      });
      _formKey.currentState.save();

      String profilFoto;
      if(_secilenFoto == null){
        profilFoto = widget.profile.foto;
      }else{
       profilFoto = await StorageServisi().profilResmiYukle(_secilenFoto);
      }
      String aktifKullaniciId = Provider.of<BenimAuthServisim>(context, listen: false).aktifKullaniciId;
      FireStoreServisi().kullaniciGuncelle(
        kullaniciId: aktifKullaniciId,
        kullaniciAdi: _kullaniciAdi,
        hakkinda: _hakkinda,
        foto: profilFoto,
      );
      setState(() {
        _yukleniyor = false;
      });
      Navigator.pop(context);
    }
  }

  _profilFoto(){
    return Padding(
        padding: const EdgeInsets.only(top: 15.0, bottom:20.0),
      child: Center(
        child: InkWell(
      onTap: _galeridenSec,
      child: CircleAvatar(
        backgroundColor: Colors.blue[50],
        backgroundImage: _secilenFoto == null ? NetworkImage(widget.profile.foto) : FileImage(_secilenFoto),
        radius: 80.0,
      ),
      ),
      ),
    );
  }
  _galeridenSec() async{
    var image = await ImagePicker().getImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800, imageQuality: 80);
    setState(() {
      _secilenFoto = File(image.path);
    });
  }
  _profilinBilgileri(){
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
    child:Form(
      key: _formKey,
    child: Column(
      children: [
        SizedBox(height: 20.0,),
        TextFormField(
          initialValue: widget.profile.kullaniciAdi,
          decoration: InputDecoration(
            labelText: "Kullanıcı Adı"
          ),
          validator: (girilenDeger){
            return girilenDeger.trim().length <= 5 ? "Kullanıcı adı en az 5 karakterden oluşmalıdır!": null;
          },
          onSaved: (girilenDeger){
            _kullaniciAdi = girilenDeger;
          },
        ),
        TextFormField(
          initialValue: widget.profile.hakkinda,
          decoration: InputDecoration(
              labelText: "Hakkında"
          ),
          validator: (girilenDeger){
            return girilenDeger.trim().length >100 ? "Hakkında kısmı en fazla 100 karakterdir" : null;
          },
          onSaved: (girilenDeger){
            _hakkinda = girilenDeger;
          },
        ),
      ],
    ),
    ),
    );
  }
}
