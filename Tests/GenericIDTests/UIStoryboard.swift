//
//  UIStoryboard.swift
//  GenericID
//
//  Created by 邓翔 on 2017/4/26.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

#if os(iOS) || os(tvOS)
    
    import UIKit
    
    extension UIStoryboard {
        
        public typealias Identifier<T> = Identifiers.Identifier<T> where T: UIViewController
        
        public class Identifiers {}
    }
    
    extension UIStoryboard.Identifiers {
        
        public class Identifier<T: UIViewController>: UIStoryboard.Identifiers, RawRepresentable {
            
            public let rawValue: String
            
            public required init(rawValue: String) {
                self.rawValue = rawValue
            }
        }
    }
    
    extension UIStoryboard.Identifier: Hashable, ExpressibleByStringLiteral {}
    
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
