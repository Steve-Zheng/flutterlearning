import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlearning/favor.dart';
import 'package:flutterlearning/friend.dart';
import 'package:flutterlearning/mock_values.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutterlearning/string_extension.dart';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

import 'package:flutterlearning/pages/favors_page.dart';

class LoginPage extends StatefulWidget{
  List<Friend> friends;
  LoginPage({Key key, this.friends}): super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>{
  String _phoneNumber;
  String _smsCode;
  String _verificationId;
  int _currentStep = 0;
  List<StepState> _stepState = [
    StepState.editing,
    StepState.indexed,
    StepState.indexed,
  ];
  bool _showProgress = false;
  String _displayName;
  File _imageFile;
  bool _labeling = false;
  List<ImageLabel> _labels = [];
  @override
  void initState(){
    super.initState();
    if(FirebaseAuth.instance.currentUser != null){
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>FavorsPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    //TODO: Implement Login page
    throw UnimplementedError();
  }
}