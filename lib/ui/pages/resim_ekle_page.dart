import 'package:arkadasekle/ui/pages/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResimEklePage extends StatefulWidget {
  String imageUrl;

  ResimEklePage(String this.imageUrl, {super.key});

  @override
  State<ResimEklePage> createState() => _ResimEklePageState();
}

class _ResimEklePageState extends State<ResimEklePage> {
  var textController = new TextEditingController();

  Future<void> resimEkle(String resimUrl,String aciklama) async {
    try {
      DocumentReference userDoc =
      FirebaseFirestore.instance.collection("users").doc(userId);

      // Get the user document
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (!userSnapshot.exists) {
        print('User document not found');
        return;
      }

      // Get the user's resimler list
      List<dynamic> resimler = userSnapshot['resimler'] ?? [];

      // Create a new resim object
      Map<String, dynamic> yeniResim = {
        'url': resimUrl,
        'begenenler': [],
        'yorumlar': [],
        'aciklama': aciklama,
      };

      // Add the new resim to the user's resimler list
      resimler.add(yeniResim);

      // Update Firestore with new data
      await userDoc.update({
        'resimler': resimler,
      });

      // Update local state if necessary
      setState(() {
        // Assuming resimler is a list in your widget state
        resimler.add(yeniResim);
      });
    } catch (e) {
      print('Error adding image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Column(
            children: [
              Center(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  child: Image.network(widget.imageUrl),
                ),
              )),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: "Resim açıklamasını giriniz",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(child: Text("Gönder"),onPressed: (){
        resimEkle(widget.imageUrl, textController.text);
        Navigator.pop(context);

      },),
    );
  }
}
