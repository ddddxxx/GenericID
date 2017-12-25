//
//  LazyReference.swift
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

import Foundation

private enum LazyValue<T> {
    
    case pending(() -> T)
    case evaluated(T)
    
    mutating func value() -> T {
        switch self {
        case let .pending(block):
            let v = block()
            self = .evaluated(v)
            return v
        case let .evaluated(v):
            return v
        }
    }
}

class LazyReference<T> {
    
    private var _value: LazyValue<T>
    
    init(_ block: @escaping () -> T) {
        _value = .pending(block)
    }
    
    var value: T {
        return _value.value()
    }
}
