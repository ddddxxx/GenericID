//
//  UICollectionView.swift
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
    
    // MARK: UICollectionViewCell
    
    extension UICollectionView {
        
        public typealias CellReuseIdentifier<T> = CellReuseIdentifiers.ID<T> where T: UICollectionViewCell
        
        public class CellReuseIdentifiers {}
    }
    
    extension UICollectionView.CellReuseIdentifiers {
        
        public class ID<T: UICollectionViewCell>: UICollectionView.CellReuseIdentifiers, StaticKey {
            
            public let rawValue: String
            
            public required init(rawValue: String) {
                self.rawValue = rawValue
            }
        }
    }
    
    extension UICollectionView.CellReuseIdentifier: UINibFromTypeGettable {
        typealias NibType = T
    }
    
    extension UICollectionView {
        
        public func register<T>(id: CellReuseIdentifier<T>) {
            register(T.self, forCellWithReuseIdentifier: id.rawValue)
        }
        
        public func registerNib<T>(id: CellReuseIdentifier<T>) {
            register(type(of: id).nib, forCellWithReuseIdentifier: id.rawValue)
        }
        
        public func registerNib<T: UINibGettable>(id: CellReuseIdentifier<T>) {
            register(T.nib, forCellWithReuseIdentifier: id.rawValue)
        }
        
        public func dequeueReusableCell<T>(withReuseIdentifier identifier: CellReuseIdentifier<T>, for indexPath: IndexPath) -> T {
            guard let cell = dequeueReusableCell(withReuseIdentifier: identifier.rawValue, for: indexPath) as? T else {
                fatalError("Could not dequeue reusable cell with identifier '\(identifier.rawValue)' for type '\(T.self)'")
            }
            return cell
        }
    }
    
    // MARK: - UICollectionReusableView
    
    extension UICollectionView {
        
        public typealias SupplementaryViewReuseIdentifier<T> = SupplementaryViewReuseIdentifiers.ID<T> where T: UICollectionReusableView
        
        public class SupplementaryViewReuseIdentifiers {}
    }
    
    extension UICollectionView.SupplementaryViewReuseIdentifiers {
        
        public class ID<T: UICollectionReusableView>: UICollectionView.SupplementaryViewReuseIdentifiers, StaticKey {
            
            public let rawValue: String
            
            public required init(rawValue: String) {
                self.rawValue = rawValue
            }
        }
    }
    
    extension UICollectionView.SupplementaryViewReuseIdentifier: UINibFromTypeGettable {
        typealias NibType = T
    }
    
    extension UICollectionView {
        
        public func register<T>(id: SupplementaryViewReuseIdentifier<T>, ofKind elementKind: String) {
            register(T.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: id.rawValue)
        }
        
        public func registerNib<T>(id: SupplementaryViewReuseIdentifier<T>, ofKind elementKind: String) {
            register(type(of: id).nib, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: id.rawValue)
        }
        
        public func registerNib<T: UINibGettable>(id: SupplementaryViewReuseIdentifier<T>, ofKind elementKind: String) {
            register(T.nib, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: id.rawValue)
        }
        
        public func dequeueReusableSupplementaryView<T>(ofKind elementKind: String, withIdentifier identifier: SupplementaryViewReuseIdentifier<T>, for indexPath: IndexPath) -> T {
            guard let view = dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: identifier.rawValue, for: indexPath) as? T else {
                fatalError("Could not dequeue reusable supplementary view with identifier '\(identifier.rawValue)' for type '\(T.self)'")
            }
            return view
        }
    }
    
#endif
