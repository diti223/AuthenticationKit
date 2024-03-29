import Foundation
import Combine

public class AuthenticationViewModel: ObservableObject {
    @Published public var user: User?
    @Published public var errorMessage: String?
    @Published public var message: String?
    
    public let authenticationUseCase: AuthenticationUseCase
    
    public init(authenticationUseCase: AuthenticationUseCase) {
        self.authenticationUseCase = authenticationUseCase
    }
    
    public func login(username: String, password: String) async {
        do {
            
            self.user = try await authenticationUseCase.login(username: username, password: password)
            if user?.isNewUser == true {
                message = "Welcome, new user!"
            }
        } catch {
            errorMessage = "Login failed: \(error.localizedDescription)"
        }
    }
}
