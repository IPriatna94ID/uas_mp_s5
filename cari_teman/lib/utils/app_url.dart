class AppUrl {
  static const String liveBaseURL = "https://apanya.com/api/v1";
  static const String localBaseURL =
      "http://192.168.1.3/latihan/mp/apis/public/";

  static const String baseURL = localBaseURL;
  static const String login = baseURL + "login";
  static const String register = baseURL + "register";
  static const String getProfile = baseURL + "profile/";
  static const String updateProfile = baseURL + "update_profile/";
  static const String post = baseURL + "post";
  static const String postList = baseURL + "post";
  static const String postDetail = baseURL + "post/";
  static const String myPost = baseURL + "my_post/";
  static const String friends = baseURL + "friends/";
  static const String comments = baseURL + "comments";
  static const String forgotPassword = baseURL + "forgot-password";
}
