import Foundation

protocol APIServiceProtocol {
    func checkEmailExist(email: String) async throws -> EmailExistResponse
    func login(email: String, password: String) async throws -> LoginResponse
    func register(email: String, password: String, age: Int?) async throws -> LoginResponse
    func getExperiments() async throws -> ExperimentsResponse
    func updateUserName(name: String) async throws -> UpdateUserNameResponse
}

class APIService: APIServiceProtocol {
    private let baseURL = "https://api.yavshok.ru"
    private let session = URLSession.shared
    
    func checkEmailExist(email: String) async throws -> EmailExistResponse {
        guard let url = URL(string: "\(baseURL)/exist") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = EmailExistRequest(email: email)
        let jsonData = try JSONEncoder().encode(requestBody)
        request.httpBody = jsonData
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        let decodedResponse = try JSONDecoder().decode(EmailExistResponse.self, from: data)
        return decodedResponse
    }
    
    func login(email: String, password: String) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = LoginRequest(email: email, password: password)
        let jsonData = try JSONEncoder().encode(requestBody)
        request.httpBody = jsonData
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        let decodedResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        return decodedResponse
    }
    
    func register(email: String, password: String, age: Int?) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/auth/register") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = RegisterRequest(email: email, password: password, age: age)
        let jsonData = try JSONEncoder().encode(requestBody)
        request.httpBody = jsonData
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        let decodedResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        return decodedResponse
    }
    
    func getExperiments() async throws -> ExperimentsResponse {
        guard let url = URL(string: "\(baseURL)/experiments") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        let decodedResponse = try JSONDecoder().decode(ExperimentsResponse.self, from: data)
        return decodedResponse
    }
    
    func updateUserName(name: String) async throws -> UpdateUserNameResponse {
        guard let url = URL(string: "\(baseURL)/user/name") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header
        let tokenStorage = TokenStorage()
        if let token = tokenStorage.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw APIError.serverError(401)
        }
        
        let requestBody = UpdateUserNameRequest(name: name)
        let jsonData = try JSONEncoder().encode(requestBody)
        request.httpBody = jsonData
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        let decodedResponse = try JSONDecoder().decode(UpdateUserNameResponse.self, from: data)
        return decodedResponse
    }
}

// MARK: - API Errors
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
} 