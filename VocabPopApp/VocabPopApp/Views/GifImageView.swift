import SwiftUI
import WebKit

struct GifImageView: NSViewRepresentable {
    var imageName: String
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.wantsLayer = true
        webView.layer?.backgroundColor = NSColor.clear.cgColor
        webView.setValue(false, forKey: "drawsBackground")
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // 1. Kiểm tra nếu là link online (http:// hoặc https://)
        if imageName.lowercased().hasPrefix("http://") || imageName.lowercased().hasPrefix("https://") {
            if let url = URL(string: imageName) {
                let html = """
                <html>
                <body style='margin:0;padding:0;background:transparent;display:flex;justify-content:center;align-items:center;'>
                    <img src='\(url.absoluteString)' style='max-width:100%;max-height:100%;object-fit:contain;'/>
                </body>
                </html>
                """
                nsView.loadHTMLString(html, baseURL: nil)
                return
            }
        }
        
        // 2. Nếu không phải link mạng, tìm file offline trong máy
        if let url = Bundle.main.url(forResource: imageName, withExtension: "gif") {
            let data = try? Data(contentsOf: url)
            nsView.load(data ?? Data(), mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: url.deletingLastPathComponent())
        } else if let url = Bundle.main.url(forResource: imageName, withExtension: "png") ?? Bundle.main.url(forResource: imageName, withExtension: "jpg") {
            // fallback cho ảnh tĩnh
            let html = "<html><body style='margin:0;padding:0;background:transparent;display:flex;justify-content:center;align-items:center;'><img src='\(url.absoluteString)' style='max-width:100%;max-height:100%;object-fit:contain;'/></body></html>"
            nsView.loadHTMLString(html, baseURL: nil)
        } else {
            // Fallback khi không tìm thấy ảnh
            let html = "<html><body style='margin:0;padding:0;background:transparent;display:flex;justify-content:center;align-items:center;color:gray;font-family:sans-serif;'>No Image Found</body></html>"
            nsView.loadHTMLString(html, baseURL: nil)
        }
    }
}
