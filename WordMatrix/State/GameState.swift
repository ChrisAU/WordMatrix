import Foundation
import ReactiveSwift
import enum Result.NoError

// MARK: Store

let store = Store(
    state: GameState(),
    reducer: gameReducer,
    middleware: [commandLogger, validateTurn])

// MARK: Reducer

func gameReducer(_ state: GameState, _ command: Command) -> GameState {
    debugPrint("Reduce \(command.mirrorLabel)")
    var newState = state
    newState.reduce(command)
    return newState
}

// MARK: Middleware

private extension Command {
    private var mirrorChild: Mirror.Child? {
        return Mirror(reflecting: self).children.first
    }
    
    var mirrorLabel: String {
        let text = mirrorChild?.label ?? String(describing: self)
        return text.replacingOccurrences(of: "()", with: "")
    }
    
    var mirrorValue: Any? {
        return mirrorChild?.value
    }
}

func commandLogger(_ state: GameState, _ command: Command) {
    func strip(_ from: String) -> String {
        return from.replacingOccurrences(of: "WordMatrix.", with: "")
    }
    let _type = "\(type(of: command))"
    let label = command.mirrorLabel
    let prefix = _type == label ? label : "\(_type).\(label)"
    print("#",
          prefix,
          "-->",
          strip("\(state)"))
}

func validateTurn(_ state: GameState, _ command: Command) {
    switch command {
    case TurnCommand.place, TurnCommand.rack:
        store.fire(state.validate)
    default:
        break
    }
}

// MARK: Commands

enum BagCommand: Command {
    case draw
    case swap([Tile])
}

enum PlayerCommand: Command {
    case next
}

enum GameCommand: Command {
    case reset(Game)
}

enum TurnCommand: Command {
    case rack(Tile)
    case place(Tile, at: Point)
    case submit
}

enum TurnValidationCommand: Command {
    case valid(Solution)
    case invalid
}

// MARK: State

struct GameState: State {
    // Player
    private(set) var players: [Player] = []
    private(set) var playerIndex: Int = 0
    private(set) var playerRackAmount: Int = 0
    private(set) var playerSolution: Solution? = nil
    
    // Word
    //private(set) var wordBingoScore: Int = 0
    //private(set) var wordMaximumLength: Int = 0
    
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
    
    mutating func reduce(_ command: Command) {
        if let gameCommand = command as? GameCommand {
            reduce(gameCommand)
        } else {
            assert(players.count > playerIndex)
            switch command {
            case let bagCommand as BagCommand:
                reduce(bagCommand)
            case let playerCommand as PlayerCommand:
                reduce(playerCommand)
            case let turnCommand as TurnCommand:
                reduce(turnCommand)
            case let turnValidationCommand as TurnValidationCommand:
                reduce(turnValidationCommand)
            default:
                break
            }
        }
    }
}

// MARK: GameCommand

private extension GameState {
    mutating func reduce(_ command: GameCommand) {
        switch command {
        case .reset(let game):
            bag = game.bag
            letterScore = bag.map { ($0.letter, $0.value) }.reduce(into: [:], { $0[$1.0] = $1.1 })
            
            players = game.players
            playerIndex = game.playerIndex
            playerRackAmount = game.playerRackAmount
            playerSolution = game.playerSolution
            
            range = 0..<game.dimensions
            filled = game.filled
            placed = game.placed
            premium = game.premium
            
            for _ in players {
                reduce(BagCommand.draw)
                reduce(PlayerCommand.next)
            }
        }
    }
}

// MARK: BagCommand

private extension GameState {
    mutating func reduce(_ command: BagCommand) {
        switch command {
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

// MARK: TurnCommand

private extension GameState {
    mutating func reduce(_ command: TurnCommand) {
        switch command {
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
            reduce(TurnCommand.rack(returnedTile))
        }
        placed[tile] = point
        reduce(TurnValidationCommand.invalid)
    }
    
    private mutating func rack(_ tile: Tile) {
        assert(placed[tile] != nil)
        assert(!player.tiles.contains(tile))
        player.tiles.append(tile)
        placed[tile] = nil
        reduce(TurnValidationCommand.invalid)
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
        reduce(TurnValidationCommand.invalid)
    }
}

// MARK: TurnValidationCommand

private extension GameState {
    mutating func reduce(_ command: TurnValidationCommand) {
        switch command {
        case let .valid(newSolution):
            playerSolution = newSolution
        case .invalid:
            playerSolution = nil
        }
    }
}

// MARK: TurnValidationMiddleware

private extension GameState {
    func validate() -> TurnValidationCommand {
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

// MARK: PlayerCommand

private extension GameState {
    mutating func reduce(_ command: PlayerCommand) {
        switch command {
        case .next:
            nextPlayer()
        }
    }
    
    private mutating func nextPlayer() {
        playerIndex = (playerIndex + 1) % players.count
    }
}
