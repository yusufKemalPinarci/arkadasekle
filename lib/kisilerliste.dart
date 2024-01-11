import 'package:arkadasekle/konusmalistele.dart';
import 'package:arkadasekle/formfield.dart';
import 'package:arkadasekle/kayitpage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'başkaprofil.dart';
import 'gonderilenisteksayfasi.dart';

class KisilerListele extends StatefulWidget {
  @override
  State<KisilerListele> createState() => _KisilerListeleState();
}

class _KisilerListeleState extends State<KisilerListele> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance; // Add this line
  List<QueryDocumentSnapshot> userList = []; // Kullanıcı listesi
  bool hesapGizli = true;
  String? token2;
  var arkadaslar;
  var arkadaslar2;

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
      Map<String, dynamic> userData =
      userSnapshot.data() as Map<String, dynamic>;
      bool hesapGizli = userData['hesapGizli'] ?? false;
      return hesapGizli;
    } else {
      print('Document does not exist for friendId: $friendId');
      return false; // or handle it according to your use case
    }
  }

  Future<void> sendNotification(String? token2) async {
    if (token2 != null) {
      print("mesaj gönderme alanına girdi");
      await _firebaseMessaging.sendMessage(
        to: token2,
        data: {
          'title': 'Arkadaşlık İsteği',
          'body': 'Yeni bir arkadaşlık isteği var!',
          'senderId': userId.toString(),
        },
      ).catchError((error) {
        print('Error sending notification: $error');
      });
    } else {
      print('Token2 is null. Cannot send notification.');
    }
  }


  Future<String?> _getToken(String friendId) async {
    DocumentSnapshot userSnapshot =
    await _firestore.collection('users').doc(friendId).get();
    return userSnapshot['token'].toString();
  }

  var bizdenGonderilenIstekler;

  void getUsers() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    DocumentSnapshot userSnapshot =
    await _firestore.collection('users').doc(userId).get();
    arkadaslar = userSnapshot["arkadaslar"];
    arkadaslar2 = userSnapshot["arkadaslar"];
    print(userId);
    print(arkadaslar);
    if (userSnapshot.exists) {
      var docData = await userSnapshot.data() as Map<String, dynamic>;


      bizdenGonderilenIstekler = await userSnapshot['GonderilenIstek'] ?? [];

      setState(() {
        userList = snapshot.docs
            .where((doc) =>
        doc.id != userId &&
            !bizdenGonderilenIstekler.contains(doc.id) &&
            !arkadaslar.contains(doc.id))
            .toList();
        print("user liste uzunlluğu"+userList.length.toString());
      });
    } else {
      print('Kullanıcı bulunamadı: $userId');
    }
  }

  String istekGonderildi = "arkadaş ekle";
  String arkadasEklendiText="arkadaş eklendi";

  @override
  Widget build(BuildContext context) {
    Future<void> ArkadasEkleGeriCek(String friendId) async {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      DocumentReference userRef2 = _firestore.collection('users').doc(friendId);

      // Mevcut arkadaşlar listesini al
      DocumentSnapshot userSnapshot = await userRef.get();
      DocumentSnapshot userSnapshot2 = await userRef2.get();
       arkadaslar = userSnapshot['arkadaslar'];
      List<dynamic> currentFriends2 = userSnapshot2['arkadaslar'];

      // İlgili arkadaşı kaldır
      arkadaslar.remove(friendId);
      currentFriends2.remove(userId);

      // Güncellenmiş arkadaşlar listesini Firestore'a yaz
      await userRef.update({'arkadaslar': arkadaslar});
      await userRef2.update({'arkadaslar': currentFriends2});
      setState(() {
        arkadaslar;
      });

    }

    void arkadasEkle(String friendId) async {
      DocumentSnapshot userSnapshot =
      await _firestore.collection('users').doc(userId).get();
      DocumentSnapshot userSnapshot2 =
      await _firestore.collection('users').doc(friendId).get();
      if (userSnapshot.exists) {



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
            arkadasEklendiText = "arkadaş eklendi";
          });
          setState(() {
            arkadaslar;
          });
        } else {
          print('Bu kullanıcı zaten arkadaşınız: $friendId');
        }
      } else {
        print('Kullanıcı bulunamadı: $userId');
      }
    }
    Future<void> ArkadasIstekGonderGeriCek(String friendId) async {
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      DocumentReference userRef2 = _firestore.collection('users').doc(friendId);
      // Mevcut arkadaşlar listesini al
      DocumentSnapshot userSnapshot = await userRef.get();
      DocumentSnapshot userSnapshot2 = await userRef2.get();
      bizdenGonderilenIstekler = userSnapshot['GonderilenIstek'];
      List<dynamic> currentFriends2 = userSnapshot2['arkadasIstekleri'];

      // İlgili arkadaşı kaldır
      bizdenGonderilenIstekler.remove(friendId);
      currentFriends2.remove(userId);

      // Güncellenmiş arkadaşlar listesini Firestore'a yaz
      await userRef.update({'GonderilenIstek': bizdenGonderilenIstekler});
      await userRef2.update({'arkadasIstekleri': currentFriends2});

      setState(() {
        bizdenGonderilenIstekler;
      });

    }


    void arkadasIstekEkle(String friendId) async {
      DocumentSnapshot userSnapshot =
      await _firestore.collection('users').doc(userId).get();
      DocumentSnapshot userSnapshot2 =
      await _firestore.collection('users').doc(friendId).get();

      if (userSnapshot.exists && userSnapshot2.exists) {
        // If 'GonderilenIstek' field doesn't exist, create it
        var docData = userSnapshot.data() as Map<String, dynamic>;
        var docData2 = userSnapshot2.data() as Map<String, dynamic>;
         bizdenGonderilenIstekler = docData.containsKey('GonderilenIstek')
            ? docData['GonderilenIstek']
            : [];

        List<dynamic> gonderilenIstek = docData2.containsKey('arkadasIstekleri')
            ? docData2['arkadasIstekleri']
            : [];

        if (!gonderilenIstek.contains(userId)) {
          gonderilenIstek.add(userId);
          bizdenGonderilenIstekler.add(friendId);

          await _firestore.collection('users').doc(friendId).update({
            'arkadasIstekleri': gonderilenIstek,
          });
          await _firestore.collection('users').doc(userId).update({
            'GonderilenIstek': bizdenGonderilenIstekler,
          });
          print(token);

          token2 = await _getToken(friendId);
          await sendNotification(token2!);
          setState(() {
            bizdenGonderilenIstekler;
          });

          //userList = userList
          //  .where((user) => user.id != friendId)
          //.toList(); // Arkadaşın listeden kaldırılması

        } else {
          print('Bu kullanıcı zaten arkadaş isteği gönderdiniz: $friendId');
        }
      } else {
        print('Kullanıcı bulunamadı: $userId veya $friendId');
      }
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => KonusmaListele()),
                  );
                },
                child: Icon(Icons.message)),
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
                  String id=userList[index].id;
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
                                  builder: (context) =>
                                      BaskaProfil(
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
                                  child: (arkadaslar.contains(id))
                                      ? Text("Arkadaş eklendi")
                                      : (bizdenGonderilenIstekler.contains(id))
                                      ? Text("İstek Gönderildi")
                                      : Text("Arkadaş ekle"),
                                  onPressed: () async {
                                    String friendId = userList[index].id;
                                    bool durum = await HesapGizliMi(friendId);

                                    if (durum) {
                                      if (bizdenGonderilenIstekler.contains(id)) {
                                        ArkadasIstekGonderGeriCek(id);
                                      } else {
                                        arkadasIstekEkle(id);
                                      }
                                    } else{if(arkadaslar.contains(id)){
                                      ArkadasEkleGeriCek(id);

                                    }else {
                                        arkadasEkle(id);
                                    }}

                                    setState(() {
                                  arkadaslar;
                                  bizdenGonderilenIstekler;
                                    });
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
