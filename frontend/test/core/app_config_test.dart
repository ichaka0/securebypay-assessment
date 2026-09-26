import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/config/app_config.dart';

void main() {
  group('AppConfig.normaliseApiUrl', () {
    const host = 'https://securebypay-assessment-wf1p.onrender.com';

    test('adds the /api prefix to a bare host', () {
      expect(AppConfig.normaliseApiUrl(host), '$host/api');
      expect(AppConfig.normaliseApiUrl('$host/'), '$host/api');
    });

    test('keeps a URL that already ends in /api', () {
      expect(AppConfig.normaliseApiUrl('$host/api'), '$host/api');
      expect(AppConfig.normaliseApiUrl('$host/api/'), '$host/api');
    });
  });
}
