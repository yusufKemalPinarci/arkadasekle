import 'dart:async';
import 'dart:io';

import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sentiment_dart/sentiment_dart.dart';
import 'package:arkadasekle/kisilerliste.dart';
import 'package:arkadasekle/ui/pages/register.dart';
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
import '../../arkadaslistele.dart';
import '../../baska_profile.dart';
import '../../firebase_service.dart';
import 'hikayeler_page.dart';
import '../../formfield.dart';
import 'konusmalistele.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../main.dart';


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
          print("tokenizken" + userSnapshot["token"]);
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

Future<String> getProfilResmiUrl(String userId) async {
  try {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    String profilResmiUrl = userSnapshot['imageUrl'] ?? '';
    return profilResmiUrl;
  } catch (e) {
    print('Error getting profile image URL: $e');
    return '';
  }
}

getUserName(String yazanId) async {
  try {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(yazanId).get();
    profilResmi = userSnapshot['imageUrl'] ?? '';
    return userSnapshot["isim"];
  } catch (e) {
    print('Error getting user name: $e');
    return '';
  }
}

getAciklama(String yazanId) async {
  try {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    DocumentSnapshot userSnapshot =
    await _firestore.collection('users').doc(yazanId).get();
    profilResmi = userSnapshot['imageUrl'] ?? '';
    return userSnapshot["isim"];
  } catch (e) {
    print('Error getting user name: $e');
    return '';
  }
}

String getEmotion(double score) {
  if (score < -5) {
    return "😢 Çok Kötü";
  } else if (score < 0) {
    return "☹️ Kötü";
  } else if (score < 3) {
    return "😐 Orta";
  } else if (score < 6) {
    return "😊 İyi";
  } else {
    return "😃 Çok İyi";
  }
}

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



class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

String profilResmi = "";
bool showBottonNavBar = false;
bool homeButtonSelected = true;
bool DiscoverButtonSelected = false;
bool FriendButtonSelected = false;
bool inboxButtonSelected = false;
bool profileButtonSelected = false;
String currentPage = "home";

class _HomePageState extends State<HomePage> {
  GlobalKey<_BottomNavbarState> bottomNavbarKey =
      GlobalKey<_BottomNavbarState>();
  bool isHidden = false;
  List resimler = [];
  List<dynamic> yorumlar = [];
  List videolar = [];
  int bottomSheetSize = 200;
  bool isButtonSelected = false;

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    String profilResmi = '';
    @override
    initState() {
      super.initState();
      // getYorumlar(ownerId);
    }
    Future<void> hikayeEkle(String resimUrl) async {
      try {
        DocumentReference userDoc =
        FirebaseFirestore.instance.collection("users").doc(userId);

        // Get the user document
        DocumentSnapshot userSnapshot = await userDoc.get();

        if (!userSnapshot.exists) {
          print('User document not found');
          return;
        }

        // Get the user's hikayeler list
        Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
        List<dynamic> hikayeler = userData?['hikayeler'] ?? [];

        // Create a new hikaye object
        Map<String, dynamic> yeniHikaye = {
          'url': resimUrl,
          'begenenler': [],
          'yorumlar': []
        };

        // Add the new hikaye to the user's hikayeler list
        hikayeler.add(yeniHikaye);

        // Update Firestore with new data
        await userDoc.set({
          'hikayeler': hikayeler,
        }, SetOptions(merge: true));

        // Update local state if necessary
        setState(() {
          // Assuming hikayeler is a list in your widget state
          hikayeler.add(yeniHikaye);
        });
      } catch (e) {
        print('Error adding hikaye: $e');
      }
    }

