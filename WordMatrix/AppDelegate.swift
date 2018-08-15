import UIKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        bindReset()
        
        Observable<Int>
            .interval(10, scheduler: MainScheduler.asyncInstance)
            .map { _ in newGame() }
            .startWith(newGame())
            .subscribe(newGameSubject)
            .disposed(by: bag)
        
        return true
    }
}
