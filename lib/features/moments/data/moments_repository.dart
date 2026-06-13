import 'moment_model.dart';

class MomentsRepository {
  /// 获取朋友圈动态列表（模拟）
  Future<List<MomentModel>> getMoments() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockMoments;
  }

  /// 点赞
  Future<void> toggleLike(String momentId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// 发朋友圈
  Future<MomentModel> publishMoment({
    required String content,
    String? imageUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MomentModel(
      id: 'moment_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'me',
      userName: '我',
      avatarUrl: 'https://i.pravatar.cc/150?u=me',
      content: content,
      imageUrl: imageUrl,
      likes: [],
      comments: [],
      createdAt: DateTime.now(),
    );
  }

  static final List<MomentModel> _mockMoments = [
    MomentModel(
      id: 'm1',
      userId: 'u1',
      userName: '小明',
      avatarUrl: 'https://i.pravatar.cc/150?u=xiaoming',
      content: '今天天气真好，适合出去走走 🌞',
      imageUrl: 'https://picsum.photos/seed/m1/800/600',
      likes: ['u2', 'u3'],
      comments: [
        CommentModel(id: 'c1', userId: 'u2', userName: '小红', content: '好羡慕！', createdAt: DateTime.now().subtract(const Duration(hours: 1))),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    MomentModel(
      id: 'm2',
      userId: 'u2',
      userName: '小红',
      avatarUrl: 'https://i.pravatar.cc/150?u=xiaohong',
      content: '刚学完 Flutter，感觉世界都在发光 ✨',
      likes: ['u1'],
      comments: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    MomentModel(
      id: 'm3',
      userId: 'u3',
      userName: '阿杰',
      avatarUrl: 'https://i.pravatar.cc/150?u=ajie',
      content: '分享一首最近在听的歌 🎵',
      imageUrl: 'https://picsum.photos/seed/m3/800/400',
      likes: ['u1', 'u2', 'u4'],
      comments: [
        CommentModel(id: 'c2', userId: 'u4', userName: '静静', content: '好听！', createdAt: DateTime.now().subtract(const Duration(minutes: 30))),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    MomentModel(
      id: 'm4',
      userId: 'u4',
      userName: '静静',
      avatarUrl: 'https://i.pravatar.cc/150?u=jingjing',
      content: '今天完成了人生第一场 10 公里跑 🏃‍♀️，纪念一下！',
      imageUrl: 'https://picsum.photos/seed/m4/800/600',
      likes: ['u1', 'u2', 'u3'],
      comments: [
        CommentModel(id: 'c3', userId: 'u1', userName: '小明', content: '太棒了！', createdAt: DateTime.now().subtract(const Duration(minutes: 10))),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
}
