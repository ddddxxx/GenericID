//
//  NSStoryboard.swift
//  GenericID
//
//  Created by 邓翔 on 2017/4/26.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

#if os(macOS)
    
    import AppKit
    
    extension NSStoryboard {
        
        public typealias Identifier<T> = Identifiers.ID<T> where T: NSViewController
        
        public class Identifiers {}
    }
    
    extension NSStoryboard.Identifiers {
        
        public class ID<T: NSViewController>: NSStoryboard.Identifiers, RawRepresentable {
            
            public let rawValue: String
            
            public required init(rawValue: String) {
                self.rawValue = rawValue
            }
        }
    }
    
    extension NSStoryboard.Identifier: Hashable, ExpressibleByStringLiteral {}
    
    extension NSStoryboard {
        
        public func instantiateController<T>(withIdentifier identifier: Identifier<T>) -> T {
            guard let vc = instantiateController(withIdentifier: identifier.rawValue) as? T else {
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
            return NSStoryboard(name: mainStoryboardName, bundle: .main)
        }
    }
    
#endif
