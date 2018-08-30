import Foundation
import ReactiveSwift
import enum Result.NoError

struct Game: Equatable {
    let dimensions: Int
    let premium: [Point: Square]
    let filled: [Point: Tile]
    let placed: [Tile: Point]
    let bag: [Tile]
    let players: [Player]
    let playerIndex: Int
    let playerRackAmount: Int
    let playerSolution: Solution?
}
