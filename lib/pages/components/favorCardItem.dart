import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:flutterlearning/classes/favor.dart';
import 'package:flutterlearning/pages/favorsPage.dart';
import 'package:flutterlearning/pages/components/stringExtension.dart';

class FavorCardItem extends StatelessWidget {
  final Favor favor;

  const FavorCardItem({Key key, this.favor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(favor.uuid),
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Padding(
        child: IntrinsicWidth(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _itemHeader(context, favor),
              Hero(
                tag: "description_${favor.uuid}",
                child: _itemDescription(context, favor),
              ),
              _itemFooter(context, favor),
            ],
          ),
        ),
        padding: EdgeInsets.all(8.0),
      ),
    );
  }

  Widget _itemHeader(BuildContext context, Favor favor) {
    return Row(
      children: [
        Hero(
          tag: "avatar_${favor.uuid}",
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              favor.friend.photoURL,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 8.0),
            //child: Text("${favor.friend.name} asked you to..."),
            child: Row(
              children: [
                favor.friend.number == FirebaseAuth.instance.currentUser.phoneNumber ?Text("Yourself",style: TextStyle(color: Theme.of(context).primaryColor)):Text(favor.friend.name),
                Text(" asked you to..."),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _itemDescription(BuildContext context, Favor favor) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        favor.description.capitalizeFirstLetter(),
        style: Theme.of(context).textTheme.headline5,
      ),
    );
  }

  Widget _itemFooter(BuildContext context, Favor favor) {
    if (favor.isCompleted) {
      final format = DateFormat();
      return Container(
        alignment: Alignment.centerRight,
        child: Chip(
          label: Text("Completed at:${format.format(favor.completed)}"),
        ),
      );
    }

    if (favor.isRefused) {
      final format = DateFormat();
      return Container(
        alignment: Alignment.centerRight,
        child: Chip(
          label: Text("Refused at:${format.format(favor.refuseDate)}"),
        ),
      );
    }

    if (favor.isRequested) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            child: Text("Refuse"),
            onPressed: () async {
              await FavorsPageState.of(context).editState("refuse", favor);
            },
          ),
          TextButton(
            child: Text("Do"),
            onPressed: () async {
              await FavorsPageState.of(context).editState("accept", favor);
            },
          )
        ],
      );
    }

    if (favor.isDoing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            child: Text("Give up"),
            onPressed: () async {
              await FavorsPageState.of(context).editState("giveUp", favor);
            },
          ),
          TextButton(
            child: Text("Complete"),
            onPressed: () async {
              await FavorsPageState.of(context).editState("complete", favor);
            },
          )
        ],
      );
    }
    return Container();
  }
}