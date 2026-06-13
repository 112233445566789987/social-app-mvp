import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/auth_repository.dart';
import '../bloc/friends_bloc.dart';
import '../../data/friends_repository.dart';
import '../../../../models/friend_request.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
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
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('好友'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_search),
              tooltip: '搜索添加好友',
              onPressed: () => context.go('/search-users'),
            ),
            IconButton(
              icon: const Icon(Icons.card_giftcard),
              tooltip: '邀请好友',
              onPressed: () {
                Share.share('我在用这款社交App，来加我好友吧！我的ID：me\n下载链接：https://github.com/112233445566789987/social-app-mvp');
              },
            ),
          ],
        ),
        body: BlocBuilder<FriendsBloc, FriendsState>(
          builder: (context, state) {
            if (state is FriendsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FriendsError) {
              return Center(child: Text('错误: ${state.message}'));
            }
            if (state is FriendsLoaded) {
              final pendingCount = state.requests
                  .where((r) => r.status == FriendRequestStatus.pending && r.toUserId == 'me')
                  .length;
              return RefreshIndicator(
                onRefresh: () async {
                  _bloc.add(LoadFriends());
                },
                child: CustomScrollView(
                  slivers: [
                    if (pendingCount > 0)
                      SliverToBoxAdapter(
                        child: _RequestBanner(count: pendingCount, onTap: () => context.go('/friend-requests')),
                      ),
                    if (state.friends.isEmpty)
                      const SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 64, color: AppTheme.textHint),
                              SizedBox(height: 16),
                              Text('还没有好友', style: TextStyle(color: AppTheme.textHint, fontSize: 16)),
                              SizedBox(height: 8),
                              Text('点击右上角搜索添加好友', style: TextStyle(color: AppTheme.textHint, fontSize: 14)),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _FriendItem(user: state.friends[index]),
                          childCount: state.friends.length,
                        ),
                      ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _RequestBanner extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _RequestBanner({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.08),
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            const Text('新的好友申请', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppTheme.textHint),
          ],
        ),
      ),
    );
  }
}

class _FriendItem extends StatelessWidget {
  final UserModel user;

  const _FriendItem({required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
        child: user.avatarUrl == null ? Text(user.name[0]) : null,
      ),
      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(user.bio, style: const TextStyle(color: AppTheme.textHint, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chat_bubble_outline, color: AppTheme.textHint),
    );
  }
}