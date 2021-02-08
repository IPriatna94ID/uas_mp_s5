import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:cari_teman/providers/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cari_teman/models/user.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flushbar/flushbar.dart';
import 'package:cari_teman/utils/router.dart';
import 'package:cari_teman/main.dart';

class PostForm extends StatefulWidget {
  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  dynamic response;
  User user;
  int userId;
  String name, email, avatar;
  final formKey = new GlobalKey<FormState>();

  final TextEditingController _bodyController = TextEditingController();
  final tagRegex = RegExp(r"@([\w\-\.]+)", caseSensitive: false);
  double characterLmitValue = 0;
  double limit = 255;

  File _image;
  bool _imageInProcess = false;
  bool _showUserList = false;
  bool dialVisible = true;

  Future<File> file;
  String status = '';
  String postText, base64Image, fileName;
  File tmpFile;
  String errMessage = 'Error Uploading Image';

  bool get isPopulated =>
      _bodyController.text.isNotEmpty && _bodyController.text.length < 255;

  bool isButtonEnabled() {
    return isPopulated;
  }

  @override
  void initState() {
    userId = 0;
    base64Image = "";
    fileName = "";
    name = "";
    email = "";
    avatar = "";
    _loadProfile();
    _bodyController.addListener(_onBodyChanged);
    super.initState();
  }

  _loadProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt("userId");
      name = prefs.getString("name");
      email = prefs.getString("email");
      avatar = prefs.getString("avatar");
    });
  }

  @override
  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  void _onBodyChanged() {
    final sentences = _bodyController.text.split('\n');
    sentences.forEach((sentence) {
      final words = sentence.split(' ');
      String withAt = words.last;
      var match = tagRegex.firstMatch(withAt);

      if (match != null) {
        setState(() {
          _showUserList = true;
        });
      } else {
        setState(() {
          _showUserList = false;
        });
      }
    });

    setState(() {
      updateCharacterLimit();
    });
  }

  updateCharacterLimit() {
    if (_bodyController.text.length == 0) {
      characterLmitValue = 0.0;
    }
    if (_bodyController.text.length > limit) {
      characterLmitValue = 1.0;
    }
    characterLmitValue = (_bodyController.text.length * 100) / 25500.0;
  }

  reachWarningLimit() {
    return _bodyController.text.length > (limit - 21);
  }

  reachErrorLimit() {
    return _bodyController.text.length > (limit + 9);
  }

  reachInitailErrorLimit() {
    return _bodyController.text.length > limit &&
        _bodyController.text.length < (limit + 9);
  }

  getIndicatorColor() {
    if (reachInitailErrorLimit()) {
      return Colors.red[400];
    }

    if (reachWarningLimit()) {
      return Colors.orange;
    }

    return Theme.of(context).primaryColor;
  }

  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  _imgFromGallery() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  Future _getImage(ImageSource source) async {
    final picker = ImagePicker();

    setState(() {
      _imageInProcess = true;
    });

    final pickedFile = await picker.getImage(source: source);

    File image = File(pickedFile.path);

    if (image != null) {
      File croppedImage = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
        compressFormat: ImageCompressFormat.png,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Edit image',
          toolbarColor: Theme.of(context).scaffoldBackgroundColor,
          activeControlsWidgetColor: Theme.of(context).primaryColor,
        ),
      );

      setState(() {
        _image = croppedImage;
        _imageInProcess = false;
      });
    } else {
      setState(() {
        _imageInProcess = false;
      });
    }
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      icon: Icons.photo,
      activeIcon: Icons.close,
      // animatedIcon: AnimatedIcons.menu_close,
      // animatedIconTheme: IconThemeData(size: 22.0),
      // buttonSize: 56.0,
      visible: true,

      /// If true user is forced to close dial manually
      /// by tapping main button and overlay is not rendered.
      closeManually: false,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      tooltip: 'Add an image',
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 8.0,
      shape: CircleBorder(),
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.photo_library, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () => _imgFromGallery(),
          label: 'Media Libraray',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.green,
        ),
        SpeedDialChild(
          child: Icon(Icons.camera, color: Colors.white),
          backgroundColor: Colors.orange,
          onTap: () => _imgFromCamera(),
          label: 'Camera',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.orange,
        ),
      ],
    );
  }

  setStatus(String message) {
    setState(() {
      status = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    AuthProvider auth = Provider.of<AuthProvider>(context);

    var submitForm = () {
      final form = formKey.currentState;

      if (_image != "" && form.validate()) {
        form.save();
        base64Image = base64Encode(_image.readAsBytesSync());
        fileName = _image.path.split("/").last;
        auth
            .submitPost(userId.toString(), fileName, base64Image, postText)
            .then((response) {
          if (response['status']) {
            Navigate.pushPageReplacement(context, MyApp());
          } else {
            Flushbar(
              title: "Registration Failed",
              message: response.toString(),
              duration: Duration(seconds: 10),
            ).show(context);
          }
        });
      } else {
        Flushbar(
          title: "Invalid resquest",
          message: "Upload foto dulu dong..",
          duration: Duration(seconds: 10),
        ).show(context);
      }
    };

    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(10.0),
                child: Form(
                  key: formKey,
                  child: ListView(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Text(
                              'Cancel',
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                          FlatButton(
                            onPressed: isButtonEnabled() ? submitForm : null,
                            color: Theme.of(context).primaryColor,
                            disabledColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Text(
                              'Publish',
                              style:
                                  Theme.of(context).textTheme.button.copyWith(
                                        color: Colors.white,
                                      ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // _userAvatar(),
                          Column(
                            children: <Widget>[
                              Container(
                                width: 320.0,
                                height: null,
                                child: SingleChildScrollView(
                                  child: TextFormField(
                                    controller: _bodyController,
                                    autofocus: true,
                                    maxLines: null,
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                    onSaved: (value) => postText = value,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      hintText: "Lagi apa?",
                                      // errorStyle: TextStyle(fontFamily: 'Poppins-Medium'),
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              _image != null ? _formImage() : Container(),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
      floatingActionButton: buildSpeedDial(),
    );
  }

  Widget _formImage() {
    return Stack(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Image(
            image: FileImage(_image),
            width: 320.0,
          ),
        ),
        Positioned(
            top: 8.0,
            right: 8.0,
            child: InkWell(
              onTap: () {
                setState(() {
                  _image = null;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(
                    .65,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(3.0),
                  child: Icon(
                    Icons.close,
                    color: Colors.grey[300],
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _userAvatar() {
    return CircleAvatar(
      radius: 20.0,
      backgroundColor: Theme.of(context).cardColor,
      backgroundImage: NetworkImage(avatar),
    );
  }

  Widget _characterLimitIndicator() {
    return _bodyController.text != null && reachErrorLimit()
        ? Padding(
            padding: EdgeInsets.only(right: 10),
            child: Text(
              '${limit.toInt() - _bodyController.text.length}',
              style: TextStyle(
                color: Colors.red[400],
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          )
        : Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                height: 25.0,
                width: 25.0,
                child: CircularProgressIndicator(
                  value: characterLmitValue,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    getIndicatorColor(),
                  ),
                ),
              ),
              reachWarningLimit()
                  ? Text(
                      '${limit.toInt() - _bodyController.text.length}',
                      style: TextStyle(
                        color: getIndicatorColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(
                      '',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
            ],
          );
  }
}
