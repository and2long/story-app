import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:story/constants.dart';
import 'package:story/core/network/http.dart';

class CategoryRepo {
  Future<Response> getCategoryList() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String buildNumber = packageInfo.buildNumber;
    return XHttp.instance.get(
      ConstantsHttp.categories,
      queryParameters: {'build_number': buildNumber},
    );
  }
}
