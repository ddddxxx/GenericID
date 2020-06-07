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

extension OptionalType {
    
    var anyWrapped: Any? {
        return wrapped
    }
    
    static var anyWrappedType: Any.Type {
        return WrappedType.self
    }
}

extension Optional: OptionalType {
    
    var wrapped: Wrapped? {
        return self
    }
    
    init(_ wrapped: WrappedType?) {
        self = wrapped
    }
}

func unwrap(_ v: Any) -> Any? {
    if let opt = v as? AnyOptionalType {
        return opt.anyWrapped
    } else {
        return v
    }
}

func unwrap(_ t: Any.Type) -> Any.Type {
    if let opt = t as? AnyOptionalType.Type {
        return opt.anyWrappedType
    } else {
        return t
    }
}

func unwrapRecursively(_ v: Any) -> Any? {
    return unwrap(v).anyWrapped.flatMap(unwrapRecursively)
}

func unwrapRecursively(_ t: Any.Type) -> Any.Type {
    if let opt = t as? AnyOptionalType.Type {
        return unwrapRecursively(opt.anyWrappedType)
    } else {
        return t
    }
}
