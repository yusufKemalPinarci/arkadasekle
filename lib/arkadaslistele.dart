import 'package:arkadasekle/arkadasistekleri.dart';
import 'package:arkadasekle/ba%C5%9Fkaprofil.dart';
import 'package:arkadasekle/formfield.dart';
import 'package:arkadasekle/kayitpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'gonderilenisteksayfasi.dart';
import 'mesajpage.dart';

class ArkadasListele extends StatefulWidget {
  @override
  _ArkadasListeleState createState() => _ArkadasListeleState();
}

class _ArkadasListeleState extends State<ArkadasListele> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> arkadaslar = [];

  @override
  void initState() {
    super.initState();
    getArkadasListesi();
  }




  Future<void> getArkadasListesi() async {
    DocumentSnapshot userSnapshot =
    await _firestore.collection('users').doc(userId).get();
    List<dynamic> arkadaslarList = userSnapshot['arkadaslar'] ?? [];
    setState(() {
      arkadaslar = arkadaslarList.cast<String>();
    });
  }


  Future<void> removeFriend(String friendId) async {
    DocumentReference userRef = _firestore.collection('users').doc(userId);
    DocumentReference userRef2 = _firestore.collection('users').doc(friendId);

    // Mevcut arkadaşlar listesini al
    DocumentSnapshot userSnapshot = await userRef.get();
    DocumentSnapshot userSnapshot2 = await userRef2.get();
    List<dynamic> currentFriends = userSnapshot['arkadaslar'];
    List<dynamic> currentFriends2 = userSnapshot2['arkadaslar'];

    // İlgili arkadaşı kaldır
    currentFriends.remove(friendId);
    currentFriends2.remove(userId);

    // Güncellenmiş arkadaşlar listesini Firestore'a yaz
    await userRef.update({'arkadaslar': currentFriends});
    await userRef2.update({'arkadaslar': currentFriends2});

  }




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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildDrawer(context),
      appBar: AppBar(
        title: Text(
          'Arkadaşlar',
        ),actions: [Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GonderilenIstekSayfasi()),
            );
          },
          child:Icon(Icons.person_pin) ,
                ),
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArkadasIstekleriSayfasi()
              ),
            );


          }, child: Icon(Icons.person_add)),
        ),
      ],
      ),
      body: RefreshIndicator(
        onRefresh: getArkadasListesi,
        child: ListView.builder(
          itemCount: arkadaslar.length,
          itemBuilder: (context, index) {
            String arkadasId = arkadaslar[index];
            print(arkadasId);

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
                      String arkadasResimUrl=snapshot.data?['imageUrl']??'';
                      return InkWell(onTap: (){
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
                            padding: const EdgeInsets.only(top: 10,bottom: 10),
                            child: ListTile(leading:CircleAvatar(radius: 40,backgroundImage: NetworkImage(arkadasResimUrl), ),
                              title: Text(
                                arkadasIsim,
                              ),
                              trailing: Row(mainAxisSize: MainAxisSize.min,
                                children: [
                                  FloatingActionButton(
                                    mini: true,
                                    onPressed: () {
                                     showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Arkadaşlıktan çıkarmak istiyor musun?"),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                InkWell(
                                                  onTap: () async {

                                                    Navigator.of(context).pop();

                                                    removeFriend(arkadasId);
                                                    await getArkadasListesi();
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(
                                                        vertical: 8.0),
                                                    child: Text(
                                                        "Evet"),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
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
                                    child: Icon(Icons.remove),
                                  ),SizedBox(width: 20)
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
