import 'dart:async';

import 'package:arkadasekle/firebase_service.dart';
import 'package:arkadasekle/ui/pages/home_page.dart';
import 'package:arkadasekle/ui/widgets/custom_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:arkadasekle/app/configs/colors.dart';
import 'package:arkadasekle/app/configs/theme.dart';
import 'package:arkadasekle/ui/pages/profile_page.dart';
import 'package:arkadasekle/ui/widgets/clip_status_bar.dart';
import 'package:flutter/widgets.dart';
import '../../baska_profile.dart';
import '../../formfield.dart';
import 'ui/pages/konusmalistele.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../main.dart';
import 'ui/pages/register.dart';

class ResimleriGoster extends StatefulWidget {
  String arkadasId;

  ResimleriGoster({Key? key, required this.arkadasId}) : super(key: key);

  @override
  State<ResimleriGoster> createState() => _ResimleriGosterState();
}

String profilResmi = "";
bool showBottonNavBar = false;

class _ResimleriGosterState extends State<ResimleriGoster> {
  GlobalKey<_BottomNavbarState> bottomNavbarKey =
      GlobalKey<_BottomNavbarState>();
  bool isHidden = false;
  List resimler = [];
  List<dynamic> yorumlar = [];

  int bottomSheetSize = 200;

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    String profilResmi = '';

    Future<String> getProfilResmiUrl(String userId) async {
      try {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        String profilResmiUrl = userSnapshot['imageUrl'] ?? '';
        return profilResmiUrl;
      } catch (e) {
        print('Error getting profile image URL: $e');
        return '';
      }
    }

    getUserName(String yazanId) async {
      try {
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(yazanId).get();
        profilResmi = userSnapshot['imageUrl'] ?? '';
        return userSnapshot["isim"];
      } catch (e) {
        print('Error getting user name: $e');
        return '';
      }
    }

    Future<void> toggleBegeni(String ownerId, int resimIndex) async {
      try {
        DocumentReference userDocRef =
            FirebaseFirestore.instance.collection('users').doc(ownerId);

        // Belirli kullanıcının dokümanını al
        DocumentSnapshot userSnapshot = await userDocRef.get();

        if (userSnapshot.exists) {
          // Resimler listesini al
          List<dynamic> resimler = userSnapshot['resimler'] ?? [];

          if (resimIndex >= 0 && resimIndex < resimler.length) {
            // Belirli resmin içindeki beğenilenler listesini al
            List<dynamic> begenenler = resimler[resimIndex]['begenenler'] ?? [];

            // Kullanıcı daha önce beğenmiş mi kontrol et
            bool alreadyLiked = begenenler.contains(userId);

            if (alreadyLiked) {
              // Kullanıcı daha önce beğenmişse, beğeniyi kaldırın
              begenenler.remove(userId);
              print('Beğeni kaldırıldı');
            } else {
              // Kullanıcı daha önce beğenmediyse, beğeni ekleyin
              begenenler.add(userId);
              print('Beğeni eklendi');
            }

            // Belirli resmin beğenilenler listesini güncelle
            resimler[resimIndex]['begenenler'] = begenenler;

            // Tüm resimleri güncelle
            await userDocRef.update({
              'resimler': resimler,
            });
          } else {
            print('Geçersiz resim index: $resimIndex');
          }
        } else {
          print('Kullanıcı bulunamadı: $userId');
        }
      } catch (e) {
        print('Hata oluştu: $e');
      }
    }

    /* Future<void> getYorumlar(String ownerId) async {
      try {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(ownerId).get();

        if (userSnapshot.exists) {
          setState(() {
            yorumlar = userSnapshot['yorumlar'] ?? [];
          });
        } else {
          print('Kullanıcı bulunamadı: $userId');
        }
      } catch (e) {
        print('Hata oluştu: $e');
      }
    }*/

