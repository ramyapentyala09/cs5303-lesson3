import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lesson3/controller/cloudstorage_controller.dart';
import 'package:lesson3/controller/firebaseauth_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/viewscreen/addnewphotomemo_screen.dart';
import 'package:lesson3/model/constant.dart';

import 'package:lesson3/viewscreen/detailedview_screen.dart';
import 'package:lesson3/viewscreen/sharedwith_screen.dart';
import 'package:lesson3/viewscreen/view/mydailog.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

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
  GlobalKey<FormState> formkey = GlobalKey();

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
          //title: Text('User Home'),
          actions: [
            con.delIndexes.isEmpty
                ? Form(
                    key: formkey,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Search (empty for all)',
                            fillColor: Theme.of(context).backgroundColor,
                            filled: true,
                          ),
                          autocorrect: true,
                          onSaved: con.saveSearchKey,
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: con.cancelDelete, icon: Icon(Icons.cancel)),
            con.delIndexes.isEmpty
                ? IconButton(onPressed: con.search, icon: Icon(Icons.search))
                : IconButton(onPressed: con.delete, icon: Icon(Icons.delete)),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(widget.displayName),
                accountEmail: Text(widget.email),
              ),
              ListTile(
                leading: Icon(Icons.people),
                title: Text('shared With'),
                onTap: con.sharedwith,
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
        body: con.photoMemoList.isEmpty
            ? Text(
                'No PhotoMemo found!',
                style: Theme.of(context).textTheme.headline6,
              )
            : ListView.builder(
                itemCount: con.photoMemoList.length,
                itemBuilder: (context, index) {
                  return Container(
                    color: con.delIndexes.contains(index)
                        ? Theme.of(context).highlightColor
                        : Theme.of(context).scaffoldBackgroundColor,
                    child: ListTile(
                      leading: WebImage(
                          url: con.photoMemoList[index].photoURL,
                          context: context),
                      trailing: Icon(Icons.arrow_right),
                      title: Text(con.photoMemoList[index].title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            con.photoMemoList[index].memo.length >= 40
                                ? con.photoMemoList[index].memo
                                        .substring(0, 40) +
                                    '...'
                                : con.photoMemoList[index].memo,
                          ),
                          Text(
                              'Created By: ${con.photoMemoList[index].createdBy}'),
                          Text(
                              'SharedWith: ${con.photoMemoList[index].sharedWith}'),
                          Text(
                              'Timestamp: ${con.photoMemoList[index].timestamp}'),
                        ],
                      ),
                      onTap: () => con.onTap(index),
                      onLongPress: () => con.onLongPress(index),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _Controller {
  late _UserHomeState state;
  late List<PhotoMemo> photoMemoList;
  String? searchKeyString;
  List<int> delIndexes = [];

  _Controller(this.state) {
    photoMemoList = state.widget.photoMemoList;
  }

  void sharedwith() async {
    try {
      List<PhotoMemo> photoMemoList =
          await FirestoreController.getPhotoMemoListSharedWith(email: state.widget.email);
      await Navigator.pushNamed(state.context, SharedWithScreen.routeName,
          arguments: {
            ARGS.PhotoMemoList: photoMemoList,
            ARGS.USER: state.widget.user,
          });
          Navigator.of(state.context).pop(); // close the drawer
    } catch (e) {
      if (Constant.DEV) print('---shared with error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Failed to get sharedwith list: $e',
      );
    }
  }

  void cancelDelete() {
    state.render(() {
      delIndexes.clear();
    });
  }

  void delete() async {
    MyDialog.circularProgressStart(state.context);
    delIndexes.sort(); //ascending order
    for (int i = delIndexes.length - 1; i >=0; i--) {
      try {
        PhotoMemo p = photoMemoList[delIndexes[i]];
        await FirestoreController.deletePhotoMemo(photoMemo: p);
        await CloudStorageController.deletePhotoFile(photoMemo: p);
        state.render(() {
          photoMemoList.removeAt(delIndexes[i]);
        });
        
      } catch (e) {
        if (Constant.DEV) print('---failed to delete user memo');
        MyDialog.showSnackBar(
          context: state.context,
          message: 'Failed to delete Photomemo: $e',
        );
        break; //quit further processing

      }
    }
    MyDialog.circularProgressStop(state.context);
    state.render(() => delIndexes.clear());
  }

  void onLongPress(int index) {
    state.render(() {
      if (delIndexes.contains(index))
        delIndexes.remove(index);
      else
        delIndexes.add(index);
    });
  }

  void saveSearchKey(String? value) {
    searchKeyString = value;
  }

  void search() async {
    FormState? currentState = state.formkey.currentState;
    if (currentState == null) return;
    currentState.save();

    List<String> keys = [];
    if (searchKeyString != null) {
      var tokens = searchKeyString!.split(RegExp('(,| )+')).toList();
      for (var t in tokens) {
        if (t.trim().isNotEmpty) keys.add(t.trim().trimLeft().toLowerCase());
      }
    }
    MyDialog.circularProgressStart(state.context);

    try {
      late List<PhotoMemo> results;
      if (keys.isEmpty) {
        //read all photomemos
        results = await FirestoreController.getPhotoMemoList(
            email: state.widget.email);
      } else {
        results = await FirestoreController.searchImage(
          createdBy: state.widget.email,
          searchLables: keys,
        );
      }
      MyDialog.circularProgressStop(state.context);
      state.render(() => photoMemoList = results);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      if (Constant.DEV) print('----Search error: $e');
      MyDialog.showSnackBar(
          context: state.context, message: 'Search error: $e');
    }
  }

  void onTap(int index) async {
    if (delIndexes.isNotEmpty) {
      onLongPress(index);
      return;
    }
    // var state;
    await Navigator.pushNamed(state.context, DetailedViewScreen.routeName,
        arguments: {
          ARGS.USER: state.widget.user,
          ARGS.OnePhotoMemo: photoMemoList[index],
        });
//rerender home screen
    state.render(() {
      //reorder based on updated timestamps
      photoMemoList.sort((a, b) {
        if (a.timestamp!.isBefore(b.timestamp!))
          return 1; //desending order
        else if (a.timestamp!.isAfter(b.timestamp!))
          return -1;
        else
          return 0;
      });
    });
  }

  void addButton() async {
    await Navigator.pushNamed(state.context, AddNewPhotoMemoScreen.routeName,
        arguments: {
          ARGS.USER: state.widget.user,
          ARGS.PhotoMemoList: photoMemoList,
        });
    state.render(() {});
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