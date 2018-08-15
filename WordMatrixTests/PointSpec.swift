import XCTest
import Quick
import Nimble
@testable import WordMatrix

final class PointSpec: QuickSpec {
    override func spec() {
        describe("Point") {
            context("value for axis") {
                it("returns column") {
                    expect(Point(row: 0, column: 5).value(forAxis: .column)) == 5
                }
                it("returns row") {
                    expect(Point(row: 5, column: 0).value(forAxis: .row)) == 5
                }
            }
            context("minimum") {
                it("returns if fixed is touching the top") {
                    let point = Point(row: 0, column: 2)
                    let fixed = [Point(row: 0, column: 1)]
                    let result = fixed.minimum(from: point, on: .column)
                    expect(result) == fixed[0]
                }
                it("returns if fixed is touching the bottom") {
                    let point = Point(row: 0, column: 1)
                    let fixed = [Point(row: 0, column: 2)]
                    let result = fixed.minimum(from: point, on: .column)
                    expect(result) == point
                }
                it("returns original if fixed is not touching the top") {
                    let point = Point(row: 0, column: 2)
                    let fixed = [Point(row: 0, column: 0)]
                    let result = fixed.minimum(from: point, on: .column)
                    expect(result) == point
                }
                it("returns original if fixed is not touching the bottom") {
                    let point = Point(row: 0, column: 0)
                    let fixed = [Point(row: 0, column: 2)]
                    let result = fixed.minimum(from: point, on: .column)
                    expect(result) == point
                }
            }
            
            context("maximum") {
                it("returns if fixed is touching the top") {
                    let point = Point(row: 0, column: 2)
                    let fixed = [Point(row: 0, column: 1)]
                    let result = fixed.maximum(from: point, on: .column)
                    expect(result) == point
                }
                it("returns if fixed is touching the bottom") {
                    let point = Point(row: 0, column: 1)
                    let fixed = [Point(row: 0, column: 2)]
                    let result = fixed.maximum(from: point, on: .column)
                    expect(result) == fixed[0]
                }
                it("returns original if fixed is not touching the top") {
                    let point = Point(row: 0, column: 2)
                    let fixed = [Point(row: 0, column: 0)]
                    let result = fixed.maximum(from: point, on: .column)
                    expect(result) == point
                }
                it("returns original if fixed is not touching the bottom") {
                    let point = Point(row: 0, column: 0)
                    let fixed = [Point(row: 0, column: 2)]
                    let result = fixed.maximum(from: point, on: .column)
                    expect(result) == point
                }
            }
            
            context("around column") {
                it("is around start and end column") {
                    let start = Point(row: 0, column: 1)
                    let end = Point(row: 0, column: 4)
                    
                    let other = [
                        Point(row: 0, column: 2),
                        Point(row: 0, column: 3)
                    ]
                    
                    let points = other.around(start, and: end, on: .column)
                    expect(points).toNot(beNil())
                }
                it("is not around start and end on opposite axis") {
                    let start = Point(row: 0, column: 1)
                    let end = Point(row: 0, column: 4)
                    
                    let other = [
                        Point(row: 0, column: 2),
                        Point(row: 0, column: 3)
                    ]
                    
                    let points = other.around(start, and: end, on: .row)
                    expect(points).to(beNil())
                }
                it("is not around start and end column if not touching") {
                    let start = Point(row: 0, column: 5)
                    let end = Point(row: 0, column: 8)
                    
                    let other = [
                        Point(row: 0, column: 2),
                        Point(row: 0, column: 3)
                    ]
                    
                    let points = other.around(start, and: end, on: .column)
                    expect(points).to(beNil())
                }
                it("is around start and end column if touching") {
                    let start = Point(row: 0, column: 4)
                    let end = Point(row: 0, column: 6)
                    
                    let other = [
                        Point(row: 0, column: 2),
                        Point(row: 0, column: 3)
                    ]
                    
                    let points = other.around(start, and: end, on: .column)
                    expect(points).toNot(beNil())
                }
            }
            
            context("around row") {
                it("is around start and end row") {
                    let start = Point(row: 1, column: 0)
                    let end = Point(row: 4, column: 0)
                    
                    let other = [
                        Point(row: 2, column: 0),
                        Point(row: 3, column: 0)
                    ]
                    
                    let points = other.around(start, and: end, on: .row)
                    expect(points).toNot(beNil())
                }
                it("is not around start and end on opposite axis") {
                    let start = Point(row: 1, column: 0)
                    let end = Point(row: 4, column: 0)
                    
                    let other = [
                        Point(row: 2, column: 0),
                        Point(row: 3, column: 0)
                    ]
                    
                    let points = other.around(start, and: end, on: .column)
                    expect(points).to(beNil())
                }
                it("is not around start and end row if not touching") {
                    let start = Point(row: 5, column: 0)
                    let end = Point(row: 8, column: 0)
                    
                    let other = [
                        Point(row: 2, column: 0),
                        Point(row: 3, column: 0)
                    ]
                    
                    let points = other.around(start, and: end, on: .row)
                    expect(points).to(beNil())
                }
                it("is around start and end column if touching") {
                    let start = Point(row: 4, column: 0)
                    let end = Point(row: 6, column: 0)
                    
                    let other = [
                        Point(row: 2, column: 0),
                        Point(row: 3, column: 0)
                    ]
                    
                    let points = other.around(start, and: end, on: .row)
                    expect(points).toNot(beNil())
                }
            }
            
            context("union column") {
                it("is invalid") {
                    let start = Point(row: 0, column: 1)
                    let end = Point(row: 0, column: 4)
                    
                    let points = [].union(with: [start, end], on: .column)
                    expect(points).to(beNil())
                }
                it("is valid") {
                    let start = Point(row: 0, column: 1)
                    let end = Point(row: 0, column: 4)
                    
                    let other = [
                        Point(row: 0, column: 2),
                        Point(row: 0, column: 3)
                    ]
                    
                    let points = other.union(with: [start, end], on: .column)
                    expect(points).toNot(beNil())
                }
                it("is valid if start index is one space away") {
                    let start = Point(row: 0, column: 0)
                    let end = Point(row: 0, column: 4)
                    
                    let other = [
                        Point(row: 0, column: 2),
                        Point(row: 0, column: 3)
                    ]
                    
                    let points = other.union(with: [start, end], on: .column)
                    expect(points).toNot(beNil())
                }
                it("is valid if end index is one space away") {
                    let start = Point(row: 0, column: 1)
                    let end = Point(row: 0, column: 5)
                    
                    let other = [
                        Point(row: 0, column: 2),
                        Point(row: 0, column: 3)
                    ]
                    
                    let points = other.union(with: [start, end], on: .column)
                    expect(points).toNot(beNil())
                }
                it("is invalid if space is skipped") {
                    let start = Point(row: 0, column: 0)
                    let end = Point(row: 0, column: 4)
                    
                    let other = [
                        Point(row: 0, column: 2)
                    ]
                    
                    let points = other.union(with: [start, end], on: .column)
                    expect(points).to(beNil())
                }
            }
            
            context("union row") {
                it("is invalid") {
                    let start = Point(row: 1, column: 0)
                    let end = Point(row: 4, column: 0)
                    
                    let points = [].union(with: [start, end], on: .row)
                    expect(points).to(beNil())
                }
                it("is valid") {
                    let start = Point(row: 1, column: 0)
                    let end = Point(row: 4, column: 0)
                    
                    let other = [
                        Point(row: 2, column: 0),
                        Point(row: 3, column: 0)
                    ]
                    
                    let points = other.union(with: [start, end], on: .row)
                    expect(points).toNot(beNil())
                }
                it("is valid if start index is one space away") {
                    let start = Point(row: 0, column: 0)
                    let end = Point(row: 4, column: 0)
                    
                    let other = [
                        Point(row: 2, column: 0),
                        Point(row: 3, column: 0)
                    ]
                    
                    let points = other.union(with: [start, end], on: .row)
                    expect(points).toNot(beNil())
                }
                it("is valid if end index is one space away") {
                    let start = Point(row: 1, column: 0)
                    let end = Point(row: 5, column: 0)
                    
                    let other = [
                        Point(row: 2, column: 0),
                        Point(row: 3, column: 0)
                    ]
                    
                    let points = other.union(with: [start, end], on: .row)
                    expect(points).toNot(beNil())
                }
                it("is invalid if space is skipped") {
                    let start = Point(row: 0, column: 0)
                    let end = Point(row: 4, column: 0)
                    
                    let other = [
                        Point(row: 2, column: 0)
                    ]
                    
                    let points = other.union(with: [start, end], on: .row)
                    expect(points).to(beNil())
                }
            }
            
            context("intersection") {
                var fixed: [Point]!
                var fluid: [Point]!
                var intersectionA: [Point]!
                var intersectionB: [Point]!
                beforeEach {
                    fixed = [
                        Point(row: 0, column: 1),
                        Point(row: 1, column: 0),
                        Point(row: 1, column: 1),
                        Point(row: 1, column: 2),
                        Point(row: 3, column: 1),
                        Point(row: 3, column: 2)
                    ]
                    fluid = [
                        Point(row: 2, column: 1),
                        Point(row: 2, column: 2)
                    ]
                    intersectionA = [
                        Point(row: 0, column: 1),
                        Point(row: 1, column: 1),
                        Point(row: 2, column: 1),
                        Point(row: 3, column: 1)
                    ]
                    intersectionB = [
                        Point(row: 1, column: 2),
                        Point(row: 2, column: 2),
                        Point(row: 3, column: 2)
                    ]
                }
                
                it("is intersected by column") {
                    let intersections = fluid.intersections(with: fixed, on: .column)
                    expect(intersections).toNot(beNil())
                    expect(intersections?.count) == 2
                    expect(intersections) == [intersectionA, intersectionB]
                }
                it("is not intersected by column") {
                    let intersections = fluid.inverse.intersections(with: fixed.inverse, on: .column)
                    expect(intersections).to(beNil())
                }
                it("is intersected by row") {
                    let intersections = fluid.inverse.intersections(with: fixed.inverse, on: .row)
                    expect(intersections).toNot(beNil())
                    expect(intersections?.count) == 2
                    expect(intersections) == [intersectionA.inverse, intersectionB.inverse]
                }
                it("is not intersected by row") {
                    let intersections = fluid.intersections(with: fixed, on: .row)
                    expect(intersections).to(beNil())
                }
            }
        }
    }
}

extension Point {
    var inverse: Point {
        return Point(row: column, column: row)
    }
}

extension Sequence where Element == Point {
    var inverse: [Point] {
        return map { $0.inverse }
    }
}
