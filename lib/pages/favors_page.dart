import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterlearning/favor.dart';
import 'package:flutterlearning/friend.dart';
import 'package:flutterlearning/pages/request_favor_page.dart';
import 'package:intl/intl.dart';
import 'package:flutterlearning/string_extension.dart';
import 'dart:math';

import 'package:flutterlearning/pages/login_page.dart';


class FavorsPage extends StatefulWidget {
  FavorsPage({
    Key key,
  }) :super(key: key);

  @override
  State<StatefulWidget> createState() => FavorsPageState();
}

class FavorsPageState extends State<FavorsPage>{
  List<Favor> pendingAnswerFavors;
  List<Favor> acceptedFavors;
  List<Favor> completedFavors;
  List<Favor> refusedFavors;
  Set<Friend> friends;

  @override
  void initState(){
    super.initState();
     if(FirebaseAuth.instance.currentUser == null){
       Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>LoginPage()));
     }
    pendingAnswerFavors = [];
    acceptedFavors = [];
    completedFavors = [];
    refusedFavors = [];
    friends = Set();
    watchFavorsCollection();
  }

  void watchFavorsCollection() async{
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
        Favor favor = Favor.fromMap(element.id,element.data());

        if(favor.isCompleted){
          newCompletedFavors.add(favor);
        } else if (favor.isRefused){
          newRefusedFavors.add(favor);
        } else if (favor.isDoing){
          newAcceptedFavors.add(favor);
        } else{
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

  static FavorsPageState of(BuildContext context) => context.findAncestorStateOfType<FavorsPageState>();

  @override
  void dispose(){
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
              _buildCategoryTab("Requests"),
              _buildCategoryTab("Doing"),
              _buildCategoryTab("Completed"),
              _buildCategoryTab("Refused"),
              _buildCategoryTab("Info"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _FavorsList(title:"Pending Requests", favors:pendingAnswerFavors),
            _FavorsList(title:"Doing", favors:acceptedFavors),
            _FavorsList(title:"Completed", favors:completedFavors),
            _FavorsList(title:"Refused", favors:refusedFavors),
            _InfoTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "request_page",
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RequestFavorPage(friends: friends.toList(),)
              ),
            );
          },
          tooltip: "Ask a favor",
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildCategoryTab(String title) {
    return Tab(
      child: Text(title),
    );
  }

  void refuseToDo(Favor favor){
    _updateFavorOnFirebase(favor.copyWith(accepted: false,refuseDate: DateTime.now()));
  }

  void acceptToDo(Favor favor){
    _updateFavorOnFirebase(favor.copyWith(accepted: true));
  }

  void giveUpDoing(Favor favor){
    _updateFavorOnFirebase(favor.copyWith(accepted:false,refuseDate: DateTime.now()));
  }

  void completeDoing(Favor favor){
    _updateFavorOnFirebase(favor.copyWith(completed: DateTime.now()));
  }

  void _updateFavorOnFirebase(Favor favor) async {
    await FirebaseFirestore.instance.collection('favors').doc(favor.uuid).set(favor.toJson());
  }
}

class _InfoTab extends StatefulWidget{
  _InfoTab({Key key}):super(key: key);
  @override
  _InfoTabState createState() => new _InfoTabState();
}

class _InfoTabState extends State<_InfoTab>{
  String _phoneNumber;
  String _displayName;

  static _InfoTabState of(BuildContext context) => context.findAncestorStateOfType<_InfoTabState>();

  @override
  void initState(){
    _phoneNumber = FirebaseAuth.instance.currentUser.phoneNumber;
    _displayName = FirebaseAuth.instance.currentUser.displayName;
    super.initState();
  }

  Future<void> _changeName(BuildContext context) async{
    String _newName;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context){
        return AlertDialog(
          title: Text("Edit name"),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("Previous name: "),
                    _displayName == null
                        ?Text("Not Set",style: TextStyle(color: Colors.red))
                        :Text("$_displayName"),
                  ],
                ),
                Container(
                  height: 16.0,
                ),
                TextField(
                  decoration: InputDecoration(hintText: "New name"),
                  onChanged: (value){
                    _newName = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: (){
                setState(() {
                  Navigator.of(context).pop();
                });
              },
            ),
            TextButton(
              child: Text("Save"),
              onPressed: ()async{
                setState(() async{
                  _displayName = _newName;
                  await FirebaseAuth.instance.currentUser.updateProfile(displayName: _displayName);
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      }
    );
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
              backgroundImage: NetworkImage(FirebaseAuth.instance.currentUser.photoURL),
              radius: 48,
            ),
            //TODO: Add change image function
          ),
          Container(
            height: 16.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _displayName == null
                  ?Text("No username",style: TextStyle(color: Colors.red))
                  :Text("$_displayName"),
              InkWell(
                child: Icon(
                  Icons.edit,
                ),
                onTap: (){_changeName(context);},
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
            onTap: ()async{
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>LoginPage()));
            },
          ),
        ],
      ),
    );
  }
}

