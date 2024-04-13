import 'package:arkadasekle/app/configs/colors.dart';
import 'package:arkadasekle/firebase_service.dart';
import 'package:arkadasekle/formfield.dart';
import 'package:arkadasekle/model.dart';
import 'package:arkadasekle/ui/pages/login.dart';
import 'package:arkadasekle/ui/widgets/background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}
String? userId;
String? token;

class _RegisterScreenState extends State<RegisterScreen> {



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Background(
        child: Form(key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[


              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "REGISTER",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    fontSize: 36
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "lütfen isminiz giriniz";
                    } else {
                      return null;
                    }
                  },
                  controller: isimController,
                  decoration: InputDecoration(
                    labelText: "Name"
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.03),

              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "please enter your email";
                    } else {
                      return null;
                    }
                  },
                  controller: emailController,
                  decoration: InputDecoration(
                      labelText: "E-mail"
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.03),

              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: TextFormField(
                  obscureText:true ,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "please enter your password";
                    } else {
                      return null;
                    }
                  },
                  controller: sifreController,
                  decoration: InputDecoration(
                      labelText: "Password"
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.05),

              Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child:SizedBox(height: 50.0,
                  width: size.width * 0.5,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(color: AppColors.primaryColor),
                       ),
                    onPressed: () async {
                      FirebaseService().kayitIslem(context);



                    },
                    child: Text(
                      "REGISTER",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.primaryColor),
                    ),
                  ),
                ),
              ),

              Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: GestureDetector(
                  onTap: () => {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()))
                  },
                  child: Text(
                    "Already Have an Account? Sign in",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                        color: AppColors.greyTextColor
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}