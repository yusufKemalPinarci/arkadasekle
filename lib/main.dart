import 'package:arkadasekle/Firebase_mesaj_islemleri.dart';
import 'package:arkadasekle/ui/pages/home_page.dart';
import 'package:arkadasekle/ui/pages/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_api.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    userId = await FirebaseAuth.instance.currentUser!.uid;
    await FirebaseApi().initNotifications();
  }
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<BottomNavBarProvider>(
        create: (BuildContext context) {
          return BottomNavBarProvider();
        },
      ),
      ChangeNotifierProvider<BottomNavBarProvider2>(
        create: (BuildContext context) {
          return BottomNavBarProvider2();
        },
      ),
      ChangeNotifierProvider<SetStateIslemi>(
        create: (BuildContext context) {
          return SetStateIslemi();
        },
      ),
    ],
    child: MyApp(initialRoute: user == null ? '/giris' : '/anasayfa'),
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Uygulama Adı',
      theme: ThemeData(),
      initialRoute: initialRoute,
      routes: {
        '/giris': (context) => RegisterScreen(),
        '/anasayfa': (context) => HomePage()
      },
    );
  }
}
