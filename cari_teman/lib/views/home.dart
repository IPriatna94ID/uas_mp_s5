import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:animations/animations.dart';
import 'package:flutter/rendering.dart';
import 'package:cari_teman/widgets/post_item.dart';
import 'package:cari_teman/views/about.dart';
import 'package:cari_teman/views/post.dart';
import 'package:cari_teman/utils/app_url.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;

  int _currentIndex = 0;

  PageController _pageController;
  bool dialVisible = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController.addListener(_onScroll);
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
  }

  // @override
  // void dispose() {
  //   _pageController.dispose();
  //   _scrollController.dispose();
  //   _animationController.dispose();
  //   super.dispose();
  // }

  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
  }

  Future<List<dynamic>> fetchUsers() async {
    var result = await http.get(AppUrl.postList);
    return json.decode(result.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Feeds"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.info,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => About()),
                );
              }),
        ],
      ),
      body: Container(
        child: FutureBuilder<List<dynamic>>(
          future: fetchUsers(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Map post = snapshot.data[index];
                  return PostItem(
                      id: post['id'],
                      uid: post['user']['id'],
                      name: post['user']['name'],
                      dp: post['user']['avatar'],
                      img: AppUrl.baseURL + post['path'],
                      text: post['text'],
                      time: post['created_at']);
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      // body: ListView.builder(
      //   padding: EdgeInsets.symmetric(horizontal: 20),
      //   itemCount: posts.length,
      //   controller: _scrollController,
      //   reverse: true,
      //   shrinkWrap: true,
      //   itemBuilder: (BuildContext context, int index) {
      //     Map post = posts[index];
      //     return PostItem(
      //       img: post['img'],
      //       name: post['name'],
      //       dp: post['dp'],
      //       time: post['time'],
      //     );
      //   },
      // ),
      floatingActionButton: OpenContainer(
          closedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(65.0),
            ),
          ),
          closedColor: Theme.of(context).primaryColor,
          closedElevation: 0.0,
          transitionDuration: Duration(milliseconds: 500),
          openBuilder: (context, action) => PostForm(),
          transitionType: ContainerTransitionType.fade,
          closedBuilder: (BuildContext context, VoidCallback openContainer) {
            return Container(
              width: 50.0,
              height: 50.0,
              // decoration: BoxDecoration(
              //   gradient: LinearGradient(
              //     colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
              //   ),
              //   color: Theme.of(context).primaryColor,
              //   shape: BoxShape.circle,
              //   boxShadow: [
              //     BoxShadow(
              //         color: Color(0xFF2F80ED).withOpacity(.3),
              //         offset: Offset(0.0, 8.0),
              //         blurRadius: 8.0)
              //   ],
              // ),
              child: RawMaterialButton(
                shape: CircleBorder(),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (_, child) {
                    return Transform.rotate(
                      angle: _animationController.value * math.pi,
                      child: child,
                    );
                  },
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
                onPressed: openContainer,
              ),
            );
          }),
    );
  }
}
