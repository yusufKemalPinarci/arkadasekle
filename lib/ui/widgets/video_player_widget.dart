import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
 VideoPlayerWidget({super.key, required this.videoUrl});
final String videoUrl;
  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    _initializeVideoPlayerFuture = _videoPlayerController.initialize().then((_) {
      _videoPlayerController.play();
      _videoPlayerController.setLooping(true);
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initializeVideoPlayerFuture, builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        return AspectRatio(
          aspectRatio: _videoPlayerController.value.aspectRatio, child:VideoPlayer(_videoPlayerController),);
      } else {
        return Center(child: CircularProgressIndicator(),);
      }
    });
  }
}
