import XCTest
import Quick
import Nimble
@testable import WordMatrix

final class GameStateSpec: QuickSpec {
    override func spec() {
        describe("GameState") {
            var sut: GameState!
            var initialGame: Game!
            
            beforeEach {
                sut = GameState()
                initialGame = Game.valid
                sut.reduce(GameAction.reset(initialGame))
            }
            
            context("Reset") {
                it("fills players tiles") {
                    expect(sut.bag.count) == initialGame.bag.count
                        - (initialGame.players.count * initialGame.playerRackAmount)
                    for player in sut.players {
                        expect(player.tiles.count) == initialGame.playerRackAmount
                    }
                }
            }
            
            context("BagAction") {
                it("does not draw if all players have tiles") {
                    let previousBag = sut.bag
                    sut.reduce(BagAction.draw)
                    expect(sut.bag) == previousBag
                    expect(sut.player.tiles.count) == sut.playerRackAmount
                }
                it("draws when players rack is missing a tile") {
                    sut.place(1)
                    sut.reduce(TurnValidationAction.valid(score: 1, candidate: [], intersections: []))
                    sut.reduce(TurnAction.submit)
                    let previousCount = sut.bag.count
                    sut.reduce(BagAction.draw)
                    expect(sut.bag.count) == previousCount - 1
                    expect(sut.player.tiles.count) == initialGame.playerRackAmount
                }
                it("handles swap") {
                    let previousTiles = sut.player.tiles
                    let previousBag = sut.bag
                    sut.reduce(BagAction.swap(sut.player.tiles))
                    expect(sut.bag) != previousBag
                    expect(sut.player.tiles) != previousTiles
                    expect(sut.bag.count) == previousBag.count
                    expect(sut.player.tiles.count) == previousTiles.count
                }
            }
            
            context("PlayerAction") {
                it("handles next") {
                    let current = sut.playerIndex
                    sut.reduce(PlayerAction.next)
                    expect(sut.playerIndex) != current
                }
                it("handles next when at end") {
                    let current = sut.playerIndex
                    _ = (0..<sut.players.count - 1).reduce(current) { (current, next) in
                        sut.reduce(PlayerAction.next)
                        expect(sut.playerIndex) != current
                        expect(sut.playerIndex) != next
                        return sut.playerIndex
                    }
                    sut.reduce(PlayerAction.next)
                    expect(sut.playerIndex) == current
                }
            }
            
            context("TurnAction") {
                it("handles place on single point") {
                    expect(sut.player.tiles.count) == initialGame.playerRackAmount
                    expect(sut.placed.count) == 0
                    sut.place(1)
                    expect(sut.player.tiles.count) == initialGame.playerRackAmount - 1
                    expect(sut.placed.count) == 1
                }
                it("handles place on same point") {
                    expect(sut.player.tiles.count) == initialGame.playerRackAmount
                    expect(sut.placed.count) == 0
                    sut.place(3, ascendingRows: false)
                    expect(sut.player.tiles.count) == initialGame.playerRackAmount - 1
                    expect(sut.placed.count) == 1
                }
                it("handles place on different point") {
                    expect(sut.player.tiles.count) == initialGame.playerRackAmount
                    expect(sut.placed.count) == 0
                    sut.place(3)
                    expect(sut.player.tiles.count) == initialGame.playerRackAmount - 3
                    expect(sut.placed.count) == 3
                }
                it("handles submit") {
                    expect(sut.premium.isEmpty) == false
                    expect(sut.placed.isEmpty) == true
                    expect(sut.filled.isEmpty) == true
                    sut.place(3)
                    sut.reduce(TurnValidationAction.valid(score: 1, candidate: [], intersections: []))
                    sut.reduce(TurnAction.submit)
                    expect(sut.placed.isEmpty) == true
                    expect(sut.filled.count) == 3
                    expect(sut.premium.isEmpty) == true
                    expect(sut.player.score) == 1
                    expect(sut.playerTurnScore) == 0
                }
            }
            
            context("TurnValidationAction") {
                it("handles valid") {
                    sut.reduce(TurnValidationAction.valid(score: 1, candidate: [], intersections: []))
                    expect(sut.playerTurnScore) == 1
                }
                it("resets valid on placement") {
                    sut.reduce(TurnValidationAction.valid(score: 1, candidate: [], intersections: []))
                    sut.place(1)
                    expect(sut.playerTurnScore) == 0
                }
                it("resets valid on rack") {
                    sut.reduce(TurnValidationAction.valid(score: 1, candidate: [], intersections: []))
                    sut.place(1)
                    sut.rack(1)
                    expect(sut.playerTurnScore) == 0
                }
                it("handles invalid") {
                    sut.reduce(TurnValidationAction.valid(score: 1, candidate: [], intersections: []))
                    sut.reduce(TurnValidationAction.invalid)
                    expect(sut.playerTurnScore) == 0
                }
            }
        }
    }
}

private extension GameState {
    mutating func rack(_ n: Int) {
        Array(placed.keys)[0..<n].forEach {
            reduce(TurnAction.rack($0))
        }
    }
    
    mutating func place(_ n: Int, ascendingRows: Bool = true) {
        (0..<n).forEach {
            let row = ascendingRows ? $0 : 0
            reduce(
                TurnAction.place(player.tiles[0],
                                 at: Point(row: row, column: 0)))
        }
    }
}

private let premiumSquares: [Point: Square] = {
    return [
        Point(row: 0, column: 0): Square(),
        Point(row: 1, column: 0): Square(multiplier: 2),
        Point(row: 2, column: 0): Square(wordMultiplier: 2)
    ]
}()

private extension Game {
    static let valid: Game = {
        return Game(
            dimensions: 5,
            premium: premiumSquares,
            filled: [:],
            placed: [:],
            bag: [].valid(30),
            players: [.zero, .zero, .zero, .zero],
            playerIndex: 0,
            playerRackAmount: 5,
            playerTurnScore: 0)
    }()
}

private extension Sequence where Element == Tile {
    private func random() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ "
        let number = Int(arc4random_uniform(UInt32(characters.count)))
        let index = characters.index(characters.startIndex, offsetBy: number)
        let character = characters[index]
        return String(character)
    }
    
    func valid(_ amount: Int) -> [Tile] {
        return (0..<amount).map { Tile(id: $0, letter: random(), value: 1) }
    }
}

private extension Player {
    static let zero: Player = {
        return Player(kind: .human, tiles: [], score: 0)
    }()
}
