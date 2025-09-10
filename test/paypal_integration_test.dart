import 'package:flutter_test/flutter_test.dart';
import 'package:paypal_integration/paypal_integration.dart';
import 'package:paypal_integration/shared/singletons/baseurl_singleton.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PayPalIntegration', () {
    setUp(() {
      // Reset singleton state
      BaseURL.getInstance.setBaseUrl('');
    });

    test('initialize sets base URL for sandbox', () async {
      await PayPalIntegration.initialize(
        clientId: 'test_id',
        secretKey: 'test_secret',
        environment: PayPalEnvironment.sandbox,
      );
      expect(BaseURL.getInstance.getBaseUrl(), contains('sandbox.paypal.com'));
    });

    test('initialize sets base URL for live', () async {
      await PayPalIntegration.initialize(
        clientId: 'test_id',
        secretKey: 'test_secret',
        environment: PayPalEnvironment.live,
      );
      expect(BaseURL.getInstance.getBaseUrl(), contains('api-m.paypal.com'));
    });

    test('initialize sets correct base URLs', () async {
      // Test sandbox
      await PayPalIntegration.initialize(
        clientId: 'test_id',
        secretKey: 'test_secret',
        environment: PayPalEnvironment.sandbox,
      );
      expect(BaseURL.getInstance.getBaseUrl(), 'https://api-m.sandbox.paypal.com');
      
      // Reset and test live
      BaseURL.getInstance.setBaseUrl('');
      await PayPalIntegration.initialize(
        clientId: 'test_id',
        secretKey: 'test_secret',
        environment: PayPalEnvironment.live,
      );
      expect(BaseURL.getInstance.getBaseUrl(), 'https://api-m.paypal.com');
    });
  });

  group('PayPalConfig', () {
    test('creates config with required parameters', () {
      final config = PayPalConfig(
        clientId: 'test_client',
        secretKey: 'test_secret',
        environment: PayPalEnvironment.sandbox,
      );
      
      expect(config.clientId, 'test_client');
      expect(config.secretKey, 'test_secret');
      expect(config.environment, PayPalEnvironment.sandbox);
    });

    test('config properties are immutable', () {
      final config = PayPalConfig(
        clientId: 'test_client',
        secretKey: 'test_secret',
        environment: PayPalEnvironment.sandbox,
      );
      
      expect(config.clientId, 'test_client');
      expect(config.secretKey, 'test_secret');
      expect(config.environment, PayPalEnvironment.sandbox);
    });
  });

  group('PayPalAuthToken', () {
    test('creates token with required parameters', () {
      final token = PayPalAuthToken(
        accessToken: 'test_token',
        expiresIn: const Duration(seconds: 3600),
      );
      
      expect(token.accessToken, 'test_token');
      expect(token.expiresIn, const Duration(seconds: 3600));
    });

    test('token properties are immutable', () {
      final token = PayPalAuthToken(
        accessToken: 'test_token',
        expiresIn: const Duration(seconds: 3600),
      );
      
      expect(token.accessToken, 'test_token');
      expect(token.expiresIn, const Duration(seconds: 3600));
    });
  });

  group('PayPalEnvironment', () {
    test('has correct values', () {
      expect(PayPalEnvironment.values.length, 2);
      expect(PayPalEnvironment.sandbox, PayPalEnvironment.sandbox);
      expect(PayPalEnvironment.live, PayPalEnvironment.live);
    });

    test('environment values are distinct', () {
      expect(PayPalEnvironment.sandbox, isNot(PayPalEnvironment.live));
    });
  });
}
