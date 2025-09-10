# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.2] - 2025-09-10

### Added
- GitHub repository links in pubspec.yaml
- Enhanced README.md with proper badges and documentation
- Updated API examples to match actual implementation
- Added proper error handling examples
- Improved package metadata for pub.dev publication

### Changed
- Updated version from 0.0.1 to 0.0.2
- Fixed API method names in documentation
- Updated payment flow examples to use correct return types
- Enhanced PayPalButton usage examples

### Fixed
- Corrected method signatures in documentation
- Fixed parameter names (paymentId → orderId)
- Updated return type handling in examples

## [0.0.1] - 2025-09-09

### Added
- Initial release of PayPal Integration package
- PayPal REST API integration (Orders v2)
- Environment configuration (sandbox/production)
- OAuth token management with automatic refresh
- Core payment operations:
  - Create payment orders
  - Execute/capture payments
  - Process refunds
  - Get payment details
- Pre-built UI components:
  - PayPalButton widget
  - PayPalWebCheckoutPage for approval flow
- Cross-platform support (Android 5.0+, iOS 11.0+)
- Comprehensive error handling
- Example application with usage demonstrations
- Unit tests for core functionality
- Documentation and contributing guidelines
- MIT License
- Code of Conduct and Contributing guidelines

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
- data_connection_checker_tv: Connection validation
- pretty_dio_logger: Request logging
