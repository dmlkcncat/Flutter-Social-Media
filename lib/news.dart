import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app7/profile.dart';
import 'package:flutter_app7/services/benimServisim.dart';
import 'package:flutter_app7/services/firestore.dart';
import 'package:flutter_app7/tekliGonderi.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'models/kullanici.dart';
import 'models/new.dart';

class News extends StatefulWidget {
  @override
  _NewsState createState() => _NewsState();
}
class _NewsState extends State<News> {
  List<New> _haberler;
  String _aktifKullaniciId;
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _aktifKullaniciId = Provider.of<BenimAuthServisim>(context, listen: false).aktifKullaniciId;
    newGetir();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }
  newGetir() async {
    List<New> haberler = await FireStoreServisi().newGetir(_aktifKullaniciId);
    if(mounted) {
      setState(() {
        _haberler = haberler;
        _yukleniyor = false;
      });
    }
  }

  newGoster(){
   if(_yukleniyor){
     return Center(child: CircularProgressIndicator());
   }
   if(_haberler.isEmpty){
     return Center(child: Text("Henüz hiç yeni new yok!"));
   }
   return Padding(
       padding: const EdgeInsets.only(top: 12.0),
       child: ListView.builder(
       itemCount: _haberler.length,
       itemBuilder: (context, index){
         New duyuru = _haberler[index];
         return duyuruSatiri(duyuru);
       }
       ),
      );
  }

  duyuruSatiri(New duyuru){
   String mesaj = mesajOlustur(duyuru.hamleTipi);
   return FutureBuilder(
     future: FireStoreServisi().kullaniciGetir(duyuru.hamleYapanId),
     builder: (context, snapshot){
       if(!snapshot.hasData){
         return SizedBox(height: 0.0,);
       }
      Kullanici hamleYapan = snapshot.data;
       return ListTile(
         leading: InkWell(
           onTap: () {
             Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile(profilId: duyuru.hamleYapanId,)));
           },
         child: CircleAvatar(
           backgroundImage: NetworkImage(hamleYapan.foto),
         ),
         ),
         title: RichText(
         text: TextSpan(
           recognizer: TapGestureRecognizer()..onTap=(){
             Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile(profilId: duyuru.hamleYapanId,)));
           },
         text: "${hamleYapan.kullaniciAdi}",
         style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
         children: [
           TextSpan(text: duyuru.yorum == null ? "  $mesaj " : " $mesaj ${duyuru.yorum}", style: TextStyle(fontWeight: FontWeight.normal)),
         ]
            ),
         ),
         subtitle: Text(timeago.format(duyuru.olusturulmaZamani.toDate(), locale: "tr")),
         trailing: gonderiGorsel(duyuru.hamleTipi, duyuru.gonderiFoto, duyuru.gonderiId),
       );
     }
   );
  }

  gonderiGorsel(String hamleTipi, String gonderiFoto, String gonderiId)
  {
    if(hamleTipi == "takip"){
      return null;
    }else if(hamleTipi == "begeni" || hamleTipi == "yorum"){
      return GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => TekliGonderi(gonderiId: gonderiId, gonderiSahibiId: _aktifKullaniciId,)));
      },
      child: Image.network(gonderiFoto, width: 60.0, fit: BoxFit.cover,)
      );
    }
  }

  mesajOlustur(String hamleTipi){
    if(hamleTipi == "begeni"){
      return "gönderini beğendi";
    }else if(hamleTipi == "takip"){
      return "seni takip etti";
    }else if(hamleTipi == "yorum"){
      return "gönderine yorum yaptı";
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[50],
        title: Text(
          "News",
          style: TextStyle(color: Colors.indigo),
        ),
      ),
      body: newGoster(),
    );
  }
}