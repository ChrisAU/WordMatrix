import Foundation
import ReactiveSwift
import enum Result.NoError

protocol Command { }

typealias Middleware<T: State> = (T, Command) -> Void

typealias Reducer<T: State> = (T, Command) -> T

protocol State { }

struct Store<T: State> {
    private let commandSignal = Signal<Command, NoError>.pipe()
    private let stateProperty: Property<T>
    
    init(state: T,
         reducer: @escaping Reducer<T>,
         middleware: [Middleware<T>]) {
        stateProperty = Property<T>(
            initial: state,
            then: commandSignal.output
                .scan(state) { middleware.call(reducer($0, $1), $1) })
    }
    
    func fire(_ command: Command) {
        commandSignal.input.send(value: command)
    }
    
    func observe() -> Property<T> {
        return stateProperty
    }
}

extension Store {
    func fire(_ commandProvider: () -> Command) {
        fire(commandProvider())
    }
    
    func fire(_ signal: Signal<Command, NoError>) {
        signal.observeValues(fire)
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

extension Property {
    func map<T>(_ keyPath: KeyPath<Value, T>) -> Property<T> {
        return map { $0[keyPath: keyPath] }
    }
}

extension Signal.Observer {
    func send(_ valueProvider: () -> Value) {
        send(value: valueProvider())
    }
}

private extension Sequence {
    func call<T: State>(_ state: T, _ command: Command) -> T where Element == Middleware<T> {
        return reduce(state) { $1(state, command); return $0 }
    }
}
