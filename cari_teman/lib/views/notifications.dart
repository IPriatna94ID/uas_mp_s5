import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:cari_teman/utils/data.dart';
import 'package:cari_teman/views/about.dart';
import 'package:cari_teman/utils/app_url.dart';
import 'package:cari_teman/providers/auth.dart';
import 'package:cari_teman/utils/router.dart';
import 'package:cari_teman/utils/time_ago.dart';
import 'package:cari_teman/main.dart';
import 'package:flushbar/flushbar.dart';
import 'package:intl/intl.dart';
import 'package:date_format/date_format.dart';
import 'package:cari_teman/views/profile.dart';

class Notifications extends StatefulWidget {
  final int uid;

  Notifications({
    Key key,
    @required this.uid,
  }) : super(key: key);
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  Future<List<dynamic>> fetchNotifs() async {
    var result =
        await http.get(AppUrl.friends + 'user_id/' + widget.uid.toString());
    return json.decode(result.body);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    AuthProvider auth = Provider.of<AuthProvider>(context);
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    void follow(userId) async {
      auth.follow(userId.toString(), widget.uid.toString()).then((response) {
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

    void convertStringFromDate() {
      final todayDate = DateTime.now();
      print(formatDate(todayDate,
          [yyyy, '-', mm, '-', dd, ' ', hh, ':', nn, ':', ss, ' ', am]));
    }

    void convertDateFromString(String strDate) {
      DateTime todayDate = DateTime.parse(strDate);
      print(todayDate);
      print(formatDate(todayDate,
          [yyyy, '/', mm, '/', dd, ' ', hh, ':', nn, ':', ss, ' ', am]));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
        ),
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
          future: fetchNotifs(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Map notif = snapshot.data[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (notif['cb']['avatar'] != "" &&
                                notif['cb']['avatar'] != null)
                            ? NetworkImage(
                                AppUrl.baseURL + notif['cb']['avatar'])
                            : AssetImage(
                                "assets/images/cm${random.nextInt(10)}.jpeg",
                              ),
                        radius: 25,
                      ),
                      contentPadding: EdgeInsets.all(0),
                      title: Text(notif['cb']['name'] + ' was following you'),
                      subtitle:
                          Text(DateTime.parse(notif['created_at']).toString()),
                      trailing: FlatButton(
                        child: Text(
                          (notif['followed_count'] > 0) ? "Followed" : "Follow",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        color: (notif['followed_count'] > 0)
                            ? Colors.grey
                            : Colors.green,
                        onPressed: () {
                          if (notif['followed_count'] > 0) {
                            return false;
                          } else {
                            follow(notif['created_by'].toString());
                          }
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Profile(uid: notif['created_by'])),
                        );
                      },
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
      //   itemCount: notifications.length,
      //   itemBuilder: (BuildContext context, int index) {
      //     Map notif = notifications[index];
      //     return Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: ListTile(
      //         leading: CircleAvatar(
      //           backgroundImage: AssetImage(
      //             notif['dp'],
      //           ),
      //           radius: 25,
      //         ),
      //         contentPadding: EdgeInsets.all(0),
      //         title: Text(notif['notif']),
      //         trailing: Text(
      //           notif['time'],
      //           style: TextStyle(
      //             fontWeight: FontWeight.w300,
      //             fontSize: 11,
      //           ),
      //         ),
      //         onTap: () {},
      //       ),
      //     );
      //   },
      // ),
    );
  }
}
