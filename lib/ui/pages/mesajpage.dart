import 'package:arkadasekle/app/configs/colors.dart';
import 'package:arkadasekle/firebase_api.dart';
import 'package:arkadasekle/ui/pages/home_page.dart';
import 'package:arkadasekle/ui/pages/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sentiment_dart/sentiment_dart.dart';
import '../widgets/emotionbar.dart';

class MesajPage extends StatefulWidget {
  String arkadasId;
  String ArkadasIsim;

  MesajPage({Key? key, required this.arkadasId, required this.ArkadasIsim})
      : super(key: key);

  @override
  State<MesajPage> createState() => _MesajPageState();
}


late CollectionReference _ref;
late CollectionReference _ref_users;
double duyguDurumu = 2;
class _MesajPageState extends State<MesajPage> {
  TextEditingController mesajController = TextEditingController();
  String documanId = "";
  double toplam=0;
  int mesajSayisi=1;




  @override
  void initState() {
    super.initState();
    _ref  = FirebaseFirestore.instance.collection('konusmalar');
    _ref_users=FirebaseFirestore.instance.collection("users");
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

    DocumentSnapshot kullaniciDokumani = await _ref_users.doc(widget.arkadasId).get();
    DocumentSnapshot bizimDokuman = await _ref_users.doc(userId).get();

    print("karşı tarafın tokeni:"+kullaniciDokumani.get("token"));
    RemoteMessage message = RemoteMessage(
      data: {
        'title': "mesaj geldi",
        'body': mesajController,
      },

      from: bizimDokuman.get("token"),
    );

    FirebaseApi().sendNotification(message);


    mesajController.text = "";
  }

  void markAsRead() async {

  }

 void scoreHesapla(double score){
    toplam+=score;
    mesajSayisi += 1;
   print(mesajSayisi);
  }


  double duyguDurumuSonuc(){
    double sonuc =toplam/mesajSayisi;
    return sonuc;
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

      if (querySnapshot.docs.length > 0) {
        List<DocumentSnapshot> documents = querySnapshot.docs;
print(documents.length);
        for (var document in documents) {
          print("hey gidi");
          print(document["message"]);

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
    double ortalamaDuyguDurumu = duyguDurumuSonuc();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ArkadasIsim),actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: EmotionBar(score: 3, maxWidth: 150),
        ), // Duygu değerini ve maksimum genişliği belirtin
      ],
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
                      double puan = Sentiment.analysis(document['mesaj'], languageCode: 'en').score;
                      print(snapshot.data!.docs.length);

                      return ListTile(
                        title: Align(
                          alignment: userId == document['senderId']
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: IntrinsicWidth(
                            child: Container(

                              decoration: BoxDecoration(
                                color: userId == document['senderId']?AppColors.greyColor:AppColors.primaryLightColor,
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
                                      onLongPress: () {
                                        print(document['mesaj']);
                                        double puan = Sentiment.analysis(document['mesaj'], languageCode: 'en').score;
                                       scoreHesapla(puan);

                                        String yorumAnaliz= getEmotion(puan);
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(yorumAnaliz),
                                            );
                                          },
                                        );
                                      },
                                      child: Text(
                                        document['mesaj'],
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.blackTextColor,
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
                                          color: AppColors.greyColor,
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
              color:AppColors.greyColor,
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