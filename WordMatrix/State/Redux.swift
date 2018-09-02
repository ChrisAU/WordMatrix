import Foundation
import ReactiveSwift
import enum Result.NoError

protocol Command { }
protocol State { }
typealias Interceptor<T: State> = (T, Command) -> Bool
typealias Reducer<T: State> = (T, Command) -> T
typealias SideEffect<T: State> = (T, Command) -> Void

struct Store<T: State> {
    private let commandSignal = Signal<Command, NoError>.pipe()
    private let stateProperty: Property<T>
    
    init(state: T,
         reducer: @escaping Reducer<T>,
         interceptors: [Interceptor<T>] = [],
         sideEffects: [SideEffect<T>] = []) {
        stateProperty = Property<T>(
            initial: state,
            then: commandSignal.output
                .scan(state) {
                    if interceptors.intercept($0, command: $1) { return $0 }
                    let newState = reducer($0, $1)
                    sideEffects.apply(newState, $1)
                    return newState
            })
    }
    
    func fire(_ command: Command) {
        commandSignal.input.send(value: command)
    }
    
    func observe() -> Property<T> {
        return stateProperty
    }
}

extension Store {
    func fire(_ commands: [Command]) {
        commands.forEach(fire)
    }
    
    func fire(_ commandProducer: () -> Command) {
        fire(commandProducer())
    }
    
    func fire(_ signal: Signal<Command, NoError>) {
        signal.observeValues(fire)
    }
    
    func fire(_ signals: [Signal<Command, NoError>]) {
        Signal.combineLatest(signals).observeValues(fire)
    }
    
    subscript<U>(_ keyPath: KeyPath<T, U>) -> Property<U> {
        return observe().map(keyPath)
    }
    
    subscript<U: Equatable>(_ keyPath: KeyPath<T, U>) -> Property<U> {
        return observe().map(keyPath).skipRepeats(==)
    }
    
    subscript<U: Equatable>(_ keyPath: KeyPath<T, [U]>) -> Property<[U]> {
        return observe().map(keyPath).skipRepeats(==)
    }
}

extension Command {
    func fire() {
        store.fire(self)
    }
}

extension Sequence where Element: Command {
    func fire() {
        store.fire(Array(self))
    }
}

extension Signal where Value == Command, Error == NoError {
    func fire() {
        store.fire(self)
    }
}

extension Sequence where Element == Signal<Command, NoError> {
    func fire() {
        store.fire(Array(self))
    }
}

extension Property {
    func map<T>(_ keyPath: KeyPath<Value, T>) -> Property<T> {
        return map { $0[keyPath: keyPath] }
    }
}

private extension Sequence {
    func intercept<T: State>(_ state: T, command: Command) -> Bool where Element == Interceptor<T> {
        return reduce(false) { $0 || $1(state, command) }
    }
    
    func apply<T: State>(_ state: T, _ command: Command) where Element == SideEffect<T> {
        return forEach { $0(state, command) }
    }
}
