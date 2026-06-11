class ChatSession {
  final String id;
  final String otherUserName;
  final String? avatarUrl;
  final String lastMessage;
  final DateTime lastTime;
  final int unreadCount;
  final bool isOnline;

  ChatSession({
    required this.id,
    required this.otherUserName,
    this.avatarUrl,
    required this.lastMessage,
    required this.lastTime,
    this.unreadCount = 0,
    this.isOnline = false,
  });
}

class Message {
  final String id;
  final String content;
  final bool isMe;
  final DateTime time;
  final MessageStatus status;

  Message({
    required this.id,
    required this.content,
    required this.isMe,
    required this.time,
    this.status = MessageStatus.sent,
  });
}

enum MessageStatus { sending, sent, delivered, read, failed }

class ChatRepository {
  Future<List<ChatSession>> getSessions() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockSessions;
  }

  Future<List<Message>> getMessages(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockMessages;
  }

  Future<void> sendMessage(String chatId, String content) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  static final List<ChatSession> _mockSessions = [
    ChatSession(
      id: 'c1', otherUserName: '小明',
      avatarUrl: 'https://i.pravatar.cc/150?u=xiaoming',
      lastMessage: '那明天见！', lastTime: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 2, isOnline: true,
    ),
    ChatSession(
      id: 'c2', otherUserName: '小红',
      avatarUrl: 'https://i.pravatar.cc/150?u=xiaohong',
      lastMessage: 'Flutter 加油 💪', lastTime: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 0, isOnline: false,
    ),
    ChatSession(
      id: 'c3', otherUserName: '阿杰',
      avatarUrl: 'https://i.pravatar.cc/150?u=ajie',
      lastMessage: '有空一起打游戏', lastTime: DateTime.now().subtract(const Duration(hours: 3)),
      unreadCount: 0, isOnline: true,
    ),
    ChatSession(
      id: 'c4', otherUserName: '静静',
      avatarUrl: 'https://i.pravatar.cc/150?u=jingjing',
      lastMessage: '谢谢你的鼓励！', lastTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 1, isOnline: false,
    ),
    ChatSession(
      id: 'c5', otherUserName: 'Leo',
      avatarUrl: 'https://i.pravatar.cc/150?u=leo',
      lastMessage: '下次一起吃饭', lastTime: DateTime.now().subtract(const Duration(days: 2)),
      unreadCount: 0, isOnline: false,
    ),
  ];

  static final List<Message> _mockMessages = [
    Message(id: 'm1', content: '你好呀！', isMe: false, time: DateTime.now().subtract(const Duration(hours: 2)), status: MessageStatus.read),
    Message(id: 'm2', content: '嗨，最近怎么样？', isMe: true, time: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)), status: MessageStatus.read),
    Message(id: 'm3', content: '挺好的，刚跑完步 🏃', isMe: false, time: DateTime.now().subtract(const Duration(hours: 1, minutes: 40)), status: MessageStatus.read),
    Message(id: 'm4', content: '太厉害了，每天都跑吗？', isMe: true, time: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)), status: MessageStatus.delivered),
    Message(id: 'm5', content: '每周三四次吧，保持健康 💪', isMe: false, time: DateTime.now().subtract(const Duration(hours: 1)), status: MessageStatus.read),
    Message(id: 'm6', content: '那明天见！', isMe: false, time: DateTime.now().subtract(const Duration(minutes: 5)), status: MessageStatus.read),
  ];
}
