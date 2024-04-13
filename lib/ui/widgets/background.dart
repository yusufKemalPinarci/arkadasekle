import 'package:arkadasekle/app/configs/colors.dart';
import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;

  const Background({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: size.height,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(color: AppColors.primaryColor,
              "assets/images/top1.png",
              width: size.width
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(color: AppColors.primaryColor,
              "assets/images/top2.png",
              width: size.width
            ),
          ),

          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(color: AppColors.primaryColor,
              "assets/images/bottom1.png",
              width: size.width
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(color: AppColors.primaryColor,
              "assets/images/bottom2.png",
              width: size.width
            ),
          ),
          child
        ],
      ),
    );
  }
}