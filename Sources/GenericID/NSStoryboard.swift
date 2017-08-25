//
//  NSStoryboard.swift
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

#if os(macOS)
    
    import AppKit
    
    extension NSStoryboard {
        
        public typealias Identifier<T> = Identifiers.ID<T>
        
        public class Identifiers: StaticKeyBase {}
    }
    
    extension NSStoryboard.Identifiers {
        
        public class ID<T>: NSStoryboard.Identifiers, RawRepresentable, ExpressibleByStringLiteral {
            
            public var rawValue: String {
                return key
            }
            
            public required init(rawValue: String) {
                super.init(rawValue)
            }
        }
    }
    
    extension NSStoryboard {
        
        public func instantiateController<T>(withIdentifier identifier: Identifier<T>) -> T {
            guard let vc = instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: identifier.rawValue)) as? T else {
                fatalError("instantiate view controller '\(identifier.rawValue)' of '\(self)' is not of class '\(T.self)'")
            }
            return vc
        }
    }
    
    extension NSStoryboard {
        
        open class func main() -> NSStoryboard {
            guard let mainStoryboardName = Bundle.main.infoDictionary?["NSMainStoryboardFile"] as? String else {
                fatalError("No NSMainStoryboardFile found in main bundle")
            }
            return NSStoryboard(name: NSStoryboard.Name(rawValue: mainStoryboardName), bundle: .main)
        }
    }
    
#endif
