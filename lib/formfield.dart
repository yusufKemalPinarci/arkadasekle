import 'package:arkadasekle/akis.dart';
import 'package:arkadasekle/arkadaslistele.dart';
import 'package:arkadasekle/kisilerliste.dart';
import 'package:arkadasekle/mesajmodel.dart';
import 'package:arkadasekle/profilpage.dart';
import 'package:flutter/material.dart';

import 'firebase_service.dart';
import 'girispage.dart';
import 'model.dart';

TextEditingController isimController = TextEditingController();
TextEditingController hakkindaController = TextEditingController();
TextEditingController mesajController = TextEditingController();
TextEditingController emailController = TextEditingController();
TextEditingController sifreController = TextEditingController();
TextEditingController yorumController = TextEditingController();

ButtonStyle butonstyle = ElevatedButton.styleFrom(minimumSize:Size(100,50),maximumSize: Size(110,100));


class TextisimYazma extends StatelessWidget {
  TextisimYazma({
    required this.labelText,
    super.key,
  });

  String labelText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "lütfen isminiz giriniz";
        } else {
          return null;
        }
      },
      controller: isimController,
      decoration: InputDecoration(
          labelText: "$labelText",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)))),
    );
  }
}

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
    return TextFormField(
      controller: yorumController,
      decoration: InputDecoration(
          labelText: "$labelText",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)))),
    );
  }
}

class TextEmailYazma extends StatelessWidget {
  TextEmailYazma({
    required this.labelText,
    super.key,
  });

  String labelText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "lütfen emailinizi giriniz";
        } else {
          return null;
        }
      },
      controller: emailController,
      decoration: InputDecoration(
          labelText: "$labelText",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)))),
    );
  }
}

class TextSifreYazma extends StatelessWidget {
  TextSifreYazma({
    required this.labelText,
    super.key,
  });

  String labelText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: true,
      controller: sifreController,
      decoration: InputDecoration(
          labelText: "$labelText",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)))),
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
    return  Text(labelText,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),);
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
                builder: (context) => ProfilPage(),
              ),
            );
          },
        ),ListTile(
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