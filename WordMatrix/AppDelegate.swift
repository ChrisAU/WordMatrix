import UIKit
import ReactiveSwift
import enum Result.NoError

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

func newGame() -> Game {
    return Game(
        dimensions: 5,
        premium: [:],
        filled: [:],
        placed: [:],
        bag: [Tile(id: 0, letter: "T", value: 2),
              Tile(id: 1, letter: "O", value: 1),
              Tile(id: 1, letter: "O", value: 1)],
        players: [Player(kind: .human, tiles: [], score: 0)],
        playerIndex: 0,
        playerRackAmount: 5,
        playerSolution: nil)
}

// TODO: Generate Game

private let newGameSignal = Signal<Game, NoError>.pipe()

func reset() {
    newGameSignal.input.send(newGame)
}

func bindReset() {
    newGameSignal.output.map(GameCommand.reset).fire()
}
