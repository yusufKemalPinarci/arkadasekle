import 'dart:io';
import 'package:arkadasekle/formfield.dart';

import 'package:arkadasekle/model.dart';
import 'package:arkadasekle/ui/pages/login.dart';
import 'package:arkadasekle/ui/pages/register.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';



XFile? pickedFile;
final FirebaseStorage _storage = FirebaseStorage.instance;

final formKey = GlobalKey<FormState>();

class FirebaseService {
  Future<void> kayitIslem(BuildContext context) async {
    String imageUrl = "";
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      try {
        var yeniUser = await UserOlustur(isimController.text,
            emailController.text, sifreController.text, imageUrl, false);
        await saveUserToFirestore(yeniUser, userId!);
        await FirebaseAuth.instance.currentUser!.sendEmailVerification();
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Başarılı'),
              content: Text(
                'Kayıt işlemi başarıyla tamamlandı. Lütfen e-postanızı onaylayın.',
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Tamam'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
        isimController.text = "";
        hakkindaController.text = "";
        emailController.text = "";
        sifreController.text = "";
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => RegisterScreen()));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Hata'),
                content: Text('Güçsüz parola en az 6 haneli olmalı'),
                actions: <Widget>[
                  TextButton(
                    child: Text('Tamam'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );

          print('Güçsüz parola.');
        } else if (e.code == 'email-already-in-use') {
          return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Hata'),
                content: Text('bu email zaaten var'),
                actions: <Widget>[
                  TextButton(
                    child: Text('Tamam'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  Future<void> girisYap(BuildContext context, String email, String sifre) async {
    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(email: email, password: sifre);

      if (userCredential.user != null) {
        // Doğrulama durumunu kontrol et
        if (!userCredential.user!.emailVerified) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Hata'),
                content: Text('E-posta adresiniz onaylanmamış.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('Tamam'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          return;
        }
        userId = userCredential.user!.uid;
        // Giriş başarılıysa, kullanıcı listeleme sayfasına yönlendir

      }
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hata'),
            content: Text('Bu kullanıcı bulunmamaktadır.'),
            actions: <Widget>[
              TextButton(
                child: Text('Tamam'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  static Future<String> uploadProfileImage(File file) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference =
        FirebaseStorage.instance.ref().child('profile_images/$fileName');
    UploadTask uploadTask = storageReference.putFile(file);
    TaskSnapshot storageSnapshot = await uploadTask;
    String downloadUrl = await storageSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  static Future<String> uploadProfilVideo(File file) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
          FirebaseStorage.instance.ref().child('profile_videos/$fileName.mp4');

      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot storageSnapshot = await uploadTask;

      String downloadUrl = await storageSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Video upload error: $e');
      return ''; // Hata durumunda boş bir string dönebilirsiniz.
    }
  }

  Future<void> deleteImageFromStorage(String imageUrl) async {
    try {
      // Storage'da bulunan resmi silme işlemi
      await _storage.refFromURL(imageUrl).delete();
      print('Resim Storage\'dan silindi: $imageUrl');
    } catch (e) {
      print('Resim Storage\'dan silinirken bir hata oluştu: $e');
    }
  }
}

Future<String> uploadVideo(File _selectedVideo) async {
  String videoUrl = await FirebaseService.uploadProfilVideo(_selectedVideo);
  return videoUrl;
  // Video yüklendikten sonra yapılması gereken işlemler
}

Future<String> uploadImage(File _selectedImage) async {
  String imageUrl = await FirebaseService.uploadProfileImage(_selectedImage);

  return imageUrl;

  // Resim yüklendikten sonra yapılması gereken işlemler
}

Future<File> pickImage(ImageSource source) async {
  File _imageFile;
  ImagePicker _picker = ImagePicker();
  pickedFile = await _picker.pickImage(
    source: source,
  );
  _imageFile = File(pickedFile!.path);
  return _imageFile;
}

Future<File> pickVideo(ImageSource source) async {
  File _videoFile;
  ImagePicker _picker = ImagePicker();
  pickedFile = await _picker.pickVideo(
    source: source,
  );
  _videoFile = File(pickedFile!.path);
  return _videoFile;
}

Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}



