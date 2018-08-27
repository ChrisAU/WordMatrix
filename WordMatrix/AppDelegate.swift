import UIKit
import ReactiveSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        bindReset()
        reset()
        
        let max = 15
        let range = CountableClosedRange(0..<max)
        
        let solutions = Point.matrix(size: max)
            .flatMap { (point: $0, axes: range.axes(for: $0)) }
            .filter { !$0.axes.isEmpty }
            .flatMap { (point, axes) -> [Solution] in
                axes.flatMap { $0.solutions(at: point) }
            }
            .lazy
        
        print(solutions)
        
        return true
    }
}
