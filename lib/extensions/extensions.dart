import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import '../utils.dart';

extension ContextExtensions on BuildContext {
  bool get isDarkMode {
    return MediaQuery.of(this).platformBrightness == Brightness.dark;
  }

  bool get isMobile => MediaQuery.of(this).size.width < 730;
  bool get isTablet {
    var width = MediaQuery.of(this).size.width;
    return width < 1190 && width >= 730;
  }

  bool get isWeb => MediaQuery.of(this).size.width >= 1190;
  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  // Size get screenSize => MediaQuery.of(this).size;
  double get statusBarHeight => MediaQuery.of(this).padding.top;

  double screenHeightPercentage(int percent) => screenHeight * percent / 100;
  double screenWidthPercentage(int percent) => screenWidth * percent / 100;
}

extension DoubleExtensions on double {
  int get toDegrees => (this * (180.0 / 3.14159265)).toInt();
}

extension IntExtensions on int {
  String get toDurationString {
    String duration = "";
    final hours = this ~/ 3600;
    final minutes = this % 3600 ~/ 60;
    final seconds = this % 60;
    if (this < 60) {
      duration = "00:${seconds.toDigitsOf(2)}";
    } else if (this < 600) {
      duration = "${minutes.toDigitsOf(2)}:${seconds.toDigitsOf(2)}";
    } else if (this > 600 && this < 3600) {
      duration = "${minutes.toDigitsOf(2)}:${seconds.toDigitsOf(2)}";
    } else {
      duration = "$hours:${minutes.toDigitsOf(2)}:${seconds.toDigitsOf(2)}";
    }
    return duration;
  }

  String toDigitsOf(int value) {
    String intString = "";
    if (toString().length < value) {
      int numberOfZerosToAdd = value - toString().length;
      if (value > numberOfZerosToAdd) {
        for (int i = 0; i < numberOfZerosToAdd; i++) {
          intString += "0";
        }
      }
      intString += "$this";
      return intString;
    } else {
      return toString();
    }
  }
}

extension StringExtensions on String {
  String? get lastChar => length > 0 ? this[length - 1] : null;
  String? get firstChar => length > 0 ? this[0] : null;

  String get capitalize =>
      length > 1 ? substring(0, 1).toUpperCase() + substring(1) : "";
  bool get endsWithSymbol =>
      lastChar == null ? false : !alphanumeric.contains(lastChar);
  bool get endsWithNumber =>
      lastChar == null ? false : numbers.contains(lastChar);

  bool get startsWithSymbol =>
      firstChar == null ? false : !alphanumeric.contains(firstChar);
  bool get startsWithNumber =>
      firstChar == null ? false : numbers.contains(firstChar);

  bool containsSymbol([List<String>? exceptions]) {
    for (int i = 0; i < length; i++) {
      final char = this[i];
      return (exceptions == null || (!exceptions.contains(char))) &&
          !alphanumeric.contains(char);
    }
    return false;
  }

  bool isOnlyNumber() {
    for (int i = 0; i < length; i++) {
      final char = this[i];
      if (!numbers.contains(char)) {
        return false;
      }
    }
    return true;
  }

  bool isValidEmail() {
    final email_pattern = RegExp("^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@" +
        "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})\$");
    return email_pattern.hasMatch(this);
  }

  bool greaterThan(String second) {
    if (length == 0 || second.length == 0) return false;
    List<String> alphabetsList = alphabets;
    String first_char = "";
    String second_char = "";
    for (int i = 0; i < second.length; i++) {
      first_char = this[i];
      second_char = second[i];
      if (first_char != second_char) {
        return alphabetsList.indexOf(first_char) >
            alphabetsList.indexOf(second_char);
      }
    }
    return false;
  }

