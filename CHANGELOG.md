# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2024-12-19

### Added
- Initial release of PayPal Integration package
- PayPal REST API integration (Orders v2, Payments v1)
- Environment configuration (sandbox/live)
- OAuth token management with automatic refresh
- Core payment operations:
  - Create payment orders
  - Execute/capture payments
  - Process refunds
  - Void authorized payments
  - Get payment details
  - Retrieve transaction history
- Pre-built UI components:
  - PayPalButton widget
  - PayPalWebviewCheckout for approval flow
- Cross-platform support (Android 5.0+, iOS 11.0+)
- Comprehensive error handling
- Example application with usage demonstrations
- Unit tests for core functionality
- Documentation and contributing guidelines

### Technical Details
- Flutter 3.0.0+ compatibility
- Dio HTTP client with logging
- Singleton pattern for configuration
- Async/await patterns throughout
- SOLID principles implementation
- Minimal third-party dependencies

### Dependencies
- dio: HTTP client
- webview_flutter: In-app checkout
- connectivity_plus: Network detection
- pretty_dio_logger: Request logging
