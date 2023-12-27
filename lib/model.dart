import 'package:arkadasekle/mesajmodel.dart';
import 'package:arkadasekle/kayitpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class User {
  String isim="";
  final String email;
  final String sifre;
  String imageUrl="";
  List<User>arkadaslar=[];
  List<User>resimler=[];
  bool hesapGizli;
  User(this.isim,this.email, this.sifre,this.imageUrl,this.arkadaslar,this.resimler,this.hesapGizli);

  // Firestore için Map'e dönüştürme metodunu tanımlayın
  Map<String, dynamic> toMap() {
    return {
      'isim':isim,
      'email': email,
      'sifre': sifre,
      'imageUrl':imageUrl,
      'arkadaslar':arkadaslar,
      'resimler':resimler,
      'hesapGizli':hesapGizli
    };
  }

}

void saveUserToFirestore(User user,String userId) async {
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
   UserOlustur(String isim ,String _email, String _sifre,String imageUrl,bool hesapGizli) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: _email,
      password: _sifre,
    );
    print("printim");
    print(userCredential.user?.uid);
    User yeniUser = User(isim,_email, _sifre,imageUrl,[],[],hesapGizli);
    userId=userCredential.user?.uid;

    return yeniUser;
}

void arkadasEkle(String userId, User yeniArkadas) async{
    // Firestore koleksiyon referansını alın
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    // Kullanıcının arkadaşlar listesine yeni arkadaşı ekleyin
    await userRef.update({
      'arkadaslar': FieldValue.arrayUnion([yeniArkadas.toMap()]),
    });


}



List<User> UserList = [];
