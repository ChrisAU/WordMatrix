import Foundation

extension Sequence where Element == Int {
    var isSequential: Bool {
        var p: Int?
        for i in sorted() {
            if p == nil {
                p = i
            } else {
                if p == i - 1 {
                    p = i
                } else {
                    return false
                }
            }
        }
        return p != nil
    }
}
