//
//  File.swift
//  
//
//  Created by Adrian Bilescu on 27.01.2024.
//

import Foundation

public typealias Token = String

public struct APIAuthenticationUseCase: AuthenticationUseCase {
    public let httpClient: HTTPClient
    public let tokenStore: (Token) -> Void
    
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    public let jsonEncoder = JSONEncoder()
    
    private var tokenUseCase: APIFetchTokenUseCase {
        APIFetchTokenUseCase(
            jsonDecoder: jsonDecoder,
            jsonEncoder: jsonEncoder,
            httpClient: httpClient
        )
    }
    
    public init(httpClient: HTTPClient, tokenStore: @escaping (Token) -> Void) {
        self.httpClient = httpClient
        self.tokenStore = tokenStore
    }
    
    
    
    public func login(username: String, password: String) async throws -> User {
        let token = try await tokenUseCase.fetch(
            username: username,
            password: password
        )
        
        tokenStore(token)
        
        let user = try await fetchUser(token: token)
        
        return user
    }
    
    private func fetchUser(token: String) async throws -> User {
        let responseData = try await httpClient.request(
            HTTPRequest(
                headers: ["Authorization": "Bearer \(token)"],
                method: .get,
                path: "/user"
            )
        ).body
        
        let apiResponse = try jsonDecoder.decode(APIUserResponse.self, from: responseData)
        
        return apiResponse.toUser()
    }
}

private struct APIUserResponse: Decodable {
    struct Name: Decodable {
        let firstName: String
        let lastName: String
    }
    
    let email: String
    let username: String
    let name: Name
    let lastAuthenticated: Date?
    
    func toUser() -> User {
        // mapping API data to domain model
        User(
            email: email,
            firstName: name.firstName,
            lastName: name.lastName,
            isNewUser: lastAuthenticated == nil
        )
    }
}
