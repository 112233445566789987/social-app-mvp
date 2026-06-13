import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/chat/presentation/screens/chat_detail_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/moments/presentation/screens/moments_screen.dart';
import '../../features/matching/presentation/screens/matching_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/friends/presentation/screens/friends_list_screen.dart';
import '../../features/friends/presentation/screens/friend_requests_screen.dart';
import '../../features/friends/presentation/screens/search_users_screen.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isLoggedIn = authState is AuthAuthenticated;
      final isOnAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isOnAuth) return '/login';
      if (isLoggedIn && isOnAuth) return '/';
      return null;
    },
    routes: [
      // 登录 / 注册
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // 主页面（底部导航）
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/',
            redirect: (_, __) => '/moments',
          ),
          GoRoute(
            path: '/moments',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MomentsScreen(),
            ),
          ),
          GoRoute(
            path: '/match',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MatchingScreen(),
            ),
          ),
          GoRoute(
            path: '/friends',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FriendsListScreen(),
            ),
          ),
          GoRoute(
            path: '/match',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MatchingScreen(),
            ),
          ),
          GoRoute(
            path: '/chats',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ChatListScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // 好友申请 & 搜索（独立页面，不带底部导航）
      GoRoute(
        path: '/friend-requests',
        builder: (context, state) => const FriendRequestsScreen(),
      ),
      GoRoute(
        path: '/search-users',
        builder: (context, state) => const SearchUsersScreen(),
      ),

      // 聊天详情（独立页面，不带底部导航）
      GoRoute(
        path: '/chat/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          final extra = state.extra as Map<String, dynamic>?;
          return ChatDetailScreen(
            chatId: chatId,
            otherUserName: extra?['otherUserName'] ?? '未知用户',
            avatarUrl: extra?['avatarUrl'],
          );
        },
      ),
    ],
  );
}
