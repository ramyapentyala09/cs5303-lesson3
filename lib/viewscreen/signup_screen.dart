import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firebaseauth_controller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/viewscreen/view/mydailog.dart';

class SignUpScreen extends StatefulWidget {
  static const routName = '/signUpScreen';

  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUpScreen> {
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
    return Scaffold(
        appBar: AppBar(
          title: Text('Create a new account'),
        ),
        body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Form(
          key: formkey,
          child: Column(
              children: [
                Text(
                  'Create an Account',
                  style: Theme.of(context).textTheme.headline5,
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Enter Email'),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: con.validateEmail,
                  onSaved: con.saveEmail,
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Enter Password'),
                  autocorrect: false,
                  obscureText: true,
                  validator: con.validatePassword,
                  onSaved: con.savePassword,
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Confirm Password'),
                  autocorrect: false,
                  obscureText: true,
                  validator: con.validatePassword,
                  onSaved: con.saveConfirmPassword,
                ),
                ElevatedButton(
                  onPressed: con.signUp,
                  child: Text(
                    'Sign Up',
                    style: Theme.of(context).textTheme.button,
                  ),
                )
              ],
          ),
        ),
            )));
  }
}

class _Controller {
  late _SignUpState state;
  String? email;
  String? password;
  String? passwordConfrim;

  _Controller(this.state);

  void signUp() async {
    FormState? currentState = state.formkey.currentState;
    if (currentState == null || !currentState.validate()) return;

    currentState.save();

    if (password != passwordConfrim) {
      MyDialog.showSnackBar(
        context: state.context,
        message: 'password and confirm do not match',
        seconds: 15,
      );
      return;
    }

    try {
      await FirebaseAuthController.createAccount(
          email: email!, password: password!);
      MyDialog.showSnackBar(
          context: state.context,
          message: 'Account created! Sign in to use the App.');
    } catch (e) {
      if (Constant.DEV) print('---create account error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Cannot create account: $e',
      );
    }
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6)
      return 'password too short';
    else
      return null;
  }

  String? validateEmail(String? value) {
    if (value == null || !(value.contains('.') && value.contains('@')))
      return 'Invalid email address';
    else
      return null;
  }

  void saveConfirmPassword(String? value) {
    passwordConfrim = value;
  }

  void savePassword(String? value) {
    password = value;
  }

  void saveEmail(String? value) {
    email = value;
  }
}