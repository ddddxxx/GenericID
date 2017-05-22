//
//  UIStoryboard.swift
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

#if os(iOS) || os(tvOS)
    
    import UIKit
    
    extension UIStoryboard {
        
        public typealias Identifier<T> = Identifiers.ID<T> where T: UIViewController
        
        public class Identifiers {}
    }
    
    extension UIStoryboard.Identifiers {
        
        public class ID<T: UIViewController>: UIStoryboard.Identifiers, StaticKey {
            
            public let rawValue: String
            
            public required init(rawValue: String) {
                self.rawValue = rawValue
            }
        }
    }
    
    extension UIStoryboard {
        
        public func instantiateViewController<T>(withIdentifier identifier: Identifier<T>) -> T {
            guard let vc = instantiateViewController(withIdentifier: identifier.rawValue) as? T else {
                fatalError("instantiate view controller '\(identifier.rawValue)' of '\(self)' is not of class '\(T.self)'")
            }
            return vc
        }
    }
    
    extension UIStoryboard {
        
        open class func main() -> UIStoryboard {
            guard let mainStoryboardName = Bundle.main.infoDictionary?["UIMainStoryboardFile"] as? String else {
                fatalError("No UIMainStoryboardFile found in main bundle")
            }
            return UIStoryboard(name: mainStoryboardName, bundle: .main)
        }
    }
    
#endif
