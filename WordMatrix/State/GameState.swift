import Foundation
import RxSwift
import RxSwiftExt

// MARK: Store

let bag = DisposeBag()
let store = Store(
    state: GameState(),
    reducer: gameReducer,
    middleware: [actionLogger, validateTurn])

// MARK: Begin

// TODO: Generate Game
func newGame() -> Game {
    return Game(
        dimensions: 5,
        premium: [:],
        filled: [:],
        placed: [:],
        bag: [Tile(id: 0, letter: "T", value: 1),
              Tile(id: 1, letter: "O", value: 1)],
        players: [Player(kind: .human, tiles: [], score: 0)],
        playerIndex: 0,
        playerRackAmount: 5,
        playerSolution: nil)
}

let newGameSubject = BehaviorSubject<Game?>(value: nil)

func bindReset() {
    store.fire(newGameSubject.unwrap().map(GameAction.reset))
}

// MARK: Reducer

func gameReducer(_ state: GameState, _ action: Action) -> GameState {
    print("Reducing \(action)")
    var newState = state
    newState.reduce(action)
    return newState
}

// MARK: Middleware

func actionLogger(_ state: GameState, _ action: Action) {
    func strip(_ from: String) -> String {
        return from.replacingOccurrences(of: "WordMatrix.", with: "")
    }
    print("#",
          strip(String(describing: type(of: action))),
          "|",
          strip(String(describing: action)))
}

func validateTurn(_ state: GameState, _ action: Action) {
    switch action {
    case TurnAction.place, TurnAction.rack:
        store.fire(state.validate())
    default:
        break
    }
}

// MARK: Actions

enum BagAction: Action {
    case draw
    case swap([Tile])
}

enum PlayerAction: Action {
    case next
}

enum GameAction: Action {
    case reset(Game)
}

enum TurnAction: Action {
    case rack(Tile)
    case place(Tile, at: Point)
    case submit
}

enum TurnValidationAction: Action {
    case valid(Solution)
    case invalid
}

// MARK: State

struct GameState: State {
    // Player
    private(set) var players: [Player] = []
    private(set) var playerIndex: Int = 0
    private(set) var playerRackAmount: Int = 0
    
    // Word
    //private(set) var wordBingoScore: Int = 0
    //private(set) var wordMaximumLength: Int = 0
    private(set) var playerSolution: Solution? = nil
    
    // Bag
    private(set) var bag: [Tile] = []
    private(set) var letterScore: [Letter: Score] = [:]
    
    // Board
    private(set) var range: CountableRange<Int> = (0..<1)
    private(set) var placed: [Tile: Point] = [:]
    private(set) var filled: [Point: Tile] = [:]
    private(set) var premium: [Point: Square] = [:]
    
    var player: Player {
        get {
            assert(players.count > playerIndex)
            return players[playerIndex]
        }
        set {
            players[playerIndex] = newValue
        }
    }
    
    mutating func reduce(_ action: Action) {
        if let gameAction = action as? GameAction {
            reduce(gameAction)
        } else {
            assert(players.count > playerIndex)
            switch action {
            case let bagAction as BagAction:
                reduce(bagAction)
            case let playerAction as PlayerAction:
                reduce(playerAction)
            case let turnAction as TurnAction:
                reduce(turnAction)
            case let turnValidationAction as TurnValidationAction:
                reduce(turnValidationAction)
            default:
                break
            }
        }
    }
}

// MARK: GameAction

private extension GameState {
    mutating func reduce(_ action: GameAction) {
        switch action {
        case .reset(let game):
            range = 0..<game.dimensions
            bag = game.bag
            players = game.players
            playerIndex = game.playerIndex
            playerRackAmount = game.playerRackAmount
            playerSolution = game.playerSolution
            filled = game.filled
            placed = game.placed
            premium = game.premium
            letterScore = bag.map { ($0.letter, $0.value) }.reduce(into: [:], { $0[$1.0] = $1.1 })
            for _ in players {
                reduce(BagAction.draw)
                reduce(PlayerAction.next)
            }
        }
    }
}

