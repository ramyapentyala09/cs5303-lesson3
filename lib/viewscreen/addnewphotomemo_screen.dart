import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lesson3/viewscreen/view/mydailog.dart';

class AddNewPhotoMemoScreen extends StatefulWidget {
  static const routeName = '/addNewPhotoMemoScreen';

  late final User user;

  AddNewPhotoMemoScreen({required this.user});

  @override
  State<StatefulWidget> createState() {
    return _AddNewPhotoMemoState();
  }
}

class _AddNewPhotoMemoState extends State<AddNewPhotoMemoScreen> {
  late _Controller con;
  GlobalKey<FormState> formKey = GlobalKey();
  File? photo;

  _AddNewPhotoMemoState() {
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New PhotoMemo'),
        actions: [
          IconButton(
            onPressed: con.save,
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: photo == null
                        ? FittedBox(
                            child: Icon(
                              Icons.photo_library,
                            ),
                          )
                        : Image.file(photo!),
                  ),
                  Positioned(
                    right: 0.0,
                    bottom: 0.0,
                    child: Container(
                      color: Colors.blue[200],
                      child: PopupMenuButton(
                        onSelected: con.getPhoto,
                        itemBuilder: (context) => [
                          for (var source in PhotoSource.values)
                          PopupMenuItem(
                            value: source,
                            child: Text('${source.toString().split('.')[1]}'),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Title',
                ),
                autocorrect: true,
                validator: PhotoMemo.validateTitle,
                onSaved: con.saveTitle,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Memo',
                ),
                autocorrect: true,
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                validator: PhotoMemo.validateMemo,
                onSaved: con.saveTitle,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Shared with (commaSeperated email List)',
                ),
                maxLines: 2,
                keyboardType: TextInputType.emailAddress,
                validator: PhotoMemo.validateSharedWith,
                onSaved: con.saveSharedWith,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  late _AddNewPhotoMemoState state;
  PhotoMemo tempMemo = PhotoMemo();
  _Controller(this.state);

  void save() {
    FormState? currentstate = state.formKey.currentState;
    if (currentstate == null || !currentstate.validate()) return;
    currentstate.save();
    print(
        '-----tempMemo: ${tempMemo.title} ${tempMemo.memo} ${tempMemo.sharedWith}');
  }

  void getPhoto(PhotoSource source) async {
    try {
      var imageSource = source == PhotoSource.CAMERA 
      ? ImageSource.camera 
      : ImageSource.gallery;
      XFile? image = await ImagePicker().pickImage(source: imageSource);
      if (image == null) return; // canceled by camera or gallery
      state.render(() => state.photo = File(image.path));
     
    } catch (e) {
      if (Constant.DEV) print('===== failed to get a pic: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Failed to get a picture: $e',
        );

}
  }

  void saveTitle(String? value) {
    if (value != null) tempMemo.title = value;
  }

  void saveMemo(String? value) {
    if (value != null) tempMemo.memo = value;
  }

  void saveSharedWith(String? value) {
    if (value != null && value.trim().length != 0) {
      tempMemo.sharedWith.addAll(value.trim().split(RegExp('(,| )+')));
    }
  }
}
