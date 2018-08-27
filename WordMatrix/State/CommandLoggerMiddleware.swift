import Foundation

func commandLogger(_ state: GameState, _ command: Command) {
    func strip(_ from: String) -> String {
        return from.replacingOccurrences(of: "WordMatrix.", with: "")
    }
    let _type = "\(type(of: command))"
    let label = command.mirrorLabel
    let prefix = _type == label ? label : "\(_type).\(label)"
    print("#",
          prefix,
          "-->",
          strip("\(state)"))
}

private extension Command {
    private var mirrorChild: Mirror.Child? {
        return Mirror(reflecting: self).children.first
    }
    
    var mirrorLabel: String {
        let text = mirrorChild?.label ?? String(describing: self)
        return text.replacingOccurrences(of: "()", with: "")
    }
    
    var mirrorValue: Any? {
        return mirrorChild?.value
    }
}
