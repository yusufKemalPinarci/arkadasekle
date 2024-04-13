import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
class VideoStoryWidget extends StatefulWidget {
  final String videoUrl;

  const VideoStoryWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoStoryWidgetState createState() => _VideoStoryWidgetState();
}

class _VideoStoryWidgetState extends State<VideoStoryWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