  bool lessThan(String second) {
    if (length == 0 || second.length == 0) return false;
    List<String> alphabetsList = alphabets;
    String first_char = "";
    String second_char = "";
    for (int i = 0; i < second.length; i++) {
      first_char = this[i];
      second_char = second[i];
      if (first_char != second_char) {
        return alphabetsList.indexOf(first_char) <
            alphabetsList.indexOf(second_char);
      }
    }
    return false;
  }
}

extension ListExtensions<T> on List<T> {
  void sortList(dynamic Function(T) callback, bool dsc) => sort((i, j) => dsc
      ? callback(i).compareTo(callback(j))
      : callback(j).compareTo(callback(i)));

  List<T> sortedList(dynamic Function(T) callback, bool dsc) {
    List<T> list = [];
    list.addAll(this);
    list.sort((i, j) => dsc
        ? callback(i).compareTo(callback(j))
        : callback(j).compareTo(callback(i)));
    return list;
  }
}

extension DatabaseReferenceExtension<T> on DatabaseReference {
  Query getQuery(List<dynamic>? where, List<dynamic>? order,
      List<dynamic>? start, List<dynamic>? end, List<dynamic>? limit) {
    Query query = this;
    if (where != null) {
      int times = (where.length / 3).floor();
      for (int i = 0; i < times; i++) {
        final j = i * 3;
        String name = where[j + 0];
        String clause = where[j + 1];
        dynamic value = where[j + 2];
        if (clause == "==") {
          query = query.equalTo(value);
        }
        // if (clause == "!="){
        //   query = query.equalTo(value);
        // }
        // query = query.where(
        //   name,
        //   isEqualTo: clause == "==" ? value : null,
        //   isNotEqualTo: clause == "!=" ? value : null,
        //   isLessThan: clause == "<" ? value : null,
        //   isGreaterThan: clause == ">" ? value : null,
        //   isLessThanOrEqualTo: clause == "<=" ? value : null,
        //   isGreaterThanOrEqualTo: clause == ">=" ? value : null,
        //   whereIn: clause == "in" ? value : null,
        //   whereNotIn: clause == "notin" ? value : null,
        //   arrayContains: clause == "contains" ? value : null,
        //   arrayContainsAny: clause == "containsany" ? value : null,
        //   isNull: clause == "null" ? value : null,
        // );
      }
    }
    if (order != null) {
      String orderName = order[0];
      bool desc = order[1] ?? false;
      query = query.orderByChild(orderName);
    }
    if (start != null) {
      dynamic startName = start[0];
      bool after = start[1] ?? false;
      query =
          after ? query.startAfter([startName]) : query.startAt([startName]);
    }
    if (end != null) {
      dynamic endName = end[0];
      bool before = end[1] ?? false;
      query = before ? query.endBefore([endName]) : query.endAt([endName]);
    }
    if (limit != null) {
      int limitCount = limit[0];
      bool last = limit[1] ?? false;
      query =
          last ? query.limitToLast(limitCount) : query.limitToFirst(limitCount);
    }
    return query;
  }
}

extension DatabaseEventExtension<T> on DatabaseEvent {
  T? getValue<T>(T Function(Map<String, dynamic> map) callback) =>
      snapshot.map != null ? callback(snapshot.map!) : null;

  List<T> getValues<T>(T Function(Map<String, dynamic> map) callback) =>
      snapshot.children.length > 0
          ? snapshot.children.map((value) => callback(value.map!)).toList()
          : [];
}

extension MapExtension on Map {
  Map<String, dynamic> toStringMap() => cast<String, dynamic>();
}

extension DataSnapshotExtension<T> on DataSnapshot {
  Map<String, dynamic>? get map =>
      value != null ? (value as Map).toStringMap() : null;
  T? getValue<T>(T Function(Map<String, dynamic> map) callback) =>
      map != null ? callback(map!) : null;

  List<T> getValues<T>(T Function(Map<String, dynamic> map) callback) =>
      children.length > 0
          ? children.map((value) => callback(value.map!)).toList()
          : [];
}