// MARK: BagAction

private extension GameState {
    mutating func reduce(_ action: BagAction) {
        switch action {
        case .draw:
            player.tiles += draw()
        case .swap(let tiles):
            let tileCount = player.tiles.count
            assert(tiles.count >= tileCount)
            player.tiles = player.tiles.filter { !tiles.contains($0) }
            assert(player.tiles.count == tileCount - tiles.count)
            bag = tiles + bag
            player.tiles += draw()
            assert(player.tiles.count == tileCount)
        }
    }
    
    private mutating func draw() -> [Tile] {
        let amount = min(bag.count, playerRackAmount - player.tiles.count)
        return (0..<amount).map { _ in bag.popLast()! }
    }
}

// MARK: TurnAction

private extension GameState {
    mutating func reduce(_ action: TurnAction) {
        switch action {
        case let .place(tile, point):
            place(tile, at: point)
        case let .rack(tile):
            rack(tile)
        case .submit:
            submit()
        }
    }
    
    private mutating func place(_ tile: Tile, at point: Point) {
        assert(range.contains(point))
        let newTiles = Array(player.tiles.filter { $0 != tile })
        assert(player.tiles != newTiles)
        player.tiles = newTiles
        if let returnedTile = placed.first(where: { $0.value == point })?.key {
            reduce(TurnAction.rack(returnedTile))
        }
        placed[tile] = point
        reduce(TurnValidationAction.invalid)
    }
    
    private mutating func rack(_ tile: Tile) {
        assert(placed[tile] != nil)
        assert(!player.tiles.contains(tile))
        player.tiles.append(tile)
        placed[tile] = nil
        reduce(TurnValidationAction.invalid)
    }
    
    private mutating func submit() {
        guard let solution = playerSolution else {
            assertionFailure("Cannot submit if there is no solution")
            return
        }
        placed.forEach { (tile, point) in
            assert(filled[point] == nil)
            filled[point] = tile
            premium.removeValue(forKey: point)
        }
        placed = [:]
        player.score += solution.score
        reduce(TurnValidationAction.invalid)
    }
}

// MARK: TurnValidationAction

private extension GameState {
    mutating func reduce(_ action: TurnValidationAction) {
        switch action {
        case let .valid(newSolution):
            playerSolution = newSolution
        case .invalid:
            playerSolution = nil
        }
    }
}

// MARK: TurnValidationMiddleware

private extension GameState {
    func validate() -> TurnValidationAction {
        if placed.isEmpty {
            return .invalid
        }
        if placed.count == 1 {
            if filled.isEmpty {
                return .invalid
            } else {
                return .valid(Solution(score: 1, points: [], intersections: []))
            }
        } else {
            guard let points = points(), let candidate = points.first else {
                return .invalid
            }
            return .valid(Solution(score: 1, points: candidate, intersections: Array(points.dropFirst())))
        }
    }
    
    private func points() -> [[Point]]? {
        return points(for: .column) ?? points(for: .row)
    }
    
    private func points(for axis: Axis) -> [[Point]]? {
        let fluid = Array(placed.values)
        let fixed = Array(filled.keys)
        guard let byAxis = fluid.union(with: fixed, on: axis),
            !byAxis.isEmpty else {
                return nil
        }
        if let byOppositeAxis = fluid.intersections(with: fixed, on: axis.inverse) {
            return [byAxis] + byOppositeAxis
        } else {
            return [byAxis]
        }
    }
}

// MARK: PlayerAction

private extension GameState {
    mutating func reduce(_ action: PlayerAction) {
        switch action {
        case .next:
            nextPlayer()
        }
    }
    
    private mutating func nextPlayer() {
        playerIndex = (playerIndex + 1) % players.count
    }
}
