import Foundation

let store = Store(
    state: GameState(),
    reducer: gameReducer,
    interceptors: [gameResetter],
    sideEffects: [commandLogger, turnValidator])

func gameReducer(_ state: GameState, _ command: Command) -> GameState {
    var newState = state
    newState.reduce(command)
    return newState
}
