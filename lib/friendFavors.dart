import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlearning/favor.dart';
import 'package:flutterlearning/friend.dart';
import 'package:flutterlearning/mock_values.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutterlearning/string_extension.dart';
import 'dart:math';

List<Favor> pendingAnswerFavors;
List<Favor> acceptedFavors;
List<Favor> completedFavors;
List<Favor> refusedFavors;

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(NavigatorApp());
}

class NavigatorApp extends StatefulWidget{
  @override
  _NavigatorAppState createState() => _NavigatorAppState();
}

class _NavigatorAppState extends State<NavigatorApp>{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Demo",
      color: Colors.lightGreen,
      theme: greenTheme,
      routes: {
        '/':(context) => FavorsPage(),
        '/request': (context) => RequestFavorPage(friends: mockFriends,),
      },
    );
  }
  Widget errorPage(){
    return Container(
      color: Colors.red,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Error!"),
        ],
      ),
    );
  }
}

final greenTheme = ThemeData(
  primarySwatch: Colors.lightGreen,
  accentColor: Colors.lightGreenAccent,
  primaryColorBrightness: Brightness.dark,
  cardColor: Colors.lightGreen.shade100,
);

class FirebaseLoader extends StatelessWidget{
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context,snapshot){
        if(snapshot.connectionState == ConnectionState.done){
          return NavigatorApp();
        }
        return NavigatorApp();
      },
    );
  }
}

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
    pendingAnswerFavors = [];
    acceptedFavors = [];
    completedFavors = [];
    refusedFavors = [];
    loadFavors();
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
  final descriptionController = TextEditingController();
  final dateTimeController = TextEditingController();
  static RequestFavorPageState of(BuildContext context){
    return context.findAncestorStateOfType<RequestFavorPageState>();
  }

  @override
  void dispose(){
    descriptionController.dispose();
    dateTimeController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  void save(){
    if(_formKey.currentState.validate()){
      final favor = new Favor(friend: _selectedFriend,description: descriptionController.text,dueDate: DateTime.now());
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
                    return null;
                  },
                  controller: descriptionController,
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
                  controller: dateTimeController,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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