    Future<void> yorumEkle(
      String yorum,
      String ownerId,
      int resimIndex,
    ) async {
      try {
        DocumentReference userDocRef =
            FirebaseFirestore.instance.collection('users').doc(ownerId);

        // Belirli kullanıcının dokümanını al
        DocumentSnapshot userSnapshot = await userDocRef.get();

        if (userSnapshot.exists) {
          // Resimler listesini al
          List<dynamic> resimler = userSnapshot['resimler'] ?? [];

          if (resimIndex >= 0 && resimIndex < resimler.length) {
            // Belirli resmin içindeki yorumlar listesini al
            List<dynamic> yorumlar = resimler[resimIndex]['yorumlar'] ?? [];

            Map<String, dynamic> yeniYorum = {'yazan': userId, 'yorum': yorum};
            // Yeni yorumu yorumlar listesine ekle
            yorumlar.add(yeniYorum);

            // Belirli resmin yorumlar listesini güncelle
            resimler[resimIndex]['yorumlar'] = yorumlar;

            // Tüm resimleri güncelle
            await userDocRef.update({
              'resimler': resimler,
            });

            print('Yorum eklendi: $yeniYorum');
          } else {
            print('Geçersiz resim index: $resimIndex');
          }
        } else {
          print('Kullanıcı bulunamadı: $userId');
        }
      } catch (e) {
        print('Hata oluştu: $e');
      }
    }

    Future<DocumentSnapshot> _getUserData(String userId) async {
      try {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .get();

        return userSnapshot;
      } catch (e) {
        print('Error fetching user data: $e');
        throw e; // Hata durumunda uygun bir işlem yapabilirsiniz.
      }
    }

