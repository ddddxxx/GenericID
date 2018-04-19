//
//  OptionalProtocol.swift
//  GenericID
//
//  Created by 邓翔 on 2017/9/1.
//

protocol OptionalProtocol {
    
    var value: Any? { get }
}

extension Optional: OptionalProtocol {
    
    var value: Any? {
        switch self {
        case .none: return nil
        case let .some(v): return v
        }
    }
}

func unwrap(_ v: Any) -> Any? {
    guard let opt = v as? OptionalProtocol else { return v }
    return opt.value.flatMap(unwrap)
}
