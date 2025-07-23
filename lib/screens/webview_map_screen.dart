import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewMapScreen extends StatefulWidget {
  final bool showAppBar;
  
  const WebViewMapScreen({super.key, this.showAppBar = true});

  @override
  State<WebViewMapScreen> createState() => _WebViewMapScreenState();
}

class _WebViewMapScreenState extends State<WebViewMapScreen> {
  late final WebViewController controller;
  
  // Google My Maps埋め込み用URL（Geminiの推奨形式）
  static const String myMapsUrl = 'https://www.google.com/maps/d/embed?mid=1OfkkT3IdnaMLeFC6HKK0Q-CpZQ3TDw8';
  
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // プログレス更新
            debugPrint('WebView loading progress: $progress%');
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
WebView resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
            ''');
            // エラー時の処理
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('マップの読み込みに失敗しました: ${error.description}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(myMapsUrl));
  }

  @override
  Widget build(BuildContext context) {
    final webViewBody = Stack(
      children: [
        // WebView
        WebViewWidget(controller: controller),
        
        // ローディングインジケーター
        if (isLoading)
          Container(
            color: Colors.white,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'マップを読み込み中...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );

    if (!widget.showAppBar) {
      return webViewBody;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'マイマップ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          // リフレッシュボタン
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.reload();
            },
          ),
        ],
      ),
      body: webViewBody,
    );
  }
}