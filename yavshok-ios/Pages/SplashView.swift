import SwiftUI

struct SplashView: View {
    @State private var isLoading = true
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var shouldExit = false
    @State private var isLoggedIn = false
    
    private let apiService: APIServiceProtocol = APIService()
    private let experimentsStorage = ExperimentsStorage.shared
    private let tokenStorage: TokenStorageProtocol = TokenStorage()
    private let userStorage: UserStorageProtocol = UserStorage.shared
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            if isLoading {
                BundleImageView(imageName: "photo_1", fileExtension: "jpg")
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .accessibilityIdentifier("splashImage")
            } else if !shouldExit {
                if isLoggedIn {
                    ProfileView()
                        .transition(.opacity)
                } else {
                    ContentView()
                        .transition(.opacity)
                }
            }
        }
        .onAppear {
            loadExperiments()
        }
        .alert("Ошибка загрузки", isPresented: $showAlert) {
            Button("OK") {
                exit(1)
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func loadExperiments() {
        Task {
            do {
                let experiments = try await apiService.getExperiments()
                await MainActor.run {
                    experimentsStorage.saveExperiments(experiments)
                    checkExistingSession()
                    withAnimation(.easeOut(duration: 0.5)) {
                        isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Не удалось загрузить конфигурацию приложения: \(error.localizedDescription)"
                    showAlert = true
                    shouldExit = true
                }
            }
        }
    }
    
    private func checkExistingSession() {
        if let _ = tokenStorage.getToken(),
           let _ = userStorage.getUser() {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }
    }
}

#Preview {
    SplashView()
} 