    @override
    initState() {
      super.initState();

      // getYorumlar(ownerId);
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Home'),
        ),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                List<QueryDocumentSnapshot> resimler =
                    snapshot.data!["resimler"];
                return ListView.builder(
                  itemCount: resimler.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot urlListesi = resimler[index]["url"];

                    List<Widget> userWidgets = [];
                    if (resimler.isEmpty) {
                      // Skip rendering content for users with no images or private accounts
                      return Container();
                    }

                    for (int i = 0; i < resimler.length; i++) {
                      bool isLiked = resimler[i]["begenenler"].contains(userId);
                      String imageeUrl = resimler[i]["url"];
                      if (imageeUrl != null && imageeUrl.isNotEmpty) {
                        userWidgets.add(SingleChildScrollView(
                          child: Stack(children: [
                            _buildImageGradient(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(resimler[i]["url"]),
                              ),
                            ),
                            Positioned(
                              height: 375,
                              width: 85,
                              right: 0,
                              top: 25,
                              child: Transform.rotate(
                                angle: 3.14,
                                child: ClipPath(
                                  clipper: ClipStatusBar(),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 10.0, sigmaY: 10.0),
                                    child: ColoredBox(
                                      color:
                                          AppColors.whiteColor.withOpacity(0.3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: 460,
                              margin: const EdgeInsets.only(bottom: 24),
                              child: Stack(children: [
                                Positioned(
                                  height: 375,
                                  width: 85,
                                  right: 0,
                                  top: 25,
                                  child: Transform.rotate(
                                    angle: 3.14,
                                    child: ClipPath(
                                      clipper: ClipStatusBar(),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 10.0, sigmaY: 10.0),
                                        child: ColoredBox(
                                          color: AppColors.whiteColor
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 120,
                                  right: 20,
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          String ownerId = widget.arkadasId;
                                          toggleBegeni(ownerId, i);
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            color: isLiked
                                                ? AppColors.purpleColor
                                                : AppColors.whiteColor
                                                    .withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            image: DecorationImage(
                                              scale: 2.3,
                                              image: AssetImage(
                                                  "assets/images/ic_heart.png"),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      GestureDetector(
                                        onTap: () {
                                          showModalBottomSheet<void>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return SizedBox(
                                                height: 250,
                                                child: Center(
                                                  child: Stack(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Expanded(
                                                          child: Container(
                                                            child: StreamBuilder<
                                                                    DocumentSnapshot>(
                                                                stream: FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'users')
                                                                    .doc(widget
                                                                        .arkadasId)
                                                                    .snapshots(),
                                                                builder: (BuildContext
                                                                        context,
                                                                    AsyncSnapshot<
                                                                            DocumentSnapshot>
                                                                        snapshot) {
                                                                  if (snapshot
                                                                      .hasError) {
                                                                    return Text(
                                                                        'Error: ${snapshot.error}');
                                                                  }

                                                                  if (snapshot
                                                                          .connectionState ==
                                                                      ConnectionState
                                                                          .waiting) {
                                                                    return CircularProgressIndicator();
                                                                  }
                                                                  print(snapshot
                                                                      .data!
                                                                      .id);
                                                                  print(snapshot
                                                                          .data![
                                                                      "resimler"][i]);

                                                                  return ListView
                                                                      .builder(
                                                                    itemCount: snapshot
                                                                        .data![
                                                                            "resimler"]
                                                                            [i][
                                                                            "yorumlar"]
                                                                        .length,
                                                                    itemBuilder:
                                                                        (BuildContext
                                                                                context,
                                                                            int index) {
                                                                      Map<String,
                                                                              dynamic>
                                                                          yorum =
                                                                          snapshot.data!["resimler"][i]["yorumlar"]
                                                                              [
                                                                              index];

                                                                      // Şimdi yorum içindeki bilgilere ulaşabilirsiniz
                                                                      String
                                                                          yazan =
                                                                          yorum['yazan'] ??
                                                                              '';
                                                                      String
                                                                          yorumMetni =
                                                                          yorum['yorum'] ??
                                                                              '';

                                                                      return ListTile(
                                                                        title: Text(
                                                                            yorumMetni),
                                                                        leading:
                                                                            FutureBuilder(
                                                                          future:
                                                                              getProfilResmiUrl(yazan),
                                                                          builder:
                                                                              (context, snapshot) {
                                                                            if (snapshot.connectionState ==
                                                                                ConnectionState.waiting) {
                                                                              return CircularProgressIndicator();
                                                                            } else if (snapshot.hasError) {
                                                                              return Icon(Icons.error);
                                                                            } else {
                                                                              return GestureDetector(
                                                                                onTap: () async {
                                                                                  var isim = await getUserName(yazan);
                                                                                  Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                      builder: (context) => BaskaProfile(
                                                                                        isim: isim.toString(),
                                                                                        arkadasId: yazan,
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                                child: CircleAvatar(
                                                                                  backgroundImage: NetworkImage(snapshot.data.toString()),
                                                                                ),
                                                                              );
                                                                            }
                                                                          },
                                                                        ),
                                                                      );
                                                                    },
                                                                  );
                                                                }),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20.0),
                                                        child: Align(
                                                            alignment: Alignment
                                                                .bottomRight,
                                                            child:
                                                                FloatingActionButton(
                                                                    child: Icon(
                                                                        Icons
                                                                            .add),
                                                                    onPressed:
                                                                        () async {
                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                Text("Yorum ekle"),
                                                                            content:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                TextYorumYazma(
                                                                                  labelText: 'Yorum Yazınız',
                                                                                ),
                                                                                TextButton(
                                                                                  onPressed: () async {
                                                                                    await yorumEkle(yorumController.text, widget.arkadasId, i);
                                                                                    yorumController.text = " ";

                                                                                    Navigator.pop(context); // Close the dialog after adding the comment
                                                                                  },
                                                                                  child: Text("Yorum Ekle"),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          );
                                                                        },
                                                                      );
                                                                    })),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            color: AppColors.greyColor
                                                .withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            image: DecorationImage(
                                              scale: 2.3,
                                              image: AssetImage(
                                                  "assets/images/ic_message.png"),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      GestureDetector(
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            color: AppColors.greyColor
                                                .withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            image: DecorationImage(
                                              scale: 2.3,
                                              image: AssetImage(
                                                  "assets/images/ic_bookmark.png"),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      GestureDetector(
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            color: AppColors.greyColor
                                                .withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            image: DecorationImage(
                                              scale: 2.3,
                                              image: AssetImage(
                                                  "assets/images/ic_send.png"),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                            ),
                            Positioned(
                              width: 5,
                              height: 30,
                              right: 72,
                              top: 200,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.whiteColor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ),

                          ]),
                        ));
                      }
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: userWidgets,
                    );
                  },
                );
              },
            ),
            Positioned(
              bottom: (showBottonNavBar == false) ? -41 : -35,
              child: Transform.rotate(
                angle: 11,
                child: InkWell(
                  onTap: () {
                    Provider.of<BottomNavBarProvider>(context, listen: false)
                        .toggleBottomNavBar();
                  },
                  child: ClipPath(
                    clipper: ClipStatusBar(),
                    child: Container(
                      height: 110,
                      width: 40,
                      color: AppColors.blackColor,
                      child: const Icon(
                        Icons.add,
                        size: 24,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar:
            Consumer<BottomNavBarProvider>(builder: (context, provider, child) {
          if (provider.showBottomNavBar) {
            return BottomNavbar();
          } else {
            return SizedBox.shrink();
          }
        }));
  }
}

class BottomNavBarProvider with ChangeNotifier {
  bool _showBottomNavBar = true;

  bool get showBottomNavBar => _showBottomNavBar;

  void toggleBottomNavBar() {
    _showBottomNavBar = !_showBottomNavBar;
    notifyListeners();
  }
}

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(right: 24, left: 24, bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildItemBottomNavBar("assets/images/ic_home.png", "Home", true),
          _buildItemBottomNavBar(
              "assets/images/ic_discorvery.png", "Discover", false),
          _buildItemBottomNavBar("assets/images/ic_inbox.png", "Inbox", false),
          _buildItemBottomNavBar(
              "assets/images/ic_profile.png", "Profile", false),
        ],
      ),
    );
  }
}

_buildItemBottomNavBar(String icon, String title, bool selected) {
  if (title == "Profile")
    return InkWell(
      onTap: () async {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .get();

        profilResmi = userSnapshot["imageUrl"];
        String isim = userSnapshot["isim"];

        Navigator.push(
          navigatorKey.currentContext as BuildContext,
          MaterialPageRoute(
            builder: (context) => ProfilePage(
              isim: isim,
            ),
          ),
        );
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: selected ? AppColors.whiteColor : Colors.transparent,
          boxShadow: [
            if (selected)
              BoxShadow(
                color: AppColors.blackColor.withOpacity(0.1),
                blurRadius: 35,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              width: 24,
              height: 24,
              color: selected ? AppColors.purpleColor : AppColors.blackColor,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.bold,
                fontSize: 12,
                color: selected ? AppColors.purpleColor : AppColors.blackColor,
              ),
            ),
          ],
        ),
      ),
    );
  if (title == "Inbox")
    return InkWell(
      onTap: () {
        Navigator.push(
          navigatorKey.currentContext as BuildContext,
          MaterialPageRoute(
            builder: (context) => KonusmaListele(),
          ),
        );
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: selected ? AppColors.whiteColor : Colors.transparent,
          boxShadow: [
            if (selected)
              BoxShadow(
                color: AppColors.blackColor.withOpacity(0.1),
                blurRadius: 35,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              width: 24,
              height: 24,
              color: selected ? AppColors.purpleColor : AppColors.blackColor,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.bold,
                fontSize: 12,
                color: selected ? AppColors.purpleColor : AppColors.blackColor,
              ),
            ),
          ],
        ),
      ),
    );
  if (title == "Discover")
    return InkWell(
      onTap: () {
        Navigator.push(
          navigatorKey.currentContext as BuildContext,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: selected ? AppColors.whiteColor : Colors.transparent,
          boxShadow: [
            if (selected)
              BoxShadow(
                color: AppColors.blackColor.withOpacity(0.1),
                blurRadius: 35,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              width: 24,
              height: 24,
              color: selected ? AppColors.purpleColor : AppColors.blackColor,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.bold,
                fontSize: 12,
                color: selected ? AppColors.purpleColor : AppColors.blackColor,
              ),
            ),
          ],
        ),
      ),
    );
  if (title == "Home")
    return InkWell(
      onTap: () {
        Navigator.push(
          navigatorKey.currentContext as BuildContext,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: selected ? AppColors.whiteColor : Colors.transparent,
          boxShadow: [
            if (selected)
              BoxShadow(
                color: AppColors.blackColor.withOpacity(0.1),
                blurRadius: 35,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              width: 24,
              height: 24,
              color: selected ? AppColors.purpleColor : AppColors.blackColor,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.bold,
                fontSize: 12,
                color: selected ? AppColors.purpleColor : AppColors.blackColor,
              ),
            ),
          ],
        ),
      ),
    );
  else
    return Container();
}

_buildBackgroundGradient() => Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.whiteColor.withOpacity(0),
          AppColors.whiteColor.withOpacity(0.8),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
    );

CustomAppBar _buildCustomAppBar(BuildContext context) {
  return CustomAppBar(
    child: Row(
      children: [
        const SizedBox(width: 8),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.blackColor.withOpacity(0.2),
                blurRadius: 35,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/ic_logo.png',
            width: 40,
            height: 40,
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () {
            Navigator.push(
              navigatorKey.currentContext as BuildContext,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          },
          child: Image.asset("assets/images/ic_notification.png",
              width: 24, height: 24),
        ),
        const SizedBox(width: 12),
        Image.asset("assets/images/ic_search.png", width: 24, height: 24),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            color: AppColors.backgroundColor,
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                child: Icon(
                  Icons.person_add,
                  color: AppColors.blackColor,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.whiteColor,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blackColor.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "Sajon.co",
                style: AppTheme.blackTextStyle
                    .copyWith(fontWeight: AppTheme.bold, fontSize: 12),
              ),
              const SizedBox(width: 2),
              Image.asset(
                "assets/images/ic_checklist.png",
                width: 16,
              ),
              const SizedBox(width: 4),
            ],
          ),
        )
      ],
    ),
  );
}

Container _buildItemPublisher(
    BuildContext context, String profilUrl, String isim) {
  return Container(
    padding: const EdgeInsets.only(left: 18, right: 40, bottom: 24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: (profilUrl == "")
                    ? Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.greyColor.withOpacity(0.17),
                          image: const DecorationImage(
                            scale: 2.3,
                            image: AssetImage("assets/images/ic_profile.png"),
                          ),
                        ),
                      )
                    : Image.network(
                        profilUrl,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 8),
              Text(
                (isim == "") ? "isimsiz" : isim,
                style: AppTheme.whiteTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: AppTheme.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "çok iyi birisi",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.whiteTextStyle.copyWith(
            fontSize: 12,
            fontWeight: AppTheme.regular,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "#cokiyibirkisi",
          style: AppTheme.whiteTextStyle.copyWith(
            color: AppColors.greenColor,
            fontSize: 12,
            fontWeight: AppTheme.medium,
          ),
        ),
      ],
    ),
  );
}

Align _buildImageGradient() {
  return Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.2),
            Colors.black.withOpacity(0.6),
          ],
        ),
      ),
    ),
  );
}

Widget _buildImageCover(String url) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(30),
    child: Stack(children: [
      Image.network(
        url,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              height: 55,
              width: 55,
              child: CircularProgressIndicator(
                color: Colors.white.withOpacity(0.8),
                strokeWidth: 1.2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      )
    ]),
  );
}
