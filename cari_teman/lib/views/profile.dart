import 'dart:math';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:cari_teman/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cari_teman/views/edit_profile.dart';
import 'package:cari_teman/utils/shared_preference.dart';
import 'package:flushbar/flushbar.dart';
import 'package:cari_teman/utils/app_url.dart';
import 'package:cari_teman/providers/auth.dart';
import 'package:cari_teman/utils/router.dart';
import 'package:cari_teman/main.dart';
import 'package:cari_teman/providers/user_provider.dart';
import 'package:cari_teman/utils/app_url.dart';

class Profile extends StatefulWidget {
  final int uid;

  Profile({
    Key key,
    @required this.uid,
  }) : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  static Random random = Random();
  User user;
  int userId, posts, followers, following;
  String name, email, avatar;
  final GlobalKey<ScaffoldState> _formkey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();
  AnimationController _animationController;

  File _image;
  bool dialVisible = true;

  Future<File> file;
  String status = '';
  String postText, base64Image, fileName;
  File tmpFile;
  String errMessage = 'Error Uploading Image';
  AuthProvider auth;
  Future<UserProfile> futureProfile;

  @override
  void initState() {
    super.initState();
    userId = 0;
    name = "";
    email = "";
    avatar = "";
    _loadCounter();
    futureProfile = fetchUser();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
  }

  _loadCounter() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt("userId");
      name = prefs.getString("name");
      email = prefs.getString("email");
      avatar = prefs.getString("avatar");
    });
  }

  void logoutUser() {
    UserPreferences().removeUser();
    Flushbar(
      title: "Logout",
      message: "Logout berhasil",
      duration: Duration(seconds: 10),
    ).show(context);
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<UserProfile> fetchUser() async {
    final response = await http.get(AppUrl.getProfile + widget.uid.toString());
    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<List<dynamic>> fetchPost() async {
    var result = await http.get(AppUrl.myPost + widget.uid.toString());
    return json.decode(result.body);
  }

  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    AuthProvider auth = Provider.of<AuthProvider>(context);

    void submitForm() async {
      if (_image != "") {
        base64Image = base64Encode(_image.readAsBytesSync());
        fileName = _image.path.split("/").last;
        auth
            .updateAvatar(userId.toString(), fileName, base64Image)
            .then((response) {
          if (response['status']) {
            User user = response['data'];
            Provider.of<UserProvider>(context, listen: false).setUser(user);
            Navigate.pushPageReplacement(context, MyApp());
          } else {
            Flushbar(
              title: "Update filed",
              message: response.toString(),
              duration: Duration(seconds: 10),
            ).show(context);
          }
        });
      }
    }

    void follow(String uid, String fid) async {
      auth.follow(uid, fid).then((response) {
        if (response['status']) {
          Navigate.pushPageReplacement(context, MyApp());
        } else {
          Flushbar(
            title: "Update filed",
            message: response.toString(),
            duration: Duration(seconds: 10),
          ).show(context);
        }
      });
    }

    void unfollow(String fid, String uid) async {
      auth.unfollow(fid, uid).then((response) {
        if (response['status']) {
          Navigate.pushPageReplacement(context, MyApp());
        } else {
          Flushbar(
            title: "Update filed",
            message: response.toString(),
            duration: Duration(seconds: 10),
          ).show(context);
        }
      });
    }

    void _imgFromCamera() async {
      File image = await ImagePicker.pickImage(
          source: ImageSource.camera, imageQuality: 50);

      setState(() {
        _image = image;
      });
      submitForm();
    }

    void _imgFromGallery() async {
      File image = await ImagePicker.pickImage(
          source: ImageSource.gallery, imageQuality: 50);

      setState(() {
        _image = image;
      });
      submitForm();
    }

    ;

    void _showPicker(context) {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext bc) {
            return SafeArea(
              child: Container(
                child: new Wrap(
                  children: <Widget>[
                    new ListTile(
                        leading: new Icon(Icons.photo_library),
                        title: new Text('Photo Library'),
                        onTap: () {
                          _imgFromGallery();
                          Navigator.of(context).pop();
                        }),
                    new ListTile(
                      leading: new Icon(Icons.photo_camera),
                      title: new Text('Camera'),
                      onTap: () {
                        _imgFromCamera();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          });
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: FutureBuilder<UserProfile>(
            future: futureProfile,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 60),
                    GestureDetector(
                      onTap: () {
                        _showPicker(context);
                      },
                      child: CircleAvatar(
                        backgroundImage: (snapshot.data.avatar != null &&
                                snapshot.data.avatar != "")
                            ? NetworkImage(
                                AppUrl.baseURL + snapshot.data.avatar)
                            : AssetImage(
                                "assets/images/cm${random.nextInt(10)}.jpeg",
                              ),
                        radius: 50,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      snapshot.data.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      email,
                      style: TextStyle(),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        FlatButton(
                          child: Icon(
                            (userId == widget.uid) ? Icons.edit : Icons.message,
                            color: Colors.white,
                          ),
                          color: Theme.of(context).accentColor,
                          onPressed: () {
                            if (userId == widget.uid) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditProfile()),
                              );
                            }
                          },
                        ),
                        SizedBox(width: 10),
                        FlatButton(
                          child: Icon(
                            (userId == widget.uid)
                                ? Icons.logout
                                : (snapshot.data.followed > 0)
                                    ? Icons.clear
                                    : Icons.add,
                            color: Colors.white,
                          ),
                          color: (snapshot.data.followed > 0)
                              ? Colors.red
                              : Colors.green,
                          onPressed: () {
                            print(userId);
                            if (userId == widget.uid) {
                              logoutUser();
                            } else if (snapshot.data.followed > 0) {
                              unfollow(
                                  widget.uid.toString(), userId.toString());
                            } else {
                              follow(userId.toString(), widget.uid.toString());
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _buildCategory("Posts", snapshot.data.posts),
                          _buildCategory("Followers", snapshot.data.followers),
                          _buildCategory("Following", snapshot.data.following),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      child: FutureBuilder<List<dynamic>>(
                        future: fetchPost(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              primary: false,
                              padding: EdgeInsets.all(5),
                              itemCount: snapshot.data.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 200 / 200,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                Map post = snapshot.data[index];
                                return Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: (post['path'] != "" ||
                                          post['path'] != null)
                                      ? Image.network(
                                          AppUrl.baseURL + post['path'])
                                      : Image.asset(
                                          "assets/images/cm${random.nextInt(10)}.jpeg",
                                          fit: BoxFit.cover,
                                        ),
                                );
                              },
                            );
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                print("${snapshot.error}");
                return Center(
                  child: Text("${snapshot.error}"),
                );
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(String title, int itemCount) {
    return Column(
      children: <Widget>[
        Text(
          itemCount.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(),
        ),
      ],
    );
  }
}

class UserProfile {
  final int id;
  final String name;
  final String email;
  final String avatar;
  final int posts;
  final int followers;
  final int following;
  final int followed;

  UserProfile(
      {this.id,
      this.name,
      this.email,
      this.avatar,
      this.posts,
      this.followers,
      this.following,
      this.followed});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      posts: json['posts_count'],
      followers: json['followers_count'],
      following: json['following_count'],
      followed: json['followed_count'],
    );
  }
}
