import Foundation

typealias Letter = String

typealias Score = Int

struct Tile: Hashable {
    let id: Int
    let letter: Letter
    let value: Score
}
