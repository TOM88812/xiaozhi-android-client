import 'package:ai_assistant/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Malay resource translates UI strings and interpolated labels', () async {
    final localizations = await const AppLocalizationsDelegate().load(
      const Locale('ms', 'MY'),
    );

    expect(localizations.translate('消息'), 'Mesej');
    expect(
      localizations.translate('与 Xiaozhi 的对话'),
      'Perbualan dengan Xiaozhi',
    );
    expect(
      localizations.translate('与 消息 的对话'),
      'Perbualan dengan 消息',
    );
    expect(localizations.translate('周一'), 'Isnin');
  });

  test('other locales retain their existing text', () async {
    final localizations = await const AppLocalizationsDelegate().load(
      const Locale('zh', 'CN'),
    );

    expect(localizations.translate('消息'), '消息');
  });
}
