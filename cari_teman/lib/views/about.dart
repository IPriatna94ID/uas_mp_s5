import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cari_teman/utils/animations.dart';
import 'package:cari_teman/utils/const.dart';
import 'package:cari_teman/utils/enum.dart';
import 'package:cari_teman/utils/router.dart';
import 'package:cari_teman/views/main_screen.dart';
import 'package:cari_teman/utils/extensions.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  FormMode formMode = FormMode.LOGIN;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("About App"),
      ),
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
                    child: buildFormContainer(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  buildFormContainer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          '${Constants.appName}',
          style: TextStyle(
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
          ),
        ).fadeInList(0, false),
        Text(
          '${Constants.tagLine}',
          style: TextStyle(
            fontSize: 18.0,
          ),
        ).fadeInList(0, false),
        SizedBox(height: 20.0),
        Visibility(
            visible: formMode == FormMode.LOGIN,
            child: Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text('Copyright @ Kelompok 2',
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.w500)),
                  SizedBox(height: 10.0),
                  Text('Aldi Risman N - 18111246'),
                  SizedBox(height: 5.0),
                  Text('Joenistian Eka P - 18111204'),
                  SizedBox(height: 5.0),
                  Text('Moh Krisna M - 18111214'),
                  SizedBox(height: 5.0),
                  Text('Iip Priatna - 18111200'),
                ],
              ),
            )
            // child: Column(
            //   children: [
            //     SizedBox(height: 10.0),
            //     Align(
            //       alignment: Alignment.center,
            //       child: FlatButton(
            //         onPressed: () {
            //           formMode = FormMode.FORGOT_PASSWORD;
            //           setState(() {});
            //         },
            //         child: Text('Copyright @ Kelompok 2'),
            //       ),
            //     ),
            //   ],
            // ),
            ).fadeInList(3, false),
      ],
    );
  }
}
