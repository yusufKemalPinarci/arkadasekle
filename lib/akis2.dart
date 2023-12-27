import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OtherUsersImages extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diğer Kullanıcıların Resimleri'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Sırala: En yeni resimleri en üste getir
            var documents = snapshot.data!.docs;
            documents.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                var imageUrl = documents[index]['imageUrl'];
                var userId = documents[index]['userId'];

                return ListTile(
                  title: Text('Kullanıcı ID: $userId'),
                  subtitle: Text('Resim: $imageUrl'),
                  // Diğer widgetleri ekleyebilirsiniz...
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Hata: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
