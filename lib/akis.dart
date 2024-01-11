import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'başkaprofil.dart';
import 'formfield.dart';



class FeedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Akış'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          List<DocumentSnapshot> userDocuments = snapshot.data!.docs;
          return ListView.builder(
            itemCount: userDocuments.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot userSnapshot = userDocuments[index];
              String kullaniciAdi = userSnapshot['isim'] ?? '';
              String profilResmi = userSnapshot['imageUrl'] ?? '';
              List<dynamic> resimler = userSnapshot['resimler'] ?? [];
              bool hesapGizli = userSnapshot['hesapGizli'] ?? false;
              if (resimler.isEmpty || hesapGizli) {
                // Skip rendering content for users with no images or private accounts
                return Container();
              }
              List<Widget> userWidgets = [];
              for (int i = 0; i < resimler.length; i++) {
                userWidgets.add(
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BaskaProfil(
                                        arkadasId: userSnapshot.id,
                                        ArkadasIsim: kullaniciAdi,
                                      ),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: profilResmi.isNotEmpty
                                      ? NetworkImage(profilResmi)
                                      : null,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(kullaniciAdi),
                              Spacer(),
                              IconButton(
                                  onPressed: () {}, icon: Icon(Icons.more_vert))
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Image.network(resimler[i]),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: userWidgets,
              );
            },
          );
        },
      ),
      drawer: buildDrawer(context),
    );
  }
}
