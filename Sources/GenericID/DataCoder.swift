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
