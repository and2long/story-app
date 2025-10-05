import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_ytlog/log.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:story/core/network/http.dart';
import 'package:story/i18n/i18n.dart';
import 'package:story/pages/home_page.dart';
import 'package:story/store.dart';
import 'package:story/utils/sp_util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化后台播放服务
  await JustAudioBackground.init(
    androidNotificationChannelId: 'tech.and2long.story.channel.audio',
    androidNotificationIcon: 'mipmap/ic_notification',
    androidNotificationChannelName: '儿童故事播放',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
    androidStopForegroundOnPause: true,
  );

  // 初始化应用
  Log.init(enable: kDebugMode, writeToFile: false);
  await SPUtil.init();
  XHttp.init();
  runApp(Store.init(const MyApp()));

  // 安卓透明状态栏
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );
  }
}

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        // 程序的字体大小不受系统字体大小影响
        textScaler: TextScaler.noScaling,
      ),
      child: Consumer<LocaleStore>(
        builder: (BuildContext context, LocaleStore value, Widget? child) {
          return Consumer<PlayerStore>(
            builder: (context, store, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                navigatorKey: MyApp.navigatorKey,
                onGenerateTitle: (context) => S.appName,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  // 项目本地化资源代理
                  S.delegate,
                ],
                // 支持的语言
                supportedLocales: S.supportedLocales,
                locale: Locale(value.languageCode),
                navigatorObservers: [MyRouteObserver()],
                builder: FlutterSmartDialog.init(
                  builder:
                      (context, child) => GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: child ?? const SizedBox(),
                      ),
                  loadingBuilder: (String msg) => CustomLoadingWidget(msg: msg),
                ),
                theme: ThemeData(primaryColor: store.themeColor),
                home: HomePage(),
              );
            },
          );
        },
      ),
    );
  }
}

class CustomLoadingWidget extends StatelessWidget {
  final String msg;

  const CustomLoadingWidget({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const SpinKitFadingCircle(color: Colors.white, size: 40.0),
    );
  }
}

class MyRouteObserver<R extends Route<dynamic>> extends RouteObserver<R> {
  final String _tag = 'MyRouteObserver';

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    Log.i(_tag, '⤴️ push to route: ${route.settings.name}');
    // String curPageName = route.settings.name ?? '';
    // BuildContext? context = MyApp.navigatorKey.currentContext;
    // if (context != null) {
    //   if (curPageName == (PlayerPage).toString()) {
    //     GlobalOverlay.remove();
    //   }
    //   if (curPageName == '/') {
    //     Future.delayed(Duration.zero, (){
    //       GlobalOverlay.show(context: context, view: const PlayerBottomBar());
    //     });
    //   }
    // }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    String curPageName = newRoute?.settings.name ?? '';
    Log.i(_tag, '🔂 replace to route: $curPageName');
  }

  @override
  void didPop(Route route, Route? previousRoute) async {
    super.didPop(route, previousRoute);
    String curPageName = previousRoute?.settings.name ?? '';
    Log.i(_tag, '⤵️ pop to route: $curPageName');
    // if (curPageName == (StoryListPage).toString()) {
    //   BuildContext? context = MyApp.navigatorKey.currentContext;
    //   if (context != null) {
    //     GlobalOverlay.show(context: context, view: const PlayerBottomBar());
    //   }
    // }
  }
}
