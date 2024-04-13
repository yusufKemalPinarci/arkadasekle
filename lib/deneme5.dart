import 'package:arkadasekle/app/configs/colors.dart';
import 'package:arkadasekle/ui/widgets/video_player_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserVideo extends StatefulWidget {
  UserVideo({super.key, required this.arkadasId});

  final String arkadasId;

  @override
  _UserVideoState createState() => _UserVideoState();
}

class _UserVideoState extends State<UserVideo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.arkadasId)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Errorr: ${snapshot.error}'),
              );
            }

            Map<String, dynamic> userData =
                snapshot.data!.data() as Map<String, dynamic>;
            List<dynamic> videolar = userData['videolar'] ?? [];

            List<Widget> videoWidgets =
                videolar.asMap().entries.map<Widget>((entry) {
              int index = entry.key;
              Map<String, dynamic> video = entry.value;

              String videoUrl = video["url"];
              if (videoUrl != null && videoUrl.isNotEmpty) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VideoPlayerWidget(videoUrl: videoUrl),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(color: AppColors.primaryLightColor,
                      child: ListTile(
                        title: Text(
                            'Video ${index + 1}'), // Kaçıncı video olduğunu göstermek için
                      ),
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            }).toList();

            return ListView(
              children: videoWidgets,
            );
          },
        ),
      );

  }
}
