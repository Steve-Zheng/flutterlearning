import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterlearning/pages/login_page.dart';
import 'package:flutterlearning/theme.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Demo",
      color: Colors.lightGreen,
      theme: greenTheme,
      home: LoginPage(),
    );
  }
}

