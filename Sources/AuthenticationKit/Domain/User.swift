//
//  File.swift
//  
//
//  Created by Adrian Bilescu on 27.01.2024.
//

import Foundation

public struct User {
    public let email: String
    public let firstName: String
    public let lastName: String
    public var isNewUser: Bool
    
    public init(email: String, firstName: String, lastName: String, isNewUser: Bool) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.isNewUser = isNewUser
    }
}
