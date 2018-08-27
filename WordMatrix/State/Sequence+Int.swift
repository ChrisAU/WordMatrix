import Foundation

extension Sequence where Element == Int {
    var isSequential: Bool {
        var isValid: Bool = false
        var p: Int?
        for i in sorted() {
            if p == nil {
                p = i
            } else {
                if p == i - 1 {
                    p = i
                    isValid = true
                } else {
                    return false
                }
            }
        }
        return p != nil && isValid
    }
}
