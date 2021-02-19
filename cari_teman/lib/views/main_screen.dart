import 'package:flutter/material.dart';
import 'package:cari_teman/widgets/icon_badge.dart';
import 'package:cari_teman/views/chat/chats.dart';
import 'package:cari_teman/views/friends.dart';
import 'package:cari_teman/views/home.dart';
import 'package:cari_teman/views/notifications.dart';
import 'package:cari_teman/views/profile.dart';
import 'package:cari_teman/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cari_teman/utils/app_url.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  PageController _pageController;
  int _page = 2;

  User user;
  int uid;

  _loadCounter() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      uid = prefs.getInt("userId");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: <Widget>[
          Chats(uid: uid),
          Friends(uid: uid),
          Home(),
          Notifications(uid: uid),
          Profile(uid: uid),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.message,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.group,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: IconBadge(icon: Icons.notifications),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '',
            ),
          ],
          onTap: navigationTapped,
          currentIndex: _page,
        ),
      ),
    );
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    _loadCounter();
    _pageController = PageController(initialPage: 2);
  }

  @override
  void dispose() {
    super.dispose();
    uid = 0;
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }
}
