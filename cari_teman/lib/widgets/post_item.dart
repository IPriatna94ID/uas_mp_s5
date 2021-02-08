import 'package:cari_teman/views/profile.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cari_teman/utils/app_url.dart';
import 'package:cari_teman/widgets/chat/conversation.dart';

class PostItem extends StatefulWidget {
  final int id;
  final int uid;
  final String name;
  final String dp;
  final String img;
  final String text;
  final String time;

  PostItem(
      {Key key,
      @required this.id,
      @required this.uid,
      @required this.name,
      @required this.dp,
      @required this.img,
      @required this.text,
      @required this.time})
      : super(key: key);
  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  static Random random = Random();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                backgroundImage: (widget.dp != "" && widget.dp != null)
                    ? NetworkImage(AppUrl.baseURL + "${widget.dp}")
                    : AssetImage(
                        "assets/images/cm${random.nextInt(10)}.jpeg",
                      ),
                backgroundColor: Colors.transparent,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Profile(uid: widget.uid)),
                );
              },
              contentPadding: EdgeInsets.all(0),
              title: Text(
                "${widget.name}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Text(
                "${widget.time}",
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 11,
                ),
              ),
            ),
            Image.network("${widget.img}"),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    "${widget.text}",
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return Conversation(id: widget.id);
              },
            ),
          );
        },
      ),
    );
  }
}
