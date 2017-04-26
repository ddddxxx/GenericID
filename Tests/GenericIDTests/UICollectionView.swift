//
//  UICollectionView.swift
//  GenericID
//
//  Created by 邓翔 on 2017/4/26.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

#if os(iOS) || os(tvOS)
    
    import UIKit
    
    // MARK: UICollectionViewCell
    
    extension UICollectionView {
        
        public typealias CellReuseIdentifier = CellReuseIdentifiers.Identifier
        
        public class CellReuseIdentifiers {}
    }
    
    extension UICollectionView.CellReuseIdentifiers {
        
        public class Identifier<T: UICollectionViewCell>: UICollectionView.CellReuseIdentifiers, RawRepresentable {
            
            public let rawValue: String
            
            public required init(rawValue: String) {
                self.rawValue = rawValue
            }
        }
    }
    
    extension UICollectionView.CellReuseIdentifier: Hashable, ExpressibleByStringLiteral {}
    
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
        
        public typealias SupplementaryViewReuseIdentifier = SupplementaryViewReuseIdentifiers.SupplementaryViewReuseIdentifier
        
        public class SupplementaryViewReuseIdentifiers {}
    }
    
    extension UICollectionView.SupplementaryViewReuseIdentifiers {
        
        public class SupplementaryViewReuseIdentifier<T: UICollectionReusableView>: UICollectionView.SupplementaryViewReuseIdentifiers, RawRepresentable {
            
            public let rawValue: String
            
            public required init(rawValue: String) {
                self.rawValue = rawValue
            }
        }
    }
    
    extension UICollectionView.SupplementaryViewReuseIdentifier: Hashable, ExpressibleByStringLiteral {}
    
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
