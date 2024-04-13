import 'package:arkadasekle/firebase_service.dart';
import 'package:arkadasekle/ui/pages/konusmalistele.dart';
import 'package:arkadasekle/mesajmodel.dart';

import 'package:arkadasekle/ui/pages/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:arkadasekle/kisilerliste.dart';

import 'baska_profile.dart';
import 'ui/pages/mesajpage.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class User {
  String isim = "";
  final String email;
  final String sifre;
  String imageUrl = "";
  List<User> arkadaslar = [];
  List<User> GonderilenIstek = [];
  List<User> bizdenGonderilenIstekler = [];
  List<User> resimler = [];
  List<User> videolar=[];
  List<User> hikayeler=[];
  bool hesapGizli;

  User(
      this.isim,
      this.email,
      this.sifre,
      this.imageUrl,
      this.arkadaslar,
      this.resimler,
      this.videolar,
      this.hikayeler,
      this.hesapGizli,
      this.GonderilenIstek,
      this.bizdenGonderilenIstekler);

  // Firestore için Map'e dönüştürme metodunu tanımlayın
  Map<String, dynamic> toMap() {
    return {
      'isim': isim,
      'email': email,
      'sifre': sifre,
      'imageUrl': imageUrl,
      'arkadaslar': arkadaslar,
      'GonderilenIstek': GonderilenIstek,
      'bizdenGonderilenIstekler': bizdenGonderilenIstekler,
      'resimler': resimler,
      'videolar':videolar,
      'hesapGizli': hesapGizli
    };
  }
}

Future<void> saveUserToFirestore(User user, String userId) async {
  try {
    // Firestore instance'ını alın
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Firestore'da bir koleksiyon referansı alın
    CollectionReference usersCollection = firestore.collection('users');

    // Sınıfı Map'e dönüştürün
    Map<String, dynamic> userData = user.toMap();

    // Koleksiyona yeni bir belge ekleyin
    await usersCollection.doc(userId).set(userData);

    print('Kullanıcı başarıyla Firestorea kaydedildi.');
  } catch (e) {
    print('Firestore kaydetme hatası: $e');
  }
}

UserOlustur(
  String isim,
  String _email,
  String _sifre,
  String imageUrl,
  bool hesapGizli,
) async {
  UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
    email: _email,
    password: _sifre,
  );
  print(userCredential.user?.uid);
  User yeniUser =
      User(isim, _email, _sifre, imageUrl, [], [], [],[],hesapGizli, [], []);
  userId = userCredential.user?.uid;

  return yeniUser;
}

void arkadasEkle(String userId, User yeniArkadas) async {
  // Firestore koleksiyon referansını alın
  DocumentReference userRef =
      FirebaseFirestore.instance.collection('users').doc(userId);

  // Kullanıcının arkadaşlar listesine yeni arkadaşı ekleyin
  await userRef.update({
    'arkadaslar': FieldValue.arrayUnion([yeniArkadas.toMap()]),
  });
}

List<QueryDocumentSnapshot> searchResults = [];

class CustomSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Arama çubuğunun solundaki widget'ları oluşturun
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Arama sonuçlarını görüntüleyen widget'ı döndürün
    return ListView.builder(
      itemCount: userList.length,
      itemBuilder: (BuildContext context, int index) {
        // Kullanıcı adını kontrol edin ve query ile eşleşiyorsa ekrana yazdırın
        String isim = userList[index]['isim'];
        if (isim.toLowerCase().contains(query.toLowerCase())) {
          return ListTile(
            title: Text(isim),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BaskaProfile(
                    arkadasId: userList[index].id,
                    isim: userList[index]["isim"],
                  ),
                ),
              );
              // Tıklanan öğe ile ilgili bir işlem yapın
            },
          );
        } else {
          return SizedBox.shrink(); // Eşleşmeyen öğeleri gizleyin
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Arama önerilerini görüntüleyen widget'ı döndürün
    return ListView.builder(
      itemCount: userList.length,
      itemBuilder: (BuildContext context, int index) {
        // Kullanıcı adını ekrana yazdırın
        String isim = userList[index]['isim'];
        return ListTile(
          title: Text(isim),
          onTap: () {
            // Arama sonuçlarını güncelleyin ve arama işlemini başlatın
            query = isim;
            showResults(context);
          },
        );
      },
    );
  }
}

class CustomSearchDelegate2 extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Arama çubuğunun solundaki widget'ları oluşturun
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget buildResults(BuildContext context) {
    // Arama sonuçlarını görüntüleyen widget'ı döndürün
    return ListView.builder(
      itemCount: Konusmalar1.length,
      itemBuilder: (context, index) {
        String arkadasId = Konusmalar1[index];
        return FutureBuilder<int>(
          future: getOkunmamiMesajSayisi(arkadasId),
          builder: (context, snapshot) {
            int sayi = snapshot.data ?? 0;
            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(arkadasId).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(title: Text('Yükleniyor...'));
                } else if (snapshot.hasError) {
                  return ListTile(title: Text('Hata: ${snapshot.error}'));
                } else {
                  String arkadasIsim = snapshot.data?['isim'] ?? '';
                  if (arkadasIsim.toLowerCase().contains(query.toLowerCase())) {
                    return Card(
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ListTile(
                          leading: CircleAvatar(
                              child: Text(
                            sayi.toString(),
                          )),
                          title: Text(
                            arkadasIsim,
                          ),
                          trailing: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MesajPage(
                                    arkadasId: arkadasId,
                                    ArkadasIsim: arkadasIsim,
                                  ),
                                ),
                              );
                            },
                            child: Image.asset("assets/images/send.png"),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Arama önerilerini görüntüleyen widget'ı döndürün
    return ListView.builder(
      itemCount: Konusmalar1.length,
      itemBuilder: (BuildContext context, int index) {
        // Kullanıcı adını ekrana yazdırın
        String arkadasId = Konusmalar1[index];
        return FutureBuilder(
            future: _firestore.collection('users').doc(arkadasId).get(),
            builder: (context, snapshot) {
              String arkadasIsim = snapshot.data?['isim'] ?? '';
              return ListTile(
                title: Text(arkadasIsim),
                onTap: () {
                  // Arama sonuçlarını güncelleyin ve arama işlemini başlatın
                  query = arkadasIsim;
                  showResults(context);
                },
              );
            });
      },
    );
  }
}
