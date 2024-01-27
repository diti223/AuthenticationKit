This is my take on refactoring the `AuthenticationViewModel`.
With the Open/Closed Principle in mind, I've leveraged the usage of an abstract `AuthenticationUseCase` to delegate the complexity outside of the view model.
This abstraction allowed for easy composition & decoration, splitting multiple responsibilities into smaller components.
Even though the example is quite small, and such separation wouldn't be justified for this simple use case. I used my imagination to think of a bigger context, a bigger app that would probably have multiple API calls but also about testing.

**Original demo code `AuthenticationViewModel`**

```swift
class AuthenticationViewModel {
    @Published var errorMessage: String?
    @Published var message: String?
    let service: AuthenticationService
    let userDefault: UserDefaults
    let userSession: UserSession
    
    init(
        service: AuthenticationService,
        userDefault: UserDefaults = .standard,
        userSession: UserSession = .shared
    ) {
        self.service = service
        self.userDefault = userDefault
        self.userSession = userSession
    }
    
    public func login(username: String, password: String) async throws {
        guard !username.isEmpty, !password.isEmpty else {
            throw ValidationError.invalidCredentials
        }
        
        do {
            let user = try await service.login(
                username: username,
                password: password
            )
            if user.isNewUser {
                message = "Welcome, new user!"
            }
            
            userSession.currentUser = user
            userSession.isLoggedIn = true
            
            userDefault.set(username, forKey: "username")
            userDefault.set(password, forKey: "password")
        } catch {
            errorMessage = "Login failed: \(error.localizedDescription)"
        }
    }
}
```

**Refactored AuthenticationViewModel**
```swift
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

```


During the refactoring, the view model has been left with little responsibilities, besides managing the states.
The actual service has become just one abstract use case, implemented with `APIAuthenticationUseCase`. 
In this API use case, demonstrates a scenario where the structure and values received differ substantially from that of the domain. In order to map the responses, I've used `APIUserResponse` and `APIFetchTokenUseCaseResponse`.

```swift
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
```

The storage logic has been moved to Keychain, to the relief of many developers that saw the code before.
The entire dependencies management has been constructed in `MainRoot` to demonstrate how complexity can be composed, leaving the view model more simple and elegant, but in the end, delivering the same functionality.

```swift
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
```


