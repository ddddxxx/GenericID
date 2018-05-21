//
//  OptionalType.swift
//
//  This file is part of GenericID.
//  Copyright (c) 2017 Xander Deng
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//

protocol AnyOptionalType {
    
    var anyWrapped: Any? { get }
    
    static var anyWrappedType: Any.Type { get }
}

protocol OptionalType: AnyOptionalType {
    
    associatedtype WrappedType
    
    var wrapped: WrappedType? { get }
    
    init(_ wrapped: WrappedType?)
}

extension Optional: OptionalType {
    
    var anyWrapped: Any? {
        return self
    }
    
    static var anyWrappedType: Any.Type {
        return Wrapped.self
    }
    
    var wrapped: Wrapped? {
        return self
    }
    
    init(_ wrapped: WrappedType?) {
        self = wrapped
    }
}

func unwrap(_ v: Any) -> Any? {
    guard let opt = v as? AnyOptionalType else { return v }
    return opt.anyWrapped.flatMap(unwrap)
}

func unwrap(_ t: Any.Type) -> Any.Type {
    guard let opt = t as? AnyOptionalType.Type else { return t }
    return unwrap(opt.anyWrappedType)
}
