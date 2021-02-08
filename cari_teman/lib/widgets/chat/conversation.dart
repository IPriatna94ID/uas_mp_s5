import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cari_teman/widgets/chat_bubble.dart';
import 'package:cari_teman/utils/data.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cari_teman/utils/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cari_teman/views/profile.dart';
import 'package:cari_teman/providers/auth.dart';
import 'package:provider/provider.dart';
import 'package:flushbar/flushbar.dart';
import 'package:cari_teman/utils/router.dart';
import 'package:cari_teman/main.dart';

class Conversation extends StatefulWidget {
  final int id;

  Conversation({
    Key key,
    @required this.id,
  }) : super(key: key);

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  static Random random = Random();
  // String name = names[random.nextInt(10)];
  int uid, fid, posts, followers, following;
  String name, email, avatar, fname, femail, favatar, postText;
  Future<Post> futurePost;

  final formKey = new GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    uid = 0;
    name = "";
    email = "";
    avatar = "";
    _loadCounter();
    futurePost = fetchPost();
  }

  _loadCounter() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.get(AppUrl.post + widget.id.toString());
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        uid = prefs.getInt("userId");
        name = prefs.getString("name");
        email = prefs.getString("email");
        avatar = prefs.getString("avatar");
        fid = data['user']['id'];
        fname = data['user']['name'];
        femail = data['user']['email'];
        favatar = data['user']['avatar'];
      });
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<Post> fetchPost() async {
    final response = await http.get(AppUrl.post + widget.id.toString());
    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<List<dynamic>> fetchComments() async {
    var result = await http.get(AppUrl.comments + '/' + widget.id.toString());
    return json.decode(result.body);
  }

  Color chatBubbleColor() {
    // if (widget.isMe) {
    //   return Theme.of(context).accentColor;
    // } else {
    //   if (Theme.of(context).brightness == Brightness.dark) {
    //     return Colors.grey[800];
    //   } else {
    //     return Colors.grey[200];
    //   }
    // }
    return Theme.of(context).accentColor;
  }

  Color chatBubbleReplyColor() {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Colors.grey[600];
    } else {
      return Colors.grey[50];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    AuthProvider auth = Provider.of<AuthProvider>(context);

    var submitForm = () {
      final form = formKey.currentState;

      if (form.validate()) {
        form.save();
        auth
            .postComment(widget.id.toString(), uid.toString(), postText)
            .then((response) {
          if (response['status']) {
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
          title: "Invalid resquest",
          message: "Upload foto dulu dong..",
          duration: Duration(seconds: 10),
        ).show(context);
      }
    };

    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_backspace,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: InkWell(
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 0.0, right: 10.0),
                child: CircleAvatar(
                    backgroundImage: (favatar == null && favatar == "")
                        ? AssetImage(
                            "assets/images/cm${random.nextInt(10)}.jpeg",
                          )
                        : NetworkImage(AppUrl.baseURL + favatar)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      fname,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Online",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Profile(uid: fid)),
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.more_horiz,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            Flexible(
              child: FutureBuilder<Post>(
                future: futurePost,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ChatBubble(
                      message: AppUrl.baseURL + snapshot.data.path,
                      username: snapshot.data.name,
                      time: snapshot.data.created_at,
                      type: "snapshot.data",
                      replyText: snapshot.data.text,
                      isMe: (snapshot.data.user_id == uid) ? true : false,
                      isGroup: false,
                      isReply: false,
                      replyName: snapshot.data.name,
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Flexible(
              child: FutureBuilder<List<dynamic>>(
                future: fetchComments(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        Map comment = snapshot.data[index];
                        return ChatBubble(
                          message: comment['text'],
                          username: comment['name'],
                          time: comment['created_at'],
                          type: "text",
                          replyText: comment['text'],
                          isMe: (comment['user_id'] == uid) ? true : false,
                          isGroup: false,
                          isReply: false,
                          replyName: comment['name'],
                        );
                      },
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: BottomAppBar(
                  elevation: 10,
                  color: Theme.of(context).primaryColor,
                  child: Form(
                    key: formKey,
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: 100,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                          Flexible(
                            child: TextFormField(
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.white,
                              ),
                              onSaved: (value) => postText = value,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10.0),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                hintText: "Write your message...",
                                hintStyle: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.white,
                                ),
                              ),
                              maxLines: null,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              submitForm();
                            },
                          )
                        ],
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class Post {
  final int id;
  final int user_id;
  final String name;
  final String avatar;
  final String text;
  final String path;
  final String created_at;

  Post(
      {this.id,
      this.user_id,
      this.name,
      this.avatar,
      this.text,
      this.path,
      this.created_at});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      user_id: json['user_id'],
      name: json['user']['name'],
      avatar: json['user']['avatar'],
      text: json['text'],
      path: json['path'],
      created_at: json['created_at'],
    );
  }
}
