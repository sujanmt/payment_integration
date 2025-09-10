## PayPal Integration for Flutter

Seamless PayPal payments for Flutter. Create orders, capture, refund, and use a ready-made PayPal button. Works with sandbox and live environments.

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
  paypal_integration: ^0.0.1
```

### Quick Start
```dart
import 'package:paypal_integration/paypal_integration.dart';

Future<void> main() async {
  // Initialize once, e.g., in your app startup
  await PayPalIntegration.initialize(
    clientId: 'YOUR_CLIENT_ID',
    secretKey: 'YOUR_SECRET_KEY',
    environment: PayPalEnvironment.sandbox,
  );
}

// Create an order
final order = await PayPalIntegration.createPayment(
  amount: 19.99,
  currency: 'USD',
  description: 'Sample purchase',
);

// Capture after buyer approval (using returned order ID)
final captured = await PayPalIntegration.executePayment(
  paymentId: order['id'],
);

// Refund
final refund = await PayPalIntegration.refund(
  captureId: captured['purchase_units'][0]['payments']['captures'][0]['id'],
  amount: 19.99,
  currency: 'USD',
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
final order = await PayPalIntegration.createPayment(
  amount: 99.99,
  currency: 'USD',
  description: 'Product description',
);

// Execute/capture payment
final captured = await PayPalIntegration.executePayment(
  paymentId: order['id'],
);

// Refund payment
final refund = await PayPalIntegration.refund(
  captureId: 'capture_id',
  amount: 99.99, // optional: partial refund
  currency: 'USD',
);

// Void authorized payment
final voided = await PayPalIntegration.voidPayment(
  authorizationId: 'auth_id',
);

// Get payment details
final details = await PayPalIntegration.getPaymentDetails(
  paymentId: order['id'],
);

// Get transaction history
final transactions = await PayPalIntegration.getTransactionHistory(
  pageSize: 20,
  startTime: '2024-01-01T00:00:00Z', // optional
  endTime: '2024-12-31T23:59:59Z',   // optional
);
```

### UI Components

#### PayPalButton
```dart
PayPalButton(
  amount: 49.99,
  currency: 'USD',
  description: 'Pro subscription',
  onCreated: (order) {
    // Handle order creation
  },
  onApproveLink: (url) {
    // Open approval URL in WebView or browser
  },
  onError: (e) {
    // Handle errors
  },
)
```

#### PayPalWebviewCheckout
```dart
final result = await Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => PayPalWebviewCheckout(
      approvalUrl: approveUrl,
      returnUrlPrefix: 'myapp://success',   // optional
      cancelUrlPrefix: 'myapp://cancel',    // optional
    ),
  ),
);

if (result is Map) {
  switch (result['status']) {
    case 'approved':
      // Handle approval
      break;
    case 'canceled':
      // Handle cancellation
      break;
  }
}
```

### Complete Payment Flow
```dart
// 1. Create order
final order = await PayPalIntegration.createPayment(
  amount: 29.99,
  currency: 'USD',
  description: 'Premium feature',
);

// 2. Extract approval URL
final links = (order['links'] as List).cast<Map<String, dynamic>>();
final approveUrl = links.firstWhere((e) => e['rel'] == 'approve')['href'] as String;

// 3. Launch approval (WebView or browser)
final result = await Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => PayPalWebviewCheckout(
      approvalUrl: approveUrl,
      returnUrlPrefix: 'myapp://return',
      cancelUrlPrefix: 'myapp://cancel',
    ),
  ),
);

// 4. Capture payment on approval
if (result is Map && result['status'] == 'approved') {
  final captured = await PayPalIntegration.executePayment(
    paymentId: order['id'],
  );
  // Handle successful payment
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
