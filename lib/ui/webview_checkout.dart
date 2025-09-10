import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayPalWebviewCheckout extends StatefulWidget {
  const PayPalWebviewCheckout({
    super.key,
    required this.approvalUrl,
    this.returnUrlPrefix,
    this.cancelUrlPrefix,
  });

  final String approvalUrl;
  final String? returnUrlPrefix;
  final String? cancelUrlPrefix;

  @override
  State<PayPalWebviewCheckout> createState() => _PayPalWebviewCheckoutState();
}

class _PayPalWebviewCheckoutState extends State<PayPalWebviewCheckout> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _loading = true);
          },
          onPageFinished: (url) {
            setState(() => _loading = false);
          },
          onNavigationRequest: (request) {
            final url = request.url;
            if (widget.returnUrlPrefix != null && url.startsWith(widget.returnUrlPrefix!)) {
              Navigator.of(context).pop({'status': 'approved', 'url': url});
              return NavigationDecision.prevent;
            }
            if (widget.cancelUrlPrefix != null && url.startsWith(widget.cancelUrlPrefix!)) {
              Navigator.of(context).pop({'status': 'canceled', 'url': url});
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PayPal Checkout')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      ),
    );
  }
}


