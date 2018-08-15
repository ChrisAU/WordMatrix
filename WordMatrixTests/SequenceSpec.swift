import XCTest
import Quick
import Nimble
@testable import WordMatrix

final class SequenceSpec: QuickSpec {
    override func spec() {
        describe("Sequence") {
            context("is sequential") {
                it("should pass") {
                    expect([0,1,2].isSequential) == true
                }
                it("should fail if skipped") {
                    expect([0,1,3].isSequential) == false
                }
                it("should pass if reversed") {
                    expect([3,2,1].isSequential) == true
                }
            }
            context("point is sequential by column") {
                it("should pass") {
                    expect([
                        Point(row: 0, column: 0),
                        Point(row: 0, column: 1),
                        Point(row: 0, column: 2)
                    ].isSequential(on: .column)) == true
                }
                it("should fail if skipped") {
                    expect([
                        Point(row: 0, column: 0),
                        Point(row: 0, column: 1),
                        Point(row: 0, column: 3)
                    ].isSequential(on: .column)) == false
                }
                it("should fail if wrong axis") {
                    expect([
                        Point(row: 0, column: 0),
                        Point(row: 0, column: 1),
                        Point(row: 0, column: 3)
                    ].isSequential(on: .row)) == false
                }
            }
            context("points on column") {
                it("should be valid") {
                    expect([
                        Point(row: 0, column: 0),
                        Point(row: 1, column: 0),
                        Point(row: 2, column: 0)
                    ].points(on: .column)).to(beNil())
                }
                it("should be invalid") {
                    expect([
                        Point(row: 0, column: 0),
                        Point(row: 0, column: 1),
                        Point(row: 0, column: 2)
                    ].points(on: .column)).toNot(beNil())
                }
            }
            context("points on row") {
                it("should be valid") {
                    expect([
                        Point(row: 0, column: 0),
                        Point(row: 0, column: 1),
                        Point(row: 0, column: 2)
                    ].points(on: .row)).to(beNil())
                }
                it("should be invalid") {
                    expect([
                        Point(row: 0, column: 0),
                        Point(row: 1, column: 0),
                        Point(row: 2, column: 0)
                    ].points(on: .row)).toNot(beNil())
                }
            }
        }
    }
}
