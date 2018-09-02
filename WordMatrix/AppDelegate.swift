import UIKit
import ReactiveSwift
import enum Result.NoError

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // TODO: As middleware
        store.observe().map { $0.collect() }
            .signal
            .observeValues { (solutions) in
                print("Solutions: \(solutions)")
        }
        
        [GameCommand.new, GameCommand.new, GameCommand.new].fire()
        return true
    }
}
