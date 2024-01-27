//
//  File.swift
//  
//
//  Created by Adrian Bilescu on 27.01.2024.
//

import Foundation

public struct AuthenticationUseCaseInterceptor: AuthenticationUseCase {
    public let useCase: AuthenticationUseCase
    public let interceptor: (User) -> Void
    
    public init(useCase: AuthenticationUseCase, interceptor: @escaping (User) -> Void) {
        self.useCase = useCase
        self.interceptor = interceptor
    }
    
    public func login(username: String, password: String) async throws -> User {
        let user = try await useCase.login(
            username: username,
            password: password
        )
        interceptor(user)
        return user
    }
}
