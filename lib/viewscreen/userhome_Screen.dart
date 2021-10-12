import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lesson3/controller/firebaseauth_controller.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/viewscreen/addnewphotomemo_screen.dart';
import 'package:lesson3/model/constant.dart';

class UserHomeScreen extends StatefulWidget {
  static const routeName = '/userHomeScreen';

  late final User user;
  late final String displayName;
  late final String email;
  final List<PhotoMemo> photoMemoList;

  UserHomeScreen({required this.user, required this.photoMemoList}) {
    displayName = user.displayName ?? 'N/A';
    email = user.email ?? 'No Email';
  }

  @override
  State<StatefulWidget> createState() {
    return _UserHomeState();
  }
}

class _UserHomeState extends State<UserHomeScreen> {
  late _Controller con;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          title: Text('User Home'),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(widget.displayName),
                accountEmail: Text(widget.email),
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Sign Out'),
                onTap: con.signOut,
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: con.addButton,
        ),
        body: Text('user home: ${widget.user.email}\nphotoMemo: ${widget.photoMemoList.length}'),
      ),
    );
  }
}

class _Controller {
  late _UserHomeState state;
  _Controller(this.state);

  void addButton() {
    Navigator.pushNamed(state.context, AddNewPhotoMemoScreen.routeName,
        arguments: {
          ARGS.USER: state.widget.user,
        });
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuthController.signOut();
    } catch (e) {
      if (Constant.DEV) print('----sign Out Error: $e');
    }
    Navigator.of(state.context).pop();
    Navigator.of(state.context).pop();
  }
}