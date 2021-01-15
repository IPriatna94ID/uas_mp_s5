import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cari_teman/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cari_teman/views/edit_profile.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  static Random random = Random();
  User user;
  int userId;
  String name, email, avatar;
  @override
  void initState() {
    super.initState();
    userId = 0;
    name = "";
    email = "";
    avatar = "";
    _loadCounter();
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

  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 60),
              CircleAvatar(
                backgroundImage: AssetImage(
                  "assets/images/cm${random.nextInt(10)}.jpeg",
                ),
                radius: 50,
              ),
              SizedBox(height: 10),
              Text(
                name,
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
                      Icons.message,
                      color: Colors.white,
                    ),
                    color: Colors.grey,
                    onPressed: () {},
                  ),
                  SizedBox(width: 10),
                  FlatButton(
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfile()),
                      );
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
                    _buildCategory("Posts"),
                    _buildCategory("Friends"),
                    _buildCategory("Groups"),
                  ],
                ),
              ),
              SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                primary: false,
                padding: EdgeInsets.all(5),
                itemCount: 15,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 200 / 200,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Image.asset(
                      "assets/images/cm${random.nextInt(10)}.jpeg",
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(String title) {
    return Column(
      children: <Widget>[
        Text(
          random.nextInt(10000).toString(),
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
