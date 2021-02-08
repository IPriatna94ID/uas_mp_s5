import 'package:cari_teman/models/post.dart';

class PostProvider {
  Post _post = new Post();

  Post get post => _post;

  void setPost(Post post) {
    _post = post;
  }
}
