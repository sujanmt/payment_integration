import 'package:flutter/material.dart';
import 'package:paypal_integration/paypal_integration.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize PayPal (replace with your credentials)
  try {
    await PayPalIntegration.initialize(
      clientId: 'YOUR_CLIENT_ID',
      secretKey: 'YOUR_SECRET_KEY',
      environment: PayPalEnvironment.sandbox,
    );
  } catch (e) {
    debugPrint('PayPal initialization failed: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PayPal Integration Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PayPalDemoScreen(),
    );
  }
}

class PayPalDemoScreen extends StatefulWidget {
  const PayPalDemoScreen({super.key});

  @override
  State<PayPalDemoScreen> createState() => _PayPalDemoScreenState();
}

class _PayPalDemoScreenState extends State<PayPalDemoScreen> {
  String? _lastOrderId;
  String? _lastCaptureId;
  String? _lastStatus;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayPal Integration Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Basic PayPal Button
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic PayPal Button',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    PayPalButton(
                      amount: 9.99,
                      currency: 'USD',
                      description: 'Demo purchase',
                      onCreated: (order) {
                        setState(() {
                          _lastOrderId = order['id'] as String?;
                          _lastStatus = 'Order created';
                        });
                        _showSnackBar('Order created: ${order['id']}');
                      },
                      onApproveLink: (url) {
                        _launchPayPalApproval(url);
                      },
                      onError: (e) {
                        _showSnackBar('Error: $e');
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Manual Payment Flow
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manual Payment Flow',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _createOrder,
                            child: const Text('Create Order'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading || _lastOrderId == null 
                                ? null : _captureOrder,
                            child: const Text('Capture'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Transaction History
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction History',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _getTransactionHistory,
                      child: const Text('Get Recent Transactions'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Status Display
            if (_lastStatus != null)
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Operation Status',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(_lastStatus!),
                      if (_lastOrderId != null) ...[
                        const SizedBox(height: 4),
                        Text('Order ID: $_lastOrderId', 
                             style: const TextStyle(fontFamily: 'monospace')),
                      ],
                      if (_lastCaptureId != null) ...[
                        const SizedBox(height: 4),
                        Text('Capture ID: $_lastCaptureId', 
                             style: const TextStyle(fontFamily: 'monospace')),
                      ],
                    ],
                  ),
                ),
              ),
            
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _createOrder() async {
    setState(() => _isLoading = true);
    try {
      final order = await PayPalIntegration.createPayment(
        amount: 19.99,
        currency: 'USD',
        description: 'Manual order creation',
      );
      
      setState(() {
        _lastOrderId = order['id'] as String?;
        _lastStatus = 'Order created successfully';
      });
      
      _showSnackBar('Order created: ${order['id']}');
      
      // Show approval dialog
      final shouldApprove = await _showApprovalDialog();
      if (shouldApprove == true) {
        await _launchPayPalApproval(
          (order['links'] as List).cast<Map<String, dynamic>>()
              .firstWhere((e) => e['rel'] == 'approve')['href'] as String
        );
      }
    } catch (e) {
      _showSnackBar('Error creating order: $e');
      setState(() => _lastStatus = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _captureOrder() async {
    if (_lastOrderId == null) return;
    
    setState(() => _isLoading = true);
    try {
      final captured = await PayPalIntegration.executePayment(
        paymentId: _lastOrderId!,
      );
      
      setState(() {
        _lastCaptureId = captured['purchase_units'][0]['payments']['captures'][0]['id'] as String?;
        _lastStatus = 'Payment captured successfully';
      });
      
      _showSnackBar('Payment captured: ${captured['status']}');
    } catch (e) {
      _showSnackBar('Error capturing payment: $e');
      setState(() => _lastStatus = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getTransactionHistory() async {
    setState(() => _isLoading = true);
    try {
      final transactions = await PayPalIntegration.getTransactionHistory(
        pageSize: 5,
      );
      
      setState(() {
        _lastStatus = 'Found ${transactions.length} transactions';
      });
      
      _showSnackBar('Retrieved ${transactions.length} transactions');
    } catch (e) {
      _showSnackBar('Error getting transactions: $e');
      setState(() => _lastStatus = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _launchPayPalApproval(String url) async {
    try {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.inAppBrowserView,
      );
    } catch (e) {
      _showSnackBar('Error launching PayPal: $e');
    }
  }

  Future<bool?> _showApprovalDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Created'),
        content: const Text('Would you like to approve this order now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Approve Now'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}


