import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ConstantsKeyCache {
  ConstantsKeyCache._internal();

  static const String keyIsFirst = 'key_is_first';
  static const String keyLanguageCode = 'key_language_code';
  static const String keyVoiceType = 'key_voice_type';
  static const String keyAccessToken = 'key_access_token';
  static const String keyTokenType = 'key_token_type';
  static const String keyRefreshToken = 'key_refresh_token';
  static const String keyFCMToken = "key_fcm_token";
  static const String keyUser = "key_user";
}

class ConstantsHttp {
  ConstantsHttp._();

  static const String baseUrl =
      kDebugMode ? 'http://localhost:5000' : 'https://story.and2long.tech';
  static const String categories = '/api/categories';
  static const String stories = '/api/stories';
}

const appBarHeight = kToolbarHeight;
const tileHeight = 55.0;
