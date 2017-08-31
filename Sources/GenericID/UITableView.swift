//
//  UITableView.swift
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
    
    // MARK: UITableViewCell
    
    extension UITableView {
        
        public typealias CellReuseIdentifier<T> = CellReuseIdentifiers.ID<T> where T: UITableViewCell
        
        public class CellReuseIdentifiers: StaticKeyBase {}
    }
    
    extension UITableView.CellReuseIdentifiers {
        
        public class ID<T: UITableViewCell>: UITableView.CellReuseIdentifiers, RawRepresentable, ExpressibleByStringLiteral {
            
            public var rawValue: String {
                return key
            }
            
            public required init(rawValue: String) {
                super.init(rawValue)
            }
        }
    }
    
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
            guard let dequeue = dequeueReusableCell(withIdentifier: identifier.rawValue) else {
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
        
        public typealias HeaderFooterViewReuseIdentifier<T> = HeaderFooterViewReuseIdentifiers.ID<T> where T: UITableViewHeaderFooterView
        
        public class HeaderFooterViewReuseIdentifiers: StaticKeyBase {}
    }
    
    extension UITableView.HeaderFooterViewReuseIdentifiers {
        
        public class ID<T: UITableViewHeaderFooterView>: UITableView.HeaderFooterViewReuseIdentifiers, RawRepresentable, ExpressibleByStringLiteral {
            
            public var rawValue: String {
                return key
            }
            
            public required init(rawValue: String) {
                super.init(rawValue)
            }
        }
    }
    
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
