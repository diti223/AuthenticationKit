//
//  File.swift
//  
//
//  Created by Adrian Bilescu on 27.01.2024.
//

import Foundation

struct AuthenticationUseCaseValidationDecorator: AuthenticationUseCase {
    let useCase: AuthenticationUseCase
    func login(username: String, password: String) async throws -> User {
        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !password.isEmpty else {
            throw InvalidCredentialsError()
        }
 
        return try await useCase.login(username: username, password: password)
    }
}

extension AuthenticationUseCase {
    func addValidation() -> AuthenticationUseCase {
        AuthenticationUseCaseValidationDecorator(useCase: self)
    }
}

struct InvalidCredentialsError: LocalizedError {
    var errorDescription: String? {
        "Username or password is invalid."
    }
}

