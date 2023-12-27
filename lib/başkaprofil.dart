import 'package:arkadasekle/kayitpage.dart';
import 'package:arkadasekle/mesajpage.dart';
import 'package:arkadasekle/yorumsayfasi.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'firebase_service.dart';
import 'formfield.dart';

class BaskaProfil extends StatefulWidget {
  String arkadasId;
  String ArkadasIsim;

  BaskaProfil({Key? key, required this.arkadasId, required this.ArkadasIsim})
      : super(key: key);

  @override
  State<BaskaProfil> createState() => _BaskaProfilState();
}

class _BaskaProfilState extends State<BaskaProfil> {
  bool isCommentsExpanded = false;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<dynamic> resimler = [];
  List<dynamic> yorumlar = [];

  String profilResmi = "";
  bool hesapGizli = false;

  getSnapshotFuture() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.arkadasId)
        .get();

    setState(() {
      profilResmi = userSnapshot["imageUrl"];
      hesapGizli = userSnapshot["hesapGizli"] ?? false;
      print(hesapGizli);
    });
  }

  getResimler() async {
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(widget.arkadasId).get();
    if (userSnapshot.exists) {
      setState(() {
        resimler = userSnapshot['resimler'] ?? [];
      });
    } else {
      print('Kullanıcı bulunamadı: ${widget.arkadasId}');
    }
  }

  getYorumlar() async {
    try {
      QuerySnapshot yorumlarSnapshot = await _firestore
          .collection('users')
          .doc(widget.arkadasId)
          .collection("yorumlar")
          .get();

      if (yorumlarSnapshot.docs.isNotEmpty) {
        setState(() {
          yorumlar = yorumlarSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        });
      } else {
        print('Yorumlar bulunamadı: ${widget.arkadasId}');
      }
    } catch (e) {
      print('Error getting comments: $e');
    }
  }



  yorumEkle(String yorum, String? yazanId) async {
    CollectionReference userSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.arkadasId).collection("yorumlar");

      setState(() {
        Map<String, dynamic> yeniYorum = {
          'yorum': yorum,
          'yazan': yazanId,
        };
        userSnapshot.add(yeniYorum);
      });
  }

  @override
  initState() {
    super.initState();
    getSnapshotFuture();
    getResimler();
    getYorumlar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MesajPage(arkadasId: widget.arkadasId, ArkadasIsim: widget.ArkadasIsim)
              ),
            );

          }, child: Icon(Icons.message)),
        ),
      ],
          title: NormalText(
        labelText: widget.ArkadasIsim,
      )),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Center(
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: InkWell(
                      onTap: () {},
                      child: profilResmi != ""
                          ? ClipOval(
                              child: Image.network(
                                profilResmi,
                                fit: BoxFit.cover,
                              ),
                            )
                          : CircleAvatar(
                              child: Icon(
                                Icons.person,
                                size: 20,
                              ),
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: widget.ArkadasIsim != ""
                      ? NormalText(labelText: widget.ArkadasIsim)
                      : CircularProgressIndicator(),
                ),
              ],
            ),
          ),
          if (!hesapGizli)
            Expanded(
              flex: 5,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 10,
                ),
                itemCount: resimler.length,
                itemBuilder: (BuildContext context, int index) {
                  final reversedIndex = resimler.length - 1 - index;
                  final resimUrl = resimler[reversedIndex];

                  return GestureDetector(
                    onLongPress: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: resimUrl != ""
                            ? Image.network(resimUrl)
                            : CircularProgressIndicator(),
                      ),
                    ),
                  );
                },
              ),
            ),if (hesapGizli)
            Expanded(flex: 5,child: NormalText(labelText: "Bu hesap Gizli")),
            Expanded(
            flex: 1,
            child: GestureDetector(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(children: [
                    InkWell(
                      onTap: () async{
                        await getYorumlar();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => YorumSayfasi(yorumlar),
                          ),
                        );
                      },
                      child: NormalText(labelText: "Yorumlar"),
                    ),
                    Spacer(),
                    if(!hesapGizli)
                    IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Yorum ekle"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextYorumYazma(
                                      labelText: 'Yorum Yazınız',
                                    ),
                                    TextButton(
                                      onPressed: () async{
                                        print("yarra");


                                          await yorumEkle(
                                              yorumController.text, userId);
                                          yorumController.text = " ";


                                        Navigator.pop(
                                            context); // Close the dialog after adding the comment
                                      },
                                      child: Text("Yorum Ekle"),
                                    )
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.add))
                  ]),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}


