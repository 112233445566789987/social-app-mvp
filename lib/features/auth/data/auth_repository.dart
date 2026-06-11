import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  static const _keyUser = 'current_user';

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyUser);
    if (json == null) return null;
    return UserModel.fromJson(jsonDecode(json));
  }

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
  }

  /// 登录（模拟接口，正式项目替换为真实 API）
  Future<UserModel> signIn(String email, String password) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));

    // TODO: 替换为真实 API 调用
    // final resp = await http.post(Uri.parse('$baseUrl/auth/login'), body: {...});

    if (email.isEmpty || password.isEmpty) {
      throw AuthException('邮箱和密码不能为空');
    }
    if (!email.contains('@')) {
      throw AuthException('请输入有效的邮箱地址');
    }
    if (password.length < 6) {
      throw AuthException('密码至少 6 位');
    }

    // 模拟登录成功
    final user = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: email.split('@').first,
      email: email,
      avatarUrl: 'https://i.pravatar.cc/150?u=$email',
      bio: '这个人很懒，什么也没写',
      createdAt: DateTime.now(),
    );
    await saveUser(user);
    return user;
  }

  /// 注册
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      throw AuthException('请填写所有必填项');
    }
    if (!email.contains('@')) {
      throw AuthException('请输入有效的邮箱地址');
    }
    if (password.length < 6) {
      throw AuthException('密码至少 6 位');
    }

    final user = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      avatarUrl: 'https://i.pravatar.cc/150?u=$email',
      bio: '这个人很懒，什么也没写',
      createdAt: DateTime.now(),
    );
    await saveUser(user);
    return user;
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String bio;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.bio,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
