import Foundation

extension Array {
    mutating func shuffle() {
        self = sorted(by: { (_, _) in arc4random() % 2 == 0 })
    }
}
