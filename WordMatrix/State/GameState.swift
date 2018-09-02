import Foundation
import ReactiveSwift
import enum Result.NoError

struct GameState: State {
    // Word
    //private(set) var wordBingoScore: Int = 0
    //private(set) var wordMaximumLength: Int = 0
    
    // Bag
    private(set) var bag: [Tile] = []
    private(set) var letterCount: [Letter: Int] = [:]
    private(set) var letterScore: [Letter: Score] = [:]
    
    // Board
    private(set) var range: CountableRange<Int> = (0..<1)
    private(set) var placed: [Tile: Point] = [:]
    private(set) var filled: [Point: Tile] = [:]
    private(set) var premium: [Point: Square] = [:]
    
    // Player
    private(set) var players: [Player] = []
    private(set) var playerIndex: Int = 0
    private(set) var playerRackAmount: Int = 0
    private(set) var playerSolution: Solution? = nil
    
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
        if let cmd = command as? GameCommand {
            reduceGame(cmd)
        } else {
            assert(players.count > playerIndex)
            switch command {
            case let cmd as BagCommand:
                reduceBag(cmd)
            case let cmd as PlayerCommand:
                reducePlayer(cmd)
            case let cmd as TurnCommand:
                reduceTurn(cmd)
            case let cmd as TurnValidationCommand:
                reduceTurnValidation(cmd)
            default:
                break
            }
        }
    }
}

// MARK: GameCommand

enum GameCommand: Command {
    case `new`
    case reset(Game)
}

private extension GameState {
    mutating func reduceGame(_ command: GameCommand) {
        switch command {
        case .reset(let game):
            bag = game.bag
            letterCount = bag.map { (letter: $0.letter, count: 1) }.reduce(into: [:]) { (result, current) in
                let value = result[current.letter] ?? 0
                result[current.letter] = value + current.count
            }
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
                reduceBag(BagCommand.draw)
                reducePlayer(PlayerCommand.next)
            }
        default:
            break
        }
    }
}

// MARK: BagCommand

enum BagCommand: Command {
    case draw
    case swap([Tile])
}

private extension GameState {
    mutating func reduceBag(_ command: BagCommand) {
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

// MARK: PlayerCommand

enum PlayerCommand: Command {
    case next
}

private extension GameState {
    mutating func reducePlayer(_ command: PlayerCommand) {
        switch command {
        case .next:
            nextPlayer()
        }
    }
    
    private mutating func nextPlayer() {
        playerIndex = (playerIndex + 1) % players.count
    }
}

// MARK: TurnCommand

enum TurnCommand: Command {
    case shuffle
    case rack(Tile)
    case place(Tile, at: Point)
    case submit
}

private extension GameState {
    mutating func reduceTurn(_ command: TurnCommand) {
        switch command {
        case let .place(tile, point):
            place(tile, at: point)
        case let .rack(tile):
            rack(tile)
        case .shuffle:
            player.tiles.shuffle()
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
            reduceTurn(TurnCommand.rack(returnedTile))
        }
        placed[tile] = point
        reduceTurnValidation(TurnValidationCommand.invalid)
    }
    
    private mutating func rack(_ tile: Tile) {
        assert(placed[tile] != nil)
        assert(!player.tiles.contains(tile))
        player.tiles.append(tile)
        placed[tile] = nil
        reduceTurnValidation(TurnValidationCommand.invalid)
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
        reduceTurnValidation(TurnValidationCommand.invalid)
    }
}

// MARK: TurnValidationCommand

enum TurnValidationCommand: Command {
    case valid(Solution)
    case invalid
}

private extension GameState {
    mutating func reduceTurnValidation(_ command: TurnValidationCommand) {
        switch command {
        case let .valid(newSolution):
            playerSolution = newSolution
        case .invalid:
            playerSolution = nil
        }
    }
}
