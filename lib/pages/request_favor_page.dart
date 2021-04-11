import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlearning/favor.dart';
import 'package:flutterlearning/friend.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class RequestFavorPage extends StatefulWidget {
  final List<Friend> friends;

  RequestFavorPage({Key key,this.friends}):super(key:key);

  @override
  RequestFavorPageState createState(){
    return new RequestFavorPageState();
  }
}

class RequestFavorPageState extends State<RequestFavorPage>{
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Friend _selectedFriend;
  DateTime _dueDate;
  String _description;

  static RequestFavorPageState of(BuildContext context){
    return context.findAncestorStateOfType<RequestFavorPageState>();
  }

  @override
  void initState() {
    super.initState();
    Friend newFriend = Friend(name: 'New number', uuid: 'new');
    widget.friends.add(newFriend);
    widget.friends.add(Friend(name: 'xxx',uuid: 'qwq'));
    print(widget.friends.length);
  }

  @override
  void dispose(){
    _formKey.currentState?.dispose();
    super.dispose();
  }

  _saveFavorOnFirebase(Favor favor) async {
    await FirebaseFirestore.instance.collection('favors').doc().set(favor.toJson());
  }

  void save(BuildContext context) async {
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      final user = FirebaseAuth.instance.currentUser;
      await _saveFavorOnFirebase(
          Favor(
            to: _selectedFriend.number,
            description: _description,
            dueDate: _dueDate,
            friend: Friend(
              name: user.displayName,
              number: user.phoneNumber,
              photoURL: user.photoURL,
            ),
          )
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context){
    return Hero(
      //tag: "request_page",
      tag: "temp_tag",
      //TODO: Fix Hero bug

      child: Scaffold(
        appBar: AppBar(
          leading: CloseButton(),
          title: Text("Requesting a favor"),
          actions: [
            Builder(
              builder: (context) => TextButton(
                child: Text("Save"),
                onPressed: (){
                  RequestFavorPageState.of(context).save(context);
                },
                style: ButtonStyle(
                  foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState>states){
                    return states.contains(MaterialState.pressed) ? Colors.grey:Colors.white;
                  }),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DropdownButtonFormField<Friend>(
                    value: _selectedFriend,
                    onChanged: (friend){
                      setState(() {
                        _selectedFriend = friend;
                      });
                    },
                    items: widget.friends.map(
                            (e) => DropdownMenuItem<Friend>(child: Text(e.name),value: e,)
                    ).toList(),
                    validator: (friend){
                      if(friend == null){
                        return "No friend selected";
                      }
                      return null;
                    },
                  ),
                  // _selectedFriend?.uuid == 'new'
                  //     ? TextFormField(
                  //         maxLines: 1,
                  //         decoration: InputDecoration(hintText: "Friend phone number"),
                  //         inputFormatters: [
                  //           LengthLimitingTextInputFormatter(20),
                  //         ],
                  //         validator: (value){
                  //           if(value.isEmpty){
                  //             return "Please enter friend phone number";
                  //           }
                  //           return null;
                  //         },
                  //         onSaved: (value){
                  //           _selectedFriend = Friend(number: value);
                  //         },
                  //       )
                  //     : Container(
                  //         height: 0,
                  //       ),
                  Container(
                    height: 16.0,
                  ),
                  Text("Favor description:"),
                  TextFormField(
                    maxLines: 3,
                    inputFormatters: [LengthLimitingTextInputFormatter(120)],
                    validator: (value){
                      if(value.isEmpty){
                        return "No description provided";
                      }
                      return null;
                    },
                    onSaved: (description){
                      _description = description;
                    },
                  ),
                  Container(
                    height: 16.0,
                  ),
                  Text("Due date:"),
                  DateTimeField(
                    format: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
                    onShowPicker: (context,currentValue) async {
                      final date = await showDatePicker(context: context, initialDate: currentValue??DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if(date != null){
                        final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()));
                        return DateTimeField.combine(date, time);
                      }
                      else{
                        return currentValue;
                      }
                    },
                    validator: (dateTime){
                      if(dateTime==null){
                        return "No due date selected";
                      }
                      return null;
                    },
                    onSaved: (dateTime){
                      _dueDate = dateTime;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

