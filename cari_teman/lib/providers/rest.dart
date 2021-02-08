import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:cari_teman/utils/app_url.dart';

class RestProvider {
  Future<Map<String, dynamic>> submitPost(String userId, String fileName,
      String base64Image, String postText) async {
    print(postText);
    final Map<String, dynamic> postData = {
      'id_user': userId,
      'file': base64Image,
      'file_name': fileName,
      'text': postText
    };

    return await post(AppUrl.post,
            body: json.encode(postData),
            headers: {'Content-Type': 'application/json'})
        .then(onValue)
        .catchError(onError);
  }

  static Future<FutureOr> onValue(Response response) async {
    var result;
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      var userData = responseData['data'];

      result = {
        'status': true,
        'message': 'Successfully registered',
        'data': userData
      };
    } else {
      //  if (response.statusCode == 401) Get.toNamed("/login");
      result = {
        'status': false,
        'message': 'Registration failed',
        'data': responseData
      };
    }

    return result;
  }

  static onError(error) {
    print("the error is $error");
    return {'status': false, 'message': 'Unsuccessful Request', 'data': error};
  }
}
