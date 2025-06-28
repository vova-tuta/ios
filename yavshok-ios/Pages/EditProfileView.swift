import SwiftUI

struct EditProfileView: View {
    @State private var name: String = ""
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    private let apiService: APIServiceProtocol = APIService()
    private let userStorage: UserStorageProtocol = UserStorage.shared
    private let tokenStorage: TokenStorageProtocol = TokenStorage()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Редактировать профиль")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Имя")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    
                    TextField("Ваше имя", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 16))
                        .accessibilityIdentifier("nameField")
                }
                .padding(.horizontal, 20)
                
                VStack(spacing: 12) {
                    Button(action: saveChanges) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Сохранить изменения")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color(red: 88/255, green: 153/255, blue: 227/255) : Color.blue)
                    .cornerRadius(12)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                    .accessibilityIdentifier("saveButton")
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Отмена")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                    }
                    .accessibilityIdentifier("cancelButton")
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationBarHidden(true)
            .onAppear {
                loadCurrentName()
            }
            .alert("Ошибка", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func loadCurrentName() {
        if let user = userStorage.getUser() {
            name = user.name
        }
    }
    
    private func saveChanges() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            return
        }
        
        guard trimmedName.count <= 50 else {
            errorMessage = "Имя должно быть 50 символов или меньше"
            showingError = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let response = try await apiService.updateUserName(name: trimmedName)
                
                await MainActor.run {
                    userStorage.saveUser(response.user)
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    
                    if let apiError = error as? APIError {
                        switch apiError {
                        case .serverError(401):
                            errorMessage = "Сессия истекла. Пожалуйста, войдите снова."
                        case .serverError(422):
                            errorMessage = "Неверное имя. Пожалуйста, проверьте ваш ввод."
                        default:
                            errorMessage = apiError.localizedDescription
                        }
                    } else {
                        errorMessage = "Не удалось обновить имя. Пожалуйста, попробуйте снова."
                    }
                    
                    showingError = true
                }
            }
        }
    }
}

#Preview {
    EditProfileView()
} 