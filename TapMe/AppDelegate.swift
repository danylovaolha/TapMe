
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let APP_ID = "25E5B414-2F5A-D2B7-FF37-C9E88ABA3000"
    let API_KEY = "F7DA18E0-5A0B-D2E2-FF72-379D81C82700"
    let SERVER_URL = "http://apitest.backendless.com"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Backendless.sharedInstance().hostURL = SERVER_URL
        Backendless.sharedInstance().initApp(APP_ID, apiKey: API_KEY)
        return true
    }
}

