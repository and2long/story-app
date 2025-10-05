import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

// Toast with No Build Context (Android & iOS)
// https://pub-web.flutter-io.cn/packages/fluttertoast#toast-with-no-build-context-android--ios
class ToastUtil {
  ToastUtil._();

  static show(String? msg) {
    if (msg == null) {
      return;
    }
    SmartDialog.showToast(msg);
  }
}
