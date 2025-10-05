import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

extension BlocBaseExtension<T> on BlocBase<T> {
  void maybeEmit(T state) {
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    if (!isClosed) emit(state);
  }
}

extension DateTimeExtensions on DateTime {
  String formatStyle1() {
    return DateFormat('yyyy-MM-dd HH:mm').format(this);
  }

  String formatStyle2() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(this);
  }

  String formatStyle3() {
    return DateFormat('yyyy.MM.dd').format(this);
  }
}

extension StringExt on String {
  String get capitalized => toBeginningOfSentenceCase(this) ?? "";

  Color hexToColor({double opacity = 1.0}) {
    var rgb = int.parse(substring(1, 7), radix: 16);
    var r1 = (rgb & 0xFF0000) >> 16;
    var g1 = (rgb & 0x00FF00) >> 8;
    var b1 = (rgb & 0x0000FF) >> 0;
    return Color.fromRGBO(r1, g1, b1, opacity);
  }

  DateTime toDateTime() {
    return DateTime.parse(this).toLocal();
  }
}
