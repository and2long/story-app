import 'package:dio/dio.dart';
import 'package:story/core/event_bus.dart';
import 'package:story/enums.dart';

class AuthInterceptor extends Interceptor {
  static bool isRefreshing = false;
  static List<Map<String, dynamic>> requestList = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent("X-API-Key", () => 'UjMJWmaEC3RQBVZBAC');
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      EventBus().fire(AuthEvent.unauthenticated);
    }
    super.onError(err, handler);
  }
}
