//
//  DataCoder.swift
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

protocol DataEncoder {
    func encode<T>(_ value: T) throws -> Data where T : Encodable
}

protocol DataDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}

extension Encodable {
    func encodedData(encoder: DataEncoder) throws -> Data {
        return try encoder.encode(self)
    }
}

extension Decodable {
    init(data: Data, decoder: DataDecoder) throws {
        self = try decoder.decode(Self.self, from: data)
    }
}

extension JSONEncoder: DataEncoder {}
extension JSONDecoder: DataDecoder {}

extension PropertyListEncoder: DataEncoder {}
extension PropertyListDecoder: DataDecoder {}

// MARK: - AnyEncodable

extension DataEncoder {
    
    /// Encode arbitrary value. This method is called `encodeAny(_:)` instead of `encode(_:)` to disambiguate it from overload.
    func encodeAny(_ any: Any) throws -> Data {
        let t = AnyEncodable(value: any)
        return try encode(t)
    }
}

private struct AnyEncodable: Encodable {
    
    let value: Any
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let encodable as Encodable:
            try encodable.encode(to: &container)
        case let optional as AnyOptionalType:
            try container.encode(optional.anyWrapped.map(AnyEncodable.init))
        case let array as [Any]:
            try container.encode(array.map(AnyEncodable.init))
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues(AnyEncodable.init))
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyEncodable value cannot be encoded")
            throw EncodingError.invalidValue(self.value, context)
        }
        
    }
}

private extension Encodable {
    
    func encode(to container: inout SingleValueEncodingContainer) throws {
        try container.encode(self)
    }
}

// MARK: - AnyDecodable

extension DataDecoder {
    
    func decodeAny(from data: Data) throws -> Any {
        return try decode(AnyDecodable.self, from: data)
    }
}

private struct AnyDecodable: Decodable {
    
    static let decodeNilValue: Void = ()
    
    static let candidateTrivialType: [Decodable.Type] = [
        Bool.self,
        Int.self,
        UInt.self,
        Double.self,
        String.self
    ]
    
    static let candidateCollectionType: [Decodable.Type] = [
        [AnyDecodable].self,
        [String: AnyDecodable].self
    ]
    
    static var candidateType: [Decodable.Type] {
        return candidateTrivialType + candidateCollectionType
    }
    
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        guard !container.decodeNil() else {
            self.init(AnyDecodable.decodeNilValue)
            return
        }
        
        for type in AnyDecodable.candidateType {
            if let value = try? type.decode(from: container) {
                self.init(value)
                return
            }
        }
        
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyDecodable value cannot be decoded")
    }
}

private extension Decodable {
    
    static func decode(from container: SingleValueDecodingContainer) throws -> Self {
        return try container.decode(Self.self)
    }
}