class _FavorsList extends StatelessWidget{
  final String title;
  final List<Favor>favors;

  const _FavorsList({Key key,this.title,this.favors}): super(key: key);

  @override
  Widget build(BuildContext context) {
    if(favors.length != 0){
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: _buildCardsList(context),
          )
        ],
      );
    }
    else{
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Text("No "+title+" favors"),
          )
        ],
      );
    }
  }

  Widget _buildCardsList(BuildContext context){
    final _screenWidth = MediaQuery.of(context).size.width;
    final _favorCardMaxWidth = 400;
    final _cardsPerRow = max(1,_screenWidth~/_favorCardMaxWidth);
    var _crossAxisSpacing = 0;
    var _width = ( _screenWidth - ((_cardsPerRow - 1) * _crossAxisSpacing)) / _cardsPerRow;
    var cellHeight = 150;
    var _aspectRatio = _width /cellHeight;

    if(_cardsPerRow==1){
      return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: favors.length,
        itemBuilder: (BuildContext context, int index){
          final favor = favors[index];
          return InkWell(
            onTap: (){
              Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_,__,___)=>FavorDetailsPage(favor:favor),
                  )
              );
            },
            child: FavorCardItem(favor: favor),
          );
        },
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: BouncingScrollPhysics(),
      itemCount: favors.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context,int index){
        final favor = favors[index];
        return InkWell(
          onTap: (){
            Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_,__,___)=>FavorDetailsPage(favor:favor),
                )
            );
          },
          child: FavorCardItem(favor: favor),
        );
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: _aspectRatio,
        crossAxisCount: _cardsPerRow,
      ),
    );
  }
}

class FavorCardItem extends StatelessWidget{
  final Favor favor;

  const FavorCardItem({Key key,this.favor}):super(key:key);

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
              _itemHeader(context,favor),
              Hero(
                tag: "description_${favor.uuid}",
                child:_itemDescription(context,favor),
              ),
              _itemFooter(context,favor),
            ],
          ),
        ),
        padding: EdgeInsets.all(8.0),
      ),
    );
  }

  Widget _itemHeader(BuildContext context,Favor favor) {
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
            child: Text("${favor.friend.name} asked you to..."),
          ),
        )
      ],
    );
  }

  Widget _itemDescription(BuildContext context,Favor favor){
    return Align(
      alignment: Alignment.center,
      child: Text(favor.description.capitalizeFirstLetter(),style: Theme.of(context).textTheme.headline5,),
    );
  }

  Widget _itemFooter(BuildContext context,Favor favor) {
    if(favor.isCompleted) {
      final format = DateFormat();
      return Container(
        alignment: Alignment.centerRight,
        child: Chip(
          label: Text("Completed at:${format.format(favor.completed)}"),
        ),
      );
    }

    if(favor.isRefused) {
      final format = DateFormat();
      return Container(
        alignment: Alignment.centerRight,
        child: Chip(
          label: Text("Refused at:${format.format(favor.refuseDate)}"),
        ),
      );
    }

    if(favor.isRequested) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            child: Text("Refuse"),
            onPressed: (){
              FavorsPageState.of(context).refuseToDo(favor);
            },
          ),
          TextButton(
            child: Text("Do"),
            onPressed: (){
              FavorsPageState.of(context).acceptToDo(favor);
            },
          )
        ],
      );
    }

    if(favor.isDoing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            child: Text("Give up"),
            onPressed: (){
              FavorsPageState.of(context).giveUpDoing(favor);
            },
          ),
          TextButton(
            child: Text("Complete"),
            onPressed: (){
              FavorsPageState.of(context).completeDoing(favor);
            },
          )
        ],
      );
    }
    return Container();
  }
}
class FavorDetailsPage extends StatefulWidget{
  final Favor favor;
  const FavorDetailsPage({Key key,this.favor}):super(key: key);
  @override
  FavorDetailsPageState createState() => FavorDetailsPageState();
}
class FavorDetailsPageState extends State<FavorDetailsPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Card(
          child: InkWell(
            onTap: (){Navigator.of(context).pop();},
            child:Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _itemHeader(context,widget.favor),
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
          )
      ),
    );
  }

  Widget _itemHeader(BuildContext context,Favor favor){
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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