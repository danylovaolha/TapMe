
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let APP_ID = "62C23AC0-96E5-B175-FF87-E3F7879F5300"
    let API_KEY = "9768C044-981C-2F44-FF53-AB73E8D73D00"
    let SERVER_URL = "http://api.backendless.com"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Backendless.sharedInstance().hostURL = SERVER_URL
        Backendless.sharedInstance().initApp(APP_ID, apiKey: API_KEY)
        return true
    }
}

