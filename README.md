# PayPal Integration for Flutter

[![pub package](https://img.shields.io/pub/v/paypal_integration.svg)](https://pub.dev/packages/paypal_integration)
[![GitHub](https://img.shields.io/github/license/sujanmt/payment_integration)](https://github.com/sujanmt/payment_integration)

Seamless PayPal payments for Flutter. Create orders, capture, refund, and use a ready-made PayPal button. Works with sandbox and live environments.

## Repository
- **GitHub**: [https://github.com/sujanmt/payment_integration](https://github.com/sujanmt/payment_integration)
- **Issues**: [https://github.com/sujanmt/payment_integration/issues](https://github.com/sujanmt/payment_integration/issues)

### Features
- Create and capture PayPal orders (Checkout v2)
- Refund captures
- Get order details
- Void authorized payments
- Retrieve transaction history
- Configurable environments (sandbox/live)
- Prebuilt `PayPalButton` widget
- WebView-based checkout flow

### Requirements
- Flutter >= 3.0.0
- Android minSdkVersion 21
- iOS 11.0+
- PayPal REST API credentials (Client ID and Secret)

### Installation
Add to `pubspec.yaml`:
```yaml
dependencies:
  paypal_integration: ^0.0.2
```

### Quick Start
```dart
import 'package:paypal_integration/paypal_integration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize once, e.g., in your app startup
  await PayPalIntegration.initialize(
    clientId: 'YOUR_CLIENT_ID',
    secretKey: 'YOUR_SECRET_KEY',
    environment: PayPalEnvironment.sandbox,
  );
  runApp(MyApp());
}

// Use the PayPalButton widget
PayPalButton(
  amount: 19.99,
  currency: 'USD',
  description: 'Sample purchase',
  returnUrl: 'myapp://paypal/return',
  cancelUrl: 'myapp://paypal/cancel',
  onResult: (result) {
    if (result.success) {
      print('Payment successful: ${result.orderId}');
    } else {
      print('Payment failed: ${result.message}');
    }
  },
);
```

### API Reference

#### Initialization
```dart
await PayPalIntegration.initialize(
  clientId: 'YOUR_CLIENT_ID',
  secretKey: 'YOUR_SECRET_KEY',
  environment: PayPalEnvironment.sandbox, // or .live
);
```

#### Payment Operations
```dart
// Create payment order
final payment = await PayPalIntegration.createPayment(
  amount: 99.99,
  currency: 'USD',
  description: 'Product description',
  returnUrl: 'myapp://paypal/return',
  cancelUrl: 'myapp://paypal/cancel',
);

// Execute/capture payment
final result = await PayPalIntegration.executePayment(
  orderId: payment.id,
);

// Refund payment
final refund = await PayPalIntegration.refund(
  captureId: 'capture_id',
  amount: 99.99, // optional: partial refund
  currency: 'USD',
);

// Get payment details
final details = await PayPalIntegration.getPaymentDetails(
  orderId: payment.id,
);

// Start web checkout flow
final checkoutResult = await PayPalIntegration.startWebCheckout(
  context: context,
  amount: 99.99,
  currency: 'USD',
  description: 'Product description',
  returnUrl: 'myapp://paypal/return',
  cancelUrl: 'myapp://paypal/cancel',
);
```

### UI Components

#### PayPalButton
```dart
PayPalButton(
  amount: 49.99,
  currency: 'USD',
  description: 'Pro subscription',
  returnUrl: 'myapp://paypal/return',
  cancelUrl: 'myapp://paypal/cancel',
  onResult: (result) {
    if (result.success) {
      print('Payment successful: ${result.orderId}');
      print('Capture ID: ${result.captureId}');
    } else {
      print('Payment failed: ${result.message}');
    }
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  ),
  child: Text('Pay with PayPal'),
)
```

### Complete Payment Flow
```dart
// 1. Create order
final payment = await PayPalIntegration.createPayment(
  amount: 29.99,
  currency: 'USD',
  description: 'Premium feature',
  returnUrl: 'myapp://paypal/return',
  cancelUrl: 'myapp://paypal/cancel',
);

// 2. Start web checkout (handles approval and capture automatically)
final result = await PayPalIntegration.startWebCheckout(
  context: context,
  amount: 29.99,
  currency: 'USD',
  description: 'Premium feature',
  returnUrl: 'myapp://paypal/return',
  cancelUrl: 'myapp://paypal/cancel',
);

// 3. Handle result
if (result.success) {
  print('Payment successful!');
  print('Order ID: ${result.orderId}');
  print('Capture ID: ${result.captureId}');
} else {
  print('Payment failed: ${result.message}');
}
```

### Troubleshooting

#### Common Issues

**Initialization Errors**
- Ensure you have valid PayPal API credentials
- Check that your app has internet permissions
- Verify environment setting (sandbox vs live)

**Payment Creation Fails**
- Validate amount format (use decimal, not integer)
- Ensure currency code is supported (USD, EUR, etc.)
- Check that description is not empty

**Capture Fails**
- Order must be in 'APPROVED' state
- Order ID must be valid and not expired
- Ensure you're using the correct order ID

**Network Errors**
- Check internet connectivity
- Verify PayPal API endpoints are accessible
- Check firewall/proxy settings

#### Error Handling
```dart
try {
  final order = await PayPalIntegration.createPayment(
    amount: 19.99,
    currency: 'USD',
  );
} catch (e) {
  if (e is StateError) {
    // PayPal not initialized
  } else if (e.toString().contains('Network error')) {
    // Network connectivity issue
  } else {
    // Other error (API response, validation, etc.)
  }
}
```

#### Debug Mode
Enable detailed logging by setting environment variables:
```dart
// Add to your app initialization
if (kDebugMode) {
  // Dio logger is already configured for detailed request/response logging
}
```

### Platform Configuration

#### Android
Add to `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

#### iOS
Add to `ios/Podfile`:
```ruby
platform :ios, '11.0'
```

### Security Notes
- Never commit API credentials to version control
- Use environment variables or secure storage
- Implement proper error handling in production
- Validate all user inputs before API calls

### License
See `LICENSE`.

### Contributing
See `CONTRIBUTING.md`.

### Code of Conduct
See `CODE_OF_CONDUCT.md`.
