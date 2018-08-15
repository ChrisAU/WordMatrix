import Foundation

struct Square: Equatable {
    var multiplier: Int
    var wordMultiplier: Int
    
    init(multiplier: Int = 1, wordMultiplier: Int = 1) {
        self.multiplier = multiplier
        self.wordMultiplier = wordMultiplier
    }
}
