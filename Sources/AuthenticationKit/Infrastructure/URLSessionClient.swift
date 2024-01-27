//
//  File.swift
//  
//
//  Created by Adrian Bilescu on 27.01.2024.
//

import Foundation

public class URLSessionClient: HTTPClient {
    public let baseURL: URL
    public let session: URLSession
    
    public init(baseURL: URL, session: URLSession) {
        self.baseURL = baseURL
        self.session = session
    }
    
    public func request(_ request: HTTPRequest) async throws -> HTTPResponse {
        let url = baseURL.appendingPathComponent(request.path)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.toString()
        
        let (data, urlResponse) = try await session.data(for: urlRequest)
        
        guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
            throw UnsupportedURLResponseError()
        }
        
        return HTTPResponse(body: data, status: httpURLResponse.statusCode)
    }
}

public struct UnsupportedURLResponseError: Error {}

extension HTTPMethod {
    func toString() -> String {
        switch self {
            case .get:
                return "GET"
            case .post:
                return "POST"
        }
    }
}
