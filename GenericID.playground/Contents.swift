import Cocoa
import GenericID

let ud = UserDefaults.standard

extension UserDefaults.DefaultKeys {
    static let colorKey: Key<NSColor?> = "colorKey"
    static let pointKey: Key<CGPoint?> = "pointKey"
}

ud.archive(#colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1), for: .colorKey)
ud.unarchive(.colorKey)

let p = CGPoint(x: 1, y: 1)

ud.wrap(p, for: .pointKey)
ud.unwrap(.pointKey)

