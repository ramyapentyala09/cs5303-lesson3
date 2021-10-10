import 'package:flutter/material.dart';
import 'package:lesson3/viewscreen/internalerror_screen.dart';
import 'package:lesson3/viewscreen/signin_screen.dart';
import 'package:lesson3/model/constant.dart';
import 'package:firebase_core/firebase_core.dart';
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
      initialRoute: SignInScreen.routeName,
      routes: {
        SignInScreen.routeName: (context) => SignInScreen(),
        UserHomeScreen.routName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return InternalErrorScreen('args is null at UserHomeScreen');
          } else {
            var argument = args as Map;
            var user = argument[ARGS.USER];
            return UserHomeScreen(user: user);
          }
        }
      },
    );
  }
}
