class MomentModel {
  final String id;
  final String userId;
  final String userName;
  final String? avatarUrl;
  final String content;
  final String? imageUrl;
  final List<String> likes; // 用户 ID 列表
  final List<CommentModel> comments;
  final DateTime createdAt;

  MomentModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.content,
    this.imageUrl,
    required this.likes,
    required this.comments,
    required this.createdAt,
  });

  int get likeCount => likes.length;
  int get commentCount => comments.length;
}

class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });
}
