//
//  File.swift
//  
//
//  Created by Adrian Bilescu on 27.01.2024.
//

import Foundation

public class MainRoot {
    public let httpClient: HTTPClient
    public let secureStorage: SecureStorage
    public var currentUser: User?
    
    init(
        httpClient: HTTPClient = URLSessionClient(
            baseURL: URL(string: "https://apple.com/")!,
            session: .shared
        ),
        secureStorage: SecureStorage = KeychainStorage()
    ) {
        self.httpClient = httpClient
        self.secureStorage = secureStorage
    }
    
    private static let tokenKey: String = "kAccessToken"
    
    private func makeAPIUseCase() -> APIAuthenticationUseCase {
        APIAuthenticationUseCase(
            httpClient: httpClient,
            tokenStore: { [weak self] token in
                let encoder = JSONEncoder()
                self?.secureStorage.store(data: try! encoder.encode(token), key: Self.tokenKey)
            }
        )
    }
    
    public func makeViewModel() -> AuthenticationViewModel {
        let useCase = makeAPIUseCase()
            .addValidation()
            .intercept { [weak self] user in
                self?.currentUser = user
            }
            
        
        let viewModel = AuthenticationViewModel(
            authenticationUseCase: useCase
        )
        
        return viewModel
    }
}
