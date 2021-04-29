import 'package:flutter/material.dart';
import 'package:flutterlearning/classes/favor.dart';

class FavorDetailsPage extends StatefulWidget {
  final Favor favor;

  const FavorDetailsPage({Key key, this.favor}) : super(key: key);

  @override
  FavorDetailsPageState createState() => FavorDetailsPageState();
}

class FavorDetailsPageState extends State<FavorDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Card(
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 24.0,
                  ),
                  _itemHeader(context, widget.favor),
                  Container(
                    height: 16.0,
                  ),
                  Expanded(
                    child: Center(
                      child: Hero(
                        tag: "description_${widget.favor.uuid}",
                        child: Text(
                          widget.favor.description,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Widget _itemHeader(BuildContext context, Favor favor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 24.0,
        ),
        Hero(
          tag: "avatar_${favor.uuid}",
          child: CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(
              favor.friend.photoURL,
            ),
          ),
        ),
        Container(
          height: 16.0,
        ),
        Text(
          "${favor.friend.name} asked you to...",
          style: Theme.of(context).textTheme.headline3,
        ),
      ],
    );
  }
}