import 'package:flutter/material.dart';

import '../paypal_integration.dart';

typedef OnApproveLink = void Function(String approveUrl);
typedef OnCreated = void Function(Map<String, dynamic> order);
typedef OnError = void Function(Object error);

class PayPalButton extends StatefulWidget {
  const PayPalButton({
    super.key,
    required this.amount,
    required this.currency,
    this.description,
    this.onCreated,
    this.onApproveLink,
    this.onError,
    this.label,
    this.style,
    this.loadingChild,
  });

    final double amount;
    final String currency;
    final String? description;
    final OnCreated? onCreated;
    final OnApproveLink? onApproveLink;
    final OnError? onError;
    final String? label;
    final ButtonStyle? style;
    final Widget? loadingChild;

  @override
  State<PayPalButton> createState() => _PayPalButtonState();
}

class _PayPalButtonState extends State<PayPalButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: widget.style,
        onPressed: _isLoading ? null : _onPressed,
        child: _isLoading
            ? (widget.loadingChild ?? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)))
            : Text(widget.label ?? 'Pay with PayPal'),
      ),
    );
  }

  Future<void> _onPressed() async {
    setState(() => _isLoading = true);
    try {
      final order = await PayPalIntegration.createPayment(
        amount: widget.amount,
        currency: widget.currency,
        description: widget.description,
      );
      widget.onCreated?.call(order);

      final links = (order['links'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
      final approve = links.firstWhere(
        (e) => e['rel'] == 'approve',
        orElse: () => const {},
      );
      final approveUrl = approve['href'] as String?;
      if (approveUrl != null) {
        widget.onApproveLink?.call(approveUrl);
      }
    } catch (e) {
      widget.onError?.call(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}


