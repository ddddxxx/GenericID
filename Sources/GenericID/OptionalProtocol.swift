//
//  OptionalProtocol.swift
//  GenericID
//
//  Created by 邓翔 on 2017/9/1.
//

protocol OptionalProtocol {}

extension Optional: OptionalProtocol {}

func unwrap(_ v: Any) -> Any? {
    let mirror = Mirror(reflecting: v)
    guard mirror.displayStyle == .optional else { return v }
    guard let value = mirror.children.first?.value else { return nil }
    return unwrap(value)
}
