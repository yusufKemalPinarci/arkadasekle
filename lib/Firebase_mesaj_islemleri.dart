import 'package:arkadasekle/ui/pages/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

late CollectionReference ref;
late CollectionReference ref_users;
class FirebaseMesajIslemleri {
  String documanId = "";
  TextEditingController mesajController = TextEditingController();
  void mesajEkle(String arkadasId, String text) async {
    await ref.add({
      "mesaj": mesajController.text,
      "senderId": userId,
      "timestamp": DateTime.now(),
      "okundu": false
    });
    DocumentReference documentSnapshot =
        ref.doc(arkadasId);
    DocumentSnapshot userSnapshot = await documentSnapshot.get();
    mesajController.text = "";
  }
  void mesajlariGetir(String arkadasId,BuildContext context) async {
    int sayi = 0;
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('konusmalar').get();
    List<DocumentSnapshot> documents = querySnapshot.docs;

    for (var document in documents) {
      List<dynamic> uyeListesi = document['uyeler'];
      if (uyeListesi.contains(arkadasId) && uyeListesi.contains(userId)) {
        sayi++;
        documanId = document.id;
        print("sayi");
      }
    }
    if (sayi > 0) {
      print("önceden konuşulmuş");
      ref = await FirebaseFirestore.instance
          .collection('konusmalar')
          .doc(documanId)
          .collection("mesajlar");

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("konusmalar")
          .doc(documanId)
          .collection("mesajlar")
          .where("senderId", isNotEqualTo: userId)
          .where("okundu", isEqualTo: false)
          .get();
      print(querySnapshot.docs.length);
      print(userId);
      if (querySnapshot.docs.length > 0) {
        List<DocumentSnapshot> documents = querySnapshot.docs;

        for (var document in documents) {
          document.reference.update({'okundu': true});
          print("true yapıldı");
        }
      }

      context.read<SetStateIslemi>();
      // _ref değiştiğinde yeniden render etmek için setState kullanılıyor
    } else {
      print("önceden konuşulmamış");
      DocumentReference yeniBelgeRef =
          await FirebaseFirestore.instance.collection("konusmalar").add({
        "uyeler": [userId, arkadasId]
      });
      String yeniBelgeId = yeniBelgeRef.id;
      ref = FirebaseFirestore.instance
          .collection('konusmalar')
          .doc(yeniBelgeId)
          .collection("mesajlar");
      context.read<SetStateIslemi>();
      // _ref değiştiğinde yeniden render etmek için setState kullanılıyor
    }
  }

}
class SetStateIslemi extends ChangeNotifier {

}