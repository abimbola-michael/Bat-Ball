// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import '../enums/emums.dart';

class GameDetails {
  double dx = 0;
  double dy = 0;
  int angle = 0;
  int speed = 0;
  String vdir = "top";
  String hdir = "left";
  String action = "";
   GameDetails({
    required this.dx,
    required this.dy,
    required this.angle,
    required this.speed,
    required this.vdir,
    required this.hdir,
    required this.action,
  });
  Direction get vDir => vdir == "top" ? Direction.up : Direction.down;
  Direction get hDir => hdir == "left" ? Direction.left : Direction.right;

  

  GameDetails copyWith({
    double? dx,
    double? dy,
    int? angle,
    int? speed,
    String? vdir,
    String? hdir,
    String? action,
  }) {
    return GameDetails(
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
      angle: angle ?? this.angle,
      speed: speed ?? this.speed,
      vdir: vdir ?? this.vdir,
      hdir: hdir ?? this.hdir,
      action: action ?? this.action,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'dx': dx,
      'dy': dy,
      'angle': angle,
      'speed': speed,
      'vdir': vdir,
      'hdir': hdir,
      'action': action,
    };
  }

  factory GameDetails.fromMap(Map<String, dynamic> map) {
    return GameDetails(
      dx: (map["dx"] ?? 0.0) as double,
      dy: (map["dy"] ?? 0.0) as double,
      angle: (map["angle"] ?? 0) as int,
      speed: (map["speed"] ?? 0) as int,
      vdir: (map["vdir"] ?? '') as String,
      hdir: (map["hdir"] ?? '') as String,
      action: (map["action"] ?? '') as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory GameDetails.fromJson(String source) => GameDetails.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'GameDetails(dx: $dx, dy: $dy, angle: $angle, speed: $speed, vdir: $vdir, hdir: $hdir, action: $action)';
  }

  @override
  bool operator ==(covariant GameDetails other) {
    if (identical(this, other)) return true;
  
    return 
      other.dx == dx &&
      other.dy == dy &&
      other.angle == angle &&
      other.speed == speed &&
      other.vdir == vdir &&
      other.hdir == hdir &&
      other.action == action;
  }

  @override
  int get hashCode {
    return dx.hashCode ^
      dy.hashCode ^
      angle.hashCode ^
      speed.hashCode ^
      vdir.hashCode ^
      hdir.hashCode ^
      action.hashCode;
  }
}
