import 'package:arkadasekle/firebase_service.dart';
import 'package:arkadasekle/model.dart';
import 'package:arkadasekle/ui/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'mesajpage.dart';
import 'register.dart';

class KonusmaListele extends StatefulWidget {
  @override
  _KonusmaListeleState createState() => _KonusmaListeleState();
}

List<String> Konusmalar1 = [];
Future<int> getOkunmamiMesajSayisi(String arkadasId) async {
  String documanId = "";
  QuerySnapshot querySnapshot =
  await FirebaseFirestore.instance.collection('konusmalar').get();
  List<DocumentSnapshot> documents = querySnapshot.docs;
  for (var document in documents) {
    List<dynamic> uyeListesi = document['uyeler'];
    if (uyeListesi.contains(arkadasId) && uyeListesi.contains(userId)) {
      documanId = document.id;
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("konusmalar")
          .doc(documanId)
          .collection("mesajlar")
          .where("okundu", isEqualTo: false).where("senderId",isNotEqualTo: userId)
          .get();
      return querySnapshot.docs.length;
    }
  }
  return 0;
}

class _KonusmaListeleState extends State<KonusmaListele> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String query = '';

  @override
  void initState() {
    super.initState();
    getArkadasListesi();
  }

  Future<void> getArkadasListesi() async {
    // Tüm belgeleri içeren bir referans alın
    CollectionReference arkadaslarCollection = _firestore.collection('konusmalar');
    QuerySnapshot allDocuments = await arkadaslarCollection.get();
    // Arkadaşlar listesini saklayacak bir liste oluşturun
    List<String> Konusmalar = [];
    String myUserId = userId!;
    // Her belgeyi kontrol edin
    for (QueryDocumentSnapshot document in allDocuments.docs) {
      List<dynamic> uyeListesi = document['uyeler'] ?? [];

      // 'uyeler' listesinde kullanıcının kimliği varsa
      if (uyeListesi.contains(myUserId)) {
        uyeListesi.forEach((uye) {
          if (uye != myUserId) {
            Konusmalar.add(uye);
            print(uye);
          }
        });
      }

    }

    setState(() {
      // State'i güncelleyin
      Konusmalar1 = Konusmalar;
      print(Konusmalar1);
    });

  }



  void searchUser(String searchText) {
    setState(() {
      query = searchText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavbar(),
      appBar: AppBar(
        title: Text(
          'Mesajlar',
        ), actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () async {
            final String? result = await showSearch(
              context: context,
              delegate: CustomSearchDelegate2(),
            );
            if (result != null && result.isNotEmpty) {
              searchUser(result);
            }
          },
        ),
      ],
      ),
      body: Konusmalar1.isEmpty
          ? Center(
        child: Text('Hiç mesaj yok!'),
      )
          : RefreshIndicator(
        onRefresh: getArkadasListesi,
        child: ListView.builder(
          itemCount: Konusmalar1.length,
          itemBuilder: (context, index) {
            String arkadasId = Konusmalar1[index];
            return FutureBuilder<int>(
              future: getOkunmamiMesajSayisi(arkadasId),
              builder: (context, snapshot) {
                int sayi = snapshot.data ?? 0;
                return FutureBuilder<DocumentSnapshot>(
                  future:
                  _firestore.collection('users').doc(arkadasId).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return ListTile(title: Text('Yükleniyor...'));
                    } else if (snapshot.hasError) {
                      return ListTile(
                          title: Text('Hata: ${snapshot.error}'));
                    } else {
                      String arkadasIsim = snapshot.data?['isim'] ?? '';
                      return Card(
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ListTile(leading: CircleAvatar(child: Text(sayi.toString(),)),
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
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
