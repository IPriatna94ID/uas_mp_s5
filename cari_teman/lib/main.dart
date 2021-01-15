import 'package:flutter/material.dart';
import 'package:cari_teman/pages/dashboard.dart';
import 'package:cari_teman/pages/login.dart';
import 'package:cari_teman/pages/register.dart';
import 'package:cari_teman/providers/auth.dart';
import 'package:cari_teman/providers/user_provider.dart';
import 'package:cari_teman/util/shared_preference.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'package:cari_teman/views/main_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<User> getUserData() => UserPreferences().getUser();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: FutureBuilder(
              future: getUserData(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  default:
                    if (snapshot.hasError)
                      return Text('Error: ${snapshot.error}');
                    else if (snapshot.data.userId == null)
                      return Login();
                    else
                      return MainScreen();
                }
              }),
          routes: {
            '/dashboard': (context) => DashBoard(),
            '/login': (context) => Login(),
            '/register': (context) => Register(),
          }),
    );
  }
}
