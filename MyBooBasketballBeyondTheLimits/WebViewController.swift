import UIKit
import WebKit

class WebViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let webView = WKWebView(frame: view.bounds)
        view.addSubview(webView)
        
        if let url = URL(string: "https://best-igaming.ru/9fsfH1hS") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
