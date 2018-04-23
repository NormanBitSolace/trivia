import UIKit

var appCoordinator: AppCoordinator!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        appCoordinator = AppCoordinator(dataSource: DataSource(), appNavigator: AppNavigator())
        return true
    }

}
