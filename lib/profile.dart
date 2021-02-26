import 'package:flutter/material.dart';
import 'package:flutter_app7/gonderiKarti.dart';
import 'package:flutter_app7/models/kullanici.dart';
import 'package:flutter_app7/profiliDuzenle.dart';
import 'package:flutter_app7/services/benimServisim.dart';
import 'package:flutter_app7/services/firestore.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'models/gonderi.dart';

class Profile extends StatefulWidget {
  final String profilId;

  const Profile({Key key, this.profilId}) : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}
class _ProfileState extends State<Profile>{
  int _gonderiSayisi = 0;
  int _takipci = 0;
  int _takipedilen = 0;
  List<Gonderi> _gonderiler = [];
  String gonderiBoyutu = "liste";
  String _aktifKullaniciId;
  Kullanici _profilSahibi;
  bool _takipEdildi = false;

  _takipciSayisiGetir() async {
    int takipciSayisi = await FireStoreServisi().takipciSayisi(widget.profilId);
    if (mounted) {
      setState(() {
        _takipci = takipciSayisi;
      });
    }
  }

  _takipedilenSayisiGetir() async {
    int takipedilenSayisi = await FireStoreServisi().takipedilenSayisi(
        widget.profilId);
    if (mounted) {
      setState(() {
        _takipedilen = takipedilenSayisi;
      });
    }
  }
  _gonderileriGetir() async {
    List<Gonderi> gonderiler = await FireStoreServisi().gonderileriGetir(
        widget.profilId);
    if (mounted) {
      setState(() {
        _gonderiler = gonderiler;
        _gonderiSayisi = _gonderiler.length;
      });
    }
  }
  _takipKontrol() async {
    bool takipVarMi = await FireStoreServisi().takipKontrol(profilId: widget.profilId, aktifKullaniciId: _aktifKullaniciId);
    setState(() {
      _takipEdildi = takipVarMi;
    });
  }

  @override
  void initState() {
    super.initState();
    _takipciSayisiGetir();
    _takipedilenSayisiGetir();
    _gonderileriGetir();
    _aktifKullaniciId = Provider.of<BenimAuthServisim>(context, listen: false).aktifKullaniciId;
    _takipKontrol();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("Damingo", style: TextStyle(fontSize: 20.0, color: Colors.indigo[900]),),
        backgroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.exit_to_app, color: Colors.indigo,), onPressed: _cikisYap)
        ],
        iconTheme: IconThemeData(
          color: Colors.indigo,
        ),
      ),
      body: FutureBuilder<Object>(
        future: FireStoreServisi().kullaniciGetir(widget.profilId),
        builder: (context, snapshot) {

          if(!snapshot.hasData){
             return Center(child: CircularProgressIndicator());
             }
          _profilSahibi = snapshot.data;


        return ListView(
        children: [
              _profilSayfasi(snapshot.data),
              _gonderileriGoster(snapshot.data),
        ],
         );
        }
        ),
    );
  }

  Widget _gonderileriGoster(Kullanici profilData){
  if(gonderiBoyutu == "liste"){
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: _gonderiler.length,
        itemBuilder: (context, index){
          return GonderiKarti(gonderi: _gonderiler[index], yayinlayan: profilData,);
        });
  }else {
    List<GridTile> fayanslar = [];
    _gonderiler.forEach((gonderi) {
      fayanslar.add(_fayansOlustur(gonderi));
    });

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      mainAxisSpacing: 2.0,
      crossAxisSpacing: 2.0,
      childAspectRatio: 1.0,
      physics: NeverScrollableScrollPhysics(),
      children: fayanslar,
    );
  }
  }

  GridTile _fayansOlustur(Gonderi gonderi){
    return GridTile(child: Image.network(gonderi.gonderiResmiUrl, fit: BoxFit.cover,));
  }

  Widget _profilSayfasi(Kullanici profilData) {
    return Padding(
        padding: const EdgeInsets.all(15.0),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 50.0,
              backgroundImage: profilData.foto.isNotEmpty ? NetworkImage(profilData.foto) : AssetImage("assets/logo.jpg"),
            ),
           Expanded(
           child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _takip(baslik: "Gönderiler", takipler: _gonderiSayisi),
                _takip(baslik: "Takipçi", takipler: _takipci),
                _takip(baslik: "Takip", takipler: _takipedilen),
              ],
            ),
           ),
          ],
        ),
        SizedBox(height: 10.0,),
        Text(
          profilData.kullaniciAdi,
          style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold
          ),
        ),
        SizedBox(height: 5.0,),
        Text(
          profilData.hakkinda,
          style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold
          ),
        ),
        SizedBox(height: 5.0,),
        widget.profilId == _aktifKullaniciId ? _profiliDuzenle() : _takipButonu(),
      ],),
    );
  }

  Widget _takipButonu(){
    return _takipEdildi ? _takiptenCikButonu() : _takipEtButonu();

  }
  Widget _takipEtButonu(){
    return Container(
      width: double.infinity,
      child: FlatButton(
        color: Colors.white,
        onPressed: (){
           FireStoreServisi().takipEt(profilId: widget.profilId, aktifKullaniciId: _aktifKullaniciId);
           setState(() {
             _takipEdildi = true;
             _takipci = _takipci +1;
           });
        },
        child: Text("Takip Et", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
      ),
    );
  }
  Widget _takiptenCikButonu(){
    return Container(
      width: double.infinity,
      child: OutlineButton(
        onPressed: (){
         FireStoreServisi().takiptenCik(profilId: widget.profilId, aktifKullaniciId: _aktifKullaniciId);
         setState(() {
           _takipEdildi = false;
           _takipci = _takipci -1;
         });
        },
        child: Text("Takipten Çık", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
      ),
    );
  }


  Widget _profiliDuzenle(){
    return Container(
        width: double.infinity,
        child: OutlineButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfiliDuzenle(profile: _profilSahibi,)));
        },
          child: Text("Profili Düzenle"),
          ),
          );
        }

  Widget _takip({String baslik, int takipler}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
            baslik,
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            )
        ),
        SizedBox(height: 1.0,),
        Text(
            takipler.toString(),
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            )
        )
      ],
    );
  }
  void _cikisYap(){
    Provider.of<BenimAuthServisim>(context, listen: false).cikisYap();
  }
}