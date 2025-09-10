import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'api/request.dart';
import 'api/request_client.dart';
import 'shared/singletons/baseurl_singleton.dart';

export 'ui/paypal_button.dart';
export 'ui/webview_checkout.dart';

/// PayPal environments.
enum PayPalEnvironment { sandbox, live }

/// Configuration used to initialize the PayPal client.
class PayPalConfig {
  PayPalConfig({
    required this.clientId,
    required this.secretKey,
    required this.environment,
  });

  final String clientId;
  final String secretKey;
  final PayPalEnvironment environment;
}

/// Lightweight auth token holder
class PayPalAuthToken {
  PayPalAuthToken({required this.accessToken, required this.expiresIn});
  final String accessToken;
  final Duration expiresIn;
}

/// Public entrypoint for the package.
class PayPalIntegration {
  PayPalIntegration._();

  static PayPalConfig? _config;
  static PayPalAuthToken? _token;
  static DateTime? _tokenExpiryUtc;

  /// Initialize the integration with credentials and environment.
  static Future<void> initialize({
    required String clientId,
    required String secretKey,
    required PayPalEnvironment environment,
  }) async {
    _config = PayPalConfig(
      clientId: clientId,
      secretKey: secretKey,
      environment: environment,
    );

    // Set base URL for RequestClient
    final baseUrl = environment == PayPalEnvironment.sandbox
        ? 'https://api-m.sandbox.paypal.com'
        : 'https://api-m.paypal.com';
    BaseURL.getInstance.setBaseUrl(baseUrl);
  }

  /// Create a payment (order) using PayPal Orders v2 API.
  static Future<Map<String, dynamic>> createPayment({
    required double amount,
    required String currency,
    String? description,
  }) async {
    final accessToken = await _getAccessToken();
    final headers = await Request.createAuthHeader(accessToken);
    final body = {
      'intent': 'CAPTURE',
      'purchase_units': [
        {
          'amount': {
            'currency_code': currency,
            'value': amount.toStringAsFixed(2),
          },
          if (description != null) 'description': description,
        }
      ],
      'application_context': {
        'shipping_preference': 'NO_SHIPPING',
        'user_action': 'PAY_NOW',
      }
    };

    final response = await RequestClient().post(
      '/v2/checkout/orders',
      headers,
      data: body,
    );

    if (response is Response) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception('Network error');
  }

  /// Capture/Execute a payment given orderId (payer approval id not required for server-side capture).
  static Future<Map<String, dynamic>> executePayment({
    required String paymentId,
  }) async {
    final accessToken = await _getAccessToken();
    final headers = await Request.createAuthHeader(accessToken);

    final response = await RequestClient().post(
      '/v2/checkout/orders/$paymentId/capture',
      headers,
    );

    if (response is Response) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception('Network error');
  }

  /// Refund a captured payment.
  static Future<Map<String, dynamic>> refund({
    required String captureId,
    double? amount,
    String? currency,
  }) async {
    final accessToken = await _getAccessToken();
    final headers = await Request.createAuthHeader(accessToken);
    final body = (amount != null && currency != null)
        ? {
            'amount': {
              'value': amount.toStringAsFixed(2),
              'currency_code': currency,
            }
          }
        : null;

    final response = await RequestClient().post(
      '/v2/payments/captures/$captureId/refund',
      headers,
      data: body,
    );

    if (response is Response) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception('Network error');
  }

  /// Get order details
  static Future<Map<String, dynamic>> getPaymentDetails({
    required String paymentId,
  }) async {
    final accessToken = await _getAccessToken();
    final headers = await Request.createAuthHeader(accessToken);

    final response = await RequestClient().get(
      '/v2/checkout/orders/$paymentId',
      headers,
    );

    if (response is Response) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception('Network error');
  }

  /// Void an authorized payment
  static Future<Map<String, dynamic>> voidPayment({
    required String authorizationId,
  }) async {
    final accessToken = await _getAccessToken();
    final headers = await Request.createAuthHeader(accessToken);

    final response = await RequestClient().post(
      '/v2/payments/authorizations/$authorizationId/void',
      headers,
    );

    if (response is Response) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception('Network error');
  }

  /// Get transaction history (simplified - last 20 transactions)
  static Future<List<Map<String, dynamic>>> getTransactionHistory({
    int? pageSize = 20,
    String? startTime,
    String? endTime,
  }) async {
    final accessToken = await _getAccessToken();
    final headers = await Request.createAuthHeader(accessToken);
    
    final queryParams = <String, dynamic>{
      'page_size': pageSize,
      'fields': 'all',
    };
    
    if (startTime != null) queryParams['start_time'] = startTime;
    if (endTime != null) queryParams['end_time'] = endTime;

    final response = await RequestClient().get(
      '/v1/reporting/transactions',
      headers,
      queryParameters: queryParams,
    );

    if (response is Response) {
      final data = response.data as Map<String, dynamic>;
      return (data['transaction_details'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    }
    throw Exception('Network error');
  }

  static Future<String> _getAccessToken() async {
    if (_config == null) {
      throw StateError('PayPalIntegration not initialized');
    }
    final now = DateTime.now().toUtc();
    if (_token != null && _tokenExpiryUtc != null && now.isBefore(_tokenExpiryUtc!)) {
      return _token!.accessToken;
    }

    // OAuth token request
    final basicAuth = _basicAuth(_config!.clientId, _config!.secretKey);
    final headers = await Request.createHeader();
    headers['Authorization'] = 'Basic $basicAuth';
    headers['Content-Type'] = 'application/x-www-form-urlencoded';

    final response = await RequestClient().post(
      '/v1/oauth2/token',
      headers,
      data: Request.urlEncodeForFormData({'grant_type': 'client_credentials'}),
    );

    if (response is Response) {
      final data = response.data as Map<String, dynamic>;
      final accessToken = data['access_token'] as String;
      final expiresInSeconds = (data['expires_in'] as num?)?.toInt() ?? 3000;
      _token = PayPalAuthToken(
        accessToken: accessToken,
        expiresIn: Duration(seconds: expiresInSeconds),
      );
      _tokenExpiryUtc = DateTime.now().toUtc().add(_token!.expiresIn);
      return accessToken;
    }
    throw Exception('Failed to obtain access token');
  }

  static String _basicAuth(String username, String password) {
    final credentials = '$username:$password';
    final encoded = base64Encode(utf8.encode(credentials));
    return encoded;
  }
}
