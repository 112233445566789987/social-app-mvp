import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/theme/app_theme.dart';
import '../../data/chat_repository.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatRepository _repo = ChatRepository();
  List<ChatSession> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sessions = await _repo.getSessions();
    setState(() {
      _sessions = sessions;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _sessions.isEmpty
                  ? const Center(child: Text('暂无聊天记录'))
                  : ListView.separated(
                      itemCount: _sessions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
                      itemBuilder: (context, index) {
                        final s = _sessions[index];
                        return _ChatSessionTile(
                          session: s,
                          onTap: () => context.push('/chat/${s.id}', extra: {
                            'otherUserName': s.otherUserName,
                            'avatarUrl': s.avatarUrl,
                          }),
                        );
                      },
                    ),
            ),
    );
  }
}

class _ChatSessionTile extends StatelessWidget {
  final ChatSession session;
  final VoidCallback onTap;

  const _ChatSessionTile({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: session.avatarUrl != null
                ? NetworkImage(session.avatarUrl!)
                : null,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: session.avatarUrl == null
                ? Text(session.otherUserName[0])
                : null,
          ),
          if (session.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              session.otherUserName,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            timeago.format(session.lastTime, locale: 'zh_CN'),
            style: const TextStyle(fontSize: 12, color: AppTheme.textHint),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              session.lastMessage,
              style: TextStyle(
                color: session.unreadCount > 0
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary,
                fontWeight: session.unreadCount > 0
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (session.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${session.unreadCount}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
