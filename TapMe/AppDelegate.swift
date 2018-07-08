
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let APP_ID = "751D3222-34C7-2619-FF11-4017F65BBC00"
    let API_KEY = "8722B6BB-6924-87E1-FFD9-53B8C1455200"
    let SERVER_URL = "https://api.backendless.com"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Backendless.sharedInstance().hostURL = SERVER_URL
        Backendless.sharedInstance().initApp(APP_ID, apiKey: API_KEY)
        return true
    }
}

