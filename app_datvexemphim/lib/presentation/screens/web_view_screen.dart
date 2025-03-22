import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) async {
          // Nếu URL là deeplink (moMo, VNPAY, ZaloPay)
          if (request.url.startsWith("momo://") ||
              request.url.startsWith("vnpay://") ||
              request.url.startsWith("zalopay://")) {
            // Mở app MoMo/ZaloPay/VNPAY
            if (await canLaunchUrl(Uri.parse(request.url))) {
              await launchUrl(Uri.parse(request.url),
                  mode: LaunchMode.externalApplication);
            }
            return NavigationDecision.prevent; // Chặn WebView điều hướng
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thanh toán MoMo")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
