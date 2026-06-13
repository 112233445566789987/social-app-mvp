
class MatchingUser {
  final String id;
  final String name;
  final String avatarUrl;
  final int age;
  final String gender;
  final String bio;
  final List<String> tags;
  final double distance;

  MatchingUser({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.age,
    required this.gender,
    required this.bio,
    required this.tags,
    required this.distance,
  });
}

class MatchingRepository {
  Future<List<MatchingUser>> getMatchSuggestions() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockUsers;
  }

  Future<void> likeUser(String currentUserId, String targetUserId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> passUser(String currentUserId, String targetUserId) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  static final List<MatchingUser> _mockUsers = [
    MatchingUser(
      id: 'match1',
      name: '小鱼',
      avatarUrl: 'https://i.pravatar.cc/300?u=match1',
      age: 24,
      gender: '女',
      bio: '喜欢旅行和摄影，想找一个人一起看世界 🌍',
      tags: ['旅行', '摄影', '健身'],
      distance: 3.2,
    ),
    MatchingUser(
      id: 'match2',
      name: '阿轩',
      avatarUrl: 'https://i.pravatar.cc/300?u=match2',
      age: 27,
      gender: '男',
      bio: '程序员一枚，空闲时间喜欢打篮球和弹吉他 🎸',
      tags: ['程序员', '篮球', '音乐'],
      distance: 5.8,
    ),
    MatchingUser(
      id: 'match3',
      name: '晴晴',
      avatarUrl: 'https://i.pravatar.cc/300?u=match3',
      age: 23,
      gender: '女',
      bio: '咖啡爱好者，正在学习烘焙 ☕',
      tags: ['咖啡', '烘焙', '阅读'],
      distance: 1.5,
    ),
    MatchingUser(
      id: 'match4',
      name: 'Leo',
      avatarUrl: 'https://i.pravatar.cc/300?u=match4',
      age: 29,
      gender: '男',
      bio: '创业中，喜欢探索新事物和美食 🍜',
      tags: ['创业', '美食', '户外'],
      distance: 8.3,
    ),
    MatchingUser(
      id: 'match5',
      name: '苏苏',
      avatarUrl: 'https://i.pravatar.cc/300?u=match5',
      age: 25,
      gender: '女',
      bio: '瑜伽教练，热爱生活的天秤座 🌿',
      tags: ['瑜伽', '冥想', '素食'],
      distance: 2.1,
    ),
  ];
}
