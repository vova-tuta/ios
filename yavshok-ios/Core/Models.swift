import Foundation

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let age: Int?
}

struct LoginResponse: Codable {
    let token: String
    let user: User
}

struct User: Codable {
    let id: Int
    let email: String
    let name: String
    let age: Int?
}

struct EmailExistRequest: Codable {
    let email: String
}

struct EmailExistResponse: Codable {
    let exist: Bool
}

struct ExperimentsResponse: Codable {
    let flags: ExperimentFlags
}

struct ExperimentFlags: Codable {
    let age: AgeExperiment
}

struct AgeExperiment: Codable {
    let enabled: Bool
    let young: AgeRange
    let adult: AgeRange
    let old: AgeRange
    let oldFrom: Int
    let youngFrom: Int
}

struct AgeRange: Codable {
    let from: Int
    let to: Int
}

struct UpdateUserNameRequest: Codable {
    let name: String
}

struct UpdateUserNameResponse: Codable {
    let user: User
}

protocol UserStorageProtocol {
    func saveUser(_ user: User)
    func getUser() -> User?
    func clearUser()
}

class UserStorage: UserStorageProtocol {
    static let shared = UserStorage()
    
    private let userKey = "current_user"
    
    private init() {}
    
    func saveUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
        }
    }
    
    func getUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: userKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }
    
    func clearUser() {
        UserDefaults.standard.removeObject(forKey: userKey)
    }
} 