import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlearning/classes/favor.dart';
import 'package:flutterlearning/classes/friend.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class RequestFavorPage extends StatefulWidget {
  final List<Friend> friends;

  RequestFavorPage({Key key, this.friends}) : super(key: key);

  @override
  _RequestFavorPageState createState() => new _RequestFavorPageState();
}

class _RequestFavorPageState extends State<RequestFavorPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Friend _selectedFriend;
  DateTime _dueDate;
  String _description;
  Future<List<Friend>> friends;

  static _RequestFavorPageState of(BuildContext context) =>
      context.findAncestorStateOfType<_RequestFavorPageState>();

  Future<List<Friend>> _getFriends() async {
    Friend newFriend = Friend(name: 'New number', uuid: 'new');
    List<Friend> friends;
    friends = widget.friends..add(newFriend);
    return Future.delayed(Duration(seconds: 1), () => friends);
  }

  @override
  void initState() {
    super.initState();

    friends = _getFriends();
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    super.dispose();
  }

  _saveFavorOnFirebase(Favor favor) async {
    await FirebaseFirestore.instance
        .collection('favors')
        .doc()
        .set(favor.toJson());
  }

  void save(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      final user = FirebaseAuth.instance.currentUser;
      await _saveFavorOnFirebase(Favor(
        to: _selectedFriend.number,
        description: _description,
        dueDate: _dueDate,
        friend: Friend(
          name: user.displayName,
          number: user.phoneNumber,
          photoURL: user.photoURL,
        ),
      ));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "request_page",
      child: Scaffold(
        appBar: AppBar(
          leading: CloseButton(),
          title: Text("Requesting a favor"),
          actions: [
            Builder(
              builder: (context) => TextButton(
                child: Text("Save"),
                onPressed: () {
                  _RequestFavorPageState.of(context).save(context);
                },
                style: ButtonStyle(
                  foregroundColor: MaterialStateColor.resolveWith(
                      (Set<MaterialState> states) {
                    return states.contains(MaterialState.pressed)
                        ? Colors.grey
                        : Colors.white;
                  }),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: new FutureBuilder(
                future: friends,
                builder: (BuildContext context,
                    AsyncSnapshot<List<Friend>> snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          DropdownButtonFormField<Friend>(
                            value: _selectedFriend,
                            onChanged: (friend) {
                              setState(() {
                                _selectedFriend = friend;
                              });
                            },
                            items: snapshot.data
                                .map(
                                  (f) => DropdownMenuItem<Friend>(
                                    value: f,
                                    child: Text(f.name),
                                  ),
                                )
                                .toList(),
                            validator: (friend) {
                              if (friend == null) {
                                return "You must select a friend to ask the favor";
                              }
                              return null;
                            },
                          ),
                          _selectedFriend?.uuid == 'new'
                              ? TextFormField(
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                      hintText: "Friend phone number"),
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(20),
                                  ],
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return "Please enter friend phone number";
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _selectedFriend = Friend(number: value);
                                  },
                                )
                              : Container(
                                  height: 0,
                                ),
                          _selectedFriend?.uuid == 'new' ||
                                  _selectedFriend == null
                              ? Container(
                                  height: 0,
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 16.0,
                                    ),
                                    Row(
                                      children: [
                                        Text("Selected phone number: "),
                                        Text(
                                          "${_selectedFriend?.number}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                          Container(
                            height: 16.0,
                          ),
                          Text("Favor description:"),
                          TextFormField(
                            maxLines: 3,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(120)
                            ],
                            validator: (value) {
                              if (value.isEmpty) {
                                return "No description provided";
                              }
                              return null;
                            },
                            onSaved: (description) {
                              _description = description;
                            },
                          ),
                          Container(
                            height: 16.0,
                          ),
                          Text("Due date:"),
                          DateTimeField(
                            format: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
                            onShowPicker: (context, currentValue) async {
                              final date = await showDatePicker(
                                  context: context,
                                  initialDate: currentValue ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100));
                              if (date != null) {
                                final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(
                                        currentValue ?? DateTime.now()));
                                return DateTimeField.combine(date, time);
                              } else {
                                return currentValue;
                              }
                            },
                            validator: (dateTime) {
                              if (dateTime == null) {
                                return "No due date selected";
                              }
                              return null;
                            },
                            onSaved: (dateTime) {
                              _dueDate = dateTime;
                            },
                          ),
                        ],
                      ),
                    );
                  }
                }),
          ),
        ),
      ),
    );
  }
}
