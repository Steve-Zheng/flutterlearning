import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterlearning/mock_values.dart';


import 'package:flutterlearning/pages/favors_page.dart';
import 'package:flutterlearning/pages/request_favor_page.dart';
import 'package:flutterlearning/pages/login_page.dart';
import 'package:flutterlearning/pages/loading.dart';
import 'package:flutterlearning/theme.dart';




void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FirebaseLoader());
}

class FirebaseLoader extends StatelessWidget{
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context,snapshot){
        if(snapshot.connectionState == ConnectionState.done){
          return NavigatorApp();
        }
        return LoadingPage();
      },
    );
  }
}

class NavigatorApp extends StatefulWidget{
  @override
  _NavigatorAppState createState() => _NavigatorAppState();
}

class _NavigatorAppState extends State<NavigatorApp>{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Demo",
      color: Colors.lightGreen,
      theme: greenTheme,
      routes: {
        '/':(context) => FavorsPage(),
        '/request': (context) => RequestFavorPage(friends: mockFriends,),
        '/login': (context) => LoginPage(),
      },
    );
  }
}


