import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlearning/favor.dart';
import 'package:flutterlearning/friend.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

import 'package:flutterlearning/pages/favors_page.dart';


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
  String _enteredDescription;
  DateTime _selectedDateTime;

  static RequestFavorPageState of(BuildContext context){
    return context.findAncestorStateOfType<RequestFavorPageState>();
  }

  @override
  void dispose(){
    _formKey.currentState?.dispose();
    super.dispose();
  }

  void save(){
    if(_formKey.currentState.validate()){
      final favor = new Favor(friend: _selectedFriend,description: _enteredDescription,dueDate: _selectedDateTime);
      pendingAnswerFavors.add(favor);
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
                  RequestFavorPageState.of(context).save();
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
                          (e) => DropdownMenuItem(child: Text(e.name),value: e,)
                  ).toList(),
                  validator: (friend){
                    if(friend == null){
                      return "No friend selected";
                    }
                    return null;
                  },
                ),
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
                    _enteredDescription = value;
                    return null;
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
                    _selectedDateTime = dateTime;
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

