import Foundation

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
