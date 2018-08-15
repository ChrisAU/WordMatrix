import Foundation

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
