import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/matching_repository.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  final MatchingRepository _repo = MatchingRepository();
  List<MatchingUser> _users = [];
  int _currentIndex = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final users = await _repo.getMatchSuggestions();
    setState(() {
      _users = users;
      _loading = false;
    });
  }

  void _onAction(bool liked) {
    if (_users.isEmpty) return;
    final user = _users[_currentIndex];
    if (liked) {
      _repo.likeUser('me', user.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已喜欢 ${user.name} 💖'),
          backgroundColor: AppTheme.accentColor,
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      _repo.passUser('me', user.id);
    }
    setState(() {
      if (_currentIndex < _users.length - 1) {
        _currentIndex++;
      } else {
        // 重新加载或显示空了
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('暂时没有更多推荐了，去看看别人吧~')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('匹配'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty || _currentIndex >= _users.length
              ? _buildEmpty()
              : _buildCardStack(),
    );
  }

  Widget _buildCardStack() {
    final user = _users[_currentIndex];
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: _UserCard(user: user),
          ),
        ),
        // 底部操作按钮
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 跳过
              _ActionButton(
                icon: Icons.close,
                color: AppTheme.textHint,
                bgColor: Colors.white,
                size: 56,
                onTap: () => _onAction(false),
              ),
              // 超级喜欢
              _ActionButton(
                icon: Icons.star,
                color: Colors.blue,
                bgColor: Colors.blue.shade50,
                size: 48,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('超级喜欢 ${user.name} ⭐'),
                      backgroundColor: Colors.blue,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                  if (_currentIndex < _users.length - 1) {
                    setState(() => _currentIndex++);
                  }
                },
              ),
              // 喜欢
              _ActionButton(
                icon: Icons.favorite,
                color: AppTheme.accentColor,
                bgColor: AppTheme.accentColor.withOpacity(0.1),
                size: 56,
                onTap: () => _onAction(true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.explore_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            '暂时没有更多推荐了',
            style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _load,
            child: const Text('刷新试试'),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final MatchingUser user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 头像
          Image.network(
            user.avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppTheme.primaryColor.withOpacity(0.1),
              child: Icon(Icons.person, size: 80, color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
          ),
          // 渐变遮罩
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          // 用户信息
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${user.age}岁',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.gender == '女' ? '♀' : '♂',
                      style: TextStyle(
                        color: user.gender == '女' ? Colors.pink : Colors.blue,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white54, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${user.distance}km',
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  user.bio,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: user.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final double size;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size * 0.45),
      ),
    );
  }
}
