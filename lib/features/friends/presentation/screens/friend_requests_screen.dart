import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/friends_bloc.dart';
import '../../data/friends_repository.dart';
import '../../../../models/friend_request.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  late FriendsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = FriendsBloc(repo: FriendsRepository());
    _bloc.add(LoadFriends());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('好友申请')),
      body: BlocBuilder<FriendsBloc, FriendsState>(
        builder: (context, state) {
          if (state is FriendsLoading) return const Center(child: CircularProgressIndicator());
          if (state is FriendsError) return Center(child: Text('错误: ${state.message}'));
          if (state is FriendsLoaded) {
            final pending = state.requests
                .where((r) => r.status == FriendRequestStatus.pending && r.toUserId == 'me')
                .toList();
            final sent = state.requests
                .where((r) => r.fromUserId == 'me')
                .toList();

            if (pending.isEmpty && sent.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: AppTheme.textHint),
                    SizedBox(height: 16),
                    Text('暂无好友申请', style: TextStyle(color: AppTheme.textHint, fontSize: 16)),
                  ],
                ),
              );
            }

            return ListView(
              children: [
                if (pending.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text('收到的好友申请', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                  ),
                  ...pending.map((r) => _PendingRequestItem(
                    request: r,
                    repo: FriendsRepository(),
                    bloc: _bloc,
                  )),
                ],
                if (sent.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text('我发出的申请', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                  ),
                  ...sent.map((r) => _SentRequestItem(request: r)),
                ],
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _PendingRequestItem extends StatelessWidget {
  final FriendRequest request;
  final FriendsRepository repo;
  final FriendsBloc bloc;

  const _PendingRequestItem({required this.request, required this.repo, required this.bloc});

  @override
  Widget build(BuildContext context) {
    final user = repo.getMockUserById(request.fromUserId);
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
        child: user?.avatarUrl == null ? Text(user?.name[0] ?? '?') : null,
      ),
      title: Text(user?.name ?? request.fromUserId, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(user?.bio ?? '', style: const TextStyle(color: AppTheme.textHint, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => bloc.add(AcceptFriendRequest(request.id)),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
            child: const Text('接受'),
          ),
          TextButton(
            onPressed: () => bloc.add(RejectFriendRequest(request.id)),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('拒绝'),
          ),
        ],
      ),
    );
  }
}

class _SentRequestItem extends StatelessWidget {
  final FriendRequest request;

  const _SentRequestItem({required this.request});

  @override
  Widget build(BuildContext context) {
    final repo = FriendsRepository();
    final user = repo.getMockUserById(request.toUserId);
    final statusText = switch (request.status) {
      FriendRequestStatus.pending => '等待回复',
      FriendRequestStatus.accepted => '已接受',
      FriendRequestStatus.rejected => '已拒绝',
    };
    final statusColor = switch (request.status) {
      FriendRequestStatus.pending => AppTheme.textHint,
      FriendRequestStatus.accepted => Colors.green,
      FriendRequestStatus.rejected => AppTheme.errorColor,
    };
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
        child: user?.avatarUrl == null ? Text(user?.name[0] ?? '?') : null,
      ),
      title: Text(user?.name ?? request.toUserId, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Text(statusText, style: TextStyle(color: statusColor, fontSize: 13)),
    );
  }
}