    return SafeArea(
      child: Scaffold(
          body: Column(
            children: [
              SizedBox(
                height: 100, // Profil resimlerinin yüksekliği
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {

                      if(snapshot.data==null){
                        return Center(child: CircularProgressIndicator());
                      }

                      List<QueryDocumentSnapshot> userDocuments =
                          snapshot.data!.docs;

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.data == null) {
                        return CircularProgressIndicator();
                      }
                      return Row(
                        children: [GestureDetector(
                          onTap: () async {
                            File _imageFile = await pickImage(ImageSource.camera);
                            String resimUrl = await uploadVideo(_imageFile!);
                            print("aga niga"+resimUrl);
                            print(userId);
                            hikayeEkle(resimUrl);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(child: Icon(Icons.add),
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryLightColor

                              ),
                            ),
                          ),
                        ),
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: userDocuments.length,
                              itemBuilder: (BuildContext context, int index) {
                                DocumentSnapshot userDocument = userDocuments[index];
                                Map<String, dynamic> userData =
                                    userDocument.data() as Map<String, dynamic>;
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    splashColor: AppColors.whiteColor,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return const StoryPagee();
                                          },
                                        ),
                                      );
                                      // Profil resmine tıklandığında yapılacak işlemler
                                    },
                                    child: (userData["imageUrl"] == "")
                                        ? GestureDetector(
                                      onTap: null,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.primaryLightColor

                                          ),
                                        ),
                                      ),
                                    )
                                        : GestureDetector(
                                      onTap: null,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(image: NetworkImage(userData["imageUrl"]))

                                          ),
                                        ),
                                      ),
                                    )
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        List<QueryDocumentSnapshot> userDocuments =
                            snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: userDocuments.length,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot userDocument =
                                userDocuments[index];
                            String ownerId = userDocument.id;
                            Map<String, dynamic> userData =
                                userDocument.data() as Map<String, dynamic>;
                            String isim = userData['isim'] ?? "";
                            String ProfilUrl = userData['imageUrl'] ?? "";
                            resimler = userData['resimler'] ?? [];
                            bool hesapGizli = userData['hesapGizli'] ?? false;

                            if (resimler.isEmpty || hesapGizli) {
                              // Skip rendering content for users with no images or private accounts
                              return Container();
                            }
                            List<Widget> userWidgets = [];
                            for (int i = 0; i < resimler.length; i++) {
                              bool isLiked =
                                  resimler[i]["begenenler"].contains(userId);
                              String imageeUrl = resimler[i]["url"];
                              String aciklama= "";
                              if (resimler[i].containsKey("aciklama")) { // "aciklama" anahtarı var mı kontrolü
                                 aciklama = resimler[i]["aciklama"];
                              }
                              if (imageeUrl != null && imageeUrl.isNotEmpty) {
                                userWidgets.add(SingleChildScrollView(
                                  child: Stack(children: [
                                    buildImageGradient(),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child:
                                            Container(width: double.infinity,child: Image.network(fit: BoxFit.cover,imageeUrl)),
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
                                              color: AppColors.whiteColor
                                                  .withOpacity(0.3),
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
                                                  String ownerId =
                                                      userDocument.id;
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
                                                        BorderRadius.circular(
                                                            30),
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
                                                    builder:
                                                        (BuildContext context) {
                                                      return SizedBox(
                                                        height: 250,
                                                        child: Center(
                                                          child: Stack(
                                                            children: <Widget>[
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: Expanded(
                                                                  child:
                                                                      Container(
                                                                    child: StreamBuilder<
                                                                            DocumentSnapshot>(
                                                                        stream: FirebaseFirestore
                                                                            .instance
                                                                            .collection(
                                                                                'users')
                                                                            .doc(
                                                                                ownerId)
                                                                            .snapshots(),
                                                                        builder: (BuildContext
                                                                                context,
                                                                            AsyncSnapshot<DocumentSnapshot>
                                                                                snapshot) {
                                                                          if (snapshot
                                                                              .hasError) {
                                                                            return Text('Error: ${snapshot.error}');
                                                                          }

                                                                          if (snapshot.connectionState ==
                                                                              ConnectionState.waiting) {
                                                                            return CircularProgressIndicator();
                                                                          }
                                                                          print(snapshot
                                                                              .data!
                                                                              .id);
                                                                          print(snapshot.data!["resimler"]
                                                                              [
                                                                              i]);

                                                                          return ListView
                                                                              .builder(
                                                                            itemCount:
                                                                                snapshot.data!["resimler"][i]["yorumlar"].length,
                                                                            itemBuilder:
                                                                                (BuildContext context, int index) {
                                                                              Map<String, dynamic> yorum = snapshot.data!["resimler"][i]["yorumlar"][index];

                                                                              // Şimdi yorum içindeki bilgilere ulaşabilirsiniz
                                                                              String yazan = yorum['yazan'] ?? '';
                                                                              String yorumMetni = yorum['yorum'] ?? '';

                                                                              return ListTile(
                                                                                title: InkWell(
                                                                                  onLongPress: () {
                                                                                    double puan = Sentiment.analysis(yorumMetni, languageCode: 'en').score;
                                                                                     String yorumAnaliz= getEmotion(puan);
                                                                                    showDialog(
                                                                                      context: context,
                                                                                      builder: (BuildContext context) {
                                                                                        return AlertDialog(
                                                                                          title: Text(yorumAnaliz),
                                                                                        );
                                                                                      },
                                                                                    );
                                                                                  },
                                                                                  child: Text(yorumMetni),
                                                                                ),
                                                                                leading: FutureBuilder(
                                                                                  future: getProfilResmiUrl(yazan),
                                                                                  builder: (context, snapshot) {
                                                                                    if (snapshot.connectionState == ConnectionState.waiting) {
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
                                                                        .all(
                                                                        20.0),
                                                                child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .bottomRight,
                                                                    child: FloatingActionButton(
                                                                        child: Icon(Icons.add),
                                                                        onPressed: () async {
                                                                          showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (BuildContext context) {
                                                                              return AlertDialog(
                                                                                title: Text("Yorum ekle"),
                                                                                content: Column(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    TextYorumYazma(
                                                                                      labelText: 'Yorum Yazınız',
                                                                                    ),
                                                                                    TextButton(
                                                                                      onPressed: () async {
                                                                                        await yorumEkle(yorumController.text, ownerId, i);
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
                                                        BorderRadius.circular(
                                                            30),
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
                                                        BorderRadius.circular(
                                                            30),
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
                                                        BorderRadius.circular(
                                                            30),
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
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10, // Adjust this value as needed
                                      left: 10, // Adjust this value as needed
                                      child: buildItemPublisher(
                                          context, ProfilUrl, isim,aciklama),
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
                    AcmaKapamaButton(),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Consumer<BottomNavBarProvider>(
              builder: (context, provider, child) {
            if (provider.showBottomNavBar) {
              return BottomNavbar();
            } else {
              return SizedBox.shrink();
            }
          })),
    );
  }
}

class AcmaKapamaButton extends StatefulWidget {
  const AcmaKapamaButton({
    super.key,
  });

  @override
  State<AcmaKapamaButton> createState() => _AcmaKapamaButtonState();
}

class _AcmaKapamaButtonState extends State<AcmaKapamaButton> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
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
    );
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

class BottomNavBarProvider2 extends ChangeNotifier {
  int selectedIndex = 0;

  void updateSelectedIndex(int index) {
    selectedIndex = index;
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
          Flexible(
            child: _buildItemBottomNavBar(
                context, "assets/images/home2.png", "Home", 0),
          ),
          Flexible(
              child: _buildItemBottomNavBar(
                  context, "assets/images/ic_discorvery.png", "Discover", 1)),
          Flexible(
              child: _buildItemBottomNavBar(
                  context, "assets/images/friend3.png", "Friend", 2)),
          Flexible(
            child: _buildItemBottomNavBar(
                context, "assets/images/ic_inbox.png", "Inbox", 3),
          ),
          Flexible(
              child: _buildItemBottomNavBar(
                  context, "assets/images/ic_profile.png", "Profile", 4)),
        ],
      ),
    );
  }
}

_buildItemBottomNavBar(
    BuildContext context, String icon, String title, int index) {
  if (title == "Profile")
    return InkWell(
      onTap: () async {
        context.read<BottomNavBarProvider2>().updateSelectedIndex(index);
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .get();

        profilResmi = userSnapshot["imageUrl"];
        String isim = userSnapshot["isim"];

        Navigator.pushReplacement(
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
          color:
              profileButtonSelected ? AppColors.whiteColor : Colors.transparent,
          boxShadow: [
            if (context.watch<BottomNavBarProvider2>().selectedIndex == index)
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
              color:
                  context.watch<BottomNavBarProvider2>().selectedIndex == index
                      ? AppColors.purpleColor
                      : AppColors.blackColor,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.bold,
                fontSize: 12,
                color: context.watch<BottomNavBarProvider2>().selectedIndex ==
                        index
                    ? AppColors.purpleColor
                    : AppColors.blackColor,
              ),
            ),
          ],
        ),
      ),
    );
  if (title == "Inbox")
    return InkWell(
      onTap: () {
        context.read<BottomNavBarProvider2>().updateSelectedIndex(index);
        Navigator.pushReplacement(
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
          color: context.watch<BottomNavBarProvider2>().selectedIndex == index
              ? AppColors.whiteColor
              : Colors.transparent,
          boxShadow: [
            if (context.watch<BottomNavBarProvider2>().selectedIndex == index)
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
              color:
                  context.watch<BottomNavBarProvider2>().selectedIndex == index
                      ? AppColors.purpleColor
                      : AppColors.blackColor,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.bold,
                fontSize: 12,
                color: context.watch<BottomNavBarProvider2>().selectedIndex ==
                        index
                    ? AppColors.purpleColor
                    : AppColors.blackColor,
              ),
            ),
          ],
        ),
      ),
    );
  if (title == "Discover")
    return InkWell(
      onTap: () {
        context.read<BottomNavBarProvider2>().updateSelectedIndex(index);
        Navigator.pushReplacement(
          navigatorKey.currentContext as BuildContext,
          MaterialPageRoute(
            builder: (context) => KisilerListele(),
          ),
        );
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: context.watch<BottomNavBarProvider2>().selectedIndex == index
              ? AppColors.whiteColor
              : Colors.transparent,
          boxShadow: [
            if (context.watch<BottomNavBarProvider2>().selectedIndex == index)
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
              color:
                  context.watch<BottomNavBarProvider2>().selectedIndex == index
                      ? AppColors.purpleColor
                      : AppColors.blackColor,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.bold,
                fontSize: 12,
                color: context.watch<BottomNavBarProvider2>().selectedIndex ==
                        index
                    ? AppColors.purpleColor
                    : AppColors.blackColor,
              ),
            ),
          ],
        ),
      ),
    );
  if (title == "Friend")
    return InkWell(
      onTap: () {
        context.read<BottomNavBarProvider2>().updateSelectedIndex(index);
        Navigator.pushReplacement(
          navigatorKey.currentContext as BuildContext,
          MaterialPageRoute(
            builder: (context) => ArkadasListele(),
          ),
        );
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: context.watch<BottomNavBarProvider2>().selectedIndex == index
              ? AppColors.whiteColor
              : Colors.transparent,
          boxShadow: [
            if (context.watch<BottomNavBarProvider2>().selectedIndex == index)
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
              color:
                  context.watch<BottomNavBarProvider2>().selectedIndex == index
                      ? AppColors.purpleColor
                      : AppColors.blackColor,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.bold,
                fontSize: 12,
                color: context.watch<BottomNavBarProvider2>().selectedIndex ==
                        index
                    ? AppColors.purpleColor
                    : AppColors.blackColor,
              ),
            ),
          ],
        ),
      ),
    );
  if (title == "Home")
    return InkWell(
      onTap: () {
        context.read<BottomNavBarProvider2>().updateSelectedIndex(index);
        Navigator.pushReplacement(
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
          color: context.watch<BottomNavBarProvider2>().selectedIndex == index
              ? AppColors.whiteColor
              : Colors.transparent,
          boxShadow: [
            if (context.watch<BottomNavBarProvider2>().selectedIndex == index)
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
              color:
                  context.watch<BottomNavBarProvider2>().selectedIndex == index
                      ? AppColors.purpleColor
                      : AppColors.blackColor,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.bold,
                fontSize: 12,
                color: context.watch<BottomNavBarProvider2>().selectedIndex ==
                        index
                    ? AppColors.purpleColor
                    : AppColors.blackColor,
              ),
            ),
          ],
        ),
      ),
    );
  else
    return Container();
}



Container buildItemPublisher(
    BuildContext context, String profilUrl, String isim,String aciklama) {
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
        Text(softWrap: true,
          overflow:TextOverflow.ellipsis,
          aciklama,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: AppTheme.regular,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "#yeniGönderi",
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

Align buildImageGradient() {
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

