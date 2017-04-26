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
            guard let dequeue = dequeueReusableHeaderFooterView(withIdentifier: identifier.rawValue) else {
                return nil
            }
            guard let cell = dequeue as? T else {
                fatalError("Could not dequeue reusable cell with identifier '\(identifier.rawValue)' for type '\(T.self)'")
            }
            return cell
        }
        
        public func dequeueReusableCell<T>(withIdentifier identifier: CellReuseIdentifier<T>, for indexPath: IndexPath) -> T {
            guard let cell = dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath) as? T else {
                fatalError("Could not dequeue reusable cell with identifier '\(identifier.rawValue)' for type '\(T.self)'")
            }
            return cell
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
            guard let dequeue = dequeueReusableHeaderFooterView(withIdentifier: identifier.rawValue) else {
                return nil
            }
            guard let view = dequeue as? T else {
                fatalError("Could not dequeue reusable header footer view with identifier '\(identifier.rawValue)' for type '\(T.self)'")
            }
            return view
        }
    }
    
#endif
