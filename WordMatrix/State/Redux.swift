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
    func call<T: State>(_ state: T, _ command: Command) -> T where Element == Middleware<T> {
        return reduce(state) { $1(state, command); return $0 }
    }
}
