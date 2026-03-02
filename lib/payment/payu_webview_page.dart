import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'payment_status_page.dart';

class PayuWebViewPage extends StatefulWidget {
  final Map paymentData;

  const PayuWebViewPage({super.key, required this.paymentData});

  @override
  State<PayuWebViewPage> createState() => _PayuWebViewPageState();
}

class _PayuWebViewPageState extends State<PayuWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final payment = widget.paymentData;

    final html = """
    <html>
      <body onload='document.forms[0].submit()'>
        <form method="post" action="https://test.payu.in/_payment">
          <input type="hidden" name="key" value="${payment['key']}" />
          <input type="hidden" name="txnid" value="${payment['txnid']}" />
          <input type="hidden" name="amount" value="${payment['amount']}" />
          <input type="hidden" name="productinfo" value="${payment['productinfo']}" />
          <input type="hidden" name="firstname" value="${payment['firstname']}" />
          <input type="hidden" name="email" value="${payment['email']}" />
          <input type="hidden" name="hash" value="${payment['hash']}" />
          <input type="hidden" name="surl" value="${payment['surl']}" />
          <input type="hidden" name="furl" value="${payment['furl']}" />
        </form>
      </body>
    </html>
    """;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains("payuCallback")) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const PaymentStatusPage(),
                ),
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PayU Payment")),
      body: WebViewWidget(controller: _controller),
    );
  }
}

