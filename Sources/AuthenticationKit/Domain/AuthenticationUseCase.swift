//
//  File.swift
//  
//
//  Created by Adrian Bilescu on 27.01.2024.
//

import Foundation

public protocol AuthenticationUseCase {
    func login(username: String, password: String) async throws -> User
}

