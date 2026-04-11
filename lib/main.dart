import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:ai_assistant/providers/theme_provider.dart';
import 'package:ai_assistant/providers/config_provider.dart';
import 'package:ai_assistant/providers/conversation_provider.dart';
import 'package:ai_assistant/screens/home_screen.dart';
import 'package:ai_assistant/screens/settings_screen.dart';
import 'package:ai_assistant/screens/test_screen.dart';
import 'package:ai_assistant/utils/app_theme.dart';
import 'package:opus_flutter/opus_flutter.dart' as opus_flutter;
import 'package:opus_dart/opus_dart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:ui';
import 'package:ai_assistant/utils/audio_util.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

// 是否启用调试工具
const bool enableDebugTools = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置全局沉浸式导航栏
  await _setupSystemUI();

  // 设置状态栏颜色变化监听器，确保状态栏样式始终如一
  SystemChannels.lifecycle.setMessageHandler((msg) async {
    if (msg == AppLifecycleState.resumed.toString()) {
      // 应用回到前台时重新应用系统UI设置
      await _setupSystemUI();
    }
    return null;
  });

  // 设置高性能渲染
  if (Platform.isAndroid || Platform.isIOS) {
    // 启用SkSL预热，提高首次渲染性能
    await Future.delayed(const Duration(milliseconds: 50));
    PaintingBinding.instance.imageCache.maximumSize = 1000;
    // 增加图像缓存容量
    PaintingBinding.instance.imageCache.maximumSizeBytes =
        100 * 1024 * 1024; // 100 MB
  }

  // 请求录音和存储权限 (macOS不适用permission_handler)
  if (!Platform.isMacOS) {
    await [
      Permission.microphone,
      Permission.storage,
      if (Platform.isAndroid) Permission.bluetoothConnect,
    ].request();
  }

  // 添加中文本地化支持
  timeago.setLocaleMessages('zh', timeago.ZhMessages());
  timeago.setDefaultLocale('zh');

  // 在Android上设置高刷新率
  if (Platform.isAndroid) {
    try {
      // 获取所有支持的显示模式
      final modes = await FlutterDisplayMode.supported;
      print('支持的显示模式: ${modes.length}');
      modes.forEach((mode) => print('模式: $mode'));

      // 获取当前活跃的模式
      final current = await FlutterDisplayMode.active;
      print('当前模式: $current');

      // 设置为高刷新率模式
      await FlutterDisplayMode.setHighRefreshRate();

      // 确认设置成功
      final afterSet = await FlutterDisplayMode.active;
      print('设置后模式: $afterSet');
    } catch (e) {
      print('设置高刷新率失败: $e');
    }
  }

  // 初始化Opus库
  try {
    initOpus(await opus_flutter.load());
    print('Opus初始化成功: ${getOpusVersion()}');
  } catch (e) {
    print('Opus初始化失败: $e');
  }

  // 初始化录音和播放器
  try {
    await AudioUtil.initRecorder();
    await AudioUtil.initPlayer();
    print('音频系统初始化成功');
  } catch (e) {
    print('音频系统初始化失败: $e');
  }

  // 初始化配置管理
  final configProvider = ConfigProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: configProvider),
        ChangeNotifierProvider(create: (_) => ConversationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// 设置系统UI沉浸式效果
Future<void> _setupSystemUI() async {
  // 设置状态栏和导航栏透明
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  if (Platform.isAndroid) {
    // 启用边缘到边缘显示模式，实现真正的全面屏效果
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  } else if (Platform.isIOS) {
    // iOS上设置为全屏显示但保留状态栏
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'AI-LHHT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const HomeScreen(),
      routes: {
        // 添加测试界面路由
        '/test': (context) => const TestScreen(),
      },
      // 添加平滑滚动设置
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        // 启用物理滚动
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        // 确保所有平台都有滚动条和弹性效果
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
    );
  }
}
