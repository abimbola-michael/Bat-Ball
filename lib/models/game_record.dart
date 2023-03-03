import 'dart:convert';

class GameRecord {
  String opponent_id;
  String score;
  String time;
  GameRecord({
    required this.opponent_id,
    required this.score,
    required this.time,
  });

  GameRecord copyWith({
    String? opponent_id,
    String? score,
    String? time,
  }) {
    return GameRecord(
      opponent_id: opponent_id ?? this.opponent_id,
      score: score ?? this.score,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'opponent_id': opponent_id,
      'score': score,
      'time': time,
    };
  }

  factory GameRecord.fromMap(Map<String, dynamic> map) {
    return GameRecord(
      opponent_id: (map["opponent_id"] ?? '') as String,
      score: (map["score"] ?? '') as String,
      time: (map["time"] ?? '') as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory GameRecord.fromJson(String source) =>
      GameRecord.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'GameRecord(opponent_id: $opponent_id, score: $score, time: $time)';

  @override
  bool operator ==(covariant GameRecord other) {
    if (identical(this, other)) return true;

    return other.opponent_id == opponent_id &&
        other.score == score &&
        other.time == time;
  }

  @override
  int get hashCode => opponent_id.hashCode ^ score.hashCode ^ time.hashCode;
}
