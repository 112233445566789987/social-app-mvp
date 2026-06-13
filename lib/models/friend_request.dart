import 'package:equatable/equatable.dart';

class FriendRequest extends Equatable {
  final String id;
  final String fromUserId;
  final String toUserId;
  final FriendRequestStatus status;
  final DateTime createdAt;

  const FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    required this.createdAt,
  });

  FriendRequest copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    FriendRequestStatus? status,
    DateTime? createdAt,
  }) {
    return FriendRequest(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      status: FriendRequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FriendRequestStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, fromUserId, toUserId, status, createdAt];
}

enum FriendRequestStatus { pending, accepted, rejected }
