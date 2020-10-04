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

func unwrapRecursively(_ v: Any) -> Any? {
    if let wrapped = (v as? AnyOptionalType)?.anyWrapped {
        return unwrapRecursively(wrapped)
    } else {
        return v
    }
}

func unwrapRecursively(_ t: Any.Type) -> Any.Type {
    if let wrapped = (t as? AnyOptionalType.Type)?.anyWrappedType {
        return unwrapRecursively(wrapped)
    } else {
        return t
    }
}
