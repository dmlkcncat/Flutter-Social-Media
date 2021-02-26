
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app7/giris.dart';
import 'package:flutter_app7/kesfet.dart';
import 'package:flutter_app7/load.dart';
import 'package:flutter_app7/news.dart';
import 'package:flutter_app7/profile.dart';
import 'package:flutter_app7/services/benimServisim.dart';
import 'package:provider/provider.dart';

class AnaSayfa extends StatefulWidget {
  @override
  _AnaSayfaState createState() => _AnaSayfaState();
}
class _AnaSayfaState extends State<AnaSayfa> {
  int _sayac=0;
  PageController gecis;

  @override
  void initState(){
    super.initState();
    gecis = PageController();
  }

   @override
   void dispose() {
     gecis.dispose();
     super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String aktifKullaniciId = Provider.of<BenimAuthServisim>(context, listen: false).aktifKullaniciId;
    return Scaffold(
      body: PageView(
        onPageChanged: (sayfa){
          setState(() {
            _sayac = sayfa;
          });
        },
        controller: gecis,
        children: [
          Giris(),
          Kesfet(),
          Load(),
          News(),
          Profile(profilId: aktifKullaniciId,),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _sayac,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.indigo,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.insert_photo_sharp ), label: "Damingo"),
            BottomNavigationBarItem(icon: Icon(Icons.add_photo_alternate_outlined ), label: "Load"),
            BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined), label: "News"),
            BottomNavigationBarItem(icon: Icon(Icons.face_sharp ), label: "Profile"),
          ],
        onTap: (sayfa){
            setState(() {
              gecis.jumpToPage(sayfa);
            });
        },
      ),
    );
  }
}

