import 'package:arkadasekle/konusmalistele.dart';
import 'package:arkadasekle/formfield.dart';
import 'package:arkadasekle/kayitpage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'başkaprofil.dart';


class KisilerListele extends StatefulWidget {
  @override
  State<KisilerListele> createState() => _KisilerListeleState();
}

class _KisilerListeleState extends State<KisilerListele> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance; // Add this line

  List<QueryDocumentSnapshot> userList = []; // Kullanıcı listesi
  bool hesapGizli =true;

  String? token2;
  @override
  void initState() {
    super.initState();
    getUsers(); // Kullanıcıları al
  }
  Future<bool> HesapGizliMi(String friendId) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(friendId)
        .get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
      bool hesapGizli = userData['hesapGizli'] ?? false;
      return hesapGizli;
    } else {
      print('Document does not exist for friendId: $friendId');
      return false; // or handle it according to your use case
    }
  }

  Future<void> sendNotification(String token2) async {
    if (token2 != null) {
      print ("mesaj gönderme alanına girdi");
      await _firebaseMessaging
          .sendMessage(
        to: token2,
        data: {
          'title': 'Arkadaşlık İsteği',
          'body': 'Yeni bir arkadaşlık isteği var!',
          'senderId': userId.toString(),
        },
      )
          .catchError((error) {
        print('Error sending notification: $error');
      });
    }
  }

  Future<String?> _getToken(String friendId) async {
    DocumentSnapshot userSnapshot =
    await _firestore.collection('users').doc(friendId).get();
    return userSnapshot['token'];
  }




  List<dynamic> GonderilenIstekler=[];
  void getUsers() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(userId).get();
    if (userSnapshot.exists ) {
      var docData = userSnapshot.data() as Map<String, dynamic>;
      if (docData!.containsKey('GönderilenIstek')) {
        GonderilenIstekler = userSnapshot['GonderilenIstek'] ?? [];

      }
      setState(() {
        userList = snapshot.docs
            .where((doc) => doc.id != userId && !GonderilenIstekler.contains(doc.id))
            .toList();
      });
    } else {
      print('Kullanıcı bulunamadı: $userId');
    }
  }


  Future<void> arkadasIstekEkle(String friendId) async {
    DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(userId).get();
    DocumentSnapshot userSnapshot2 = await _firestore.collection('users').doc(friendId).get();

    if (userSnapshot.exists && userSnapshot2.exists) {
      // If 'GonderilenIstek' field doesn't exist, create it
      var docData = userSnapshot.data() as Map<String, dynamic>;
      List<dynamic> bizimIstek = docData.containsKey('GonderilenIstek') ? docData['GonderilenIstek'] : [];

      // If 'arkadasIstekleri' field doesn't exist, create it
      var docData2 = userSnapshot2.data() as Map<String, dynamic>;
      List<dynamic> gonderilenIstek = docData2.containsKey('arkadasIstekleri') ? docData2['arkadasIstekleri'] : [];

      if (!gonderilenIstek.contains(userId)) {
        gonderilenIstek.add(userId);
        bizimIstek.add(friendId);

        await _firestore.collection('users').doc(friendId).update({
          'arkadasIstekleri': gonderilenIstek,
        });
        await _firestore.collection('users').doc(userId).update({
          'GonderilenIstek': bizimIstek,
        });
        print(token);

         token2=await _getToken(friendId);
        await sendNotification(token2!);
        print('Istek gönderildi: $friendId');
        setState(() {
          userList = userList
              .where((user) => user.id != friendId)
              .toList(); // Arkadaşın listeden kaldırılması
        });
      } else {
        print('Bu kullanıcı zaten arkadaş isteği gönderdiniz: $friendId');
      }
    } else {
      print('Kullanıcı bulunamadı: $userId veya $friendId');
    }
  }



  void arkadasEkle(String friendId) async {
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(userId).get();
    DocumentSnapshot userSnapshot2 =
    await _firestore.collection('users').doc(friendId).get();
    if (userSnapshot.exists) {
      List<dynamic> arkadaslar = userSnapshot['arkadaslar'] ?? [];
      List<dynamic> arkadaslar2 = userSnapshot2['arkadaslar'] ?? [];

      if (!arkadaslar.contains(friendId)) {
        arkadaslar.add(friendId);
        arkadaslar2.add(userId);
        await _firestore.collection('users').doc(userId).update({
          'arkadaslar': arkadaslar,
        });
        await _firestore.collection('users').doc(friendId).update({
          'arkadaslar': arkadaslar2,
        });
        print('Arkadaş eklendi: $friendId');
        print('Arkadaş eklendi: $userId');
        setState(() {
          userList = userList
              .where((user) => user.id != friendId)
              .toList(); // Arkadaşın listeden kaldırılması
        });
      } else {
        print('Bu kullanıcı zaten arkadaşınız: $friendId');
      }
    } else {
      print('Kullanıcı bulunamadı: $userId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => KonusmaListele()
                ),
              );

            }, child: Icon(Icons.message)),
          ),
        ],
        title: Text("Arkadaş Bul"),
      ),
      body: Column(
        children: [
          Expanded(
              child: userList.length == 0
                  ? Container(
                      child: Center(
                        child: Text(
                          "Eklenecek kimse yok dostum :(",
                        ),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: userList.length,
                      itemBuilder: (BuildContext context, int index) {
                        String isim = userList[index]['isim'];
                        return Container(
                          width: 150,
                          height: 200,
                          child: Card(
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BaskaProfil(
                                          arkadasId: userList[index].id,
                                          ArkadasIsim: userList[index]["isim"],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: ClipOval(
                                        child: userList[index]["imageUrl"] != ""
                                            ? Image.network(
                                                userList[index]["imageUrl"],
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Image.network(
                                                    "https://c4.wallpaperflare.com/wallpaper/269/648/952/simple-background-texture-digital-art-textured-wallpaper-preview.jpg",
                                                    fit: BoxFit.cover,
                                                  );
                                                },
                                              )
                                            : CircleAvatar(
                                                child: Icon(Icons.person)),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    isim,
                                  ),
                                ),
                                Spacer(), // Added Spacer to push buttons to the end
                                Padding(
                                  padding: const EdgeInsets.only(right: 14.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.all(8.0)),
                                      ElevatedButton(
                                        child: Icon(Icons.add),
                                        onPressed: () async {
                                          String friendId = userList[index].id;
                                          bool durum= await HesapGizliMi(friendId);
                                          if(durum==true){
                                            await arkadasIstekEkle(friendId);
                                          }

                                          if(durum == false){
                                             arkadasEkle(friendId);
                                          }
                                        },
                                        style: butonstyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )),
        ],
      ),
      drawer: buildDrawer(context),
    );
  }
}
