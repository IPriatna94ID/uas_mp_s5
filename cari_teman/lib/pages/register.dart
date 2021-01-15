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
import 'package:cari_teman/main.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final formKey = new GlobalKey<FormState>();

  String _fname, _username, _password, _confirmPassword;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    AuthProvider auth = Provider.of<AuthProvider>(context);

    final fNameField = TextFormField(
      autofocus: false,
      validator: (value) =>
          value.isEmpty ? "Nama lengkap tidak kosong dong.." : null,
      onSaved: (value) => _fname = value,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.person),
        hintText: 'Masukan nama lengkap dirimu itu..',
        labelText: 'Nama Lengkap',
        border: new OutlineInputBorder(
          borderRadius: new BorderRadius.circular(10.0),
          borderSide: new BorderSide(),
        ),
      ),
    );

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
      validator: (value) =>
          value.isEmpty ? "Password juga harus diisi pun.." : null,
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

    final confirmPassword = TextFormField(
      autofocus: false,
      validator: (value) =>
          value.isEmpty ? "Udah sama blom sama password yg diatas?" : null,
      onSaved: (value) => _confirmPassword = value,
      obscureText: true,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock),
        hintText: 'Masukan password dirimu lagi sih..',
        labelText: 'Konfirmasi Password',
        border: new OutlineInputBorder(
          borderRadius: new BorderRadius.circular(10.0),
          borderSide: new BorderSide(),
        ),
      ),
    );

    final haveAccount = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text("Sudah memiliki akun pun?",
            style: TextStyle(fontWeight: FontWeight.w300)),
        FlatButton(
          padding: EdgeInsets.only(left: 0.0),
          child: Text("Login", style: TextStyle(fontWeight: FontWeight.w300)),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    );

    var loading = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Text(" Registering ... Please wait")
      ],
    );

    var doRegister = () {
      final form = formKey.currentState;
      if (form.validate()) {
        form.save();
        if (_password == _confirmPassword) {
          auth
              .register(_fname, _username, _password, _confirmPassword)
              .then((response) {
            if (response['status']) {
              User user = response['data'];
              Provider.of<UserProvider>(context, listen: false).setUser(user);
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
        resizeToAvoidBottomInset: false,
        body: Container(
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
                            fNameField,
                            SizedBox(height: 5.0),
                            usernameField,
                            SizedBox(height: 10.0),
                            passwordField,
                            SizedBox(height: 10.0),
                            confirmPassword,
                            SizedBox(height: 20.0),
                            auth.loggedInStatus == Status.Authenticating
                                ? loading
                                : longButtons("Login", doRegister),
                            haveAccount
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
