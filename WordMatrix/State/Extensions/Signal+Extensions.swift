import Foundation
import ReactiveSwift

extension Signal.Observer {
    func send(_ valueProvider: () -> Value) {
        send(value: valueProvider())
    }
}
