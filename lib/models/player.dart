// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
class Player {
  String player_id;
  String opponent_id;
  Player({
    required this.player_id,
    required this.opponent_id,
  });
  

  Player copyWith({
    String? player_id,
    String? opponent_id,
  }) {
    return Player(
      player_id: player_id ?? this.player_id,
      opponent_id: opponent_id ?? this.opponent_id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'player_id': player_id,
      'opponent_id': opponent_id,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      player_id: (map["player_id"] ?? '') as String,
      opponent_id: (map["opponent_id"] ?? '') as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Player.fromJson(String source) => Player.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Player(player_id: $player_id, opponent_id: $opponent_id)';

  @override
  bool operator ==(covariant Player other) {
    if (identical(this, other)) return true;
  
    return 
      other.player_id == player_id &&
      other.opponent_id == opponent_id;
  }

  @override
  int get hashCode => player_id.hashCode ^ opponent_id.hashCode;
}
