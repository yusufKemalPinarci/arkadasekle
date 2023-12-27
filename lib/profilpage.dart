import 'dart:io';

import 'package:arkadasekle/firebase_service.dart';
import 'package:arkadasekle/formfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'kayitpage.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<dynamic> resimler = [];
  String imageUrl = "";
  String profilResmi = "";
  String isim = "";
  bool isLoading = true;
  bool hesapGizli = false;

  getSnapshotFuture() async {
    DocumentSnapshot userSnapshot =
    await FirebaseFirestore.instance.collection("users").doc(userId).get();

    setState(() {
      profilResmi = userSnapshot["imageUrl"];
      isim = userSnapshot["isim"];
      hesapGizli = userSnapshot["hesapGizli"] ?? false;
    });
  }

  @override
  initState() {
    super.initState();
    getSnapshotFuture();
    getResimler();
  }

  getResimler() async {
    DocumentSnapshot userSnapshot =
    await _firestore.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      setState(() {
        resimler = userSnapshot['resimler'] ?? [];
      });
    } else {
      print('Kullanıcı bulunamadı: $userId');
    }
  }

  profilResimEkle(String _imageUrl) async {
    DocumentSnapshot userSnapshot =
    await _firestore.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      await _firestore.collection('users').doc(userId).update({
        'imageUrl': _imageUrl,
      });
      print('resim eklendi: $_imageUrl');
      setState(() {
        profilResmi = _imageUrl;
      });
    } else {
      print('Kullanıcı bulunamadı: $userId');
    }
    setState(() {});
  }

  void resimEkle(String imageUrl) async {
    DocumentSnapshot userSnapshot =
    await _firestore.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      List<dynamic> resimler = userSnapshot['resimler'] ?? [];
      resimler.add(imageUrl);

      await _firestore.collection('users').doc(userId).update({
        'resimler': resimler,
      });

      print('resim eklendi: $imageUrl');
    } else {
      print('Kullanıcı bulunamadı: $userId');
    }
    getResimler();
  }


  Future<void> profilResminiGuncelle(String yeniResimUrl) async {
    // Eski resmi al
    String eskiResimUrl = profilResmi;

    // Eğer eski resim boş değilse, sil
    if (eskiResimUrl.isNotEmpty) {
      await FirebaseService().deleteImageFromStorage(eskiResimUrl);
    }

    // Yeni resmi veritabanına kaydet
    await _firestore.collection('users').doc(userId).update({
      'imageUrl': yeniResimUrl,
    });

    // State'i güncelle
    setState(() {
      profilResmi = yeniResimUrl;
    });
  }


  void profilResmiSil() async {
    DocumentSnapshot userSnapshot =
    await _firestore.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      String currentImageUrl = userSnapshot['imageUrl'];
      if (currentImageUrl.isNotEmpty) {
        // Firestore'dan profil resmini sil
        await _firestore.collection('users').doc(userId).update({
          'imageUrl': FieldValue.delete(),
        });
        print('Profil resmi Firestore\'dan silindi.');

        // Firebase Storage'dan profil resmini sil
        await FirebaseService().deleteImageFromStorage(currentImageUrl);
        print('Profil resmi Firebase Storage\'dan silindi.');

        setState(() {
          profilResmi = "";
        });
      }
    } else {
      print('Kullanıcı bulunamadı: $userId');
    }
  }

  void resmiSil(int index) async {
    DocumentSnapshot userSnapshot =
    await _firestore.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      List<dynamic> resimler = userSnapshot['resimler'] ?? [];
      if (index >= 0 && index < resimler.length) {
        String resimUrl = resimler[index];
        resimler.removeAt(index);

        // Firestore'dan resmi sil
        await _firestore.collection('users').doc(userId).update({
          'resimler': resimler,
        });
        print('Resim Firestore\'dan silindi.');

        // Firebase Storage'dan resmi sil
        await FirebaseService().deleteImageFromStorage(resimUrl);
        print('Resim Firebase Storage\'dan silindi.');

        setState(() {
          this.resimler = resimler;
        });
      }
    } else {
      print('Kullanıcı bulunamadı: $userId');
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(appBar: AppBar(title: Text("Profil sayfası")),
        floatingActionButton:   FloatingActionButton(onPressed: ()async {
          File _imageFile = await pickImage(ImageSource.camera);
          imageUrl = await uploadImage(_imageFile!);
          resimEkle(imageUrl);
        },child: Icon(Icons.add),),
        body: Column(
          children: [
            SizedBox(
              height: 120,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 70,
                        width: 70,
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Profil Resmi"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          Navigator.of(context).pop();
                                          File _imageFile =
                                          await pickImage(
                                              ImageSource.camera);
                                          String _imageUrl =
                                          await uploadImage(_imageFile);
                                          await profilResminiGuncelle(_imageUrl);
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                              "Profil Resmini Güncelle"),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          profilResmiSil();
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text("Profil Resmini Sil"),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: profilResmi != ""
                              ? ClipOval(
                                child: Image.network(
                                  profilResmi,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : CircleAvatar(
                            child: Icon(
                              Icons.person,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: isim != ""
                            ? Text(isim)
                            : CircularProgressIndicator(),
                      ),
                      Spacer(),
                      Switch(
                        value: hesapGizli,
                        onChanged: (value) async {
                          // Toggle the value of hesapGizli
                          await _firestore.collection('users').doc(userId).update({
                            'hesapGizli': value,
                          });
                          setState(() {
                            hesapGizli = value;
                          });
                        },
                      ),
                      Text(hesapGizli ? "Gizli" : "Açık"),

                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 10,
                ),
                itemCount: resimler.length,
                itemBuilder: (BuildContext context, int index) {
                  final reversedIndex = resimler.length - 1 - index;
                  final resimUrl = resimler[reversedIndex];

                  return GestureDetector(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Resmi Sil"),
                            content: Text("Bu resmi silmek istediğinize emin misiniz?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  resmiSil(reversedIndex);
                                },
                                child: Text("Sil"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("İptal"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: resimUrl != ""
                            ? Image.network(resimUrl)
                            : CircularProgressIndicator(),
                      ),
                    ),
                  );
                },
              ),
            ),

          ],
        ),drawer: buildDrawer(context),
      ),
    );
    
  }
}
