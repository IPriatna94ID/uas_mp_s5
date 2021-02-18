import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:cari_teman/models/user.dart';
import 'package:cari_teman/utils/app_url.dart';
import 'package:cari_teman/utils/shared_preference.dart';

enum Status {
  NotLoggedIn,
  NotRegistered,
  LoggedIn,
  Registered,
  Authenticating,
  Registering,
  LoggedOut
}

class AuthProvider with ChangeNotifier {
  Status _loggedInStatus = Status.NotLoggedIn;
  Status _registeredInStatus = Status.NotRegistered;

  Status get loggedInStatus => _loggedInStatus;
  Status get registeredInStatus => _registeredInStatus;

  Future<Map<String, dynamic>> login(String email, String password) async {
    var result;

    final Map<String, dynamic> loginData = {
      'email': email,
      'password': password
    };

    _loggedInStatus = Status.Authenticating;
    notifyListeners();

    Response response = await post(
      AppUrl.login,
      body: json.encode(loginData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      var userData = responseData['data'];

      User authUser = User.fromJson(userData);

      UserPreferences().saveUser(authUser);

      _loggedInStatus = Status.LoggedIn;
      notifyListeners();

      result = {'status': true, 'message': 'Successful', 'user': authUser};
    } else {
      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();
      result = {
        'status': false,
        'message': json.decode(response.body)['error']
      };
    }
    return result;
  }

  Future<Map<String, dynamic>> register(
      String name, email, String password, String passwordConfirmation) async {
    final Map<String, dynamic> registrationData = {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation
    };

    return await post(AppUrl.register,
            body: json.encode(registrationData),
            headers: {'Content-Type': 'application/json'})
        .then(onValue)
        .catchError(onError);
  }

  static Future<FutureOr> onValue(Response response) async {
    var result;
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      var userData = responseData['data'];

      User authUser = User.fromJson(userData);

      UserPreferences().saveUser(authUser);
      result = {
        'status': true,
        'message': 'Successfully registered',
        'data': authUser
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

  Future<Map<String, dynamic>> update(String uid, String name, String email,
      String password, String passwordConfirmation) async {
    final Map<String, dynamic> registrationData = {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation
    };

    return await post(AppUrl.updateProfile + uid,
            body: json.encode(registrationData),
            headers: {'Content-Type': 'application/json'})
        .then(onUpdate)
        .catchError(onError);
  }

  Future<Map<String, dynamic>> updateAvatar(
      String userId, String fileName, String base64Image) async {
    final Map<String, dynamic> postData = {
      'file_name': fileName,
      'file': base64Image,
    };

    return await post(AppUrl.updateProfile + userId,
            body: json.encode(postData),
            headers: {'Content-Type': 'application/json'})
        .then(onUpdate)
        .catchError(onError);
  }

  static Future<FutureOr> onUpdate(Response response) async {
    var result;
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      var userData = responseData['data'];

      User authUser = User.fromJson(userData);

      UserPreferences().saveUser(authUser);
      result = {
        'status': true,
        'message': 'Update profile berhasil',
        'data': authUser
      };
    } else {
      //  if (response.statusCode == 401) Get.toNamed("/login");
      result = {
        'status': false,
        'message': 'Update failed',
        'data': responseData
      };
    }

    return result;
  }

  Future<Map<String, dynamic>> submitPost(String userId, String fileName,
      String base64Image, String postText) async {
    final Map<String, dynamic> postData = {
      'user_id': userId,
      'file': base64Image,
      'file_name': fileName,
      'text': postText
    };
    print(postData);
    print(AppUrl.post);
    return await post(AppUrl.post,
            body: json.encode(postData),
            headers: {'Content-Type': 'application/json'})
        .then(onSaved)
        .catchError(onError);
  }

  Future<Map<String, dynamic>> follow(String fid, String uid) async {
    final Map<String, dynamic> params = {'user_id': fid};
    return await post(AppUrl.friends + uid,
            body: json.encode(params),
            headers: {'Content-Type': 'application/json'})
        .then(onSaved)
        .catchError(onError);
  }

  Future<Map<String, dynamic>> postComment(
      String postId, String userId, String postText) async {
    final Map<String, dynamic> postData = {
      'post_id': postId,
      'user_id': userId,
      'text': postText
    };
    print(postData);
    return await post(AppUrl.comments,
            body: json.encode(postData),
            headers: {'Content-Type': 'application/json'})
        .then(onSaved)
        .catchError(onError);
  }

  Future<Map<String, dynamic>> unfollow(String fid, String uid) async {
    return await delete(AppUrl.friends + fid + '/' + uid,
            headers: {'Content-Type': 'application/json'})
        .then(onSaved)
        .catchError(onError);
  }

  static Future<FutureOr> onSaved(Response response) async {
    var result;
    final Map<String, dynamic> responseData = json.decode(response.body);
    print(responseData);
    if (response.statusCode == 200) {
      result = {'status': true, 'message': 'Data saved'};
    } else {
      //  if (response.statusCode == 401) Get.toNamed("/login");
      result = {
        'status': false,
        'message': 'Invalid request',
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
