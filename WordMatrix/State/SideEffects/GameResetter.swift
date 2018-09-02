import Foundation

let gameResetter: Interceptor<GameState> = { state, command in
    switch command {
    case GameCommand.new:
        GameCommand.reset(newGame(for: state)).fire()
        return true
    default:
        return false
    }
}

private func newGame(`for` state: GameState) -> Game {
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
