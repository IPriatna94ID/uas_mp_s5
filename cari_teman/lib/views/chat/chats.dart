import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:cari_teman/widgets/chat_item.dart';
// import 'package:cari_teman/utils/data.dart';
import 'package:animations/animations.dart';
import 'package:flutter/rendering.dart';
import 'package:cari_teman/views/about.dart';
import 'package:cari_teman/utils/app_url.dart';
import 'package:cari_teman/views/post.dart';

class Chats extends StatefulWidget {
  final int uid;

  Chats({
    Key key,
    @required this.uid,
  }) : super(key: key);
  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // TabController _tabController;
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

  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
  }

  Future<List<dynamic>> fetchChat() async {
    var result = await http.get(AppUrl.chat + widget.uid.toString());
    return json.decode(result.body);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chat",
        ),
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
          future: fetchChat(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Map chat = snapshot.data[index];
                  return ChatItem(
                      id: chat['post']['id'],
                      dp: chat['post']['user']['avatar'],
                      name: chat['post']['user']['name'],
                      isOnline: true,
                      counter: 0,
                      msg: chat['post']['text'],
                      time: chat['created_at']);
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      // body: TabBarView(
      //   controller: _tabController,
      //   children: <Widget>[
      //     ListView.separated(
      //       padding: EdgeInsets.all(10),
      //       separatorBuilder: (BuildContext context, int index) {
      //         return Align(
      //           alignment: Alignment.centerRight,
      //           child: Container(
      //             height: 0.5,
      //             width: MediaQuery.of(context).size.width / 1.3,
      //             child: Divider(),
      //           ),
      //         );
      //       },
      //       itemCount: chats.length,
      //       itemBuilder: (BuildContext context, int index) {
      //         Map chat = chats[index];
      //         return ChatItem(
      //           dp: chat['dp'],
      //           name: chat['name'],
      //           isOnline: chat['isOnline'],
      //           counter: chat['counter'],
      //           msg: chat['msg'],
      //           time: chat['time'],
      //         );
      //       },
      //     ),
      //     ListView.separated(
      //       padding: EdgeInsets.all(10),
      //       separatorBuilder: (BuildContext context, int index) {
      //         return Align(
      //           alignment: Alignment.centerRight,
      //           child: Container(
      //             height: 0.5,
      //             width: MediaQuery.of(context).size.width / 1.3,
      //             child: Divider(),
      //           ),
      //         );
      //       },
      //       itemCount: groups.length,
      //       itemBuilder: (BuildContext context, int index) {
      //         Map chat = groups[index];
      //         return ChatItem(
      //           dp: chat['dp'],
      //           name: chat['name'],
      //           isOnline: chat['isOnline'],
      //           counter: chat['counter'],
      //           msg: chat['msg'],
      //           time: chat['time'],
      //         );
      //       },
      //     ),
      //   ],
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

  @override
  bool get wantKeepAlive => true;
}
