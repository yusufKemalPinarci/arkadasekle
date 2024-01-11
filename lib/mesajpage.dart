import 'package:arkadasekle/firebase_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'kayitpage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MesajPage extends StatefulWidget {
  String arkadasId;
  String ArkadasIsim;

  MesajPage({Key? key, required this.arkadasId, required this.ArkadasIsim})
      : super(key: key);

  @override
  State<MesajPage> createState() => _MesajPageState();
}

late CollectionReference _ref;

class _MesajPageState extends State<MesajPage> {
  TextEditingController mesajController = TextEditingController();
  String documanId = "";

  String duyguDurumu = "";
  Future<void> analizEt(String metin) async {
    final String apiUrl = 'http://192.168.231.1:5000/analiz_et'; // API adresini buraya ekleyin

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'metin': metin,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        duyguDurumu = data['duygu_durumu'];
      });
    } else {
      setState(() {
        duyguDurumu = "Analiz başarısız: ${response.statusCode}";
      });
    }
  }


  @override
  void initState() {
    super.initState();
    _ref = FirebaseFirestore.instance.collection('konusmalar');
    mesajlariGetir();
    markAsRead();
  }

  void mesajEkle() async {
    await _ref.add({
      "mesaj": mesajController.text,
      "senderId": userId,
      "timestamp": DateTime.now(),
      "okundu": false
    });

    mesajController.text = "";
  }

  void markAsRead() async {

  }

  void mesajlariGetir() async {
    int sayi = 0;
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('konusmalar').get();
    List<DocumentSnapshot> documents = querySnapshot.docs;

    for (var document in documents) {
      List<dynamic> uyeListesi = document['uyeler'];
      if (uyeListesi.contains(widget.arkadasId) &&
          uyeListesi.contains(userId)) {
        sayi++;
        documanId = document.id;
        print("sayi");
      }
    }
    if (sayi > 0) {
      print("önceden konuşulmuş");
      _ref = await FirebaseFirestore.instance
          .collection('konusmalar')
          .doc(documanId)
          .collection("mesajlar");

      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection("konusmalar").doc(documanId).collection("mesajlar").where("senderId",isNotEqualTo: userId).where("okundu",isEqualTo: false).get();
      print(querySnapshot.docs.length);
      print(userId);
      if (querySnapshot.docs.length > 0) {
        List<DocumentSnapshot> documents = querySnapshot.docs;

        for (var document in documents) {

          document.reference.update({'okundu': true});
          print("true yapılcı");
        }
      }


      setState(
          () {}); // _ref değiştiğinde yeniden render etmek için setState kullanılıyor
    } else {
      print("önceden konuşulmamış");
      DocumentReference yeniBelgeRef =
          await FirebaseFirestore.instance.collection("konusmalar").add({
        "uyeler": [userId, widget.arkadasId]
      });
      String yeniBelgeId = yeniBelgeRef.id;
      _ref = FirebaseFirestore.instance
          .collection('konusmalar')
          .doc(yeniBelgeId)
          .collection("mesajlar");

      setState(
          () {}); // _ref değiştiğinde yeniden render etmek için setState kullanılıyor
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ArkadasIsim),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _ref.orderBy('timestamp', descending: false).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final reversedIndex =
                          snapshot.data!.docs.length - 1 - index;
                      final document = snapshot.data!.docs[reversedIndex];
                      DateTime datetime = document["timestamp"].toDate();

                      return ListTile(
                        title: Align(
                          alignment: userId == document['senderId']
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: IntrinsicWidth(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(10),
                                  right: Radius.circular(10),
                                ),
                              ),
                              margin: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              padding: EdgeInsets.all(16),
                              child: GestureDetector(
                                onLongPress: () {
                                  // Uzun basma olayını işleyin
                                },
                                child: Column(
                                  children: [
                                    InkWell(
                                      onTap: (){analizEt(document['mesaj']);print(duyguDurumu);},
                                      child: Text(
                                        document['mesaj'],
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        datetime.hour.toString() +
                                            ":" +
                                            datetime.minute.toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Veriler alınırken bir hata oluştu.');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
          Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.blue,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: mesajController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Mesaj yazın',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async{
                     mesajEkle();


                  },
                  icon: Icon(Icons.send),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
