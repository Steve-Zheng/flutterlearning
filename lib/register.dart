import 'package:flutter/material.dart';

void main() => runApp(RegisterApp());

class RegisterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes:{
        '/' : (context) => RegisterScreen(),
        '/welcome':(context) => WelcomeScreen(),
      },
    );
  }
}

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: RegisterForm(),
          ),
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Text(
          'Welcome',
          style: Theme.of(context).textTheme.headline2
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget{
  @override
  _RegisterFormState createState()=>_RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _rePasswordTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Register',style:Theme.of(context).textTheme.headline4),
          Padding(
              padding: EdgeInsets.all(8),
              child: TextFormField(
                controller: _emailTextController,
                decoration: InputDecoration(hintText: 'E-mail'),
              ),
          ),
          Padding(
              padding: EdgeInsets.all(8),
              child: TextFormField(
                controller: _passwordTextController,
                decoration: InputDecoration(hintText: 'Password'),
              ),
          ),
          Padding(
              padding: EdgeInsets.all(8),
              child: TextFormField(
                controller: _rePasswordTextController,
                decoration: InputDecoration(hintText: 'Re-enter password'),
              ),
          ),
          TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState>states){
                return states.contains(MaterialState.disabled) ? null:Colors.white;
              }),
              backgroundColor: MaterialStateColor.resolveWith((Set<MaterialState>states){
                return states.contains(MaterialState.disabled) ? null:Colors.blue;
              }),
            ),
            onPressed: _showWelcomeScreen,
            child: Text('Register'),
          ),
        ],
      ),
    );
  }
  void _showWelcomeScreen(){
    Navigator.of(context).pushNamed('/welcome');
  }
}