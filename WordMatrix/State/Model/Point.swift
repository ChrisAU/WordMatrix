import Foundation

struct Point: Equatable, Hashable {
    let row: Int
    let column: Int
    
    func value(forAxis axis: Axis) -> Int {
        return axis == .column ? column : row
    }
    
    static func make(_ a: Int, _ b: Int, on axis: Axis) -> Point {
        if axis == .column {
            return Point(row: b, column: a)
        } else {
            return Point(row: a, column: b)
        }
    }
    
    static let zero = Point(row: 0, column: 0)
}

enum Axis {
    case column, row
    var inverse: Axis { return self == .column ? .row : .column }
}

extension CountableRange where Bound == Int {
    func contains(_ point: Point) -> Bool {
        return contains(point.column) && contains(point.row)
    }
}

extension Array where Element == Point {
    func minimum(from touching: Point, on axis: Axis) -> Point {
        let previous = touching.value(forAxis: axis) - 1
        guard let point = first(where: { $0.value(forAxis: axis) == previous }) else {
            return touching
        }
        return minimum(from: point, on: axis)
    }
    
    func maximum(from touching: Point, on axis: Axis) -> Point {
        let next = touching.value(forAxis: axis) + 1
        guard let point = first(where: { $0.value(forAxis: axis) == next }) else {
            return touching
        }
        return maximum(from: point, on: axis)
    }
    
    func around(_ start: Point, and end: Point, on axis: Axis) -> [Point]? {
        let startIndex = minimum(from: start, on: axis).value(forAxis: axis)
        let endIndex = maximum(from: end, on: axis).value(forAxis: axis)
        let range = startIndex...endIndex
        
        let otherAxis = axis.inverse
        let otherSorted = sorted(by: axis)
        let mainValueInverse = start.value(forAxis: otherAxis)
        
        let placement = otherSorted.filter { otherPoint in
            return otherPoint.value(forAxis: otherAxis) == mainValueInverse &&
                range.contains(otherPoint.value(forAxis: axis))
            }.sorted(by: axis)
        
        return placement.isEmpty ? nil : placement
    }
    
    func union(with other: [Point], on axis: Axis) -> [Point]? {
        guard let current = points(on: axis),
            let first = current.first,
            let last = current.last else {
                return nil
        }
        assert(current.count == count)
        
        let around = other.around(first, and: last, on: axis) ?? []
        let all = (current + around).sorted(by: axis)
        guard !all.isEmpty, all.isSequential(on: axis) else {
            return nil
        }
        return all
    }
}

extension Sequence where Element == Point {
    func intersections(with other: [Point], on axis: Axis) -> [[Point]]? {
        var buffer = [[Point]]()
        for point in self {
            guard let intersection = other.around(point, and: point, on: axis.inverse) else {
                continue
            }
            let full = (intersection + [point]).sorted(by: axis.inverse)
            buffer.append(full)
        }
        return buffer.isEmpty ? nil : buffer
    }
    
    func isSequential(on axis: Axis) -> Bool {
        return map { $0.value(forAxis: axis) }.isSequential
    }
    
    func sorted(by axis: Axis) -> [Point] {
        return axis == .column ? sortedByColumn() : sortedByRow()
    }
    
    func points(on axis: Axis) -> [Point]? {
        return axis == .column ? column() : row()
    }
    
    private func sortedByColumn() -> [Point] {
        return sorted(by: { $0.column < $1.column })
    }
    
    private func sortedByRow() -> [Point] {
        return sorted(by: { $0.row < $1.row })
    }
    
    private func column() -> [Point]? {
        let sortedPoints = sortedByColumn()
        var p: Point?
        for point in sortedPoints {
            if let p = p {
                if p.row != point.row {
                    return nil
                }
            } else {
                p = point
            }
        }
        return sortedPoints.isEmpty ? nil : sortedPoints
    }
    
    private func row() -> [Point]? {
        let sortedPoints = sortedByRow()
        var p: Point?
        for point in sortedPoints {
            if let p = p {
                if p.column != point.column {
                    return nil
                }
            } else {
                p = point
            }
        }
        return sortedPoints.isEmpty ? nil : sortedPoints
    }
}
