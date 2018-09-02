import Foundation

let store = Store(
    state: GameState(),
    reducer: gameReducer,
    sideEffects: [commandLogger, turnValidator])

func gameReducer(_ state: GameState, _ command: Command) -> GameState {
    var newState = state
    newState.reduce(command)
    return newState
}
