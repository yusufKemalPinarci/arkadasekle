import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'başkaprofil.dart';

class YorumSayfasi extends StatefulWidget {
  List yorumlar;

  YorumSayfasi(List<dynamic> this.yorumlar, {Key? key}) : super(key: key);

  @override
  State<YorumSayfasi> createState() => _YorumSayfasiState();

}

class _YorumSayfasiState extends State<YorumSayfasi> {
  List guncellenmisYorumlar=[];
  @override
  void initState() {
    setState(() {


    });

    // TODO: implement initState
    super.initState();
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String profilResmi = '';

  Future<String> getProfilResmiUrl(String userId) async {
    try {
      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
      String profilResmiUrl = userSnapshot['imageUrl'] ?? '';
      return profilResmiUrl;
    } catch (e) {
      print('Error getting profile image URL: $e');
      return '';
    }
  }

  getUserName(String yazanId) async {
    try {
      DocumentSnapshot userSnapshot =
      await _firestore.collection('users').doc(yazanId).get();
      profilResmi = userSnapshot['imageUrl'] ?? '';
      return userSnapshot["isim"];
    } catch (e) {
      print('Error getting user name: $e');
      return '';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yorumlar'),
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          if (widget.yorumlar[index]['yazan'] != null) {
            String yazanId = widget.yorumlar[index]['yazan'];
            return Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(widget.yorumlar[index]['yorum']),
                leading: FutureBuilder(
                  future: getProfilResmiUrl(yazanId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Icon(Icons.error);
                    } else {
                      return GestureDetector(
                        onTap: () async {
                          var isim = await getUserName(yazanId);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BaskaProfil(
                                ArkadasIsim: isim.toString(),
                                arkadasId: yazanId,
                              ),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(snapshot.data.toString()),
                        ),
                      );
                    }
                  },
                ),
              ),
            );
          } else {
            print("yazan field is null");
            return Container();
          }
        },
        itemCount: widget.yorumlar.length,
      ),
    );
  }
}
