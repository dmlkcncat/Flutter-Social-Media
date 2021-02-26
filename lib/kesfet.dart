import 'package:flutter/material.dart';
import 'package:flutter_app7/profile.dart';
import 'package:flutter_app7/services/firestore.dart';
import 'package:flutter_app7/models/kullanici.dart';

class Kesfet extends StatefulWidget {
  @override
  _KesfetState createState() => _KesfetState();
}
class _KesfetState extends State<Kesfet>{
  TextEditingController _kesfetController = TextEditingController();
  Future<List<Kullanici>> _aramaSonucu;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarOlustur(),
      body: _aramaSonucu != null ? sonuclariGetir() : aramaYok(),
    );
  }
  AppBar _appBarOlustur() {
    return AppBar(
      backgroundColor: Colors.blue[50],
      title: TextFormField(
        onFieldSubmitted: (girilenDeger){
          setState(() {
            _aramaSonucu = FireStoreServisi().kullaniciAra(girilenDeger);
          });
        },
        controller: _kesfetController,
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, size: 30.0,),
            suffixIcon: IconButton(icon: Icon(Icons.clear), onPressed: () {
              _kesfetController.clear();
               setState(() {
              _aramaSonucu = null;
               });
           }),
    hintText: "Kullanıcı Ara..",
            contentPadding: EdgeInsets.only(top:16.0),
        ),
      ),
    );
  }
  aramaYok(){
    return Center(child: Text("Kullanıcı ara"));
  }
  sonuclariGetir(){
    return FutureBuilder<List<Kullanici>>(
      future: _aramaSonucu,
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return Center(child: Text("Bu arama için sonuç bulunamadı!"));
        }
        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context, index){
            Kullanici kullanici = snapshot.data[index];
            return kullaniciSatiri(kullanici);
          }
        );
      }
    );
  }

  kullaniciSatiri(Kullanici kullanici){
    return GestureDetector(
        onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(profilId: kullanici.id,)));
        },
         child: ListTile(
           leading: CircleAvatar(
                 backgroundImage: NetworkImage(kullanici.foto),
             ),
      title: Text(kullanici.kullaniciAdi, style: TextStyle(fontWeight: FontWeight.bold),),
       ),
     );
  }
}
