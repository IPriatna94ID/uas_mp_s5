import 'package:cari_teman/main.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cari_teman/models/user.dart';
import 'package:cari_teman/providers/auth.dart';
import 'package:cari_teman/providers/user_provider.dart';
import 'package:cari_teman/util/validators.dart';
import 'package:cari_teman/util/widgets.dart';
import 'package:provider/provider.dart';
import 'package:cari_teman/util/extensions.dart';
import 'package:cari_teman/util/animations.dart';
import 'package:cari_teman/util/router.dart';
import 'package:cari_teman/views/main_screen.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = new GlobalKey<FormState>();

  String _username, _password;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    AuthProvider auth = Provider.of<AuthProvider>(context);

    final usernameField = TextFormField(
      autofocus: false,
      validator: validateEmail,
      onSaved: (value) => _username = value,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.mail),
        hintText: 'Masukan email dirimu dong..',
        labelText: 'Email',
        border: new OutlineInputBorder(
          borderRadius: new BorderRadius.circular(10.0),
          borderSide: new BorderSide(),
        ),
      ),
    );

    final passwordField = TextFormField(
      autofocus: false,
      obscureText: true,
      validator: (value) => value.isEmpty ? "Isi passwordnya dulu sih.." : null,
      onSaved: (value) => _password = value,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock),
        hintText: 'Masukan password dirimu pun..',
        labelText: 'Password',
        border: new OutlineInputBorder(
          borderRadius: new BorderRadius.circular(10.0),
          borderSide: new BorderSide(),
        ),
      ),
    );

    var loading = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Text(" Authenticating ... Please wait")
      ],
    );

    final forgotLabel = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FlatButton(
          padding: EdgeInsets.only(right: 0.0),
          child: Text("Melupai passwordnya?",
              style: TextStyle(fontWeight: FontWeight.w300)),
          onPressed: () {
            //  Navigator.pushReplacementNamed(context, '/reset-password');
          },
        ),
      ],
    );

    final haventAccount = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text("Belum memiliki akun dong?",
            style: TextStyle(fontWeight: FontWeight.w300)),
        FlatButton(
          padding: EdgeInsets.only(left: 0.0),
          child:
              Text("Register", style: TextStyle(fontWeight: FontWeight.w300)),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/register');
          },
        ),
      ],
    );

    var doLogin = () {
      final form = formKey.currentState;

      if (form.validate()) {
        form.save();

        final Future<Map<String, dynamic>> successfulMessage =
            auth.login(_username, _password);

        successfulMessage.then((response) {
          if (response['status']) {
            User user = response['data'];
            Provider.of<UserProvider>(context, listen: false).setUser(user);
            Navigate.pushPageReplacement(context, MyApp());
          } else {
            Flushbar(
              title: "Failed Login",
              message: response['message']['message'].toString(),
              duration: Duration(seconds: 3),
            ).show(context);
          }
        });
      } else {
        print("form is invalid");
      }
    };

    buildLottieContainer() {
      final screenWidth = MediaQuery.of(context).size.width;
      return AnimatedContainer(
        width: screenWidth < 700 ? 0 : screenWidth * 0.5,
        duration: Duration(milliseconds: 500),
        color: Theme.of(context).accentColor.withOpacity(0.3),
        child: Center(
          child: Lottie.asset(
            AppAnimations.chatAnimation,
            height: 400,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        body: Container(
          // padding: EdgeInsets.all(40.0),
          child: Row(
            children: [
              buildLottieContainer(),
              Expanded(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  child: Center(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Cari Teman',
                              style: TextStyle(
                                fontSize: 40.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ).fadeInList(0, false),
                            Text(
                              'Cari teman? Cari Teman aja!',
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                            ).fadeInList(0, false),
                            SizedBox(height: 15.0),
                            usernameField,
                            SizedBox(height: 20.0),
                            passwordField,
                            forgotLabel,
                            longButtons("Login", doLogin),
                            SizedBox(height: 5.0),
                            haventAccount
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
