//
//  File.swift
//  
//
//  Created by Adrian Bilescu on 27.01.2024.
//

import SwiftUI

struct ExampleView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        Text("Login")
            .font(.title)
            .padding(20)
        
        VStack {
            TextField("Email", text: $username)
            TextField("Password", text: $password)
            Button(action: {
                Task {
                    await viewModel.login(username: username, password: password)
                }
            }, label: {
                Text("Login").frame(minWidth: 100)
            })
        }
        .textFieldStyle(.roundedBorder)
        .padding(20)
        .alert(message: $viewModel.errorMessage)
        .alert(message: $viewModel.message)
    }
}

#Preview("New User") {
    ExampleView(
        viewModel: AuthenticationViewModel(authenticationUseCase: PreviewAuthenticationUseCase(isNewUser: true))
    )
}

#Preview("Error") {
    ExampleView(
        viewModel: AuthenticationViewModel(authenticationUseCase: PreviewFailureAuthenticationUseCase(error: SomeError()))
    )
}

#Preview {
    ExampleView(
        viewModel: AuthenticationViewModel(authenticationUseCase: PreviewAuthenticationUseCase(isNewUser: false))
    )
}


struct SomeError: LocalizedError {
    var errorDescription: String? {
        "Preview Error"
    }
}

private struct PreviewAuthenticationUseCase: AuthenticationUseCase {
    let isNewUser: Bool
    func login(username: String, password: String) async throws -> User {
        User(email: "Email", firstName: "First", lastName: "Last", isNewUser: isNewUser)
    }
}

private struct PreviewFailureAuthenticationUseCase: AuthenticationUseCase {
    let error: Error
    func login(username: String, password: String) async throws -> User {
        throw error
    }
}
