import 'package:batball/blocs/firebase_methods.dart';
import 'package:batball/models/game.dart';
import 'package:batball/models/idtime.dart';

import '../enums/emums.dart';
import '../models/models.dart';

class FirebaseService {
  FirebaseMethods fm = FirebaseMethods();
  String myId = "";
  String timeNow = DateTime.now().millisecondsSinceEpoch.toString();

  FirebaseService() {
    myId = fm.myId;
  }
  Stream<User?> getStreamUser(String user_id) async* {
    yield* fm
        .getStreamValue<User>((map) => User.fromMap(map), ["users", user_id]);
  }

  Future<User?> getUser(String user_id) async {
    return fm.getValue<User>((map) => User.fromMap(map), ["users", user_id]);
  }

  Future<Group?> getGroup(String group_id) async {
    return fm
        .getValue<Group>((map) => Group.fromMap(map), ["groups", group_id]);
  }

  Future<User?> searchUser(String type, String searchString) async {
    final users = await fm.getValues<User>(
        (map) => User.fromMap(map), ["users"],
        where: [type, "==", searchString]);
    return users.isNotEmpty ? users.first : null;
  }

  Future<Group?> searchGroup(String type, String searchString) async {
    final groups = await fm.getValues<Group>(
        (map) => Group.fromMap(map), ["groups"],
        where: [type, "==", searchString]);
    return groups.isNotEmpty ? groups.first : null;
  }

  Future<Game> createGame(List<String> opponent_ids) async {
    String game_id = fm.getId(["games"]);
    String time = timeNow;
    Game game = Game(
        game_id: game_id,
        creator_id: myId,
        winner_id: "",
        time_started: time,
        time_ended: "");
    await fm.setValue(["games", game_id], value: game.toMap());
    Player player = Player(player_id: myId, opponent_id: "");

    await fm
        .setValue(["games", game_id, "players", myId], value: player.toMap());

    await fm.setValue([
      "users",
      myId,
    ], value: {
      "current_game_id": game_id
    }, update: true);
    for (String opponent_id in opponent_ids) {
      await fm.setValue(["games", game_id, "players", opponent_id],
          value: player.copyWith(player_id: opponent_id).toMap());

      await fm.setValue([
        "users",
        opponent_id,
      ], value: {
        "current_game_id": game_id
      }, update: true);
    }
    Player playing = Player(player_id: myId, opponent_id: "");
    await fm
        .setValue(["games", game_id, "playing", myId], value: playing.toMap());
    return game;
  }

  Future updateGameRecord(
      String game_id, String opponent_id, String score) async {
    GameRecord record =
        GameRecord(opponent_id: opponent_id, score: score, time: timeNow);
    await fm.setValue(["games", game_id, "players", myId],
        value: {"opponent_id": opponent_id});
    await fm.setValue(
        ["games", game_id, "players", myId, "records", opponent_id],
        value: record.toMap());
  }

  Future updateTimeStart(String game_id) async {
    await fm.setValue(["games", game_id], value: {"time_started": timeNow});
  }

  Future startGame(String game_id, String opponent_id) async {
    await fm.setValue(["games", game_id, "playing", myId],
        value: {"opponent_id": opponent_id});
  }

  Future endGame(
      String game_id, String opponent_id, String score, bool win) async {
    await updateGameRecord(game_id, opponent_id, score);
    if (win) {
      await fm.setValue(["games", game_id, "playing", myId],
          value: {"opponent_id": ""});
      await fm.removeValue(["games", game_id, "playing", myId, "details"]);
    } else {
      await fm.setValue(["users", myId], value: {"current_game_id": ""});
      await fm.removeValue(["games", game_id, "playing", myId]);
    }
  }

  Future updateWinner(String game_id) async {
    await fm.setValue(["games", game_id],
        value: {"winner_id": myId, "time_ended": timeNow});
  }

  Future acceptGame(String game_id) async {
    Player playing = Player(player_id: myId, opponent_id: "");
    await fm
        .setValue(["games", game_id, "playing", myId], value: playing.toMap());
  }

  Future rejectGame(String game_id) async {
    await fm.removeValue(["games", game_id, "players", myId]);
  }

  Future updateMovement(
      String game_id, String opponent_id, double dy, double dx) async {
    Map<String, dynamic> map = {"dx": dx, "dy": dy};
    await fm.setValue(["games", game_id, "playing", myId, "details"],
        value: map, update: true);
  }

  Future updateHit(String game_id, String opponent_id, int angle, int speed,
      Direction vDir, Direction hDir) async {
    Map<String, dynamic> map = {
      "angle": angle,
      "speed": speed,
      "vdir": vDir.name,
      "hdir": hDir.name
    };
    await fm.setValue(["games", game_id, "playing", myId, "details"],
        value: map, update: true);
  }

  Future updateAction(String game_id, String opponent_id, String action) async {
    Map<String, dynamic> map = {
      "action": action,
    };
    await fm.setValue(["games", game_id, "playing", myId, "details"],
        value: map, update: true);
  }

  Future<Game?> getGame(String game_id) async {
    return fm.getValue((map) => Game.fromMap(map), ["games", game_id]);
  }

  Stream<Game?> getGameStream(String game_id) async* {
    yield* fm.getStreamValue((map) => Game.fromMap(map), ["games", game_id]);
  }

  Stream<List<Player>> getPlayers(String game_id) async* {
    yield* fm.getStreamValues(
        (map) => Player.fromMap(map), ["games", game_id, "players"]);
  }

  Stream<List<Player>> getPlaying(String game_id) async* {
    yield* fm.getStreamValues(
        (map) => Player.fromMap(map), ["games", game_id, "playing"]);
  }

  Stream<GameDetails?> getGameDetails(
      String game_id, String opponent_id) async* {
    yield* fm.getStreamValue((map) => GameDetails.fromMap(map),
        ["games", game_id, "playing", opponent_id, "details"]);
  }

  Future updateStatus() async {
    return fm.updateStatus();
  }
}
