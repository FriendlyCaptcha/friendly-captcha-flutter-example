import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

String buildPageContent({String sitekey, String theme = "", String start = "auto", String lang = "", String puzzleEndpoint = ""}) {
  return """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Friendly Captcha Verification</title>

    <script type="module" src="https://cdn.jsdelivr.net/npm/friendly-challenge@0.8.8/widget.module.min.js"></script>
    <script nomodule src="https://cdn.jsdelivr.net/npm/friendly-challenge@0.8.8/widget.min.js"></script>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        html, body {
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100%;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
            ${theme == "dark" ? "background-color: #000;" : ""}
        }
    </style>
  </head>
  <body>
    <form action="POST" method="?">
      <div class="frc-captcha ${theme}" data-sitekey="${sitekey}" data-start="${start}" data-callback="doneCallback" data-lang="${lang}" data-puzzle-endpoint="${puzzleEndpoint}"></div>
    </form>
    <script>
      let isFlutterInAppWebViewReady = false;
      window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
       isFlutterInAppWebViewReady = true;
      });
      function doneCallback(solution) {
        if (!isFlutterInAppWebViewReady) { setTimeout(function(){doneCallback(solution)}, 500); } // Try again after 500ms
        window.flutter_inappwebview.callHandler('solutionCallback', {solution: solution});
      }
    </script>
  </body>
</html>
""";
}
class FriendlyCaptcha extends StatefulWidget {
  Function(String solution) callback;

  String sitekey;
  String theme;
  String start;
  String lang;
  String puzzleEndpoint;

  FriendlyCaptcha({
    @required this.sitekey,
    @required this.callback,
    this.theme = "",
    this.start = "auto",
    this.lang = "",
    this.puzzleEndpoint = ""}
  ) {}

  @override
  State<StatefulWidget> createState() {
    return CaptchaState();
  }
}

class CaptchaState extends State<FriendlyCaptcha> {
  InAppWebViewController webViewController;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var htmlSource = buildPageContent(
        sitekey: widget.sitekey,
        lang: widget.lang,
        puzzleEndpoint: widget.puzzleEndpoint,
        theme: widget.theme,
        start: widget.start,
    );

    return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 100, // Empirically determined to fit the widget.. to be improved
        ),
        child: Container(
            child: InAppWebView(
              initialData: InAppWebViewInitialData(
                data: htmlSource
              ),
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    useShouldOverrideUrlLoading: true,
                    disableContextMenu: true,
                    clearCache: true,
                    incognito: true,
                    applicationNameForUserAgent: "FriendlyCaptchaFlutter"
                  ),
                  android: AndroidInAppWebViewOptions(
                    useHybridComposition: true,
                  )
              ),
              onConsoleMessage: (controller, consoleMessage) {
                print(consoleMessage); // Useful for debugging, this prints (error) messages from the webview.
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                // We deny any navigation away (which could be caused by the user clicking a link)
                return NavigationActionPolicy.CANCEL;
              },
              onWebViewCreated: (InAppWebViewController w) {
                w.addJavaScriptHandler(handlerName: 'solutionCallback', callback: (args) {
                  widget.callback(args[0]["solution"]);
                });
                webViewController = w;
              },
            )
        )
    );
  }
}
