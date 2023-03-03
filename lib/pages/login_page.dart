import 'package:batball/blocs/firebase_methods.dart';
import 'package:batball/components/components.dart';
import 'package:batball/models/models.dart';
import 'package:batball/styles/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:batball/models/user.dart' as myUser;
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  final bool login;
  const LoginPage({super.key, required this.login});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool login = false;
  String username = "", email = "", password = "";
  FirebaseMethods fm = FirebaseMethods();
  int timeNow = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    login = widget.login;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Bat Ball",
                          style: GoogleFonts.orbitron(
                              fontSize: 40, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Text(
                      //   login ? "Login to Batball" : "Sign Up for Batball",
                      //   style: TextStyle(
                      //       fontSize: 30,
                      //       color: tintColor,
                      //       fontWeight: FontWeight.bold),
                      //   textAlign: TextAlign.center,
                      // ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: lightTintColor)),
                            hintText: "Email"),
                        onChanged: ((value) {
                          email = value;
                        }),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      if (!login) ...[
                        TextField(
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: lightTintColor)),
                              hintText: "Username"),
                          onChanged: ((value) {
                            username = value;
                          }),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: lightTintColor)),
                            hintText: "Password"),
                        onChanged: ((value) {
                          password = value;
                        }),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ActionButton(login ? "Login" : "Sign Up", onPressed: () {
                        if (login) {
                          fm.login(email, password).then((value) async {
                            final emailVerified = await fm.isEmailVerified();
                            if (emailVerified) {
                              Navigator.pop(context);
                            } else {
                              fm.logOut().then((value) {
                                Navigator.pop(context);
                              });
                            }
                          }).onError((error, stackTrace) {
                            Navigator.pop(context);
                          });
                        } else {
                          fm.createAccount(email, password).then((value) {
                            fm.sendEmailVerification().then((value) async {
                              final user = FirebaseAuth.instance.currentUser;
                              await fm.setValue(["usernames", username],
                                  value:
                                      Username(username: username, email: email)
                                          .toMap());
                              if (user != null) {
                                await fm.setValue(["users", user.uid],
                                    value: myUser.User(
                                            email: email,
                                            user_id: user.uid,
                                            username: username,
                                            phone: "",
                                            time: timeNow.toString(),
                                            last_seen: timeNow.toString(),
                                            opponent_id: "",
                                            current_game_id: "")
                                        .toMap());
                              }

                              fm.logOut().then((value) {
                                Navigator.pop(context);
                              }).onError((error, stackTrace) {
                                Navigator.pop(context);
                              });
                            });
                          });
                        }
                      }, height: 60)
                    ]),
              ),
            ),
            Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: login
                            ? "Don't have an account? "
                            : "Already have an account? ",
                        style: TextStyle(color: tintColor),
                        children: [
                          TextSpan(
                              text: login ? "Sign Up" : "Login",
                              style: TextStyle(color: appColor),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  setState(() {
                                    login = !login;
                                  });
                                }),
                        ])))
          ],
        ),
      ),
    );
  }
}
