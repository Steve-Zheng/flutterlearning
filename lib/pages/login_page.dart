import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlearning/friend.dart';
import 'package:flutterlearning/pages/verification_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

import 'package:flutterlearning/pages/favors_page.dart';


class LoginPage extends StatefulWidget{
  final List<Friend> friends;
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
  Image _imageForWeb;
  bool _labeling = false;
  List<ImageLabel> _labels = [];
  ConfirmationResult confirmationResult;
  @override
  void initState(){
    super.initState();
    if(FirebaseAuth.instance.currentUser != null){
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>FavorsPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Login",
                  style: Theme.of(context).textTheme.headline2.copyWith(color: Theme.of(context).primaryColor),
                ),
              ],
            ),
            Stepper(
              type: StepperType.vertical,
              steps: <Step>[
                Step(
                  state: _stepState[0],
                  isActive: _enteringPhoneNumber(),
                  title: Text("Enter your phone number"),
                  content: TextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[0-9+]")),
                    ],
                    onChanged: (value){
                      setState(() {
                        _phoneNumber = value;
                      });
                    },
                  ),
                ),
                Step(
                  state: _stepState[1],
                  isActive: _enteringVerificationCode(),
                  title: Text("Enter verification code"),
                  content: VerificationCodeInput(
                    onChanged: (value){
                      setState(() {
                        _smsCode = value;
                      });
                    }
                  ),
                ),
                Step(
                  state: _stepState[2],
                  isActive: _enteringProfile(),
                  title: Text("Profile"),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        child: CircleAvatar(
                          backgroundImage: _imageFile != null ? (kIsWeb? _imageForWeb.image:FileImage(_imageFile)) : (kIsWeb? AssetImage('images/default_avatar.png'):AssetImage('assets/images/default_avatar.png')),
                        ),
                        onTap: (){
                          _importImage();
                        },
                      ),
                      Container(
                        height: 16.0,
                      ),
                      Text(_labeling ? "Labeling the captured image..." : "Capture a image to start labeling. Not supported in web yet."),
                      Container(
                        height: 32.0,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: min(_labels.length, 5),
                        scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, int index) => Text("${_labels[index].text}, confidence: ${_labels[index].confidence}"),
                      ),
                      Container(
                        height: 16.0,
                      ),
                      TextField(
                        decoration: InputDecoration(hintText: "User name"),
                        onChanged: (value){
                          setState(() {
                            _displayName = value;
                          });
                        },
                      )
                    ],
                  ),
                ),
              ],
              currentStep: _currentStep,
              controlsBuilder: _stepControlsBuilder,
              onStepContinue: (){
                switch(_currentStep){
                  case 0:{_sendVerificationCode();}break;
                  case 1:{_executeLogin();}break;
                  default: {_saveProfile();}break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepControlsBuilder(BuildContext context,{VoidCallback onStepContinue, VoidCallback onStepCancel}){
    if(_showProgress){
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [CircularProgressIndicator()],
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: onStepContinue,
          child: Text("Continue"),
        ),
      ],
    );
  }

  bool _enteringPhoneNumber() => _currentStep == 0 && _stepState[0] == StepState.editing;
  bool _enteringVerificationCode() => _currentStep == 1 && _stepState[1] == StepState.editing;
  bool _enteringProfile() => _currentStep == 2 && _stepState[2] == StepState.editing;

  void _goBackToFirstStep() {
    setState(() {
      _showProgress = false;
      _stepState[0] = StepState.editing;
      _stepState[1] = StepState.indexed;
      _currentStep = 0;
    });
  }

  void _goToVerificationStep() {
    setState(() {
      _stepState[0] = StepState.complete;
      _stepState[1] = StepState.editing;
      _currentStep = 1;
    });
  }

  void _goToProfileStep() {
    setState(() {
      _showProgress = false;
      _stepState[1] = StepState.complete;
      _stepState[2] = StepState.editing;
      _currentStep = 2;
    });
  }

  void _loggedIn(){
    setState(() {
      _showProgress = false;
      _stepState[1] = StepState.complete;
    });
  }

  void _sendVerificationCode() async {
    final PhoneCodeSent codeSent = (String verID, [int forceCodeResend]) {
      _verificationId = verID;
      _goToVerificationStep();
    };

    final PhoneVerificationCompleted verificationSuccess = (AuthCredential phoneAuthCredential){
      _loggedIn();
    };

    final PhoneVerificationFailed verificationFail = (FirebaseAuthException exception){
      _goBackToFirstStep();
    };

    final PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout = (String verID){
      this._verificationId = verID;
    };
    FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
    if(kIsWeb){
      confirmationResult = await FirebaseAuth.instance.signInWithPhoneNumber(_phoneNumber);
      _goToVerificationStep();
    }
    else {
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: _phoneNumber,
          verificationCompleted: verificationSuccess,
          verificationFailed: verificationFail,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: autoRetrievalTimeout
      );
    }
  }

  void _executeLogin() async {
    setState(() {
      _showProgress = true;
    });

    if(kIsWeb){
      await confirmationResult.confirm(_smsCode);
    }
    else {
      await FirebaseAuth.instance.signInWithCredential(
          PhoneAuthProvider.credential(
            verificationId: _verificationId,
            smsCode: _smsCode,
          )
      );
    }
    if(FirebaseAuth.instance.currentUser != null){
      _goToProfileStep();
    }
  }

  void _saveProfile() async {
    setState(() {
      _showProgress = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    await user.updateProfile(displayName: _displayName);
    if(_imageFile != null){
      user.updateProfile(photoURL: await _uploadPicture(user.uid));
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => FavorsPage(),
      ),
    );
  }

  void _importImage() async {
    final _picker = ImagePicker();
    PickedFile _image = await _picker.getImage(source: ImageSource.camera);
    setState(() {
      _imageForWeb = Image.network(_image.path);
      _imageFile = File(_image.path);
    });
    if(!kIsWeb){
      _labelImage();
    }
  }

  _uploadPicture(String userID) async {
    Reference ref;
    if(!kIsWeb){
      ref = FirebaseStorage.instance.ref().child('profiles').child('profile_$userID');
      await ref.putFile(_imageFile);
    } else{
      ref = FirebaseStorage.instance.ref().child('profiles').child('default_avatar.png');
    }
    return await ref.getDownloadURL();
  }

  _labelImage() async {
    if(_imageFile == null){
      return;
    }

    setState(() {
      _labeling = true;
    });

    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(_imageFile);
    final ImageLabeler labelDetector = FirebaseVision.instance.imageLabeler();

    List<ImageLabel> labels = await labelDetector.processImage(visionImage);

    setState(() {
      _labels = labels;
      _labeling = false;
    });
  }
}