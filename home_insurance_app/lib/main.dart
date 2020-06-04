import 'package:flutter/material.dart';
import 'package:homeinsuranceapp/pages/home.dart';
import 'login_screen.dart';
import 'package:homeinsuranceapp/pages/contact.dart';
import 'package:homeinsuranceapp/pages/profile.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home',
      initialRoute: WelcomeScreen.id,
      routes: {
        // '/':(context)=>HomePage(),
        WelcomeScreen.id: (context) => WelcomeScreen(),
        HomePage.id: (context) => HomePage(),
        Contact.id: (context) => Contact(),

        Profile.id: (context) => Profile(),
      },
    );
  }
}
