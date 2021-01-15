import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cari_teman/models/user.dart';
import 'package:cari_teman/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:cari_teman/providers/user_provider.dart';
import 'package:cari_teman/util/shared_preference.dart';
import 'package:provider/provider.dart';
import 'package:cari_teman/models/user.dart';
import 'package:cari_teman/util/router.dart';
import 'package:cari_teman/pages/login.dart';

class Welcome extends StatelessWidget {
  final User user;

  Welcome({Key key, @required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Provider.of<UserProvider>(context).setUser(user);

    void logoutUser() {
      UserPreferences().removeUser();
      Navigate.pushPageReplacement(context, Login());
    }

    print(user);

    return Scaffold(
      body: Container(
        child: Center(
            child: RaisedButton(
          onPressed: () {
            logoutUser();
          },
          child: Text("Logout"),
          color: Colors.lightBlueAccent,
        )),
      ),
    );
  }
}
