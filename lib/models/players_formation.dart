// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'models.dart';

class PlayersFormation {
  String id;
  User user1;
  User user2;
  PlayersFormation({
    required this.id,
    required this.user1,
    required this.user2,
  });

  PlayersFormation copyWith({
    String? id,
    User? user1,
    User? user2,
  }) {
    return PlayersFormation(
      id: id ?? this.id,
      user1: user1 ?? this.user1,
      user2: user2 ?? this.user2,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user1': user1.toMap(),
      'user2': user2.toMap(),
    };
  }

  factory PlayersFormation.fromMap(Map<String, dynamic> map) {
    return PlayersFormation(
      id: (map["id"] ?? '') as String,
      user1: User.fromMap((map["user1"] ?? Map<String, dynamic>.from({}))
          as Map<String, dynamic>),
      user2: User.fromMap((map["user2"] ?? Map<String, dynamic>.from({}))
          as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory PlayersFormation.fromJson(String source) =>
      PlayersFormation.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'PlayersFormation(id: $id, user1: $user1, user2: $user2)';

  @override
  bool operator ==(covariant PlayersFormation other) {
    if (identical(this, other)) return true;

    return other.id == id && other.user1 == user1 && other.user2 == user2;
  }

  @override
  int get hashCode => id.hashCode ^ user1.hashCode ^ user2.hashCode;
}
