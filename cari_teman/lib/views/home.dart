import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:cari_teman/widgets/post_item.dart';
import 'package:cari_teman/util/data.dart';
import 'package:cari_teman/widgets/camera.dart';
import 'package:cari_teman/views/about.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ScrollController scrollController;
  ScrollController _scrollController = new ScrollController();

  bool dialVisible = true;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController()
      ..addListener(() {
        setDialVisible(scrollController.position.userScrollDirection ==
            ScrollDirection.forward);
      });
  }

  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
  }

  Widget buildBody() {
    return ListView.builder(
      controller: scrollController,
      itemCount: 30,
      itemBuilder: (ctx, i) => ListTile(title: Text('Item $i')),
    );
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      // child: Icon(Icons.add),
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      visible: dialVisible,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.edit, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () => print('Text'),
          label: 'Text',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.green,
        ),
        SpeedDialChild(
          child: Icon(Icons.photo_library, color: Colors.white),
          backgroundColor: Colors.orange,
          onTap: () => print('SECOND CHILD'),
          label: 'Media Libraray',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.orange,
        ),
        SpeedDialChild(
          child: Icon(Icons.camera, color: Colors.white),
          backgroundColor: Colors.red,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CameraExampleHome()),
          ),
          label: 'Camera',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.red,
        ),
      ],
    );
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
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: posts.length,
        // controller: _scrollController,
        reverse: true,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          Map post = posts[index];
          return PostItem(
            img: post['img'],
            name: post['name'],
            dp: post['dp'],
            time: post['time'],
          );
        },
      ),
      floatingActionButton: buildSpeedDial(),
    );
  }
}
