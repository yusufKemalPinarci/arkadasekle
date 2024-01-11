import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'başkaprofil.dart';
import 'formfield.dart';
import 'kayitpage.dart';
import 'main.dart';

class GonderilenIstekSayfasi extends StatefulWidget {
  const GonderilenIstekSayfasi({Key? key}) : super(key: key);

  @override
  State<GonderilenIstekSayfasi> createState() => _GonderilenIstekSayfasiState();
}

class _GonderilenIstekSayfasiState extends State<GonderilenIstekSayfasi> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> arkadaslar = [];

  @override
  Future<void> getArkadasIstekListesi() async {
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(userId).get();
    List<dynamic> arkadaslarList = userSnapshot['GonderilenIstek'] ?? [];
    setState(() {
      arkadaslar = arkadaslarList.cast<String>();
    });
  }

  Future<void> ArkadasIstekKaldir(String friendId) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    DocumentReference userRef = _firestore.collection('users').doc(userId);
    // Mevcut arkadaşlar listesini al
    DocumentSnapshot userSnapshot = await userRef.get();
    List<dynamic> currentFriends = userSnapshot['arkadasIstekleri'];

    // İlgili arkadaşı kaldır
    currentFriends.remove(friendId);

    // Güncellenmiş arkadaşlar listesini Firestore'a yaz
    await userRef.update({'arkadasIstekleri': currentFriends});
  }

  Future<void> ArkadasIstekGonderKaldir(String friendId) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    DocumentReference userRef = _firestore.collection('users').doc(userId);
    DocumentReference userRef2 = _firestore.collection('users').doc(friendId);
    // Mevcut arkadaşlar listesini al
    DocumentSnapshot userSnapshot = await userRef.get();
    DocumentSnapshot userSnapshot2 = await userRef2.get();
    List<dynamic> currentFriends = userSnapshot['GonderilenIstek'];
    List<dynamic> currentFriends2 = userSnapshot2['arkadasIstekleri'];

    // İlgili arkadaşı kaldır
    currentFriends.remove(friendId);
    currentFriends2.remove(userId);

    // Güncellenmiş arkadaşlar listesini Firestore'a yaz
    await userRef.update({'GonderilenIstek': currentFriends});
    await userRef2.update({'arkadasIstekleri': currentFriends2});

  }

  @override
  void initState() {
    getArkadasIstekListesi();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gönderilen İstekler',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: getArkadasIstekListesi,
        child: ListView.builder(
          itemCount: arkadaslar.length,
          itemBuilder: (context, index) {
            String arkadasId = arkadaslar[index];
            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(arkadasId).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(title: Text('Yükleniyor...'));
                } else if (snapshot.hasError) {
                  return ListTile(title: Text('Hata: ${snapshot.error}'));
                } else {
                  String arkadasIsim = snapshot.data?['isim'] ?? '';
                  String arkadasResimUrl = snapshot.data?['imageUrl'] ?? '';
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BaskaProfil(
                            arkadasId: arkadasId,
                            ArkadasIsim: arkadasIsim,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(arkadasResimUrl),
                          ),
                          title: Text(
                            arkadasIsim,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FloatingActionButton(
                                mini: true,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title:
                                            Text("Arkadaş isteğini Geri çek"),
                                        content: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Spacer(),
                                            ElevatedButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  ArkadasIstekGonderKaldir(
                                                      arkadasId);
                                                });
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 8.0),
                                                child: Text("Evet"),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 8.0),
                                                child: Text("Hayır"),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Icon(Icons.arrow_back),
                              ),
                              SizedBox(width: 20)
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
