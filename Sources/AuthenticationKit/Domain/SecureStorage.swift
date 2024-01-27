//
//  File.swift
//  
//
//  Created by Adrian Bilescu on 27.01.2024.
//

import Foundation

public protocol SecureStorage {
    func store(data: Data, key: String)
    func fetchData(for key: String) -> Data?
}
