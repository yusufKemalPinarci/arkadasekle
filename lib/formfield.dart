import 'package:arkadasekle/akis.dart';
import 'package:arkadasekle/arkadaslistele.dart';
import 'package:arkadasekle/kisilerliste.dart';
import 'package:arkadasekle/mesajmodel.dart';
import 'package:arkadasekle/ui/pages/profile_page.dart';
import 'package:flutter/material.dart';

import 'firebase_service.dart';
import 'girispage.dart';
import 'model.dart';

TextEditingController hakkindaController = TextEditingController();
TextEditingController mesajController = TextEditingController();
TextEditingController yorumController = TextEditingController();
TextEditingController isimController = TextEditingController();
TextEditingController sifreController = TextEditingController();
TextEditingController emailController = TextEditingController();
ButtonStyle butonstyle = ElevatedButton.styleFrom(
    minimumSize: Size(100, 50), maximumSize: Size(110, 100));



class TexthakkindaYazma extends StatelessWidget {
  TexthakkindaYazma({
    required this.labelText,
    super.key,
  });

  String labelText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: hakkindaController,
      decoration: InputDecoration(
          labelText: "$labelText",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)))),
    );
  }
}

class TextMesajYazma extends StatelessWidget {
  TextMesajYazma({
    required this.labelText,
    super.key,
  });

  String labelText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: mesajController,
      decoration: InputDecoration(
          labelText: "$labelText",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)))),
    );
  }
}

class TextYorumYazma extends StatelessWidget {
  TextYorumYazma({
    required this.labelText,
    super.key,
  });

  String labelText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextFormField(

        controller: yorumController,
        decoration: InputDecoration(border:  OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(20))),
          labelText: "$labelText",
        ),
      ),
    );
  }
}





class NormalText extends StatelessWidget {
  NormalText({
    required this.labelText,
    super.key,
  });

  String labelText;

  @override
  Widget build(BuildContext context) {
    return Text(
      labelText,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

Drawer buildDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(100))),
          child: Text('Arkadaş Ekle'),
        ),
        ListTile(
          title: const Text('Akış'),
          leading: Icon(Icons.stream),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FeedPage(),
              ),
            );
          },
        ),
        ListTile(
          title: const Text('Profilin'),
          leading: Icon(Icons.person),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(isim: '',),
              ),
            );
          },
        ),
        ListTile(
          title: const Text('Arkadaş bul'),
          leading: Icon(Icons.person_add),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => KisilerListele(),
              ),
            );
          },
        ),
        ListTile(
          title: const Text('Arkadaşları Listele'),
          leading: Icon(Icons.sentiment_satisfied_alt_outlined),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArkadasListele(),
              ),
            );
          },
        ),
        ListTile(
          title: const Text('Ayarlar'),
          leading: Icon(Icons.settings),
          onTap: () {
            // Update the state of the app

            // Then close the drawer
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('Çıkış Yap'),
          leading: Icon(Icons.login_outlined),
          onTap: () async {
            await signOut();

            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => GirisSayfasi(),
              ),
            );
          },
        ),
      ],
    ),
  );
}
