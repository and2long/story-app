import 'package:dio/dio.dart';
import 'package:flutter_ytlog/log.dart';
import 'package:story/utils/toast_util.dart';

const String _tag = 'HandleError';
void handleError(Object e, {StackTrace? stackTrace}) {
  Log.e(_tag, e);
  Log.e(_tag, stackTrace);
  if (e is DioException) {
    if (e.response?.statusCode == 400) {
      final errorMessage = e.response?.data['error'];
      if (errorMessage != null) {
        ToastUtil.show(errorMessage);
        return;
      }
    }
  }
  ToastUtil.show(e.toString());
}
