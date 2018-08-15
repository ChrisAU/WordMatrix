import Foundation

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
        
        guard let around = other.around(first, and: last, on: axis) else {
            return current
        }
        let all = (current + around).sorted(by: axis)
        guard !all.isEmpty, all.isSequential(on: axis) else {
            return nil
        }
        return all
    }
}
