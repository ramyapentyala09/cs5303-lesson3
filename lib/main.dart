import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/viewscreen/addnewphotomemo_screen.dart';

import 'package:lesson3/viewscreen/detailedview_screen.dart';
import 'package:lesson3/viewscreen/internalerror_screen.dart';
import 'package:lesson3/viewscreen/sharedwith_screen.dart';
import 'package:lesson3/viewscreen/signin_screen.dart';
import 'package:lesson3/model/constant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lesson3/viewscreen/signup_screen.dart';
import 'package:lesson3/viewscreen/userhome_Screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Lesson3App());
}

class Lesson3App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: Constant.DEV,
      theme: ThemeData(
          brightness: Constant.DARKMODE ? Brightness.dark : Brightness.light,
          primaryColor: Colors.blueAccent),
      initialRoute: SignInScreen.routeName,
      routes: {
        SignInScreen.routeName: (context) => SignInScreen(),
        UserHomeScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return InternalErrorScreen('args is null at UserHomeScreen');
          } else {
            var argument = args as Map;
            var user = argument[ARGS.USER];
            var photoMemoList = argument[ARGS.PhotoMemoList];
            return UserHomeScreen(user: user, photoMemoList: photoMemoList);
          }
        },
        SharedWithScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return InternalErrorScreen('args is null at UserHomeScreen');
          } else {
            var argument = args as Map;
            var user = argument[ARGS.USER];
            var photoMemoList = argument[ARGS.PhotoMemoList];
            return SharedWithScreen(user: user, photoMemoList: photoMemoList);
          }
        },
        AddNewPhotoMemoScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return InternalErrorScreen('args is null at UserHomeScreen');
          } else {
            var argument = args as Map;
            var user = argument[ARGS.USER];
            var photoMemoList = argument[ARGS.PhotoMemoList];
            return AddNewPhotoMemoScreen(
                user: user, photoMemoList: photoMemoList);
          }
        },
        DetailedViewScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return InternalErrorScreen('Args is null at Deatiled View Screen');
          } else {
            var argument = args as Map;
            var user = argument[ARGS.USER];
            var photoMemo = argument[ARGS.OnePhotoMemo];
            return DetailedViewScreen(
              user: user,
              photoMemo: photoMemo,
            );
          }
        },
        SignUpScreen.routName: (context) => SignUpScreen(),
        

      },
    );
  }
}