import Foundation

let store = Store(
    state: GameState(),
    reducer: gameReducer,
    middleware: [commandLogger, validateTurn])

func gameReducer(_ state: GameState, _ command: Command) -> GameState {
    var newState = state
    newState.reduce(command)
    return newState
}
