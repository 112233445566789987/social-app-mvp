import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/friends_repository.dart';
import '../../../../models/friend_request.dart';
import '../../../auth/data/auth_repository.dart';

// ============ Events ============

abstract class FriendsEvent extends Equatable {
  const FriendsEvent();
  @override
  List<Object?> get props => [];
}

class LoadFriends extends FriendsEvent {}
class LoadFriendRequests extends FriendsEvent {}

class SendFriendRequest extends FriendsEvent {
  final String toUserId;
  const SendFriendRequest(this.toUserId);
  @override
  List<Object?> get props => [toUserId];
}

class AcceptFriendRequest extends FriendsEvent {
  final String requestId;
  const AcceptFriendRequest(this.requestId);
  @override
  List<Object?> get props => [requestId];
}

class RejectFriendRequest extends FriendsEvent {
  final String requestId;
  const RejectFriendRequest(this.requestId);
  @override
  List<Object?> get props => [requestId];
}

class SearchUsers extends FriendsEvent {
  final String query;
  const SearchUsers(this.query);
  @override
  List<Object?> get props => [query];
}

// ============ State ============

abstract class FriendsState extends Equatable {
  const FriendsState();
  @override
  List<Object?> get props => [];
}

class FriendsInitial extends FriendsState {}
class FriendsLoading extends FriendsState {}

class FriendsLoaded extends FriendsState {
  final List<UserModel> friends;
  final List<FriendRequest> requests;
  final List<UserModel> searchResults;
  final String? searchQuery;
  final Map<String, bool> friendStatus;
  final Map<String, bool> requestStatus;

  const FriendsLoaded({
    this.friends = const [],
    this.requests = const [],
    this.searchResults = const [],
    this.searchQuery,
    this.friendStatus = const {},
    this.requestStatus = const {},
  });

  FriendsLoaded copyWith({
    List<UserModel>? friends,
    List<FriendRequest>? requests,
    List<UserModel>? searchResults,
    String? searchQuery,
    Map<String, bool>? friendStatus,
    Map<String, bool>? requestStatus,
  }) {
    return FriendsLoaded(
      friends: friends ?? this.friends,
      requests: requests ?? this.requests,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      friendStatus: friendStatus ?? this.friendStatus,
      requestStatus: requestStatus ?? this.requestStatus,
    );
  }

  @override
  List<Object?> get props => [friends, requests, searchResults, searchQuery, friendStatus, requestStatus];
}

class FriendsError extends FriendsState {
  final String message;
  const FriendsError(this.message);
  @override
  List<Object?> get props => [message];
}

// ============ Bloc ============

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final FriendsRepository _repo;

  FriendsBloc({required FriendsRepository repo}) : _repo = repo, super(FriendsInitial()) {
    on<LoadFriends>(_onLoadFriends);
    on<LoadFriendRequests>(_onLoadFriendRequests);
    on<SendFriendRequest>(_onSendFriendRequest);
    on<AcceptFriendRequest>(_onAcceptFriendRequest);
    on<RejectFriendRequest>(_onRejectFriendRequest);
    on<SearchUsers>(_onSearchUsers);
  }

  Future<void> _onLoadFriends(LoadFriends event, Emitter<FriendsState> emit) async {
    emit(FriendsLoading());
    try {
      final friends = await _repo.getFriends();
      final requests = await _repo.getFriendRequests();
      final friendStatus = <String, bool>{};
      final requestStatus = <String, bool>{};
      for (final f in friends) {
        friendStatus[f.id] = true;
      }
      for (final r in requests.where((r) => r.status == FriendRequestStatus.pending)) {
        requestStatus[r.fromUserId] = true;
      }
      emit(FriendsLoaded(
        friends: friends,
        requests: requests,
        friendStatus: friendStatus,
        requestStatus: requestStatus,
      ));
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  Future<void> _onLoadFriendRequests(LoadFriendRequests event, Emitter<FriendsState> emit) async {
    try {
      final requests = await _repo.getFriendRequests();
      if (state is FriendsLoaded) {
        emit((state as FriendsLoaded).copyWith(requests: requests));
      } else {
        emit(FriendsLoaded(requests: requests));
      }
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  Future<void> _onSendFriendRequest(SendFriendRequest event, Emitter<FriendsState> emit) async {
    try {
      await _repo.sendFriendRequest(event.toUserId);
      final s = state as FriendsLoaded;
      final rs = Map<String, bool>.from(s.requestStatus);
      rs[event.toUserId] = true;
      emit(s.copyWith(requestStatus: rs));
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  Future<void> _onAcceptFriendRequest(AcceptFriendRequest event, Emitter<FriendsState> emit) async {
    try {
      await _repo.acceptFriendRequest(event.requestId);
      final friends = await _repo.getFriends();
      final requests = await _repo.getFriendRequests();
      final fs = <String, bool>{};
      for (final f in friends) {
        fs[f.id] = true;
      }
      emit((state as FriendsLoaded).copyWith(friends: friends, requests: requests, friendStatus: fs));
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  Future<void> _onRejectFriendRequest(RejectFriendRequest event, Emitter<FriendsState> emit) async {
    try {
      await _repo.rejectFriendRequest(event.requestId);
      final requests = await _repo.getFriendRequests();
      emit((state as FriendsLoaded).copyWith(requests: requests));
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  Future<void> _onSearchUsers(SearchUsers event, Emitter<FriendsState> emit) async {
    try {
      final results = await _repo.searchUsers(event.query);
      final fs = <String, bool>{};
      final rs = <String, bool>{};
      for (final u in results) {
        fs[u.id] = await _repo.isFriend(u.id);
        rs[u.id] = await _repo.hasPendingRequest(u.id);
      }
      if (state is FriendsLoaded) {
        final s = state as FriendsLoaded;
        emit(s.copyWith(
          searchResults: results,
          searchQuery: event.query,
          friendStatus: {...s.friendStatus, ...fs},
          requestStatus: {...s.requestStatus, ...rs},
        ));
      } else {
        emit(FriendsLoaded(searchResults: results, searchQuery: event.query, friendStatus: fs, requestStatus: rs));
      }
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }
}