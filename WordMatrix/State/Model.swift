import Foundation

struct Game: Equatable {
    let dimensions: Int
    let premium: [Point: Square]
    let filled: [Point: Tile]
    let placed: [Tile: Point]
    let bag: [Tile]
    let players: [Player]
    let playerIndex: Int
    let playerRackAmount: Int
    let playerTurnScore: Score
}

struct Point: Equatable, Hashable {
    let row: Int
    let column: Int
    
    func value(forAxis axis: Axis) -> Int {
        return axis == .column ? column : row
    }
}

enum Axis {
    case column
    case row
    
    var inverse: Axis {
        return self == .column ? .row : .column
    }
}

struct Square: Equatable {
    var multiplier: Int
    var wordMultiplier: Int
    
    init(multiplier: Int = 1, wordMultiplier: Int = 1) {
        self.multiplier = multiplier
        self.wordMultiplier = wordMultiplier
    }
}

typealias Letter = String

typealias Score = Int

struct Tile: Hashable {
    let id: Int
    let letter: Letter
    let value: Score
}

struct Player: Equatable {
    enum Kind: Equatable {
        enum Level: Equatable {
            case easy
            case medium
            case hard
            case expert
        }
        case human
        case ai(Level)
    }
    let kind: Kind
    var tiles: [Tile]
    var score: Score
}
