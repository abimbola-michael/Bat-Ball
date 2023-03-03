import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

bool get darkMode =>
    SchedulerBinding.instance.window.platformBrightness == Brightness.dark;
// ignore: unrelated_type_equality_checks
bool get isiPhone => TargetPlatform == TargetPlatform.iOS;
bool get isWindows => TargetPlatform == TargetPlatform.windows;

List<String> alphabets = [
  "a",
  "b",
  "c",
  "d",
  "e",
  "f",
  "g",
  "h",
  "i",
  "j",
  "k",
  "l",
  "m",
  "n",
  "o",
  "p",
  "q",
  "r",
  "s",
  "t",
  "u",
  "v",
  "w",
  "x",
  "y",
  "z"
];
List<String> numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
List<String> alphanumeric = [...alphabets, ...numbers];
