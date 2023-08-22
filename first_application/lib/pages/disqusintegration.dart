import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class DisqusIntegration extends StatelessWidget {
  final String disqusHtml = '''
    <!DOCTYPE html>
    <html>
    <head>
      <title>Disqus Comments</title>
    </head>
    <body>
      <div id="disqus_thread"></div>
      <script>
        var disqus_config = function () {
          this.page.url = window.location.href;
          this.page.identifier = window.location.href;
        };
        (function() {
          var d = document, s = d.createElement('script');
          s.src = 'https://e-learning-18.disqus.com/embed.js';
          s.setAttribute('data-timestamp', +new Date());
          (d.head || d.body).appendChild(s);
        })();
      </script>
    </body>
    </html>
    ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disqus Comments'),
      ),
      body: InAppWebView(
        initialData: InAppWebViewInitialData(data: disqusHtml),
      ),
    );
  }
}
