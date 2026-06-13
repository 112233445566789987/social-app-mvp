import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/auth_repository.dart';
import '../bloc/friends_bloc.dart';
import '../../data/friends_repository.dart';

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key});

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  late FriendsBloc _bloc;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = FriendsBloc(repo: FriendsRepository());
    _bloc.add(LoadFriends());
  }

  @override
  void dispose() {
    _bloc.close();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;
    _bloc.add(SearchUsers(query.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('搜索添加好友')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '输入用户名、邮箱或ID搜索',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() {}); })
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (v) => setState(() {}),
              onSubmitted: _onSearch,
            ),
          ),
          Expanded(
            child: BlocBuilder<FriendsBloc, FriendsState>(
              builder: (context, state) {
                if (state is FriendsLoading) return const Center(child: CircularProgressIndicator());
                if (state is FriendsError) return Center(child: Text('错误: ${state.message}'));
                if (state is FriendsLoaded) {
                  if (state.searchQuery == null) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_search, size: 64, color: AppTheme.textHint),
                          SizedBox(height: 16),
                          Text('搜索你想添加的好友', style: TextStyle(color: AppTheme.textHint, fontSize: 16)),
                        ],
                      ),
                    );
                  }
                  if (state.searchResults.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: AppTheme.textHint),
                          SizedBox(height: 16),
                          Text('没有找到匹配的用户', style: TextStyle(color: AppTheme.textHint, fontSize: 16)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: state.searchResults.length,
                    itemBuilder: (context, index) {
                      final user = state.searchResults[index];
                      final isFriend = state.friendStatus[user.id] ?? false;
                      final hasRequest = state.requestStatus[user.id] ?? false;
                      return _SearchResultItem(
                        user: user,
                        isFriend: isFriend,
                        hasPendingRequest: hasRequest,
                        onAddFriend: () => _bloc.add(SendFriendRequest(user.id)),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final UserModel user;
  final bool isFriend;
  final bool hasPendingRequest;
  final VoidCallback onAddFriend;

  const _SearchResultItem({
    required this.user,
    required this.isFriend,
    required this.hasPendingRequest,
    required this.onAddFriend,
  });

  @override
  Widget build(BuildContext context) {
    final buttonLabel = isFriend ? '已好友' : hasPendingRequest ? '已申请' : '加好友';
    final buttonColor = isFriend ? Colors.green : hasPendingRequest ? AppTheme.textHint : AppTheme.primaryColor;
    final buttonEnabled = !isFriend && !hasPendingRequest;

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
        child: user.avatarUrl == null ? Text(user.name[0]) : null,
      ),
      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text('ID: ${user.id}', style: const TextStyle(color: AppTheme.textHint, fontSize: 13)),
      trailing: SizedBox(
        height: 36,
        child: ElevatedButton(
          onPressed: buttonEnabled ? onAddFriend : null,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: buttonColor,
            disabledBackgroundColor: buttonColor.withOpacity(0.5),
            disabledForegroundColor: Colors.white.withOpacity(0.7),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          child: Text(buttonLabel, style: const TextStyle(fontSize: 13)),
        ),
      ),
    );
  }
}