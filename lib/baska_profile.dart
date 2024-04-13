import 'dart:io';
import 'package:arkadasekle/ui/pages/mesajpage.dart';
import 'package:arkadasekle/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arkadasekle/app/configs/colors.dart';
import 'package:arkadasekle/app/configs/theme.dart';
import 'package:arkadasekle/ui/bloc/gallery_profile_cubit.dart';
import 'package:image_picker/image_picker.dart';


import 'deneme5.dart';

class BaskaProfile extends StatefulWidget {
  String arkadasId;
  String isim;

  BaskaProfile({Key? key, required String this.isim, required this.arkadasId})
      : super(key: key);

  @override
  State<BaskaProfile> createState() => _BaskaProfileState();
}



class _BaskaProfileState extends State<BaskaProfile> {
  bool arkadasDurumu = false;
  String yazi = "friend add";
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<dynamic> resimler = [];
  String ProfilResimUrl = "";
  String isim = "";
  bool isLoading = true;
  bool hesapGizli = false;
  int arkadasSayisi = 0;

  late List arkadaslar;

  getSnapshotFuture() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.arkadasId)
        .get();

    setState(() {
      ProfilResimUrl = userSnapshot["imageUrl"];
      isim = userSnapshot["isim"];
      hesapGizli = userSnapshot["hesapGizli"] ?? false;
    });
  }

  getArkadasSayisi() async {
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(widget.arkadasId).get();
    if (userSnapshot.exists) {
      arkadaslar = userSnapshot['arkadaslar'];
      setState(() {
        arkadasSayisi = arkadaslar.length;
      });
    } else {
      print('Kullanıcı bulunamadı: $widget.arkadasId');
    }
  }

  @override
  initState() {
    super.initState();
    getSnapshotFuture();
    getResimler();
    getArkadasSayisi();
  }

  getResimler() async {
    try {
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection("users").doc(widget.arkadasId);
      DocumentSnapshot userSnapshot = await userDoc.get();
      if (!userSnapshot.exists) {
        print('User document not found');
        return;
      }
      resimler = userSnapshot['resimler'] ?? [];
    } catch (e) {
      print('Error getting comments: $e');
    }
  }

  Future<void> resimEkle(String resimUrl) async {
    try {
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection("users").doc(widget.arkadasId);

      // Get the user document
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (!userSnapshot.exists) {
        print('User document not found');
        return;
      }

      // Get the user's resimler list
      List<dynamic> resimler = userSnapshot['resimler'] ?? [];

      // Create a new resim object
      Map<String, dynamic> yeniResim = {
        'url': resimUrl,
        'begenenler': [],
        'yorumlar': []
      };

      // Add the new resim to the user's resimler list
      resimler.add(yeniResim);

      // Update Firestore with new data
      await userDoc.update({
        'resimler': resimler,
      });

      // Update local state if necessary
      setState(() {
        // Assuming resimler is a list in your widget state
        resimler.add(yeniResim);
      });
    } catch (e) {
      print('Error adding image: $e');
    }
  }

  profilResimEkle(String _imageUrl) async {
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(widget.arkadasId).get();
    if (userSnapshot.exists) {
      await _firestore.collection('users').doc(widget.arkadasId).update({
        'imageUrl': _imageUrl,
      });
      print('resim eklendi: $_imageUrl');
      setState(() {
        ProfilResimUrl = _imageUrl;
      });
    } else {
      print('Kullanıcı bulunamadı: $widget.arkadasId');
    }
    setState(() {});
  }

  Future<void> profilResminiGuncelle(String yeniResimUrl) async {
    // Eski resmi al
    String eskiResimUrl = ProfilResimUrl;

    // Eğer eski resim boş değilse, sil
    if (eskiResimUrl.isNotEmpty) {
      await FirebaseService().deleteImageFromStorage(eskiResimUrl);
    }

    // Yeni resmi veritabanına kaydet
    await _firestore.collection('users').doc(widget.arkadasId).update({
      'imageUrl': yeniResimUrl,
    });

    // State'i güncelle
    setState(() {
      ProfilResimUrl = yeniResimUrl;
    });
  }

  void profilResmiSil() async {
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(widget.arkadasId).get();
    if (userSnapshot.exists) {
      String currentImageUrl = userSnapshot['imageUrl'];
      if (currentImageUrl.isNotEmpty) {
        // Firestore'dan profil resmini sil
        await _firestore.collection('users').doc(widget.arkadasId).update({
          'imageUrl': FieldValue.delete(),
        });
        print('Profil resmi Firestore\'dan silindi.');

        // Firebase Storage'dan profil resmini sil
        await FirebaseService().deleteImageFromStorage(currentImageUrl);
        print('Profil resmi Firebase Storage\'dan silindi.');

        setState(() {
          ProfilResimUrl = "";
        });
      }
    } else {
      print('Kullanıcı bulunamadı: $widget.arkadasId');
    }
  }

  void resmiSil(int index) async {
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(widget.arkadasId).get();
    if (userSnapshot.exists) {
      List<dynamic> resimler = userSnapshot['resimler'] ?? [];
      if (index >= 0 && index < resimler.length) {
        String resimUrl = resimler[index];
        resimler.removeAt(index);

        // Firestore'dan resmi sil
        await _firestore.collection('users').doc(widget.arkadasId).update({
          'resimler': resimler,
        });
        print('Resim Firestore\'dan silindi.');

        // Firebase Storage'dan resmi sil
        await FirebaseService().deleteImageFromStorage(resimUrl);
        print('Resim Firebase Storage\'dan silindi.');

        setState(() {
          this.resimler = resimler;
        });
      }
    } else {
      print('Kullanıcı bulunamadı: $widget.arkadasId');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 24,
            color: AppColors.blackColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 24, left: 24, top: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildImageProfile(),
                const SizedBox(height: 16),
                Text(
                  widget.isim,
                  style: AppTheme.blackTextStyle.copyWith(
                    fontWeight: AppTheme.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 24),
                _buildDescription(),
                const SizedBox(height: 24),
                _buildButtonAction(),
                const SizedBox(height: 30),
                _buildTabBar(),
                const SizedBox(height: 24),
                if (hesapGizli) Text("hesap gizli"),
                if (!hesapGizli) _buildGridList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BlocProvider<GalleryProfileCubit> _buildGridList(BuildContext context) {
    return BlocProvider(
      create: (context) => GalleryProfileCubit()..getGalleryProfile(),
      child: BlocBuilder<GalleryProfileCubit, GalleryProfileState>(
        builder: (_, state) {
          if (state is GalleryProfileError) {
            return Center(child: Text(state.message));
          } else if (state is GalleryProfileLoaded) {
            return (resimler.length != 0)
                ? SizedBox(
                    height: 400,
                    width: double.infinity,
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                      childAspectRatio: 0.62,
                      physics: const BouncingScrollPhysics(),
                      children: List.generate(resimler.length, (index) {
                        return Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      resimler[index]["url"],
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 10,
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                // You can replace this with your actual like data from the state
                                resimler[index]["begenenler"].length.toString(),
                                style: AppTheme.blackTextStyle.copyWith(
                                  fontWeight: AppTheme.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  )
                : Container();
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Row _buildTabBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Photos",
          style: AppTheme.blackTextStyle.copyWith(
            fontWeight: AppTheme.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(width: 24),
        InkWell(onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserVideo(
                arkadasId: widget.arkadasId,
              ),
            ),
          );
        },
          child: Text(
            "Video",
            style: AppTheme.blackTextStyle.copyWith(
              fontWeight: AppTheme.bold,
              fontSize: 18,
              color: AppColors.greyColor,
            ),
          ),
        ),
        const SizedBox(width: 24),
        Text(
          "Tagged",
          style: AppTheme.blackTextStyle.copyWith(
            fontWeight: AppTheme.bold,
            fontSize: 18,
            color: AppColors.greyColor,
          ),
        ),
      ],
    );
  }

  Row _buildButtonAction() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              arkadasDurumu != arkadasDurumu;
              if (arkadasDurumu) {
                yazi = "friend add";
              } else {
                yazi = "friend";
              }
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            minimumSize: const Size(120, 45),
            elevation: 8,
            shadowColor: AppColors.primaryColor.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(yazi,
              style: AppTheme.whiteTextStyle
                  .copyWith(fontWeight: AppTheme.semiBold)),
        ),
        const SizedBox(width: 12),
        if (!hesapGizli)
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => MesajPage(
                          arkadasId: widget.arkadasId,
                          ArkadasIsim: widget.isim)));
            },
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.greyColor.withOpacity(0.17),
                image: const DecorationImage(
                  scale: 2.3,
                  image: AssetImage("assets/images/ic_inbox.png"),
                ),
              ),
            ),
          )
      ],
    );
  }

  Row _buildDescription() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              arkadasSayisi.toString(),
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Arkadaş",
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.regular,
                color: AppColors.greyColor,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "121.9k",
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Followers",
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.regular,
                color: AppColors.greyColor,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              arkadasSayisi.toString(),
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Likes",
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.regular,
                color: AppColors.greyColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Container _buildImageProfile() {
    return Container(
      width: 130,
      height: 130,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.dashedLineColor,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: (ProfilResimUrl == "")
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
            : InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: AppColors.whiteColor,
                        title: Text("Profil Resmi",
                            style: AppTheme.greyTextStyle.copyWith(
                              fontWeight: AppTheme.bold,
                              fontSize: 22,
                              color: AppColors.greyTextColor,
                            )),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () async {
                                Navigator.of(context).pop();
                                File _imageFile =
                                    await pickImage(ImageSource.camera);
                                String _imageUrl =
                                    await uploadImage(_imageFile);
                                await profilResminiGuncelle(_imageUrl);
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  "Profil Resmini Güncelle",
                                  style: AppTheme.blackTextStyle.copyWith(
                                    fontWeight: AppTheme.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                                profilResmiSil();
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  "Profil Resmini Sil",
                                  style: AppTheme.blackTextStyle.copyWith(
                                    fontWeight: AppTheme.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Image.network(
                  ProfilResimUrl,
                  width: 120,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }
}
