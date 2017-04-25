//
//  UITableView.swift
//  GenericID
//
//  Created by 邓翔 on 2017/4/25.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

#if os(iOS) || os(tvOS)
    
    import UIKit
    
    // MARK: UITableViewCell
    
    extension UITableView {
        
        public typealias CellReuseIdentifier = CellReuseIdentifiers.Identifier
        
        public class CellReuseIdentifiers {}
    }
    
    extension UITableView.CellReuseIdentifiers {
        
        public class Identifier<T: UITableViewCell>: UITableView.CellReuseIdentifiers, RawRepresentable {
            
            public let rawValue: String
            
            public required init(rawValue: String) {
                self.rawValue = rawValue
            }
        }
    }
    
    extension UITableView.CellReuseIdentifier: Hashable, ExpressibleByStringLiteral {}
    
    extension UITableView.CellReuseIdentifier: UINibFromTypeGettable {
        typealias NibType = T
    }
    
    extension UITableView {
        
        public func register<T>(id: CellReuseIdentifier<T>) {
            register(T.self, forCellReuseIdentifier: id.rawValue)
        }
        
        public func registerNib<T>(id: CellReuseIdentifier<T>) {
            register(type(of: id).nib, forCellReuseIdentifier: id.rawValue)
        }
        
        public func registerNib<T: UINibGettable>(id: CellReuseIdentifier<T>) {
            register(T.nib, forCellReuseIdentifier: id.rawValue)
        }
        
        public func dequeueReusableCell<T>(withIdentifier identifier: CellReuseIdentifier<T>) -> T? {
            return dequeueReusableCell(withIdentifier: identifier.rawValue).map { $0 as! T }
        }
        
        public func dequeueReusableCell<T>(withIdentifier identifier: CellReuseIdentifier<T>, for indexPath: IndexPath) -> T {
            return dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath) as! T
        }
    }
    
    // MARK: - UITableViewHeaderFooterView
    
    extension UITableView {
        
        public typealias HeaderFooterViewReuseIdentifier = HeaderFooterViewReuseIdentifiers.HeaderFooterViewReuseIdentifier
        
        public class HeaderFooterViewReuseIdentifiers {}
    }
    
    extension UITableView.HeaderFooterViewReuseIdentifiers {
        
        public class HeaderFooterViewReuseIdentifier<T: UITableViewHeaderFooterView>: UITableView.HeaderFooterViewReuseIdentifiers, RawRepresentable {
            
            public let rawValue: String
            
            public required init(rawValue: String) {
                self.rawValue = rawValue
            }
        }
    }
    
    extension UITableView.HeaderFooterViewReuseIdentifier: Hashable, ExpressibleByStringLiteral {}
    
    extension UITableView.HeaderFooterViewReuseIdentifier: UINibFromTypeGettable {
        typealias NibType = T
    }
    
    extension UITableView {
        
        public func register<T>(id: HeaderFooterViewReuseIdentifier<T>) {
            register(T.self, forHeaderFooterViewReuseIdentifier: id.rawValue)
        }
        
        public func registerNib<T>(id: HeaderFooterViewReuseIdentifier<T>) {
            register(type(of: id).nib, forHeaderFooterViewReuseIdentifier: id.rawValue)
        }
        
        public func registerNib<T: UINibGettable>(id: HeaderFooterViewReuseIdentifier<T>) {
            register(T.nib, forHeaderFooterViewReuseIdentifier: id.rawValue)
        }
        
        public func dequeueReusableHeaderFooterView<T>(withIdentifier identifier: HeaderFooterViewReuseIdentifier<T>) -> T? {
            return dequeueReusableHeaderFooterView(withIdentifier: identifier.rawValue) as? T
        }
    }
    
#endif
