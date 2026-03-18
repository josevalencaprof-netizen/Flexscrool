import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()

        // Allow inline media and camera access without user gesture
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        // Allow camera via getUserMedia
        if #available(iOS 15.0, *) {
            config.defaultWebpagePreferences.allowsContentJavaScript = true
        }

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.backgroundColor = UIColor(red: 10/255, green: 10/255, blue: 8/255, alpha: 1)
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.isOpaque = false
        webView.navigationDelegate = context.coordinator

        // Load the bundled HTML using an https base URL so that:
        // 1. CDN scripts load without CORS issues
        // 2. getUserMedia works (requires secure context)
        // 3. localStorage persists across sessions
        if let htmlPath = Bundle.main.path(forResource: "index", ofType: "html"),
           let html = try? String(contentsOfFile: htmlPath, encoding: .utf8) {
            webView.loadHTMLString(html, baseURL: URL(string: "https://flexscroll.local"))
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Allow all navigation (needed for the app to function)
            decisionHandler(.allow)
        }
    }
}
