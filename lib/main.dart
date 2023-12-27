import 'package:arkadasekle/girispage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'akis.dart';
import 'firebase_api.dart';
import 'kayitpage.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    userId = await FirebaseAuth.instance.currentUser!.uid;
    await FirebaseApi().initNotifications();
  }


  runApp(MyApp(initialRoute: user == null ? '/giris' : '/anasayfa'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({ Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Uygulama Adı',
      theme: ThemeData(

      ),

      initialRoute: initialRoute,
      routes: {
        '/giris': (context) => GirisSayfasi(),
        '/anasayfa': (context) => FeedPage(),
      },
    );
  }
}
