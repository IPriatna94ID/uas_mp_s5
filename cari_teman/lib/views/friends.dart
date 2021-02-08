import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:cari_teman/utils/data.dart';
import 'package:cari_teman/views/about.dart';
import 'package:cari_teman/utils/app_url.dart';
import 'package:cari_teman/providers/auth.dart';
import 'package:cari_teman/utils/router.dart';
import 'package:cari_teman/main.dart';
import 'package:flushbar/flushbar.dart';

class Friends extends StatefulWidget {
  final int uid;

  Friends({
    Key key,
    @required this.uid,
  }) : super(key: key);
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  Future<List<dynamic>> fetchFriends() async {
    var result =
        await http.get(AppUrl.friends + 'created_by/' + widget.uid.toString());
    return json.decode(result.body);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    AuthProvider auth = Provider.of<AuthProvider>(context);
    void unfollow(String fid, String uid) async {
      auth.unfollow(fid, uid).then((response) {
        if (response['status']) {
          Navigate.pushPageReplacement(context, MyApp());
        } else {
          Flushbar(
            title: "Update filed",
            message: response.toString(),
            duration: Duration(seconds: 10),
          ).show(context);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Friends",
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
          future: fetchFriends(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Map friend = snapshot.data[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (friend['user']['avatar'] != "" ||
                                friend['user']['avatar'] != null)
                            ? NetworkImage(
                                AppUrl.baseURL + friend['user']['avatar'])
                            : AssetImage(
                                "assets/images/cm${random.nextInt(10)}.jpeg",
                              ),
                        radius: 25,
                      ),
                      contentPadding: EdgeInsets.all(0),
                      title: Text(friend['user']['name']),
                      subtitle: Text(friend['user']['email']),
                      trailing: FlatButton(
                        child: Text(
                          "Unfollow",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        color: Colors.orange,
                        onPressed: () {
                          unfollow(friend['user_id'].toString(),
                              widget.uid.toString());
                        },
                      ),
                      onTap: () {},
                    ),
                  );
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      // body: ListView.separated(
      //   padding: EdgeInsets.all(10),
      //   separatorBuilder: (BuildContext context, int index) {
      //     return Align(
      //       alignment: Alignment.centerRight,
      //       child: Container(
      //         height: 0.5,
      //         width: MediaQuery.of(context).size.width / 1.3,
      //         child: Divider(),
      //       ),
      //     );
      //   },
      //   itemCount: friends.length,
      //   itemBuilder: (BuildContext context, int index) {
      //     Map friend = friends[index];
      //     return Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
      //       child: ListTile(
      //         leading: CircleAvatar(
      //           backgroundImage: AssetImage(
      //             friend['dp'],
      //           ),
      //           radius: 25,
      //         ),
      //         contentPadding: EdgeInsets.all(0),
      //         title: Text(friend['name']),
      //         subtitle: Text(friend['status']),
      //         trailing: friend['isAccept']
      //             ? FlatButton(
      //                 child: Text(
      //                   "Unfollow",
      //                   style: TextStyle(
      //                     color: Colors.white,
      //                   ),
      //                 ),
      //                 color: Colors.grey,
      //                 onPressed: () {},
      //               )
      //             : FlatButton(
      //                 child: Text(
      //                   "Follow",
      //                   style: TextStyle(
      //                     color: Colors.white,
      //                   ),
      //                 ),
      //                 color: Theme.of(context).accentColor,
      //                 onPressed: () {},
      //               ),
      //         onTap: () {},
      //       ),
      //     );
      //   },
      // ),
    );
  }
}
