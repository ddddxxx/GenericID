import Cocoa
import GenericID

let ud = UserDefaults.standard

extension UserDefaults.DefaultsKeys {
    static let intKey       = Key<Int>("intKey")
    static let stringKey    = Key<String>("stringKey")
    static let stringArrayKey = Key<[String]>("arrayKey")
    static let dictKey      = Key<[String: Int]>("dictKey")
    static let colorKey     = Key<NSColor?>("colorKey", transformer: .keyedArchive)
    static let pointKey     = Key<CGPoint?>("pointKey", transformer: .json)
}

ud.removeAll()

ud[.intKey] = 42
ud[.intKey] += 1

ud[.stringKey] = "foo"
ud[.stringKey] += "bar"

ud[.stringArrayKey] = ["foo", "bar"]
ud[.stringArrayKey].contains("foo")
ud[.stringArrayKey][0] += "baz"

ud[.dictKey] = ["foo": 42]
ud[.dictKey]["bar"] = 233
ud[.dictKey].removeValue(forKey: "foo")

ud[.colorKey] = .orange
ud[.colorKey]?.redComponent

ud[.pointKey] = CGPoint(x: 1, y: 1)
ud[.pointKey]?.x += 1
