import Foundation

func validateTurn(_ state: GameState, _ command: Command) {
    switch command {
    case TurnCommand.place, TurnCommand.rack:
        store.fire(state.validate)
    default:
        break
    }
}

private extension GameState {
    func validate() -> TurnValidationCommand {
        if placed.isEmpty {
            return .invalid
        }
        if placed.count == 1 {
            if filled.isEmpty {
                return .invalid
            } else {
                return .valid(Solution(score: 1, points: [], intersections: []))
            }
        } else {
            guard let points = points(), let candidate = points.first else {
                return .invalid
            }
            return .valid(Solution(score: 1, points: candidate, intersections: Array(points.dropFirst())))
        }
    }
    
    private func points() -> [[Point]]? {
        return points(for: .column) ?? points(for: .row)
    }
    
    private func points(for axis: Axis) -> [[Point]]? {
        let fluid = Array(placed.values)
        let fixed = Array(filled.keys)
        guard let byAxis = fluid.union(with: fixed, on: axis),
            !byAxis.isEmpty else {
                return nil
        }
        if let byOppositeAxis = fluid.intersections(with: fixed, on: axis.inverse) {
            return [byAxis] + byOppositeAxis
        } else {
            return [byAxis]
        }
    }
}
