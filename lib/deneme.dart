import 'dart:ffi';

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
import '../../kayitpage.dart';
import '../../konusmalistele.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

import 'main.dart';

class DenemePage extends StatefulWidget {
  @override
  State<DenemePage> createState() => _DenemePageState();
}

String profilResmi = "";

class _DenemePageState extends State<DenemePage> {
  GlobalKey<_BottomNavbarState> bottomNavbarKey =
      GlobalKey<_BottomNavbarState>();
  bool isHidden = false;
  List resimler = [];

  @override
  Widget build(BuildContext context) {
    Future<void> toggleLike(String url, String ownerId) async {
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      try {
        DocumentReference ownerDocRef =
            _firestore.collection('users').doc(ownerId);

        // Get the owner's document
        DocumentSnapshot ownerDocSnapshot = await ownerDocRef.get();
        Map<String, dynamic> ownerData =
            ownerDocSnapshot.data() as Map<String, dynamic>;

        // Get the list of images from the owner's data
        List resimler = ownerData['resimler'] ?? [];

        // Find the index of the image with the given resimId
        int index = resimler.indexOf(url);

        // If the image is found in the owner's resimler list
        if (index != -1) {
          // Get the specific image data
          Map<String, dynamic> resimData = resimler[index];

          // Get the list of users who liked the image
          List<dynamic> likedBy = resimData['begenenler'] ?? [];

          // Check if the user has already liked the post
          bool alreadyLiked = likedBy.contains(ownerId);

          if (alreadyLiked) {
            // User already liked, so unlike the post
            likedBy.remove(ownerId);
          } else {
            // User hasn't liked, so like the post
            likedBy.add(ownerId);
          }

          // Update the specific image data

          // Update Firestore with new data
          await ownerDocRef.update({
            'resimler': resimler,
          });

          // Update local state if necessary
          setState(() {
            // You might not need to update the local state here
            // depending on how you're using it in your app
          });
        } else {
          print('Belge bulunamadı: $url');
        }
      } catch (e) {
        print('Error toggling like: $e');
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              List<QueryDocumentSnapshot> userDocuments = snapshot.data!.docs;
              return ListView.builder(
                itemCount: userDocuments.length,
                itemBuilder: (BuildContext context, int index) {
                  DocumentSnapshot userDocument = userDocuments[index];
                  String ownerId = userDocument.id;
                  Map<String, dynamic> userData =
                      userDocument.data() as Map<String, dynamic>;
                  String isim = userData['isim'] ?? "";
                  String ProfilUrl = userData['imageUrl'] ?? "";
                  resimler = userData['resimler'] ?? [];
                  List<Widget> userWidgets = [];
                  if (resimler.isEmpty) {
                    // Skip rendering content for users with no images or private accounts
                    return Container();
                  }

                  for (int i = 0; i < resimler.length; i++) {
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
                                        String ownerId = userDocument.id;
                                        toggleLike(resimler[i], ownerId);
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.whiteColor
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
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.whiteColor
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
                                          color: AppColors.whiteColor
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
                                          color: AppColors.whiteColor
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
                          Positioned(
                            bottom: 10, // Adjust this value as needed
                            left: 10, // Adjust this value as needed
                            child:
                                _buildItemPublisher(context, ProfilUrl, isim),
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
            bottom: (isHidden == true) ? 91 : -40,
            child: Transform.rotate(
              angle: 11,
              child: InkWell(
                onTap: () {
                  setState(() {
                    isHidden = !isHidden;
                  });
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
          if (isHidden == true) BottomNavbar(),
        ],
      ),
    );
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
      height: 110,
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
            builder: (context) => DenemePage(),
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
            builder: (context) => DenemePage(),
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
                builder: (context) => DenemePage(),
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
