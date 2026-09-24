import 'package:flutter_test/flutter_test.dart';
import 'package:ai_assistant/l10n/app_localizations.dart';
import 'package:ai_assistant/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ARB files', () {
    test('have same keys across all locales', () async {
      final zhKeys = _loadArbKeys('lib/l10n/app_zh.arb');
      final enKeys = _loadArbKeys('lib/l10n/app_en.arb');
      final ruKeys = _loadArbKeys('lib/l10n/app_ru.arb');
      
      expect(enKeys, equals(zhKeys), reason: 'English ARB missing keys present in Chinese');
      expect(ruKeys, equals(zhKeys), reason: 'Russian ARB missing keys present in Chinese');
    });
  });

  test('flutter gen-l10n succeeds', () async {
    final result = await Process.run('flutter', ['gen-l10n']);
    expect(result.exitCode, 0, reason: 'flutter gen-l10n failed: ${result.stderr}');
  });

  group('LocaleProvider', () {
    test('setLocale persists to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = LocaleProvider();
      await provider.setLocale(const Locale('en'));
      expect(provider.locale.languageCode, 'en');
      
      // Create new provider WITHOUT resetting mock - it should load the persisted value
      final newProvider = LocaleProvider();
      await newProvider.loadLocale();
      expect(newProvider.locale.languageCode, 'en');
    });

    test('loads saved locale', () async {
      // Start fresh with the saved locale
      SharedPreferences.setMockInitialValues({'app_locale': 'ru'});
      final provider = LocaleProvider();
      await provider.loadLocale();
      expect(provider.locale.languageCode, 'ru');
    });
  });

  test('Supported locales are en, zh, ru', () {
    expect(S.supportedLocales.map((l) => l.languageCode), containsAll(['en', 'zh', 'ru']));
    expect(S.supportedLocales.length, 3);
  });
}

Set<String> _loadArbKeys(String path) {
  final file = File(path);
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return json.keys.where((k) => !k.startsWith('@')).toSet();
}
