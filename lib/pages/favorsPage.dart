import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutterlearning/classes/favor.dart';
import 'package:flutterlearning/classes/friend.dart';

import 'package:flutterlearning/pages/requestFavorPage.dart';
import 'package:flutterlearning/pages/loginPage.dart';
import 'package:flutterlearning/pages/components/favorsList.dart';
import 'package:flutterlearning/pages/components/infoTab.dart';
import 'package:flutterlearning/pages/components/showLoading.dart';

class FavorsPage extends StatefulWidget {
  FavorsPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => FavorsPageState();
}

class FavorsPageState extends State<FavorsPage> {
  List<Favor> pendingAnswerFavors;
  List<Favor> acceptedFavors;
  List<Favor> completedFavors;
  List<Favor> refusedFavors;
  Set<Friend> friends;

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()));
    }
    pendingAnswerFavors = [];
    acceptedFavors = [];
    completedFavors = [];
    refusedFavors = [];
    friends = Set();
    watchFavorsCollection();
  }

  void watchFavorsCollection() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('favors')
        .where('to', isEqualTo: currentUser.phoneNumber)
        .snapshots()
        .listen((event) {
      List<Favor> newCompletedFavors = [];
      List<Favor> newRefusedFavors = [];
      List<Favor> newAcceptedFavors = [];
      List<Favor> newPendingAnswerFavors = [];
      Set<Friend> newFriends = Set();

      event.docs.forEach((element) {
        Favor favor = Favor.fromMap(element.id, element.data());

        if (favor.isCompleted) {
          newCompletedFavors.add(favor);
        } else if (favor.isRefused) {
          newRefusedFavors.add(favor);
        } else if (favor.isDoing) {
          newAcceptedFavors.add(favor);
        } else {
          newPendingAnswerFavors.add(favor);
        }

        newFriends.add(favor.friend);
      });

      setState(() {
        this.completedFavors = newCompletedFavors;
        this.pendingAnswerFavors = newPendingAnswerFavors;
        this.refusedFavors = newRefusedFavors;
        this.acceptedFavors = newAcceptedFavors;
        this.friends = newFriends;
      });
    });
  }

  static FavorsPageState of(BuildContext context) =>
      context.findAncestorStateOfType<FavorsPageState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Your favors"),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(child: Text("Requests"),),
              Tab(child: Text("Doing"),),
              Tab(child: Text("Completed"),),
              Tab(child: Text("Refused"),),
              Tab(child: Text("Info"),),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FavorsList(title: "Pending Requests", favors: pendingAnswerFavors),
            FavorsList(title: "Doing", favors: acceptedFavors),
            FavorsList(title: "Completed", favors: completedFavors),
            FavorsList(title: "Refused", favors: refusedFavors),
            InfoTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "request_page",
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => RequestFavorPage(
                        friends: friends.toList(),
                      )),
            );
          },
          tooltip: "Ask a favor",
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> editState(String event, Favor favor) async {
    showLoading(context);
    switch (event) {
      case "refuse":
        {
          await _updateFavorOnFirebase(
              favor.copyWith(accepted: false, refuseDate: DateTime.now()));
        }
        break;
      case "accept":
        {
          await _updateFavorOnFirebase(favor.copyWith(accepted: true));
        }
        break;
      case "giveUp":
        {
          await _updateFavorOnFirebase(
              favor.copyWith(accepted: false, refuseDate: DateTime.now()));
        }
        break;
      case "complete":
        {
          await _updateFavorOnFirebase(
              favor.copyWith(completed: DateTime.now()));
        }
        break;
    }
    Navigator.of(context).pop();
    setState(() {

    });
  }

  Future<void> _updateFavorOnFirebase(Favor favor) async {
    await FirebaseFirestore.instance
        .collection('favors')
        .doc(favor.uuid)
        .set(favor.toJson());
  }
}

