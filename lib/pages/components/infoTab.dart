import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutterlearning/classes/favor.dart';

import 'package:flutterlearning/pages/loginPage.dart';

class InfoTab extends StatefulWidget {
  InfoTab({Key key}) : super(key: key);

  @override
  _InfoTabState createState() => new _InfoTabState();
}

class _InfoTabState extends State<InfoTab> {
  String _phoneNumber;
  String _displayName;

  File _imageFile;
  String _newName;

  @override
  void initState() {
    _phoneNumber = FirebaseAuth.instance.currentUser.phoneNumber;
    _displayName = FirebaseAuth.instance.currentUser.displayName;
    super.initState();
  }

  Future<void> _getImage(BuildContext context) async {
    if (kIsWeb) {
      return;
    }
    final _picker = ImagePicker();
    PickedFile _image = await _picker.getImage(source: ImageSource.camera, maxHeight: 640, maxWidth: 640);
    setState(() {
      _imageFile = File(_image.path);
    });
  }

  Future<void> _uploadImage() async {
    User _currentUser = FirebaseAuth.instance.currentUser;
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('profiles')
        .child('profile_${_currentUser.uid}');
    await ref.putFile(_imageFile);
    String _photoURL = await ref.getDownloadURL();
    await _currentUser.updateProfile(photoURL: _photoURL);
    await FirebaseFirestore.instance
        .collection('favors')
        .where('friend.number', isEqualTo: _currentUser.phoneNumber)
        .get()
        .then((snapshot) => {
              if (snapshot.docs.length != 0)
                {
                  snapshot.docs.forEach((element) {
                    Favor favor = Favor.fromMap(element.id, element.data());
                    favor = favor.copyWith(
                        friend: favor.friend.copyWith(photoURL: _photoURL));
                    FirebaseFirestore.instance
                        .collection('favors')
                        .doc(element.id)
                        .set(favor.toJson());
                  })
                }
            });
  }

  Future<void> _changePhoto(BuildContext context) async {
    bool _showProgress = false;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text("Edit profile photo"),
                //TODO: Implement AlertDialog
                content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16.0,
                      ),
                      Center(
                        child: InkWell(
                          child: CircleAvatar(
                            backgroundImage: _imageFile == null
                                ? NetworkImage(
                                    FirebaseAuth.instance.currentUser.photoURL)
                                : FileImage(_imageFile),
                            radius: 48,
                          ),
                          onTap: ()async {
                                  await _getImage(context);
                                  setState((){});
                          }
                        ),
                      ),
                      Container(
                        height: 16.0,
                      ),
                      _showProgress
                          ? Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CircularProgressIndicator(),
                                ],
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    _imageFile = null;
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text("Save"),
                                  onPressed: _imageFile == null
                                      ? null
                                      : () async {
                                          setState(() {
                                            _showProgress = true;
                                          });
                                          await _uploadImage();
                                          setState(() {
                                            _showProgress = false;
                                          });
                                          _imageFile = null;
                                          Navigator.of(context).pop();
                                        },
                                ),
                              ],
                            )
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  Future<void> _editNameInFirestore() async {
    User _currentUser = FirebaseAuth.instance.currentUser;
    await _currentUser.updateProfile(displayName: _newName);
    await FirebaseFirestore.instance
        .collection('favors')
        .where('friend.number', isEqualTo: _currentUser.phoneNumber)
        .get()
        .then((snapshot) => {
              if (snapshot.docs.length != 0)
                {
                  snapshot.docs.forEach((element) {
                    Favor favor = Favor.fromMap(element.id, element.data());
                    favor = favor.copyWith(
                        friend: favor.friend.copyWith(name: _newName));
                    FirebaseFirestore.instance
                        .collection('favors')
                        .doc(element.id)
                        .set(favor.toJson());
                  })
                }
            });
  }

  Future<void> _changeName(BuildContext context) async {
    bool _showProgress = false;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text("Edit display name"),
                content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("Previous name: "),
                          _displayName == null
                              ? Text("Not Set",
                                  style: TextStyle(color: Colors.red))
                              : Text("$_displayName"),
                        ],
                      ),
                      Container(
                        height: 16.0,
                      ),
                      TextField(
                        decoration: InputDecoration(hintText: "New name"),
                        onChanged: (value) {
                          _newName = value;
                          setState(() {});
                        },
                      ),
                      Container(
                        height: 16.0,
                      ),
                      _showProgress
                          ? Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CircularProgressIndicator(),
                                ],
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    _newName = null;
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text("Save"),
                                  onPressed: _newName == null
                                      ? null
                                      : () async {
                                          setState(() {
                                            _showProgress = true;
                                          });
                                          await _editNameInFirestore();
                                          setState(() {
                                            _showProgress = false;
                                            _displayName = _newName;
                                          });
                                          _newName = null;
                                          Navigator.of(context).pop();
                                        },
                                ),
                              ],
                            )
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 32.0,
          ),
          InkWell(
            child: CircleAvatar(
              backgroundImage:
                  NetworkImage(FirebaseAuth.instance.currentUser.photoURL),
              radius: 48,
            ),
            onTap: () async {
              await _changePhoto(context);
              setState(() {});
            },
          ),
          Container(
            height: 16.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _displayName == null
                  ? Text("No username", style: TextStyle(color: Colors.red))
                  : Text("$_displayName"),
              InkWell(
                child: Icon(
                  Icons.edit,
                ),
                onTap: () async {
                  await _changeName(context);
                  setState(() {});
                },
              )
            ],
          ),
          Container(
            height: 16.0,
          ),
          Text("Phone number: $_phoneNumber"),
          Container(
            height: 32.0,
          ),
          InkWell(
            child: Text("Sign out"),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
    );
  }
}
