//
//  File.swift
//  
//
//  Created by Adrian Bilescu on 27.01.2024.
//

import Foundation

struct APIFetchTokenUseCase {
    let jsonDecoder: JSONDecoder
    let jsonEncoder: JSONEncoder
    let httpClient: HTTPClient
    
    func fetch(username: String, password: String) async throws -> Token {
        let request = APIFetchTokenUseCaseRequest(username: username, password: password)
        let requestData = try jsonEncoder.encode(request)
        
        let responseData = try await httpClient.request(
            HTTPRequest(
                method: .post,
                path: "/auth",
                body: requestData
            )
        ).body
        
        
        let response = try jsonDecoder.decode(APIFetchTokenUseCaseResponse.self, from: responseData)
        
        return response.accessToken
    }
}



private struct APIFetchTokenUseCaseRequest: Encodable {
    let username: String
    let password: String
}

private struct APIFetchTokenUseCaseResponse: Decodable {
    let accessToken: String
    let idToken: String
}
