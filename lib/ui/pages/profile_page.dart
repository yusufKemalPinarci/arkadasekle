import 'dart:io';

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

import '../../girispage.dart';
import '../../kayitpage.dart';

class ProfilePage extends StatefulWidget {


   String isim;
   ProfilePage({Key? key,required String this.isim}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<dynamic> resimler = [];
  String ProfilResimUrl = "";
  String isim = "";
  bool isLoading = true;
  bool hesapGizli = false;
  int arkadasSayisi=0;

  getSnapshotFuture() async {
    DocumentSnapshot userSnapshot =
    await FirebaseFirestore.instance.collection("users").doc(userId).get();

    setState(() {
      ProfilResimUrl = userSnapshot["imageUrl"];
      isim = userSnapshot["isim"];
      hesapGizli = userSnapshot["hesapGizli"] ?? false;
    });
  }
  getArkadasSayisi() async {
    DocumentSnapshot userSnapshot =
    await _firestore.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      List arkadaslar = userSnapshot['arkadaslar'];
      setState(() {
        arkadasSayisi=arkadaslar.length;

      });
    } else {
      print('Kullanıcı bulunamadı: $userId');
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
      DocumentReference userDoc = FirebaseFirestore.instance.collection("users").doc(userId);
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
      DocumentReference userDoc = FirebaseFirestore.instance.collection("users").doc(userId);

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
    await _firestore.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      await _firestore.collection('users').doc(userId).update({
        'imageUrl': _imageUrl,
      });
      print('resim eklendi: $_imageUrl');
      setState(() {
        ProfilResimUrl = _imageUrl;
      });
    } else {
      print('Kullanıcı bulunamadı: $userId');
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
    await _firestore.collection('users').doc(userId).update({
      'imageUrl': yeniResimUrl,
    });

    // State'i güncelle
    setState(() {
      ProfilResimUrl = yeniResimUrl;
    });
  }


  void profilResmiSil() async {
    DocumentSnapshot userSnapshot =
    await _firestore.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      String currentImageUrl = userSnapshot['imageUrl'];
      if (currentImageUrl.isNotEmpty) {
        // Firestore'dan profil resmini sil
        await _firestore.collection('users').doc(userId).update({
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
      print('Kullanıcı bulunamadı: $userId');
    }
  }

  void resmiSil(int index) async {
    DocumentSnapshot userSnapshot =
    await _firestore.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      List<dynamic> resimler = userSnapshot['resimler'] ?? [];
      if (index >= 0 && index < resimler.length) {
        String resimUrl = resimler[index];
        resimler.removeAt(index);

        // Firestore'dan resmi sil
        await _firestore.collection('users').doc(userId).update({
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
      print('Kullanıcı bulunamadı: $userId');
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
    return Scaffold(floatingActionButton: FloatingActionButton(onPressed: ()async {
      File _imageFile = await pickImage(ImageSource.camera);
      String imageUrl = await uploadImage(_imageFile!);
      resimEkle(imageUrl);
    },child: Icon(Icons.add),),
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
        actions: [
          Builder(
            builder: (BuildContext context) {
              return InkWell(
                onTap: () {
                  RenderBox renderBox = context.findRenderObject() as RenderBox;
                  var offset = renderBox.localToGlobal(Offset.zero);
                  showMenu(color:AppColors.whiteColor,
                    context: context,
                    position: RelativeRect.fromLTRB(offset.dx, offset.dy, 0, 0),
                    items: [
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(color: AppColors.blackTextColor,Icons.exit_to_app),
                          title: Text(selectionColor:  AppColors.blackTextColor,'Logout'),
                          onTap: () async{
                            await signOut();

                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GirisSayfasi(),
                            ),
                          );

                            // Handle logout action here
                            Navigator.pop(context); // Close the menu
                          },
                        ),
                      ),
                    ],
                  );
                },
                child: Icon(
                  Icons.more_horiz_rounded,
                  size: 24,
                  color: AppColors.blackColor,
                ),
              );
            },
          ),
          SizedBox(width: 24),
        ],
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
                _buildGridList(context),
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

            return (resimler.length!=0)?SizedBox(
              height: 400,
              width: double.infinity,
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 0.62,
                physics: const BouncingScrollPhysics(),
                children: List.generate(
                  resimler.length,
                      (index) => Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      GestureDetector(onLongPress: (){
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Resmi Sil" ,style: AppTheme.greyTextStyle.copyWith(
                              fontWeight: AppTheme.bold,
                                fontSize: 22,
                                color: AppColors.greyTextColor
                              ),),
                              content: Text("resmi silmek istediğinize emin misiniz?", style: AppTheme.blackTextStyle.copyWith(

                                fontSize: 12,
                              ),),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    resmiSil(index);
                                  },
                                  child: Text("Sil" ,style: AppTheme.blackTextStyle.copyWith(
                            fontWeight: AppTheme.bold,
                            fontSize: 16,
                                    color: AppColors.purpleColor
                            ),),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("İptal",style: AppTheme.blackTextStyle.copyWith(
                                      fontWeight: AppTheme.bold,
                                      fontSize: 16,
                                      color: AppColors.purpleColor
                                  )),
                                ),
                              ],
                            );
                          },
                        );

                      },
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
                  ),
                ),
              ),
            ):Container();
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }


  Row _buildTabBar() {
    return Row(mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Photos",
          style: AppTheme.blackTextStyle.copyWith(
            fontWeight: AppTheme.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(width: 24),
        Text(
          "Video",
          style: AppTheme.blackTextStyle.copyWith(
            fontWeight: AppTheme.bold,
            fontSize: 18,
            color: AppColors.greyColor,
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
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.greenColor,
            minimumSize: const Size(120, 45),
            elevation: 8,
            shadowColor: AppColors.primaryColor.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('Follow',
              style: AppTheme.whiteTextStyle
                  .copyWith(fontWeight: AppTheme.semiBold)),
        ),
        const SizedBox(width: 12),
        Container(
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
              "7.5M",
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
        child: (ProfilResimUrl=="")?Container(
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
        ):InkWell(onTap: (){
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(backgroundColor: AppColors.whiteColor,
                title: Text("Profil Resmi",style: AppTheme.greyTextStyle.copyWith(
                  fontWeight: AppTheme.bold,
                  fontSize: 22,
                  color:  AppColors.greyTextColor,
                )),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () async {
                        Navigator.of(context).pop();
                        File _imageFile =
                        await pickImage(
                            ImageSource.camera);
                        String _imageUrl =
                        await uploadImage(_imageFile);
                        await profilResminiGuncelle(_imageUrl);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0),
                        child: Text(
                            "Profil Resmini Güncelle", style: AppTheme.blackTextStyle.copyWith(
                          fontWeight: AppTheme.bold,
                          fontSize: 16,
                        ),),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        profilResmiSil();
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0),
                        child: Text("Profil Resmini Sil",style: AppTheme.blackTextStyle.copyWith(
                          fontWeight: AppTheme.bold,
                          fontSize: 16,
                        ),),
                      ),
                    ),
                  ],
                ),
              );
            },
          );

        },
          child: Image.network(ProfilResimUrl,
                 width: 120,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
