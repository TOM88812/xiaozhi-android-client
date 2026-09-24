import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// Settings screen title
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// General settings tab
  ///
  /// In zh, this message translates to:
  /// **'通用'**
  String get general;

  /// Dark mode toggle
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get darkMode;

  /// Add configuration button
  ///
  /// In zh, this message translates to:
  /// **'添加配置'**
  String get addConfig;

  /// Dify tab label
  ///
  /// In zh, this message translates to:
  /// **'Dify'**
  String get dify;

  /// MiniMax tab label
  ///
  /// In zh, this message translates to:
  /// **'MiniMax'**
  String get minimax;

  /// Xiaozhi tab label
  ///
  /// In zh, this message translates to:
  /// **'小智'**
  String get xiaozhi;

  /// Cancel button
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// Confirm button
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirm;

  /// Delete button
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// Edit button
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit;

  /// Save button
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// Messages tab
  ///
  /// In zh, this message translates to:
  /// **'消息'**
  String get messages;

  /// Discover tab
  ///
  /// In zh, this message translates to:
  /// **'发现'**
  String get discover;

  /// Search conversations placeholder
  ///
  /// In zh, this message translates to:
  /// **'搜索对话'**
  String get searchConversations;

  /// Pin conversation action
  ///
  /// In zh, this message translates to:
  /// **'置顶对话'**
  String get pinConversation;

  /// All conversations label
  ///
  /// In zh, this message translates to:
  /// **'全部对话'**
  String get allConversations;

  /// No conversations empty state
  ///
  /// In zh, this message translates to:
  /// **'没有对话'**
  String get noConversations;

  /// Discovery screen title
  ///
  /// In zh, this message translates to:
  /// **'发现'**
  String get discovery;

  /// Text message type
  ///
  /// In zh, this message translates to:
  /// **'文本'**
  String get text;

  /// Voice message type
  ///
  /// In zh, this message translates to:
  /// **'语音'**
  String get voice;

  /// Yesterday label
  ///
  /// In zh, this message translates to:
  /// **'昨天'**
  String get yesterday;

  /// Language selector label
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// Empty state instruction to create new conversation
  ///
  /// In zh, this message translates to:
  /// **'点击 + 创建新对话'**
  String get createNewConversation;

  /// Deleted confirmation suffix
  ///
  /// In zh, this message translates to:
  /// **'已删除'**
  String get deleted;

  /// Undo action
  ///
  /// In zh, this message translates to:
  /// **'撤销'**
  String get undo;

  /// Unpin conversation action
  ///
  /// In zh, this message translates to:
  /// **'取消置顶'**
  String get unpinConversation;

  /// Delete conversation action
  ///
  /// In zh, this message translates to:
  /// **'删除对话'**
  String get deleteConversation;

  /// Monday
  ///
  /// In zh, this message translates to:
  /// **'一'**
  String get weekday1;

  /// Tuesday
  ///
  /// In zh, this message translates to:
  /// **'二'**
  String get weekday2;

  /// Wednesday
  ///
  /// In zh, this message translates to:
  /// **'三'**
  String get weekday3;

  /// Thursday
  ///
  /// In zh, this message translates to:
  /// **'四'**
  String get weekday4;

  /// Friday
  ///
  /// In zh, this message translates to:
  /// **'五'**
  String get weekday5;

  /// Saturday
  ///
  /// In zh, this message translates to:
  /// **'六'**
  String get weekday6;

  /// Sunday
  ///
  /// In zh, this message translates to:
  /// **'日'**
  String get weekday7;

  /// Practical tools section header
  ///
  /// In zh, this message translates to:
  /// **'实用工具'**
  String get practicalTools;

  /// Featured recommendations section header
  ///
  /// In zh, this message translates to:
  /// **'精选推荐'**
  String get featuredRecommendations;

  /// Reading assistant card title
  ///
  /// In zh, this message translates to:
  /// **'阅读助手'**
  String get readingAssistant;

  /// Reading assistant description
  ///
  /// In zh, this message translates to:
  /// **'高效理解和总结文章'**
  String get readingAssistantDesc;

  /// Translation tool card title
  ///
  /// In zh, this message translates to:
  /// **'翻译工具'**
  String get translationTool;

  /// Translation tool description
  ///
  /// In zh, this message translates to:
  /// **'多语言实时翻译'**
  String get translationToolDesc;

  /// Voice assistant card title
  ///
  /// In zh, this message translates to:
  /// **'语音助手'**
  String get voiceAssistant;

  /// Voice assistant description
  ///
  /// In zh, this message translates to:
  /// **'智能语音交互'**
  String get voiceAssistantDesc;

  /// Document parser card title
  ///
  /// In zh, this message translates to:
  /// **'文档解析'**
  String get documentParser;

  /// Document parser description
  ///
  /// In zh, this message translates to:
  /// **'智能分析文档内容'**
  String get documentParserDesc;

  /// AI writing assistant card title
  ///
  /// In zh, this message translates to:
  /// **'AI写作助手'**
  String get aiWritingAssistant;

  /// AI writing assistant description
  ///
  /// In zh, this message translates to:
  /// **'让你的文章更专业'**
  String get aiWritingAssistantDesc;

  /// Smart reminder card title
  ///
  /// In zh, this message translates to:
  /// **'智能提醒'**
  String get smartReminder;

  /// Smart reminder description
  ///
  /// In zh, this message translates to:
  /// **'不错过重要事项'**
  String get smartReminderDesc;

  /// Voice notes card title
  ///
  /// In zh, this message translates to:
  /// **'语音笔记'**
  String get voiceNotes;

  /// Voice notes description
  ///
  /// In zh, this message translates to:
  /// **'随时随地记录灵感'**
  String get voiceNotesDesc;

  /// Under development suffix for feature cards
  ///
  /// In zh, this message translates to:
  /// **'功能开发中'**
  String get underDevelopment;

  /// appearance string
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get appearance;

  /// appearanceSettingsSubtitle string
  ///
  /// In zh, this message translates to:
  /// **'调整应用的外观设置'**
  String get appearanceSettingsSubtitle;

  /// fillAllFields string
  ///
  /// In zh, this message translates to:
  /// **'请填写所有字段'**
  String get fillAllFields;

  /// difyConfigAdded string
  ///
  /// In zh, this message translates to:
  /// **'已添加Dify配置'**
  String get difyConfigAdded;

  /// addNewDifyConfig string
  ///
  /// In zh, this message translates to:
  /// **'添加新的Dify API配置'**
  String get addNewDifyConfig;

  /// editDifyConfig string
  ///
  /// In zh, this message translates to:
  /// **'编辑Dify配置'**
  String get editDifyConfig;

  /// apiAddress string
  ///
  /// In zh, this message translates to:
  /// **'API地址'**
  String get apiAddress;

  /// apiKey string
  ///
  /// In zh, this message translates to:
  /// **'API密钥'**
  String get apiKey;

  /// configName string
  ///
  /// In zh, this message translates to:
  /// **'配置名称'**
  String get configName;

  /// inputConfigName string
  ///
  /// In zh, this message translates to:
  /// **'输入配置名称'**
  String get inputConfigName;

  /// difyConfigUpdated string
  ///
  /// In zh, this message translates to:
  /// **'已更新Dify配置'**
  String get difyConfigUpdated;

  /// deleteDifyConfig string
  ///
  /// In zh, this message translates to:
  /// **'删除Dify配置'**
  String get deleteDifyConfig;

  /// confirmDeleteDify string
  ///
  /// In zh, this message translates to:
  /// **'确定要删除配置吗？这个操作不可撤销。'**
  String get confirmDeleteDify;

  /// configDeleted string
  ///
  /// In zh, this message translates to:
  /// **'已删除配置'**
  String get configDeleted;

  /// noDifyConfig string
  ///
  /// In zh, this message translates to:
  /// **'暂无Dify配置，点击右上角添加'**
  String get noDifyConfig;

  /// minimaxConfigAdded string
  ///
  /// In zh, this message translates to:
  /// **'已添加MiniMax配置'**
  String get minimaxConfigAdded;

  /// addNewMinimaxConfig string
  ///
  /// In zh, this message translates to:
  /// **'添加新的MiniMax AI配置'**
  String get addNewMinimaxConfig;

  /// editMinimaxConfig string
  ///
  /// In zh, this message translates to:
  /// **'编辑MiniMax配置'**
  String get editMinimaxConfig;

  /// minimaxConfigUpdated string
  ///
  /// In zh, this message translates to:
  /// **'已更新MiniMax配置'**
  String get minimaxConfigUpdated;

  /// deleteMinimaxConfig string
  ///
  /// In zh, this message translates to:
  /// **'删除MiniMax配置'**
  String get deleteMinimaxConfig;

  /// confirmDeleteMinimax string
  ///
  /// In zh, this message translates to:
  /// **'确定要删除配置吗？'**
  String get confirmDeleteMinimax;

  /// noMinimaxConfig string
  ///
  /// In zh, this message translates to:
  /// **'暂无MiniMax配置，点击右上角添加'**
  String get noMinimaxConfig;

  /// model string
  ///
  /// In zh, this message translates to:
  /// **'模型'**
  String get model;

  /// xiaozhiServiceConfig string
  ///
  /// In zh, this message translates to:
  /// **'小智服务配置'**
  String get xiaozhiServiceConfig;

  /// xiaozhiServiceConfigSubtitle string
  ///
  /// In zh, this message translates to:
  /// **'管理小智语音服务配置'**
  String get xiaozhiServiceConfigSubtitle;

  /// addXiaozhiService string
  ///
  /// In zh, this message translates to:
  /// **'添加小智服务'**
  String get addXiaozhiService;

  /// addNewXiaozhiServiceConfig string
  ///
  /// In zh, this message translates to:
  /// **'添加新的小智语音服务配置'**
  String get addNewXiaozhiServiceConfig;

  /// editXiaozhiService string
  ///
  /// In zh, this message translates to:
  /// **'编辑小智服务'**
  String get editXiaozhiService;

  /// modifyXiaozhiServiceConfig string
  ///
  /// In zh, this message translates to:
  /// **'修改小智语音服务配置'**
  String get modifyXiaozhiServiceConfig;

  /// serviceName string
  ///
  /// In zh, this message translates to:
  /// **'服务名称'**
  String get serviceName;

  /// inputServiceName string
  ///
  /// In zh, this message translates to:
  /// **'例如：家庭小智'**
  String get inputServiceName;

  /// websocketAddress string
  ///
  /// In zh, this message translates to:
  /// **'WebSocket地址'**
  String get websocketAddress;

  /// inputWebsocketAddress string
  ///
  /// In zh, this message translates to:
  /// **'例如：wss://example.com'**
  String get inputWebsocketAddress;

  /// macAddress string
  ///
  /// In zh, this message translates to:
  /// **'MAC地址'**
  String get macAddress;

  /// macAddressOptional string
  ///
  /// In zh, this message translates to:
  /// **'MAC地址 (可选)'**
  String get macAddressOptional;

  /// autoGenerate string
  ///
  /// In zh, this message translates to:
  /// **'留空将自动生成'**
  String get autoGenerate;

  /// autoGenerateDesc string
  ///
  /// In zh, this message translates to:
  /// **'留空将根据设备ID自动生成'**
  String get autoGenerateDesc;

  /// token string
  ///
  /// In zh, this message translates to:
  /// **'Token'**
  String get token;

  /// enabledByDefault string
  ///
  /// In zh, this message translates to:
  /// **'默认开启'**
  String get enabledByDefault;

  /// fillRequiredFields string
  ///
  /// In zh, this message translates to:
  /// **'请填写所有必填字段'**
  String get fillRequiredFields;

  /// xiaozhiServiceAdded string
  ///
  /// In zh, this message translates to:
  /// **'小智服务已添加'**
  String get xiaozhiServiceAdded;

  /// xiaozhiServiceUpdated string
  ///
  /// In zh, this message translates to:
  /// **'小智服务已更新'**
  String get xiaozhiServiceUpdated;

  /// deleteXiaozhiService string
  ///
  /// In zh, this message translates to:
  /// **'删除小智服务'**
  String get deleteXiaozhiService;

  /// confirmDeleteXiaozhi string
  ///
  /// In zh, this message translates to:
  /// **'确定要删除服务吗？'**
  String get confirmDeleteXiaozhi;

  /// xiaozhiServiceDeleted string
  ///
  /// In zh, this message translates to:
  /// **'小智服务已删除'**
  String get xiaozhiServiceDeleted;

  /// addService string
  ///
  /// In zh, this message translates to:
  /// **'添加服务'**
  String get addService;

  /// noXiaozhiService string
  ///
  /// In zh, this message translates to:
  /// **'暂无小智服务，点击右上角添加'**
  String get noXiaozhiService;

  /// unconfigured string
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get unconfigured;

  /// difyApiConfig string
  ///
  /// In zh, this message translates to:
  /// **'Dify API配置'**
  String get difyApiConfig;

  /// difyApiConfigSubtitle string
  ///
  /// In zh, this message translates to:
  /// **'配置并管理多个Dify API服务'**
  String get difyApiConfigSubtitle;

  /// minimaxAiConfig string
  ///
  /// In zh, this message translates to:
  /// **'MiniMax AI配置'**
  String get minimaxAiConfig;

  /// minimaxAiConfigSubtitle string
  ///
  /// In zh, this message translates to:
  /// **'配置并管理MiniMax API服务'**
  String get minimaxAiConfigSubtitle;

  /// Add button
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get add;

  /// addDifyConfig string
  ///
  /// In zh, this message translates to:
  /// **'添加Dify配置'**
  String get addDifyConfig;

  /// addMinimaxConfig string
  ///
  /// In zh, this message translates to:
  /// **'添加MiniMax配置'**
  String get addMinimaxConfig;

  /// Hint text for API Key input field
  ///
  /// In zh, this message translates to:
  /// **'输入API Key'**
  String get enterApiKey;

  /// Hint text for MiniMax API Key input
  ///
  /// In zh, this message translates to:
  /// **'输入MiniMax API Key'**
  String get enterMinimaxApiKey;

  /// Example WebSocket address hint
  ///
  /// In zh, this message translates to:
  /// **'例如：wss://example.com'**
  String get wsExample;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'ru':
      return SRu();
    case 'zh':
      return SZh();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
