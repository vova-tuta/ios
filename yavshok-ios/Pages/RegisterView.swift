import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var age = ""
    @State private var isLoading = false
    @State private var isRegistered = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var hasValidationError = false
    @Environment(\.dismiss) private var dismiss
    
    private let apiService: APIServiceProtocol = APIService()
    private let tokenStorage: TokenStorageProtocol = TokenStorage()
    private let userStorage: UserStorageProtocol = UserStorage.shared
    
    private var isFormValid: Bool {
        return !email.isEmpty && 
               email.count <= 50 &&
               !password.isEmpty && 
               password.count >= 5 && 
               password.count <= 20 &&
               !age.isEmpty &&
               Int(age) != nil &&
               Int(age)! >= 0 &&
               Int(age)! <= 99
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("Регистрация в ШОКе")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 60)
                    .padding(.bottom, 40)
                    .accessibilityIdentifier("registerTitle")
                
                VStack(spacing: 20) {
                    VStack(spacing: 0) {
                        TextField("Введите email", text: $email)
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
                            .onChange(of: email) { newValue in
                                if newValue.count > 50 {
                                    email = String(newValue.prefix(50))
                                }
                                if hasValidationError {
                                    hasValidationError = false
                                }
                            }
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 0) {
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
                            .onChange(of: password) { newValue in
                                if newValue.count > 20 {
                                    password = String(newValue.prefix(20))
                                }
                                if hasValidationError {
                                    hasValidationError = false
                                }
                            }
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 8) {
                        TextField("Возраст", text: $age)
                            .keyboardType(.numberPad)
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
                            .accessibilityIdentifier("ageField")
                            .onChange(of: age) { newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                if let ageInt = Int(filtered), ageInt > 99 {
                                    age = "99"
                                } else {
                                    age = filtered
                                }
                                if hasValidationError {
                                    hasValidationError = false
                                }
                            }
                        
                        if hasValidationError {
                            HStack {
                                Text("Пользователь уже зарегистрирован")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                                    .accessibilityIdentifier("validationError")
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Button(action: performRegister) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(isLoading ? "Регистрация..." : "Зарегистрироваться")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background((isLoading || !isFormValid) ? Color(red: 88/255, green: 153/255, blue: 227/255) : Color(red: 0.3, green: 0.5, blue: 1.0))
                        .cornerRadius(12)
                    }
                    .disabled(isLoading || !isFormValid)
                    .accessibilityIdentifier("registerButton")
                    .padding(.horizontal, 20)
                    
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
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .background(Color.white)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $isRegistered) {
            ProfileView()
        }
        .alert("Ошибка", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func performRegister() {
        guard isFormValid else { return }
        
        isLoading = true
        hasValidationError = false
        
        let ageValue = Int(age)!
        
        Task {
            do {
                let response = try await apiService.register(email: email, password: password, age: ageValue)
                await MainActor.run {
                    tokenStorage.saveToken(response.token)
                    userStorage.saveUser(response.user)
                    isRegistered = true
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
    RegisterView()
} 