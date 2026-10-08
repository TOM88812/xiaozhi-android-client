import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale, this._translations);

  final Locale locale;
  final Map<String, String> _translations;

  static AppLocalizations? of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  String translate(String value) {
    final exact = _translations[value];
    if (exact != null) {
      return exact;
    }

    for (final entry in _translations.entries) {
      if (!entry.key.contains(r'$')) {
        continue;
      }

      final placeholders = RegExp(r'\$\{[^}]+\}|\$[A-Za-z_]\w*');
      final patternBuffer = StringBuffer('^');
      var offset = 0;
      for (final placeholder in placeholders.allMatches(entry.key)) {
        patternBuffer
          ..write(RegExp.escape(entry.key.substring(offset, placeholder.start)))
          ..write(r'(.+?)');
        offset = placeholder.end;
      }
      patternBuffer
        ..write(RegExp.escape(entry.key.substring(offset)))
        ..write(r'$');
      final pattern = RegExp(patternBuffer.toString());
      final match = pattern.firstMatch(value);
      if (match == null) {
        continue;
      }

      var translated = entry.value;
      final sourcePlaceholders = placeholders.allMatches(entry.key);
      var index = 1;
      for (final placeholder in sourcePlaceholders) {
        final capturedValue = match.group(index)!;
        final replacement =
            entry.key == r'$title 功能开发中...'
                ? _translations[capturedValue] ?? capturedValue
                : capturedValue;
        translated = translated.replaceAll(
          placeholder.group(0)!,
          replacement,
        );
        index++;
      }
      return translated;
    }

    return value;
  }
}

extension AppLocalizationsContext on BuildContext {
  String tr(String value) =>
      AppLocalizations.of(this)?.translate(value) ?? value;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async {
    if (locale.languageCode != 'ms') {
      return SynchronousFuture(AppLocalizations(locale, const {}));
    }

    final json = await rootBundle.loadString('assets/l10n/ms_MY.json');
    final values = jsonDecode(json) as Map<String, dynamic>;
    return AppLocalizations(
      locale,
      values.map((key, value) => MapEntry(key, value as String)),
    );
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
