import 'package:flutter/material.dart';

void main() => runApp(NavigatorWidgetsApp());

class NavigatorWidgetsApp extends StatefulWidget{
  @override
  _NavigatorWidgetsAppState createState() => _NavigatorWidgetsAppState();
}

class _NavigatorWidgetsAppState extends State<NavigatorWidgetsApp> {
  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: Colors.black,
      onGenerateRoute: (settings){
        if(settings.name == '/'){
          return MaterialPageRoute(
            builder: (context)=>Screen1(context:context,argument:settings.arguments),
          );
        }
        else if(settings.name == '/2'){
          return MaterialPageRoute(
            builder: (context)=>Screen2(context:context,argument:settings.arguments),
          );
        }
        return MaterialPageRoute(
          builder: (context)=>_errorScreen(context,settings.arguments),
        );
      },
    );
  }

  Widget _errorScreen(BuildContext context, String argument){
    return Container(
      color: Colors.red,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Error!"),
          Text("Arguments: "+argument),
        ],
      ),
    );
  }
}

class Screen1 extends StatefulWidget{
  final String argument;
  final BuildContext context;
  Screen1({Key key,this.context,this.argument}):super(key: key);
  @override
  _Screen1State createState() => _Screen1State();
}

class _Screen1State extends State<Screen1>{
  String _argumentFromScreen2 = "0";
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Screen 1"),
          ElevatedButton(
            onPressed: ()async{
              final argumentFromScreen2 = await Navigator.of(context).pushNamed('/2',arguments: "Hello");
              setState(() {
                _argumentFromScreen2 = argumentFromScreen2;
              });
            },
            child: Text("Go to screen 2"),
          ),
          Text("Counter: "+_argumentFromScreen2),
        ],
      ),
    );
  }
}

class Screen2 extends StatefulWidget{
  final String argument;
  final BuildContext context;
  Screen2({Key key,this.context,this.argument}):super(key: key);
  @override
  _Screen2State createState() => _Screen2State();
}

class _Screen2State extends State<Screen2>{
  int _counter = 0;
  void _incrementCounter(){
    setState(() {
      _counter++;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.lightGreen,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Screen 2"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: (){Navigator.of(context).pop(_counter.toString());},
                  child: Text("Go to screen 1")
              ),
              ElevatedButton(
                onPressed: _incrementCounter,
                child: Text("Add counter by 1"),
              ),
            ],
          ),
          Text("Counter: "+_counter.toString()),
          Text("Argument from screen 1: "+widget.argument),
        ],
      ),
    );
  }
}