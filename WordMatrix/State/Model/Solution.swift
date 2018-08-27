import Foundation

struct Solution: Equatable {
    let score: Score
    let points: [Point]
    let intersections: [[Point]]
}

extension Point {
    private func iterate(upTo: Int, on axis: Axis) -> AnyIterator<Point> {
        let opposite = value(forAxis: axis.inverse)
        let range = value(forAxis: axis)...upTo
        return AnyIterator(range.map { Point.make($0, opposite, on: axis) }.makeIterator())
    }
    
    static func matrix(size: Int) -> AnyIterator<Point> {
        return AnyIterator(Point.zero.iterate(upTo: size, on: .column).flatMap { (point) in
            point.iterate(upTo: size, on: .row)
        }.makeIterator())
    }
}

extension Int {
    func upTo(_ max: Int) -> AnyIterator<Int> {
        return AnyIterator((self...max).makeIterator())
    }
}

extension CountableRange where Bound == Int {
    func range(_ size: Int) -> AnyIterator<AnyIterator<Int>> {
        return AnyIterator(map { AnyIterator((0...(size - $0)).makeIterator()) }.makeIterator())
    }
    
    func contains(_ point: Point, on axis: Axis) -> Bool {
        return contains(point.value(forAxis: axis))
    }
    
    func axes(for point: Point) -> [Axis] {
        return reduce([], { (result, index) in
            if index == point.row { return result + [.row] }
            if index == point.column { return result + [.column] }
            return result
        })
    }
}

extension GameState {
    func solutions(at point: Point, on axis: Axis) -> [Solution] {
        return []
    }
    
    func collect() -> [Solution] {
        return Point.matrix(size: range.upperBound)
            .compactMap { (point: $0, axes: range.axes(for: $0)) }
            .filter { !$0.axes.isEmpty }
            .flatMap { (point, axes) -> [Solution] in
                axes.flatMap { self.solutions(at: point, on: $0) }
            }
    }
}
