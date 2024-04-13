import 'package:flutter/material.dart';

class EmotionBar extends StatelessWidget {
  final double score;
  final double maxWidth;

  EmotionBar({required this.score, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    Color color = _getColorForEmotion(score);
    double height = _getHeightForEmotion(score);
    return Container(
      width: maxWidth,
      height: 30,
      child: Stack(
        children: [
          Container(
            width: maxWidth,
            height: 10,
            color: Colors.grey[300],
          ),
          Container(
            width: maxWidth * height,
            height: 10,
            color: color,
          ),
        ],
      ),
    );
  }

  Color _getColorForEmotion(double score) {
    if (score < -5) {
      return Colors.red;
    } else if (score < 0) {
      return Colors.orange;
    } else if (score < 3) {
      return Colors.yellow;
    } else if (score < 6) {
      return Colors.lightGreen;
    } else {
      return Colors.green;
    }
  }

  double _getHeightForEmotion(double score) {
    return (score + 7) / 14; // 0 ile 1 arasında normalize edilmiş değer
  }
}
