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
    store.fire(newGameSignal.output.map(GameCommand.reset))
}
