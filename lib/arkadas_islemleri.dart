import 'package:flutter/material.dart';

import 'formfield.dart';

class ArkadasIslemleriSayfasi extends StatefulWidget {
  const ArkadasIslemleriSayfasi({Key? key}) : super(key: key);

  @override
  State<ArkadasIslemleriSayfasi> createState() =>
      _ArkadasIslemleriSayfasiState();
}

class _ArkadasIslemleriSayfasiState extends State<ArkadasIslemleriSayfasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Arkadaş İşlemleri")),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton(
              onPressed: () {}, child: Text("Arkadaş Bul"), style: butonstyle),
          Padding(padding: EdgeInsetsDirectional.only(top: 20)),
          ElevatedButton(
              onPressed: () {},
              child: Text("Arkadaş Listele"),
              style: butonstyle), Padding(padding: EdgeInsetsDirectional.only(top: 20)),
          ElevatedButton(
              onPressed: () {}, child: Text("Gelen İstekler"), style: butonstyle), Padding(padding: EdgeInsetsDirectional.only(top: 20)),

          ElevatedButton(
              onPressed: () {},
              child: Text("Gönderilen İstekler"),
              style: ButtonStyle()), Padding(padding: EdgeInsetsDirectional.only(top: 20)),
        ]),
      ),
    );
  }
}
