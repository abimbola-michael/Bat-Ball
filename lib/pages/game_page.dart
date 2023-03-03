import 'dart:async';
import 'dart:math';
//import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:batball/blocs/firebase_methods.dart';
import 'package:batball/blocs/firebase_service.dart';
import 'package:batball/extensions/extensions.dart';
import 'package:batball/models/idtime.dart';
import 'package:batball/pages/login_page.dart';
import 'package:batball/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:batball/extensions/extensions.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';

import '../components/components.dart';
import '../enums/emums.dart';
import '../models/models.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with
        TickerProviderStateMixin,
        WidgetsBindingObserver,
        AutomaticKeepAliveClientMixin {
  int width = 0;
  int height = 0;
  double ballPosX = 0;
  double ballPosY = 0;
  int batWidth = 0;
  int batHeight = 0;
  int postHeight = 0;
  int postWidth = 0;
  int postThickness = 5;
  double player1BatX = 0, player2BatX = 0;
  double player1BatY = 0, player2BatY = 0;
  int playerDistanceFromPost = 50;
  int postX = 0;
  int player1PostY = 0, player2PostY = 0;
  int maxplayer1BatY = 0, maxplayer2BatY = 0;
  int speed = 10;
  int angle = 45;
  double incrementX = 1;
  double incrementY = 1;
  int minSpeed = 10;
  int maxSpeed = 25;
  int ballDiameter = 30, boardCenterDiammeter = 0;
  int player1Score = 0, player2Score = 0;
  int currentTime = 0;
  int pauseTime = 0;

  Direction vDir = Direction.down;
  Direction hDir = Direction.right;
  bool? ballHitX;
  bool hasHitBall = false;
  bool player1Hit = false;
  bool player2Hit = false;
  int timerCount = -1;
  DragUpdateDetails? player1Details, player2Details;
  int timeNow = DateTime.now().millisecondsSinceEpoch;
  bool isOnPause = false;
  GameMode gameMode = GameMode.unplayed;
  //GameType gameType = GameType.oneonone;
  GamePlatform gamePlatform = GamePlatform.phone;
  //GameStyle gameStyle = GameStyle.friendly;
  String currentOption = "";
  User? opponent, me;
  Stream<User?>? userStream;
  StreamSubscription<User?>? userStreamSub;

  Stream<List<Player>>? playersStream;
  StreamSubscription<List<Player>>? playersStreamSub;
  Stream<List<Player>>? playingStream;
  StreamSubscription<List<Player>>? playingStreamSub;
  Stream<GameDetails?>? gameDetails;
  StreamSubscription<GameDetails?>? gameDetailsSub;

  String myId = "";
  AnimationController? controller;
  FirebaseMethods fm = FirebaseMethods();
  FirebaseService fs = FirebaseService();
  String player1Action = "";
  String player2Action = "";
  String player1Name = "Player 1";
  String player2Name = "Player 2";
  List<User> selectedPlayers = [];
  bool loggedIn = false;
  bool gameStarted = false;
  bool waitingForPlayer = false;
  // AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
  String game_id = "";
  String opponent_id = "";
  bool creating = false;
  List<Player> players = [];
  List<Player> playing = [];
  List<PlayersFormation> players_formation = [];

  List<User> players_users = [];
  List<User> playing_users = [];
  List<User> not_playing_users = [];
  List<User> ready_users = [];
  List<User> not_ready_users = [];

  bool startedGame = true;
  bool created = false;
  TextEditingController text_controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    myId = fm.myId;
    loggedIn = fs.myId != "";
    userStream = fs.getStreamUser(myId);
    userStream!.listen((user) async {
      if (!mounted) return;
      setState(() {
        me = user;
      });
      if (user != null) {
        game_id = user.current_game_id;
        if (user.current_game_id != "") {
          setState(() {
            if (currentOption == "") currentOption = "create";
          });
          final game = await fs.getGame(game_id);
          if (game != null) {
            playersStream = fs.getPlayers(game_id);
            playersStreamSub = playersStream!.listen((players) async {
              startedGame = true;
              for (var player in players) {
                final user = await fs.getUser(player.opponent_id);
                if (user != null) players_users.add(user);

                if (player.opponent_id == "") {
                  startedGame = false;
                }
              }
              List<User> removedUsers = [];
              for (var player in this.players) {
                final index = players.indexWhere(
                    (element) => element.player_id == player.player_id);
                if (index == -1) {
                  removedUsers.add(user);
                }
              }
              this.players = players;

              if (removedUsers.isNotEmpty) {
                for (var user in removedUsers) {
                  removedUsers.removeWhere(
                      (element) => element.user_id == user.user_id);
                  Fluttertoast.showToast(
                      msg: "${user.username} is not playing");
                }
              }
              setState(() {});
              playingStream = fs.getPlaying(game_id);
              playingStreamSub = playingStream!.listen((playing) async {
                this.playing = playing;
                players_formation = getPlayerFormation();

                waitingForPlayer = false;
                for (var player in playing) {
                  final user = await fs.getUser(player.opponent_id);
                  if (user != null) playing_users.add(user);
                  if (player.opponent_id == "") {
                    waitingForPlayer = true;
                    if (user != null) not_ready_users.add(user);
                  } else {
                    if (user != null) ready_users.add(user);
                  }
                }
                if (!waitingForPlayer &&
                    (startedGame || players.length == playing.length)) {
                  readGameDetails();
                  startGame();
                }
              });
            });
          }
        } else {
          setState(() {
            currentOption = "";
          });

          playersStreamSub?.cancel();
          playingStreamSub?.cancel();
          gameDetailsSub?.cancel();
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeVariables();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    controller?.dispose();
    userStreamSub?.cancel();
    playersStreamSub?.cancel();
    playingStreamSub?.cancel();
    gameDetailsSub?.cancel();
    text_controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive) {
      isOnPause;
      if (gameMode == GameMode.playing || gameMode == GameMode.starting)
        pauseGame();
    } else if (state == AppLifecycleState.resumed) {
      if (gameMode == GameMode.pause && isOnPause) startGame();
      isOnPause = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        if (currentOption == "create") {
          currentOption = "";
          selectedPlayers.clear();
          return false;
        } else if (currentOption == "game") {
          if (gameMode == GameMode.playing || gameMode == GameMode.starting) {
            pauseGame();
          } else {
            setState(() {
              currentOption = "";
            });
          }
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            BoardCenter(
              diameter: boardCenterDiammeter,
            ),
            Container(
              height: 5,
              width: width.toDouble(),
              color: context.isDarkMode ? Colors.white : Colors.black,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                    width: 5,
                    color: context.isDarkMode ? Colors.white : Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: gameMode == GameMode.unplayed
                        ? Container()
                        : Text(
                            player2Name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18),
                          ),
                  ),
                  Text(
                    '$player2Score',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 60,
                        color: context.isDarkMode
                            ? Colors.white.withOpacity(0.5)
                            : Colors.black.withOpacity(0.5)),
                    textAlign: TextAlign.center,
                  ),
                  gameMode == GameMode.playing
                      ? Container(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                                color: context.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                                controller == null
                                    ? pauseTime.toInt().toDurationString
                                    : "${controller?.value.toInt().toDurationString}",
                                style: TextStyle(
                                    color: context.isDarkMode
                                        ? Colors.black
                                        : Colors.white)),
                          ),
                        )
                      : Container(),
                  Text(
                    '$player1Score',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 60,
                        color: context.isDarkMode
                            ? Colors.white.withOpacity(0.5)
                            : Colors.black.withOpacity(0.5)),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: gameMode == GameMode.unplayed
                        ? Container()
                        : Text(
                            player1Name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18),
                          ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: ballPosY,
              left: ballPosX,
              child: Ball(
                diameter: ballDiameter.toDouble(),
              ),
            ),
            Positioned(
              top: player2BatY,
              left: player2BatX,
              child: Bat(
                width: batWidth,
                height: batHeight,
                color: Colors.red,
              ),
            ),
            Positioned(
              top: player1BatY,
              left: player1BatX,
              child: Bat(
                width: batWidth,
                height: batHeight,
                color: Colors.blue,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.center,
                child: Post(
                  height: postHeight,
                  width: postWidth,
                  down: true,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.center,
                child: Post(
                  height: postHeight,
                  width: postWidth,
                  down: false,
                ),
              ),
            ),
            Positioned.fill(
                child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onPanStart: (details) {},
                    onPanEnd: ((details) {
                      setState(() {
                        player2Details = null;
                      });
                    }),
                    onPanUpdate: (details) => moveBat(details, false),
                    child: Container(
                      height: height / 2,
                      width: width.toDouble(),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onPanStart: (details) {},
                    onPanEnd: ((details) {
                      setState(() {
                        player1Details = null;
                      });
                    }),
                    onPanUpdate: (details) => moveBat(details, true),
                    child: Container(
                      height: height / 2,
                      width: width.toDouble(),
                    ),
                  ),
                )
              ],
            )),
            Positioned.fill(
                child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (currentOption == "") ...[
                      Padding(
                        padding:
                            EdgeInsets.all(context.screenWidthPercentage(10)),
                        child: ActionButton("Play on phone", onPressed: () {
                          gamePlatform = GamePlatform.phone;
                          startGame();
                        }, height: 50),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.all(context.screenWidthPercentage(10)),
                        child: ActionButton("Play online", onPressed: () {
                          gamePlatform = GamePlatform.online;
                          if (me != null) selectedPlayers.add(me!);
                          setState(() {
                            currentOption = "create";
                          });
                        }, height: 50),
                      ),
                    ],
                    if (currentOption == "create") ...[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Select Players",
                          style: TextStyle(
                              color: tintColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: TextField(
                                  controller: text_controller,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: lightTintColor)),
                                      hintText:
                                          "Enter username, email or phone"),
                                  //onChanged: ((value) {}),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                String value = text_controller.text;
                                String type = "";
                                if (value.isValidEmail()) {
                                  type = "email";
                                } else if (value.isOnlyNumber()) {
                                  type = "phone";
                                } else {
                                  type = "username";
                                }
                                final user = await fs.searchUser(type, value);
                                if (user != null) {
                                  if (user.current_game_id == "") {
                                    if (user.last_seen != "") {
                                      Fluttertoast.showToast(
                                          msg:
                                              "${user.username} is not active. Contact to play");
                                    } else {
                                      final index = selectedPlayers.indexWhere(
                                          (element) =>
                                              element.user_id == user.user_id);
                                      if (index != -1) {
                                        Fluttertoast.showToast(
                                            msg:
                                                "${user.username} is already added");
                                      } else {
                                        selectedPlayers.add(user);
                                      }
                                      text_controller.clear();
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            "${user.username} is currently in another game");
                                  }
                                  setState(() {});
                                } else {
                                  Fluttertoast.showToast(msg: "No match found");
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: appColor,
                                    borderRadius: BorderRadius.circular(10)),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(left: 4),
                                height: 50,
                                width: 50,
                                child: const Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: height / 2,
                        child: currentOption == "create"
                            ? ListView.builder(
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(16),
                                itemCount: selectedPlayers.length,
                                itemBuilder: (context, index) {
                                  final user = selectedPlayers[index];
                                  return Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: waitingForPlayer
                                            ? lighthestTintColor
                                            : appColor,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Text(
                                      user.username,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: waitingForPlayer
                                              ? tintColor
                                              : Colors.white),
                                    ),
                                  );
                                })
                            : ListView.builder(
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(16),
                                itemCount: players_formation.length,
                                itemBuilder: (context, index) {
                                  final player_formation =
                                      players_formation[index];
                                  final user1 = player_formation.user1;
                                  final user2 = player_formation.user2;

                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        user1.username,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: waitingForPlayer
                                                ? tintColor
                                                : Colors.white),
                                      ),
                                    ],
                                  );
                                }),
                      ),
                    ]
                  ],
                ),
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: currentOption == ""
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                                onPressed: () {
                                  gotoLoginOrSignUp(false);
                                },
                                child: const Text("Sign Up")),
                            const Text("   |   "),
                            TextButton(
                                onPressed: () {
                                  if (loggedIn) {
                                    fm.logOut().then((value) {
                                      setState(() {
                                        loggedIn = false;
                                      });
                                    });
                                  } else {
                                    gotoLoginOrSignUp(true);
                                  }
                                },
                                child: Text(loggedIn ? "LogOut" : "Login")),
                          ],
                        )
                      : currentOption == "create"
                          ? Row(
                              children: [
                                ActionButton(
                                    game_id == ""
                                        ? "Create Game"
                                        : "Accept Game", onPressed: () async {
                                  if (game_id == "") {
                                    final playersSize = selectedPlayers.length;
                                    if (playersSize == 0 || playersSize == 1) {
                                      Fluttertoast.showToast(
                                          msg:
                                              "You are yet to select a player");
                                    } else {
                                      if (playersSize != 2 ||
                                          playersSize != 4 ||
                                          playersSize != 8 ||
                                          playersSize != 16) {
                                        Fluttertoast.showToast(
                                            msg:
                                                "There can only be 2, 4, 8, 16 number of players in Bat Ball");
                                      } else {
                                        final game = await fs.createGame(
                                            selectedPlayers
                                                .map((e) => e.user_id)
                                                .toList());
                                        // game_id = game.game_id;
                                      }
                                    }
                                  } else {
                                    await fs.acceptGame(game_id);
                                  }
                                  setState(() {
                                    currentOption = "game";
                                  });
                                }, height: 50),
                                const SizedBox(
                                  width: 20,
                                ),
                                ActionButton(
                                  game_id == "" ? "Cancel Game" : "Reject Game",
                                  onPressed: () async {
                                    if (game_id == "") {
                                      selectedPlayers.clear();
                                    } else {
                                      await fs.rejectGame(game_id);
                                    }
                                    setState(() {
                                      currentOption = "";
                                    });
                                  },
                                  height: 50,
                                  color: lighthestTintColor,
                                  textColor: tintColor,
                                )
                              ],
                            )
                          : ActionButton(
                              waitingForPlayer
                                  ? "Waiting for Others"
                                  : "Start Game", onPressed: () async {
                              if (opponent == null) {
                                final playerOpponent = playing
                                    .where((element) =>
                                        element.opponent_id == myId)
                                    .toList();
                                if (playerOpponent.isNotEmpty) {
                                  opponent = playing_users.firstWhere(
                                      (element) =>
                                          element.user_id ==
                                          playerOpponent[0].player_id);
                                  opponent_id = playerOpponent[0].player_id;
                                } else {
                                  final playersWithoutMe = playing
                                      .where((element) =>
                                          element.player_id != myId &&
                                          element.opponent_id == "")
                                      .toList();
                                  final pos = playersWithoutMe.length > 1
                                      ? Random()
                                          .nextInt(playersWithoutMe.length)
                                      : 0;
                                  opponent_id = playersWithoutMe[pos].player_id;
                                  opponent = playing_users.firstWhere(
                                      (element) =>
                                          element.user_id == opponent_id);
                                }
                                await fs.startGame(game_id, opponent_id);
                              }
                              if (waitingForPlayer) {
                                final usernames = not_ready_users
                                    .map((e) => e.username)
                                    .toList()
                                    .join();
                                Fluttertoast.showToast(
                                    msg:
                                        "Still waiting for $usernames to accept");
                              } else {}

                              setState(() {});
                            }, height: 50),
                )
              ],
            )),
            Positioned.fill(
                child: gameMode == GameMode.end || gameMode == GameMode.pause
                    ? Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // IconButton(
                                //     onPressed: () {},
                                //     icon: const Icon(Icons.mail)),
                                Text(
                                  "Bat Ball",
                                  style: GoogleFonts.orbitron(fontSize: 30),
                                ),
                                // IconButton(
                                //     onPressed: () {},
                                //     icon: const Icon(Icons.question_mark))
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (gameMode == GameMode.end) ...[
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    scoreMessage(),
                                    style: const TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "$player1Score",
                                            style:
                                                const TextStyle(fontSize: 50),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          Text(
                                            player1Name,
                                            style:
                                                const TextStyle(fontSize: 25),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 100,
                                        height: 5,
                                        color: tintColor,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 50),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "$player2Score",
                                            style:
                                                const TextStyle(fontSize: 50),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          Text(
                                            player2Name,
                                            style:
                                                const TextStyle(fontSize: 25),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // Text(
                                  //   "$player1Score  -  $player2Score",
                                  //   style: const TextStyle(fontSize: 50),
                                  //   textAlign: TextAlign.center,
                                  // ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                ],
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.all(
                                  context.screenWidthPercentage(10)),
                              child: ActionButton(getActionButton(),
                                  onPressed: startGame, height: 50),
                            ),
                            if (gameMode == GameMode.pause ||
                                gameMode == GameMode.end) ...[
                              Padding(
                                padding: EdgeInsets.all(
                                    context.screenWidthPercentage(10)),
                                child: ActionButton("Restart Game",
                                    onPressed: restartGame, height: 50),
                              ),
                              Padding(
                                padding: EdgeInsets.all(
                                    context.screenWidthPercentage(10)),
                                child: ActionButton("Main Menu",
                                    onPressed: gotoMainMenu, height: 50),
                              ),
                            ]
                          ],
                        ),
                      )
                    : gameMode == GameMode.starting && timerCount != -1
                        ? Text(
                            timerCount == 3 ? "Go" : "${3 - timerCount}",
                            style: const TextStyle(fontSize: 80),
                          )
                        : Container()),
          ],
        ),
      ),
    );
  }

  String scoreMessage() {
    String message = "";
    if (player1Score > player2Score) {
      message = "${player1Name} Won";
    } else {
      message = "${player2Name} Won";
    }
    return message;
  }

  void initializeController() {
    controller = AnimationController(
        duration: const Duration(minutes: 5),
        vsync: this,
        lowerBound: 0,
        upperBound: 300);
    controller!.addListener(() {
      if (gameMode == GameMode.playing) moveBall();
    });
    controller!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (gameMode == GameMode.playing) {
          if (opponent != null) {
            fs.endGame(game_id, opponent!.opponent_id,
                "$player1Score $player2Score", player1Score > player2Score);
          }
          gameStarted = false;
          //gameDetailsSub?.cancel;
          setState(() {
            gameMode = GameMode.end;
          });
        }
      }
    });
    setState(() {
      gameStarted = true;
      gameMode = GameMode.playing;
    });
    controller!.forward(from: pauseTime.toDouble());
  }

  void initializeVariables() {
    height = context.screenHeight.toInt();
    width = context.screenWidth.toInt();
    batWidth = context.screenWidthPercentage(20).toInt();
    batHeight = context.screenHeightPercentage(4).toInt();
    postWidth = context.screenWidthPercentage(70).toInt();
    postHeight = context.screenHeightPercentage(5).toInt();
    boardCenterDiammeter = context.screenWidthPercentage(50).toInt();
    ballPosX = width / 2 - ballDiameter / 2;
    ballPosY = (height / 2) - (ballDiameter / 2);
    player1BatX = (width / 2) - (batWidth / 2);
    player2BatX = (width / 2) - (batWidth / 2);
    player1BatY =
        height - postHeight.toDouble() - playerDistanceFromPost - batHeight;
    player2BatY = postHeight.toDouble() + playerDistanceFromPost;
    // angle = Random().nextInt(90);
    // vDir = Random().nextInt(2) == 0 ? Direction.up : Direction.down;
    // hDir = Random().nextInt(2) == 0 ? Direction.left : Direction.right;
    postX = context.screenWidthPercentage(15).toInt();
    postX = context.screenWidthPercentage(15).toInt();
    player1PostY = height - postHeight;
    player2PostY = postHeight;
    maxplayer1BatY = (height ~/ 2) + batHeight;
    maxplayer2BatY = (height ~/ 2) - batHeight;
    speed = minSpeed;
  }

  String getActionButton() {
    if (gameMode == GameMode.unplayed) {
      return "Play Game";
    } else if (gameMode == GameMode.pause) {
      return "Resume Game";
    } else if (gameMode == GameMode.end) {
      return "Play Again";
    } else {
      return "";
    }
  }

  void moveBall() {
    if (gameMode != GameMode.playing) return;
    Direction hDir = this.hDir.toString().split(".").last == "left"
        ? Direction.left
        : Direction.right;
    Direction vDir = this.vDir.toString().split(".").last == "up"
        ? Direction.up
        : Direction.down;

    if (ballPosX <= 0) {
      hDir = Direction.right;
    }
    if (ballPosX >= width - ballDiameter) {
      hDir = Direction.left;
    }
    if (ballPosY <= postHeight && ballPosY >= -1) {
      if (ballPosX >= postX && ballPosX <= postX + postWidth - ballDiameter) {
        if (ballPosY <= 0) {
          winGame(true);
        } else {
          if (ballPosX >= postX + postWidth - ballDiameter) {
            hDir = Direction.left;
          } else if (ballPosX <= postX) {
            hDir = Direction.right;
          }
        }
      } else if (ballPosX >= postX - ballDiameter ||
          ballPosX <= postX + postWidth) {
        if (ballPosY >= (postHeight / 2) && ballPosY <= postHeight) {
          vDir = Direction.down;
        } else {
          if (ballPosX >= postX - ballDiameter) {
            hDir = Direction.left;
          } else if (ballPosX <= postX + postWidth) {
            hDir = Direction.right;
          }
        }
      } else {
        vDir = Direction.down;
      }
    }

    if (ballPosY >= height - postHeight - ballDiameter && ballPosY <= height) {
      if (ballPosX >= postX && ballPosX <= postX + postWidth - ballDiameter) {
        if (ballPosY >= height - ballDiameter) {
          winGame(false);
        } else {
          if (ballPosX >= postX + postWidth - ballDiameter) {
            hDir = Direction.left;
          } else if (ballPosX <= postX) {
            hDir = Direction.right;
          }
        }
      } else if (ballPosX >= postX - ballDiameter ||
          ballPosX <= postX + postWidth) {
        if (ballPosY >= height - postHeight - ballDiameter &&
            ballPosY <= height - ballDiameter - (postHeight / 2)) {
          vDir = Direction.up;
        } else {
          if (ballPosX >= postX - ballDiameter) {
            hDir = Direction.left;
          } else if (ballPosX <= postX + postWidth) {
            hDir = Direction.right;
          }
        }
      } else {
        vDir = Direction.up;
      }
    }

    if (ballPosY >= player1BatY - ballDiameter &&
        ballPosY <= player1BatY + batHeight &&
        ballPosX >= player1BatX - ballDiameter &&
        ballPosX <= player1BatX + batWidth) {
      if (ballPosY >= player1BatY - ballDiameter && !player1Hit) {
        vDir = Direction.up;
        player1Hit = true;
      } else if (ballPosY <= player1BatY + batHeight && !player1Hit) {
        vDir = Direction.down;
        player1Hit = true;
      }
    } else {
      player1Hit = false;
    }

    if (ballPosY <= player2BatY + batHeight &&
        ballPosY >= player2BatY - ballDiameter &&
        ballPosX >= player2BatX - ballDiameter &&
        ballPosX <= player2BatX + batWidth) {
      if (ballPosY >= player2BatY - ballDiameter && !player2Hit) {
        vDir = Direction.down;
        player2Hit = true;
      } else if (ballPosY <= player2BatY + batHeight && !player2Hit) {
        vDir = Direction.up;
        player2Hit = true;
      }
    } else {
      player2Hit = false;
    }

    // setState(() {
    // if (ballPosX >= double.infinity) {
    //   ballPosX = width;
    // } else if (ballPosX <= double.negativeInfinity) {
    //   ballPosX = 0;
    // } else if (ballPosX.isNaN) {
    //   ballPosX = 0;
    // }

    // if (ballPosY >= double.infinity) {
    //   ballPosY = height;
    // } else if (ballPosY <= double.negativeInfinity) {
    //   ballPosY = 0;
    // } else if (ballPosY.isNaN) {
    //   ballPosY = 0;
    // }

    if (this.hDir != hDir || this.vDir != vDir || player1Hit || player2Hit) {
      if (this.hDir != hDir) this.hDir = hDir;
      if (this.vDir != vDir) this.vDir = vDir;
      //if (gameStarted) gameStarted = false;
      final hitX = this.hDir != hDir;
      bool hasHit = false;
      if (player1Details != null && player1Hit) {
        if (gamePlatform == GamePlatform.online && opponent != null) {
          fs.updateMovement(
              game_id, opponent!.user_id, player1BatY, player1BatX);
        }
        changeHitDetails(player1Details!, true);
        hasHit = true;
      }

      if (player2Details != null && player2Hit) {
        changeHitDetails(player2Details!, false);
        hasHit = true;
      }
      if (hasHit) {
        playHitBallSound();
      } else {
        playHitEdgeSound();
      }
      changeBallDirection(hitX, hasHit);
    }

    final additionX = incrementX * speed;
    final additionY = incrementY * speed;

    this.hDir == Direction.right
        ? ballPosX + additionX >= width
            ? width
            : ballPosX += additionX
        : ballPosX - additionX <= 0
            ? 0
            : ballPosX -= additionX;
    this.vDir == Direction.down
        ? ballPosY + additionY >= height
            ? height
            : ballPosY += additionY
        : ballPosY - additionY <= 0
            ? 0
            : ballPosY -= additionY;

    if (gamePlatform == GamePlatform.phone) {
      player2BatX = ballPosX.toDouble() >= width - ballDiameter
          ? width.toDouble() - ballDiameter
          : ballPosX <= 0
              ? 0
              : ballPosX - (batWidth ~/ 2);
    }
    setState(() {});
  }

  void changeBallDirection(bool hitX, bool hasHit) {
    if (!hasHit) {
      if (speed < minSpeed) {
        speed = minSpeed;
      } else {
        speed--;
      }
    }
    final hitPointX = ballPosX;
    final hitPointY = ballPosY;
    if (ballHitX != null) {
      if (ballHitX != hitX) {
        if (!hasHit) {
          angle = 90 - angle;
        }
        ballHitX = hitX;
      }
    } else {
      ballHitX = hitX;
    }
    if (hitX) {
      final remainingY = vDir == Direction.up ? ballPosY : height - hitPointY;
      final expectedX = (angle / 45) * remainingY;
      if (expectedX > remainingY) {
        incrementX = remainingY / expectedX;
        incrementY = 1;
      } else {
        incrementX = 1;
        incrementY = expectedX / remainingY;
      }
    } else {
      final remainingX = hDir == Direction.left ? ballPosX : width - hitPointX;
      final expectedY = (angle / 45) * remainingX;
      if (expectedY > remainingX) {
        incrementX = remainingX / expectedY;
        incrementY = 1;
      } else {
        incrementX = 1;
        incrementY = expectedY / remainingX;
      }
    }
  }

  void changeHitDetails(DragUpdateDetails details, bool playerOne) {
    // print("changeHitDetails");
    if (!hasHitBall) hasHitBall = true;
    double dx = details.delta.dx.isNaN ? 0 : details.delta.dx;
    double dy = details.delta.dy.isNaN ? 0 : details.delta.dy;
    if (dx >= double.infinity) {
      dx = width.toDouble();
    } else if (dx <= double.negativeInfinity) {
      dx = 0;
    }
    if (dy >= double.infinity) {
      dy = height.toDouble();
    } else if (dy <= double.negativeInfinity) {
      dy = 0;
    }
    // final dx = details.delta.dx;
    // final dy = details.delta.dy;
    final distance = details.delta.distance;
    int speed = 0;

    //hDir = dx > 0 ? Direction.right : Direction.left;

    if (dx != 0) {
      hDir = dy > 0
          ? dx > 0
              ? Direction.left
              : Direction.right
          : dx > 0
              ? Direction.right
              : Direction.left;

      if (dy == 0) {
        angle = 90 - angle;
        speed = (dx * 2).toInt();
      } else {
        angle = atan2(dy.abs(), dx.abs()).toDegrees;
        speed = (distance * 2).toInt();
      }
    } else {
      if (dy == 0) {
        angle = 90 - angle;
        this.speed--;
      } else {
        angle = 90;
        speed = (dy * 2).toInt();
      }
    }
    int newSpeed = speed < minSpeed
        ? minSpeed
        : speed > maxSpeed
            ? maxSpeed
            : speed;
    if (newSpeed > this.speed) {
      this.speed = newSpeed;
    }
    if (player1Hit) {
      if (gamePlatform == GamePlatform.online && opponent != null) {
        fs.updateHit(game_id, opponent!.user_id, angle, speed, vDir, hDir);
      }
    }
  }

  void moveBat(DragUpdateDetails details, bool playerOne) {
    if (gameMode != GameMode.playing) return;

    double dx = details.delta.dx.isNaN ? 0 : details.delta.dx;
    double dy = details.delta.dy.isNaN ? 0 : details.delta.dy;

    if (playerOne) {
      final player1xResult = player1BatX + dx;
      final player1yResult = player1BatY + dy;

      player1BatX = player1xResult <= 0
          ? 1
          : player1xResult >= width - batWidth
              ? width - batWidth + 1
              : player1xResult;

      player1BatY = player1yResult <= 0
          ? 1
          : player1yResult >= height - batHeight
              ? height - batHeight + 1
              : player1yResult;

      player1Details = details;
      if (gamePlatform == GamePlatform.online && opponent != null) {
        fs.updateMovement(game_id, opponent!.user_id, player1BatY, player1BatX);
      }
    } else {
      final player2xResult = player2BatX + dx;
      final player2yResult = player2BatY + dy;

      player2BatX = player2xResult <= 0
          ? 1
          : player2xResult >= width - batWidth
              ? width - batWidth + 1
              : player2xResult;

      player2BatY = player2yResult <= 0
          ? 1
          : player2yResult >= height - batHeight
              ? height - batHeight + 1
              : player2yResult;

      player2Details = details;
    }
    setState(() {});
  }

  double randomNumber() {
    //this is a number between 0.5 and 1.5;
    var ran = Random();
    int myNum = ran.nextInt(101);
    return (50 + myNum) / 100;
  }

  void resetPositions() {
    setState(() {
      ballPosX = (width / 2) - (ballDiameter / 2);
      ballPosY = (height / 2) - (ballDiameter / 2);
      player1BatX = (width / 2) - (batWidth / 2);
      player2BatX = (width / 2) - (batWidth / 2);
      player1BatY =
          height - postHeight.toDouble() - playerDistanceFromPost - batHeight;
      player2BatY = postHeight.toDouble() + playerDistanceFromPost;
      // angle = Random().nextInt(90);
      // vDir = Random().nextInt(2) == 0 ? Direction.up : Direction.down;
      // hDir = Random().nextInt(2) == 0 ? Direction.left : Direction.right;
      speed = minSpeed;
      incrementX = 1;
      incrementY = 1;
      hasHitBall = false;
    });
  }

  void winGame(bool playerOne) async {
    if (playerOne) {
      player1Score++;
    } else {
      player2Score++;
    }
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate();
    }
    pauseGame();
    resetPositions();
    startGame();
  }

  void restartGame() {
    pauseTime = 0;
    player1Score = 0;
    player2Score = 0;
    pauseGame();
    resetPositions();
    startGame();
  }

  void gotoMainMenu() {
    pauseTime = 0;
    pauseGame();
    resetPositions();
    setState(() {
      gameMode == GameMode.unplayed;
    });
  }

  void startGame() {
    // if (gameType == GameType.oneonone && gamePlatform == GamePlatform.net) {
    //   if (opponent != null) {
    //     fs.startGame(opponent!.user_id);
    //     selectedPlayers.add(opponent!);
    //   } else {}
    // }
    if (gameStarted) {
      fs.updateTimeStart(game_id);
      gameStarted = false;
    }

    setState(() {
      gameMode = GameMode.starting;
    });
    startReadyTimer();
  }

  void pauseGame() {
    pauseTime = controller?.value.toInt() ?? 0;
    controller?.dispose();
    controller = null;
    if (gameMode != GameMode.unplayed) {
      setState(() {
        gameMode = GameMode.pause;
      });
    }
  }

  void startReadyTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerCount >= 3) {
        timerCount = -1;
        timer.cancel();
        initializeController();
      } else {
        if (gameMode != GameMode.starting) {
          timer.cancel();
          timerCount = -1;
        } else {
          setState(() {
            timerCount++;
          });
        }
      }
    });
  }

  void playHitBallSound() {
    // assetsAudioPlayer.stop();
    // assetsAudioPlayer.open(
    //   Audio("assets/audios/hit-ball-60701.mp3"),
    // );
  }

  void playHitEdgeSound() {
    // assetsAudioPlayer.stop();
    // assetsAudioPlayer.open(
    //   Audio("assets/audios/mixkit-ball-bouncing-in-the-ground-2077.wav"),
    // );
  }
  void gotoLoginOrSignUp(bool login) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => LoginPage(
              login: login,
            )));
  }

  void readGameDetails() {
    gameDetails = fs.getGameDetails(game_id, opponent_id);
    if (gameDetailsSub != null) gameDetailsSub?.cancel();
    gameDetailsSub = gameDetails!.listen((details) async {
      if (details != null && opponent != null) {
        player2BatX = width - details.dx;
        player2BatY = details.dy;
        speed = details.speed;
        angle = details.angle;
        vDir = details.vDir == Direction.down ? Direction.up : Direction.down;
        hDir =
            details.hDir == Direction.left ? Direction.right : Direction.left;
        player2Action = details.action;
        setState(() {});
      }
    });
  }

  // void showIncomingGameDialog(User user) {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: Text("${user.username} will like to play Batball with you"),
  //           actions: [
  //             TextButton(
  //                 onPressed: () async {
  //                   await fs.acceptGame(game_id, user.user_id);
  //                   startGame();
  //                   Navigator.of(context).pop();
  //                   setState(() {});
  //                 },
  //                 child: const Text("Accept")),
  //             TextButton(
  //                 onPressed: () async {
  //                   await fs.rejectGame(game_id, user.user_id);
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: const Text("Reject"))
  //           ],
  //         );
  //       });
  // }

  @override
  bool get wantKeepAlive => true;

  List<PlayersFormation> getPlayerFormation() {
    List<PlayersFormation> players_formation = [];
    for (Player player in playing) {
      if (player.opponent_id != "") {
        for (Player inner_player in playing) {
          if (inner_player.opponent_id == player.player_id &&
              player.opponent_id == inner_player.player_id) {
            String id = "";
            if (player.player_id.greaterThan(inner_player.player_id)) {
              id = "${player.player_id}_${inner_player.player_id}";
              final user1 = playing_users
                  .firstWhere((element) => element.user_id == player.player_id);
              final user2 = playing_users.firstWhere(
                  (element) => element.user_id == inner_player.player_id);
              players_formation
                  .add(PlayersFormation(id: id, user1: user1, user2: user2));
            } else {
              id = "${player.player_id}_${inner_player.player_id}";
              final user1 = playing_users.firstWhere(
                  (element) => element.user_id == inner_player.player_id);
              final user2 = playing_users
                  .firstWhere((element) => element.user_id == player.player_id);
              players_formation
                  .add(PlayersFormation(id: id, user1: user1, user2: user2));
            }
          }
        }
      }
    }
    return players_formation;
  }

  void initialAlg() async {
    final sortedPlayers = playing.sortedList((value) => value.player_id, false);
    final index =
        sortedPlayers.indexWhere((element) => element.player_id == myId);
    if (index != -1) {
      final opponent = sortedPlayers[index.isEven ? index + 1 : index - 1];
      opponent_id = opponent.opponent_id;
    }
    final user = await fs.getUser(opponent_id);
    player2Name = user?.username ?? "";
    await fs.startGame(game_id, opponent_id);
  }
}
