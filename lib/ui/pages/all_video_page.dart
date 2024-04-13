import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/video_player_widget.dart';

class AllVideo extends StatefulWidget {
  const AllVideo({Key? key}) : super(key: key);

  @override
  _AllVideoState createState() => _AllVideoState();
}

class _AllVideoState extends State<AllVideo> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('users').get(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            List<Widget> videoWidgets = snapshot.data!.docs.map((userDocument) {
              Map<String, dynamic> userData = userDocument.data() as Map<String, dynamic>;
              List<dynamic> videolar = userData['videolar'] ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: videolar.map<Widget>((video) {
                  String videoUrl = video["url"];
                  if (videoUrl != null && videoUrl.isNotEmpty) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerWidget(videoUrl: videoUrl),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text('Video'),
                        subtitle: Text(videoUrl),
                      ),
                    );
                  }
                  return SizedBox.shrink(); // Boş bir widget döndürmek için kullanılabilir
                }).toList(),
              );
            }).toList();

            return ListView(
              children: videoWidgets,
            );
          },
        ),
      ),
    );
  }
}