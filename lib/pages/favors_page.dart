import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterlearning/favor.dart';
import 'package:flutterlearning/friend.dart';
import 'package:flutterlearning/mock_values.dart';
import 'package:intl/intl.dart';
import 'package:flutterlearning/string_extension.dart';
import 'dart:math';

import 'package:flutterlearning/pages/login_page.dart';

List<Favor> pendingAnswerFavors;
List<Favor> acceptedFavors;
List<Favor> completedFavors;
List<Favor> refusedFavors;
Set<Friend> friends;

class FavorsPage extends StatefulWidget {
  FavorsPage({
    Key key,
  }) :super(key: key);

  @override
  State<StatefulWidget> createState() => FavorsPageState();
}

class FavorsPageState extends State<FavorsPage>{
  @override
  void initState(){
    super.initState();
    //TODO: Uncomment this to enable login
    // if(FirebaseAuth.instance.currentUser == null){
    //   Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>LoginPage()));
    // }
    pendingAnswerFavors = [];
    acceptedFavors = [];
    completedFavors = [];
    refusedFavors = [];
    friends = Set();
    loadFavors();
    watchFavorsCollection();
  }

  void watchFavorsCollection() async{
    final currentUser = FirebaseAuth.instance.currentUser;
    //TODO: Implement watchFavorsCollection
  }

  void loadFavors(){
    pendingAnswerFavors.addAll(mockPendingFavors);
    acceptedFavors.addAll(mockDoingFavors);
    completedFavors.addAll(mockCompletedFavors);
    refusedFavors.addAll(mockRefusedFavors);
  }

  static FavorsPageState of(BuildContext context){
    return context.findAncestorStateOfType<FavorsPageState>();
  }
  @override
  void dispose(){
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
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
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FavorsList(title:"Pending Requests", favors:pendingAnswerFavors),
            FavorsList(title:"Doing", favors:acceptedFavors),
            FavorsList(title:"Completed", favors:completedFavors),
            FavorsList(title:"Refused", favors:refusedFavors),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "request_page",
          onPressed: () {
            Navigator.of(context).pushNamed("/request");
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
    setState(() {
      pendingAnswerFavors.remove(favor);
      refusedFavors.add(favor.copyWith(accepted:false,refuseDate:DateTime.now()));
    });
  }

  void acceptToDo(Favor favor){
    setState(() {
      pendingAnswerFavors.remove(favor);
      acceptedFavors.add(favor.copyWith(accepted: true));
    });
  }

  void giveUpDoing(Favor favor){
    setState(() {
      acceptedFavors.remove(favor);
      refusedFavors.add(favor.copyWith(accepted: false,refuseDate: DateTime.now()));
    });
  }

  void completeDoing(Favor favor){
    setState(() {
      acceptedFavors.remove(favor);
      completedFavors.add(favor.copyWith(completed: DateTime.now()));
    });
  }
}

class FavorsList extends StatelessWidget{
  final String title;
  final List<Favor>favors;

  const FavorsList({Key key,this.title,this.favors}): super(key: key);

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