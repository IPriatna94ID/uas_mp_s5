import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final int userID;
  final String fileUrl;

  const Post({this.userID, this.fileUrl});

  @override
  List<Object> get props => [
        userID,
        fileUrl,
      ];

  static Post fromJson(dynamic json) {
    final authData = json['data'];
    return Post(
      userID: authData['user_id'] as int,
      fileUrl: authData['fileUrl'] as String,
    );
  }
}
