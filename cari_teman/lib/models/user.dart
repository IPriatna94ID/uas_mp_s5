class User {
  int userId;
  String name;
  String email;
  String avatar;

  User({this.userId, this.name, this.email, this.avatar});

  factory User.fromJson(Map<String, dynamic> responseData) {
    return User(
        userId: responseData['id'],
        name: responseData['name'],
        email: responseData['email'],
        avatar: responseData['avatar']);
  }
}
