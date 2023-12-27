import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'kayitpage.dart';
XFile? pickedFile;
final FirebaseStorage _storage = FirebaseStorage.instance;
class FirebaseService {
  static Future<String> uploadProfileImage(File file) async {

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child('profile_images/$fileName');
      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot storageSnapshot = await uploadTask;
      String downloadUrl = await storageSnapshot.ref.getDownloadURL();
      return downloadUrl;
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


Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}





