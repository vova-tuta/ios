import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var isLoggedIn = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var hasValidationError = false
    @Environment(\.dismiss) private var dismiss
    
    private let apiService: APIServiceProtocol = APIService()
    private let tokenStorage: TokenStorageProtocol = TokenStorage()
    private let userStorage: UserStorageProtocol = UserStorage.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("Войти в ШОК")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 60)
                    .padding(.bottom, 40)
                    .accessibilityIdentifier("loginTitle")
                
                VStack(spacing: 20) {
                    VStack(spacing: 0) {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .font(.system(size: 16))
                            .padding(.horizontal, 16)
                            .frame(height: 56)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(hasValidationError ? Color.red : Color.clear, lineWidth: 2)
                            )
                            .contentShape(Rectangle())
                            .accessibilityIdentifier("emailField")
                            .onChange(of: email) { _ in
                                if hasValidationError {
                                    hasValidationError = false
                                }
                            }
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 8) {
                        SecureField("Пароль", text: $password)
                            .font(.system(size: 16))
                            .padding(.horizontal, 16)
                            .frame(height: 56)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(hasValidationError ? Color.red : Color.clear, lineWidth: 2)
                            )
                            .contentShape(Rectangle())
                            .accessibilityIdentifier("passwordField")
                            .onChange(of: password) { _ in
                                if hasValidationError {
                                    hasValidationError = false
                                }
                            }
                        
                        if hasValidationError {
                            HStack {
                                Text("Email или пароль неправильные")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                                    .accessibilityIdentifier("validationError")
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    HStack(spacing: 10) {
                        Button(action: performLogin) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                Text(isLoading ? "Вход..." : "В шок")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background((isLoading || email.isEmpty || password.isEmpty) ? Color(red: 88/255, green: 153/255, blue: 227/255) : Color(red: 0.3, green: 0.5, blue: 1.0))
                            .cornerRadius(12)
                        }
                        .disabled(isLoading || email.isEmpty || password.isEmpty)
                        .accessibilityIdentifier("loginButton")
                        
                        Button(action: { dismiss() }) {
                            Text("Назад")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(red: 108/255, green: 117/255, blue: 125/255))
                                .cornerRadius(12)
                        }
                        .accessibilityIdentifier("backButton")
                    }
                    .padding(.horizontal, 20)
                    
                    NavigationLink(destination: RegisterView()) {
                        Text("Регистрация")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0.3, green: 0.5, blue: 1.0))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .accessibilityIdentifier("registerButton")
                }
                
                Spacer()
            }
            .background(Color.white)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $isLoggedIn) {
            ProfileView()
        }
        .alert("Ошибка", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func performLogin() {
        guard !email.isEmpty && !password.isEmpty else { return }
        
        isLoading = true
        hasValidationError = false
        
        Task {
            do {
                let response = try await apiService.login(email: email, password: password)
                await MainActor.run {
                    tokenStorage.saveToken(response.token)
                    userStorage.saveUser(response.user)
                    isLoggedIn = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    
                    if let apiError = error as? APIError,
                       case .serverError(422) = apiError {
                        hasValidationError = true
                    } else {
                        alertMessage = "Произошла ошибка: \(error.localizedDescription)"
                        showAlert = true
                    }
                }
            }
        }
    }
}

#Preview {
    LoginView()
} 