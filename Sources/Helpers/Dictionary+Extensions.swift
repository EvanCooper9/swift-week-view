import Foundation

extension Dictionary {
    static func += <K, V> (left: inout [K: V], right: [K: V]) {
        right.forEach { (key: K, value: V) in
            left[key] = value
        }
    }
}
