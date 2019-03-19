
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let APP_ID = "APP ID"
    let API_KEY = "API KEY"
    let SERVER_URL = "https://api.backendless.com"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Backendless.sharedInstance().hostURL = SERVER_URL
        Backendless.sharedInstance().initApp(APP_ID, apiKey: API_KEY)
        return true
    }
}

