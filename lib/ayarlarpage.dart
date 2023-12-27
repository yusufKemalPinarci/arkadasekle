import 'package:flutter/material.dart';

class AyarlarPage extends StatefulWidget {
  const AyarlarPage({Key? key}) : super(key: key);

  @override
  State<AyarlarPage> createState() => _AyarlarPageState();
}

class _AyarlarPageState extends State<AyarlarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ayarlar")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Center(child: Text("Ayarlar sayfası henüz mevcut değil"))],
      ),
    );
  }
}
