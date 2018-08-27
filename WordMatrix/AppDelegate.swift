import UIKit
import ReactiveSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        bindReset()
        
        // TODO: As middleware
        store.observe().map { $0.collect() }
            .signal
            .observeValues { (solutions) in
                print("Solutions: \(solutions)")
        }
        
        reset()
        
        return true
    }
}
