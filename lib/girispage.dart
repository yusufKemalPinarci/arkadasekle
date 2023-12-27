import 'package:arkadasekle/anasayfa2.dart';
import 'package:arkadasekle/kisilerliste.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'formfield.dart';
import 'kayitpage.dart';

class GirisSayfasi extends StatefulWidget {
  const GirisSayfasi({Key? key}) : super(key: key);

  @override
  _GirisSayfasiState createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giriş Yap'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-posta',
              ),
            ),
            TextField(
              controller: _sifreController,
              decoration: InputDecoration(
                labelText: 'Şifre',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center,children: [
              ElevatedButton(style: butonstyle,
                onPressed: () {
                  String email = _emailController.text;
                  String sifre = _sifreController.text;
                  _girisYap(email, sifre);
                },
                child: Text('Giriş Yap'),
              ),
              SizedBox(width: 50,),
              ElevatedButton(style: butonstyle,
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => KayitPage()));
                },
                child: Text('Kayıt Ol'),
              ),

            ],)

          ],
        ),
      ),
    );
  }

  Future<void> _girisYap(String email, String sifre) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: sifre,
      );
      userId = userCredential.user?.uid;


      if (userCredential.user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('user_id',userCredential.user!.uid);

      }


      // Giriş başarılıysa, kullanıcı listeleme sayfasına yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Anasayfa2(),
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hata'),
            content: Text('bu kullanıcı bulunmamaktadır'),
            actions: <Widget>[
              TextButton(
                child: Text('Tamam'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
