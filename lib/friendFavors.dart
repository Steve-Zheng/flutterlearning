import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterlearning/favor.dart';
import 'package:flutterlearning/mock_values.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: FavorsPage(
        pendingAnswerFavors: mockPendingFavors,
        completedFavors: mockCompletedFavors,
        refusedFavors: mockRefusedFavors,
        acceptedFavors: mockDoingFavors,
      ),
    );
  }
}

class FavorsPage extends StatelessWidget {
  final List<Favor> pendingAnswerFavors;
  final List<Favor> acceptedFavors;
  final List<Favor> completedFavors;
  final List<Favor> refusedFavors;

  FavorsPage({
    Key key,
    this.pendingAnswerFavors,
    this.acceptedFavors,
    this.completedFavors,
    this.refusedFavors,
}):super(key:key);
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
      children: <Widget>[
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
                    children: <Widget>[
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
      children: <Widget>[
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
        children: <Widget>[
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
        children: <Widget>[
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