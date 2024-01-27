//
//  File.swift
//  
//
//  Created by Adrian Bilescu on 27.01.2024.
//

import Foundation

extension AuthenticationUseCase {
    public func intercept(_ interceptor: @escaping (User) -> Void) -> AuthenticationUseCase {
        AuthenticationUseCaseInterceptor(
            useCase: self,
            interceptor: interceptor
        )
    }
}
