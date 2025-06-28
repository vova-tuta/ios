import SwiftUI

struct MainView: View {
    @State private var email = ""
    @State private var isLoading = false
    @State private var emailExists: Bool? = nil
    @State private var showConfetti = false
    @State private var errorMessage: String? = nil
    
    private let apiService: APIServiceProtocol = APIService()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("Я в ШОКе")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 60)
                    .padding(.bottom, 40)
                    .accessibilityIdentifier("mainTitle")
                
                VStack(spacing: 20) {
                    emailTextField
                    
                    if let emailExists = emailExists {
                        if emailExists {
                            successStateContent
                        } else {
                            failureStateContent
                        }
                    }
                    
                    checkButton
                    navigationButton
                    
                    if let errorMessage = errorMessage {
                        errorText
                    }
                }
                
                Spacer()
            }
            .background(Color.white)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .displayConfetti(isActive: $showConfetti)
    }
    
    private var emailTextField: some View {
        TextField(emailExists == nil ? "Email" : "Введите email", text: $email)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .font(.system(size: 16))
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal, 20)
            .accessibilityIdentifier(emailExists == nil ? "emailInput" : (emailExists! ? "successEmailInput" : "failureEmailInput"))
    }
    
    private var checkButton: some View {
        Button(action: checkEmail) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                Text(isLoading ? "Проверяю..." : "Я в шоке?")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(checkButtonColor)
            .cornerRadius(12)
        }
        .disabled(isLoading)
        .accessibilityIdentifier(emailExists == nil ? "checkButton" : (emailExists! ? "recheckButton" : "failureRecheckButton"))
        .padding(.horizontal, 20)
    }
    
    private var navigationButton: some View {
        NavigationLink(destination: LoginView()) {
            Text("В шок")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(red: 0.3, green: 0.5, blue: 1.0))
                .cornerRadius(12)
        }
        .accessibilityIdentifier(emailExists == nil ? "navigationButton" : (emailExists! ? "successNavigationButton" : "failureNavigationButton"))
        .padding(.horizontal, 20)
    }
    
    private var errorText: some View {
        Text(errorMessage ?? "")
            .font(.system(size: 14))
            .foregroundColor(.red)
            .padding(.horizontal, 20)
            .accessibilityIdentifier("errorMessage")
    }
    
    private var successStateContent: some View {
        VStack(spacing: 20) {
            GIFView(gifName: "cat")
                .frame(maxWidth: .infinity)
                .frame(minHeight: 200, maxHeight: 300)
                .clipped()
                .cornerRadius(12)
                .padding(.horizontal, 20)
            
            Text("Ты уже в ШОКе")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.green)
                .accessibilityIdentifier("successText")
        }
        .onAppear {
            triggerConfetti()
        }
    }
    
    private var failureStateContent: some View {
        Text("Ты еще не в ШОКе")
            .font(.system(size: 24, weight: .medium))
            .foregroundColor(.red)
            .padding(.vertical, 20)
            .accessibilityIdentifier("failureText")
    }
    
    private var checkButtonColor: Color {
        return email.isEmpty ? 
            Color(red: 204/255, green: 204/255, blue: 204/255) : 
            Color(red: 108/255, green: 117/255, blue: 125/255)
    }
    
    private func checkEmail() {
        guard !email.isEmpty else { return }
        
        emailExists = nil
        errorMessage = nil
        showConfetti = false
        isLoading = true
        
        Task {
            do {
                let response = try await apiService.checkEmailExist(email: email)
                await MainActor.run {
                    self.emailExists = response.exist
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Ошибка при проверке: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    

    
    private func triggerConfetti() {
        showConfetti = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showConfetti = false
        }
    }
}







#Preview {
    MainView()
} 