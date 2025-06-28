import Foundation

protocol TokenStorageProtocol {
    func saveToken(_ token: String)
    func getToken() -> String?
    func deleteToken()
}

class TokenStorage: TokenStorageProtocol {
    private let tokenKey = "auth_token"
    
    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }
    
    func deleteToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
} 