// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:batball/models/gamedetails.dart';

class Game {
  String game_id = "";
  String creator_id = "";
  String winner_id = "";
  String time_started = "";
  String time_ended = "";
  Game({
    required this.game_id,
    required this.creator_id,
    required this.winner_id,
    required this.time_started,
    required this.time_ended,
  });

  Game copyWith({
    String? game_id,
    String? creator_id,
    String? winner_id,
    String? time_started,
    String? time_ended,
  }) {
    return Game(
      game_id: game_id ?? this.game_id,
      creator_id: creator_id ?? this.creator_id,
      winner_id: winner_id ?? this.winner_id,
      time_started: time_started ?? this.time_started,
      time_ended: time_ended ?? this.time_ended,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'game_id': game_id,
      'creator_id': creator_id,
      'winner_id': winner_id,
      'time_started': time_started,
      'time_ended': time_ended,
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      game_id: (map["game_id"] ?? '') as String,
      creator_id: (map["creator_id"] ?? '') as String,
      winner_id: (map["winner_id"] ?? '') as String,
      time_started: (map["time_started"] ?? '') as String,
      time_ended: (map["time_ended"] ?? '') as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Game.fromJson(String source) =>
      Game.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Game(game_id: $game_id, creator_id: $creator_id, winner_id: $winner_id, time_started: $time_started, time_ended: $time_ended)';
  }

  @override
  bool operator ==(covariant Game other) {
    if (identical(this, other)) return true;

    return other.game_id == game_id &&
        other.creator_id == creator_id &&
        other.winner_id == winner_id &&
        other.time_started == time_started &&
        other.time_ended == time_ended;
  }

  @override
  int get hashCode {
    return game_id.hashCode ^
        creator_id.hashCode ^
        winner_id.hashCode ^
        time_started.hashCode ^
        time_ended.hashCode;
  }
}
