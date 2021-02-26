
import 'package:flutter/material.dart';
import 'package:flutter_app7/models/kullanici.dart';
import 'package:flutter_app7/services/benimServisim.dart';
import 'package:flutter_app7/services/firestore.dart';
import 'package:flutter_app7/yorumlar.dart';
import 'package:provider/provider.dart';

import 'models/gonderi.dart';

class GonderiKarti extends StatefulWidget {
  final Gonderi gonderi;
  final Kullanici yayinlayan;

  const GonderiKarti({Key key, this.gonderi, this.yayinlayan}) : super(key: key);

  @override
  _GonderiKartiState createState() => _GonderiKartiState();
}

class _GonderiKartiState extends State<GonderiKarti> {
  int _begeniSayisi = 0;
  bool _begendin = false;
  String _aktifKullaniciId;

  @override
  void initState(){
    super.initState();
    _aktifKullaniciId = Provider.of<BenimAuthServisim>(context, listen: false).aktifKullaniciId;
    _begeniSayisi = widget.gonderi.begeniSayisi;
    begeniVarmi();
  }

  begeniVarmi() async {
    bool begeniVarmi = await FireStoreServisi().begeniVarmi(widget.gonderi, _aktifKullaniciId);
    if(begeniVarmi) {
      if (mounted) {
        setState(() {
          _begendin = true;
        });
      }
    }
    }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          _gonderiBasligi(),
          _gonderiYazi(),
          _gonderiResmi(),
          _gonderiAlt(),
        ],
      ),
    );
  }

  gonderiSecenekleri(){
    showDialog(
        context: context,
        builder: (context){
          return SimpleDialog(
            title: Text("Yapmak istediğiniz işlemi seçiniz"),
            children: [
              SimpleDialogOption(
                child: Text("Gönderiyi Sil"),
                onPressed: (){
                  FireStoreServisi().gonderiSil(aktifKullaniciId: _aktifKullaniciId, gonderi: widget.gonderi);
                  Navigator.pop(context);
                },
              ),
              SimpleDialogOption(
                child: Text("Vazgeç", style: TextStyle(color: Colors.red),),
                onPressed: (){
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }
    );
  }
  Widget _gonderiBasligi() {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: CircleAvatar(
            backgroundColor: Colors.white30,
            backgroundImage: widget.yayinlayan.foto.isNotEmpty ? NetworkImage(widget.yayinlayan.foto) :  AssetImage("assets/logo.jpg"),
          ),
      ),
      title: Text(widget.yayinlayan.kullaniciAdi,
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold,),),
      trailing: _aktifKullaniciId == widget.gonderi.yayinlayanId ? IconButton(icon: Icon(Icons.more_vert), onPressed: ()=> gonderiSecenekleri()) : null,
      contentPadding: EdgeInsets.all(0.0),
    );
  }


  Widget _gonderiYazi() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
       children: [ RichText(
        text: TextSpan(
          text: widget.yayinlayan.kullaniciAdi + " ",
          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.black87),
          children: [
            TextSpan(
              text: widget.gonderi.aciklama,
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16.0,),
            ),
          ],
        ),
      ),
         SizedBox(height: 50.0,),
    ]
      ),
    );
  }

  Widget _gonderiResmi() {
      return GestureDetector(
        onDoubleTap: _begeniDegistir,
          child: Image.network(
      widget.gonderi.gonderiResmiUrl,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width,
      fit: BoxFit.cover,
          ),
    );
  }

  Widget _gonderiAlt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: !_begendin ? Icon(Icons.favorite_border, size: 35.0,): Icon(Icons.favorite, size: 35.0, color: Colors.red,),
              onPressed: _begeniDegistir),
            IconButton(icon: Icon(Icons.comment_outlined, size: 35.0,),
              onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => Yorumlar(gonderi: widget.gonderi,)));
              },),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text("$_begeniSayisi beğeni",
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold,)),
        ),
      ],
    );
  }
  void _begeniDegistir(){
    if(_begendin){
      setState(() {
        _begendin = false;
        _begeniSayisi = _begeniSayisi -1;
      });
      FireStoreServisi().gonderiBegeniKaldir(widget.gonderi, _aktifKullaniciId);
    }else{
      setState(() {
        _begendin = true;
        _begeniSayisi = _begeniSayisi +1;
      });
      FireStoreServisi().gonderiBegen(widget.gonderi, _aktifKullaniciId);
    }
  }
}

