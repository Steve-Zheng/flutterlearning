import 'dart:math';
import 'package:flutter/material.dart';

import 'package:flutterlearning/classes/favor.dart';
import 'package:flutterlearning/pages/components/favorCardItem.dart';
import 'package:flutterlearning/pages/components/favorDetailsPage.dart';

class FavorsList extends StatelessWidget {
  final String title;
  final List<Favor> favors;

  const FavorsList({Key key, this.title, this.favors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (favors.length != 0) {
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: _buildCardsList(context),
          )
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Text("No " + title + " favors"),
          )
        ],
      );
    }
  }

  Widget _buildCardsList(BuildContext context) {
    final _screenWidth = MediaQuery.of(context).size.width;
    final _favorCardMaxWidth = 400;
    final _cardsPerRow = max(1, _screenWidth ~/ _favorCardMaxWidth);
    var _crossAxisSpacing = 0;
    var _width = (_screenWidth - ((_cardsPerRow - 1) * _crossAxisSpacing)) /
        _cardsPerRow;
    var cellHeight = 150;
    var _aspectRatio = _width / cellHeight;

    if (_cardsPerRow == 1) {
      return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: favors.length,
        itemBuilder: (BuildContext context, int index) {
          final favor = favors[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => FavorDetailsPage(favor: favor),
                  ));
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
      itemBuilder: (BuildContext context, int index) {
        final favor = favors[index];
        return InkWell(
          onTap: () {
            Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => FavorDetailsPage(favor: favor),
                ));
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
