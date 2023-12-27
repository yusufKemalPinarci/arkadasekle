import 'package:arkadasekle/girispage.dart';
import 'package:arkadasekle/model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'formfield.dart';


class KayitPage extends StatefulWidget {
  const KayitPage({Key? key}) : super(key: key);

  @override
  State<KayitPage> createState() => _KayitPageState();
}

String? userId;
String? token;

class _KayitPageState extends State<KayitPage> {
  String imageUrl = "";
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    /* Future<void> _showPickImageDialog() async {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Resim Yükleme"),
            content: Text("Kameradan mı yoksa galeriden mi seçmek istersiniz?"),
            actions: <Widget>[
              TextButton(
                child: Text("Kamera"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _imageFile=pickImage(ImageSource.camera) as File?;
                },
              ),
              TextButton(
                child: Text("Galeri"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _imageFile=pickImage(ImageSource.gallery) as File?;
                },
              ),
            ],
          );
        },
      );
    }*/

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            SizedBox(
              height: 200,
            ),
            Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Arkadaş Ekle",
                      style:
                          TextStyle(fontSize: 30,),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextisimYazma(labelText: "isim"),
                    SizedBox(
                      height: 30,
                    ),
                    TextEmailYazma(
                      labelText: "email",
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextSifreYazma(
                      labelText: "sifre",
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                        ElevatedButton(style: butonstyle,

                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                try {
                                  var yeniUser = await UserOlustur(
                                      isimController.text,
                                      emailController.text,
                                      sifreController.text,
                                      imageUrl,false);
                                  saveUserToFirestore(yeniUser, userId!);
                                  isimController.text = "";
                                  hakkindaController.text = "";
                                  emailController.text = "";
                                  sifreController.text = "";
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => GirisSayfasi()));
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'weak-password') {
                                    return showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Hata'),
                                          content: Text(
                                              'Güçsüz parola en az 6 haneli olmalı'),
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

                                    print('Güçsüz parola.');
                                  } else if (e.code == 'email-already-in-use') {
                                    return showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Hata'),
                                          content: Text('bu email zaaten var'),
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
                            },
                            child: Text("Kayıt Ol")),
                        SizedBox(width: 50,),
                        ElevatedButton(
                          style: butonstyle,
                            onPressed: () async {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GirisSayfasi()));
                            },
                            child: Text("Giriş yap")),

                      ],),
                    )

                  ]),
            )
          ],
        ),
      ),
    );
  }
}
