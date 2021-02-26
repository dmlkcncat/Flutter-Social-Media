
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app7/models/yorum.dart';
import 'package:flutter_app7/services/benimServisim.dart';
import 'package:flutter_app7/services/firestore.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'models/gonderi.dart';
import 'models/kullanici.dart';

class Yorumlar extends StatefulWidget {
  final Gonderi gonderi;

  const Yorumlar({Key key, this.gonderi}) : super(key: key);
  @override
  _YorumlarState createState() => _YorumlarState();
}

class _YorumlarState extends State<Yorumlar> {
  TextEditingController _yorumKontrol = TextEditingController();

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Yorumlar", style: TextStyle(color: Colors.indigo),),
        iconTheme: IconThemeData(
         color: Colors.indigo,
      ),
      ),
      body: Column(
        children: [
          _yorumlariGoster(),
          _yorumEkle(),
        ],
      ) ,
    );
  }

  _yorumlariGoster(){
    return Expanded( child: StreamBuilder<QuerySnapshot>(
      stream: FireStoreServisi().yorumlariGetir(widget.gonderi.id),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index){
              Yorum yorum = Yorum.dokumandanUret(snapshot.data.documents[index]);
              return _yorumSatiri(yorum);
            });
      },
    ),
    );
  }

  _yorumSatiri(Yorum yorum){
    return FutureBuilder<Kullanici>(
        future: FireStoreServisi().kullaniciGetir(yorum.yayinlayanId),
         builder: (context, snapshot) {
          if(!snapshot.hasData){
            return SizedBox(height: 0.0,);
          }
          Kullanici yayinlayan = snapshot.data;
          return ListTile(
             leading: CircleAvatar(
                backgroundColor: Colors.blue[50],
                backgroundImage: NetworkImage(yayinlayan.foto),
         ),
        title: RichText(
           text: TextSpan(
              text: yayinlayan.kullaniciAdi + "  ",
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.indigo),
                children: [
                   TextSpan(
                       text: yorum.aciklama,
                       style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14.0, color: Colors.black ),
               )
             ]
             ),
            ),
            subtitle: Text(timeago.format(yorum.olusturulmaZamani.toDate(), locale: "tr")),
         );
       }
    );
  }

  _yorumEkle(){
    return ListTile(
      title: TextFormField(
        controller: _yorumKontrol,
        decoration: InputDecoration(
          hintText: "Yorumu buruya yazınız",
        ),
      ),
      trailing: IconButton(icon: Icon(Icons.send), onPressed: _yorumGonder),
    );
  }

  void _yorumGonder(){
    String aktifKullaniciId = Provider.of<BenimAuthServisim>(context, listen: false).aktifKullaniciId;
    FireStoreServisi().yorumEkle(aktifKullaniciId: aktifKullaniciId, gonderi: widget.gonderi, aciklama: _yorumKontrol.text);
    _yorumKontrol.clear();
  }
}
