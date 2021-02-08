import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cari_teman/models/user.dart';
import 'package:cari_teman/providers/auth.dart';
import 'package:cari_teman/providers/user_provider.dart';
import 'package:flushbar/flushbar.dart';
import 'package:json_form_generator/json_form_generator.dart';
import 'package:cari_teman/utils/router.dart';
import 'package:cari_teman/main.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  dynamic response;
  User user;
  int userId;
  String name, email, avatar;
  var _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    userId = 0;
    name = "";
    email = "";
    avatar = "";
    _loadProfile();
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

  String form = json.encode([
    {
      "title": "name",
      "label": "Nama lengkap",
      "type": "text",
      "required": "yes"
    },
    {"title": "email", "label": "Email", "type": "text", "required": "yes"},
    {
      "title": "password",
      "label": "Password",
      "type": "password",
      "required": "yes"
    },
    {
      "title": "konfirmasi_password",
      "label": "Konfirmasi Password",
      "type": "password",
      "required": "yes"
    },
  ]);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    AuthProvider auth = Provider.of<AuthProvider>(context);

    void submitForm(formData) async {
      final form = _formkey.currentState;

      if (form.validate()) {
        form.save();
        if (formData['password'] == formData['konfirmasi_password']) {
          auth
              .update(userId.toString(), formData['name'], formData['email'],
                  formData['password'], formData['konfirmasi_password'])
              .then((response) {
            if (response['status']) {
              User user = response['data'];
              Provider.of<UserProvider>(context, listen: false).setUser(user);
              Navigate.pushPageReplacement(context, MyApp());
            } else {
              Flushbar(
                title: "Update data Failed",
                message: response.toString(),
                duration: Duration(seconds: 10),
              ).show(context);
            }
          });
        } else {
          Flushbar(
            title: "Invalid form",
            message:
                "Password & konfirmasi password nampaknya tidak memiliki kemiripan",
            duration: Duration(seconds: 10),
          ).show(context);
        }
      } else {
        Flushbar(
          title: "Invalid form",
          message: "Please Complete the form properly",
          duration: Duration(seconds: 10),
        ).show(context);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Update Profile"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(children: <Widget>[
            JsonFormGenerator(
              form: form,
              onChanged: (dynamic value) {
                print(value);
                setState(() {
                  this.response = value;
                });
              },
            ),
            new RaisedButton(
                child: new Text('Submit'),
                onPressed: () {
                  if (_formkey.currentState.validate()) {
                    submitForm(this.response);
                  }
                })
          ]),
        ),
      ),
    );
  }
}
