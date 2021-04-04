import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlearning/favor.dart';
import 'package:flutterlearning/friend.dart';
import 'package:flutterlearning/mock_values.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: FavorsPage(
      ),
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
  List<Favor> pendingAnswerFavors;
  List<Favor> acceptedFavors;
  List<Favor> completedFavors;
  List<Favor> refusedFavors;
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
              _favorsList("Pending Requests", pendingAnswerFavors),
              _favorsList("Doing", acceptedFavors),
              _favorsList("Completed", completedFavors),
              _favorsList("Refused", refusedFavors),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
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

  Widget _favorsList(String title, List<Favor> favors) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text(title),
        ),
        Expanded(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: favors.length,
            itemBuilder: (BuildContext context, int index){
              final favor = favors[index];
              return Card(
                key: ValueKey(favor.uuid),
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                child: Padding(
                  child: Column(
                    children: [
                      _itemHeader(favor),
                      Text(favor.description),
                      _itemFooter(favor),
                    ],
                  ),
                  padding: EdgeInsets.all(8.0),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Row _itemHeader(Favor favor) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(
            favor.friend.photoURL,
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

  Widget _itemFooter(Favor favor) {
    if(favor.isCompleted) {
      final format = DateFormat();
      return Container(
        margin: EdgeInsets.only(top: 8.0),
        alignment: Alignment.centerRight,
        child: Chip(
          label: Text("Completed at:${format.format(favor.completed)}"),
        ),
      );
    }
    if(favor.isRefused) {
      final format = DateFormat();
      return Container(
        margin: EdgeInsets.only(top: 8.0),
        alignment: Alignment.centerRight,
        child: Chip(
          label: Text("Due date at:${format.format(favor.dueDate)}"),
        ),
      );
    }
    if(favor.isRequested) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            child: Text("Refuse"),
            onPressed: (){},
          ),
          TextButton(
            child: Text("Do"),
            onPressed: (){},
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
            onPressed: (){},
          ),
          TextButton(
            child: Text("Complete"),
            onPressed: (){},
          )
        ],
      );
    }
    return Container();
  }
}

class RequestFavorPage extends StatelessWidget {
  final List<Friend> friends;
  RequestFavorPage({Key key,this.friends}):super(key:key);
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(),
        title: Text("Requesting a favor"),
        actions: [
          TextButton(
            child: Text("Save"),
              onPressed: (){},
              style: TextButton.styleFrom(primary: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Request a favor to:"),
            DropdownButtonFormField(
              items: friends.map((e) => DropdownMenuItem(child: Text(e.name),),).toList(),
            ),
            Container(
              height: 16.0,
            ),
            Text("Favor description:"),
            TextFormField(
              maxLines: 3,
              inputFormatters: [LengthLimitingTextInputFormatter(120)],
            ),
            Container(
              height: 16.0,
            ),
            Text("Due date:"),
            DateTimeField(
              format: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),

              decoration: InputDecoration(
                labelText: 'Date/Time', floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
              onChanged: (dt){},
            ),
          ],
        ),
      ),
    );
  }
}