//
//  File.swift
//  
//
//  Created by Adrian Bilescu on 27.01.2024.
//

import Foundation

public protocol HTTPClient {
    func request(_ request: HTTPRequest) async throws -> HTTPResponse
}

public enum HTTPMethod {
    case get, post
}

public struct HTTPRequest {
    public var headers: [String: String]
    public var method: HTTPMethod
    public let path: String
    public var body: Data?
    
    public init(
        headers: [String : String] = [:],
        method: HTTPMethod = .get,
        path: String,
        body: Data? = nil
    ) {
        self.headers = headers
        self.method = method
        self.path = path
        self.body = body
    }
}

public struct HTTPResponse {
    public let body: Data
    public let status: Int
    
    public init(
        body: Data,
        status: Int
    ) {
        self.body = body
        self.status = status
    }
}
