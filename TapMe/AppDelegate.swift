
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let APP_ID = "APP_ID"
    let API_KEY = "API_KEY"
    let SERVER_URL = "http://api.backendless.com"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Backendless.sharedInstance().hostURL = SERVER_URL
        Backendless.sharedInstance().initApp(APP_ID, apiKey: API_KEY)
        return true
    }
}

