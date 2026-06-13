import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../models/friend_request.dart';
import '../../auth/data/auth_repository.dart';

class FriendsRepository {
  static const _keyFriends = 'friends_list';
  static const _keyRequests = 'friend_requests';

  // Mock 示例用户（模拟真实用户数据库）
  static const List<Map<String, dynamic>> _mockUsers = [
    {'id': 'user_lisa', 'name': 'Lisa', 'email': 'lisa@example.com', 'avatarUrl': 'https://i.pravatar.cc/150?u=lisa', 'bio': '热爱旅行和摄影 📷'},
    {'id': 'user_wang', 'name': '王大明', 'email': 'wang@example.com', 'avatarUrl': 'https://i.pravatar.cc/150?u=wang', 'bio': '美食爱好者，周末常去探店'},
    {'id': 'user_mike', 'name': 'Mike', 'email': 'mike@example.com', 'avatarUrl': 'https://i.pravatar.cc/150?u=mike', 'bio': '健身达人 💪 每天打卡'},
    {'id': 'user_chen', 'name': '陈小美', 'email': 'chen@example.com', 'avatarUrl': 'https://i.pravatar.cc/150?u=chen', 'bio': '音乐是灵魂的语言 🎵'},
    {'id': 'user_alex', 'name': 'Alex', 'email': 'alex@example.com', 'avatarUrl': 'https://i.pravatar.cc/150?u=alex', 'bio': '程序员 / 咖啡控 ☕'},
  ];

  Future<List<UserModel>> getFriends() async {
    final prefs = await SharedPreferences.getInstance();
    final friendIds = prefs.getStringList(_keyFriends) ?? ['user_lisa', 'user_wang'];
    if (!prefs.containsKey(_keyFriends)) {
      await prefs.setStringList(_keyFriends, friendIds);
    }
    return _mockUsers
        .where((u) => friendIds.contains(u['id']))
        .map((u) => UserModel.fromJson(u))
        .toList();
  }

  Future<List<FriendRequest>> getFriendRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_keyRequests);
    if (stored != null) {
      final list = jsonDecode(stored) as List;
      return list.map((e) => FriendRequest.fromJson(e as Map<String, dynamic>)).toList();
    }
    // 默认 mock: 1 条待处理请求
    final defaultRequests = [
      FriendRequest(
        id: 'req_1',
        fromUserId: 'user_mike',
        toUserId: 'me',
        status: FriendRequestStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
    await prefs.setString(_keyRequests, jsonEncode(defaultRequests.map((e) => e.toJson()).toList()));
    return defaultRequests;
  }

  Future<void> sendFriendRequest(String toUserId) async {
    final prefs = await SharedPreferences.getInstance();
    final requests = await getFriendRequests();
    final newRequest = FriendRequest(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      fromUserId: 'me',
      toUserId: toUserId,
      status: FriendRequestStatus.pending,
      createdAt: DateTime.now(),
    );
    requests.add(newRequest);
    await prefs.setString(_keyRequests, jsonEncode(requests.map((e) => e.toJson()).toList()));
  }

  Future<void> acceptFriendRequest(String requestId) async {
    final prefs = await SharedPreferences.getInstance();
    final requests = await getFriendRequests();
    final index = requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      requests[index] = requests[index].copyWith(status: FriendRequestStatus.accepted);
      await prefs.setString(_keyRequests, jsonEncode(requests.map((e) => e.toJson()).toList()));

      // 添加到好友列表
      final friendIds = prefs.getStringList(_keyFriends) ?? [];
      final fromId = requests[index].fromUserId;
      if (!friendIds.contains(fromId)) {
        friendIds.add(fromId);
        await prefs.setStringList(_keyFriends, friendIds);
      }
    }
  }

  Future<void> rejectFriendRequest(String requestId) async {
    final prefs = await SharedPreferences.getInstance();
    final requests = await getFriendRequests();
    final index = requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      requests[index] = requests[index].copyWith(status: FriendRequestStatus.rejected);
      await prefs.setString(_keyRequests, jsonEncode(requests.map((e) => e.toJson()).toList()));
    }
  }

  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return _mockUsers
        .where((u) =>
            (u['name'] as String).toLowerCase().contains(q) ||
            (u['email'] as String).toLowerCase().contains(q) ||
            (u['id'] as String).toLowerCase().contains(q))
        .map((u) => UserModel.fromJson(u))
        .toList();
  }

  Future<bool> isFriend(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final friendIds = prefs.getStringList(_keyFriends) ?? ['user_lisa', 'user_wang'];
    return friendIds.contains(userId);
  }

  Future<bool> hasPendingRequest(String userId) async {
    final requests = await getFriendRequests();
    return requests.any((r) =>
        (r.fromUserId == 'me' && r.toUserId == userId && r.status == FriendRequestStatus.pending) ||
        (r.fromUserId == userId && r.toUserId == 'me' && r.status == FriendRequestStatus.pending));
  }

  UserModel? getMockUserById(String userId) {
    final match = _mockUsers.where((u) => u['id'] == userId);
    if (match.isEmpty) return null;
    return UserModel.fromJson(match.first);
  }
}