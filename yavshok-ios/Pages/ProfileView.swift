import SwiftUI

struct BundleImageView: View {
    let imageName: String
    let fileExtension: String
    
    var body: some View {
        if let bundlePath = Bundle.main.path(forResource: imageName, ofType: fileExtension),
           let uiImage = UIImage(contentsOfFile: bundlePath) {
            Image(uiImage: uiImage)
                .resizable()
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
        }
    }
}

struct ProfileView: View {
    @State private var user: User?
    @State private var showingMainView = false
    @State private var showingEditProfile = false
    @State private var ageDescription = "Ты молоденькиий котик"
    
    private let userStorage: UserStorageProtocol = UserStorage.shared
    private let tokenStorage: TokenStorageProtocol = TokenStorage()
    private let experimentsStorage = ExperimentsStorage.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 16) {
                        HStack(alignment: .center, spacing: 16) {
                            GIFView(gifName: "profile", contentMode: .scaleAspectFill)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .accessibilityIdentifier("profileImage")
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user?.name ?? "Имя пользователя")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                    .accessibilityIdentifier("userName")
                                
                                Text(ageDescription)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .accessibilityIdentifier("ageLabel")
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        HStack(spacing: 0) {
                            HStack(spacing: 20) {
                                VStack(spacing: 4) {
                                    Text("42")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.black)
                                    Text("Постов")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                .accessibilityIdentifier("postsCount")
                                
                                VStack(spacing: 4) {
                                    Text("567")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.black)
                                    Text("Подписчиков")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                .accessibilityIdentifier("followersCount")
                                
                                VStack(spacing: 4) {
                                    Text("890")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.black)
                                    Text("Лайков")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                .accessibilityIdentifier("likesCount")
                            }
                            .padding(.leading, 20)
                            
                            Spacer()
                            
                            Button(action: logout) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 24))
                                    .foregroundColor(.black)
                            }
                            .accessibilityIdentifier("logoutButton")
                            .padding(.trailing, 20)
                        }
                        .padding(.vertical, 16)
                        
                        Button(action: {
                            showingEditProfile = true
                        }) {
                            Text("Редактировать профиль")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                )
                        }
                        .accessibilityIdentifier("editProfileButton")
                        .padding(.horizontal, 20)
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 1), count: 3), spacing: 1) {
                        ForEach(1...4, id: \.self) { index in
                            BundleImageView(imageName: "photo_\(index)", fileExtension: "jpg")
                                .aspectRatio(1, contentMode: .fill)
                                .clipped()
                                .accessibilityIdentifier("photo\(index)")
                        }
                    }
                    .padding(.horizontal, 1)
                    .padding(.top, 20)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
        .onAppear {
            loadUserData()
        }
        .fullScreenCover(isPresented: $showingMainView) {
            ContentView()
        }
        .sheet(isPresented: $showingEditProfile, onDismiss: {
            loadUserData()
        }) {
            EditProfileView()
        }
    }
    
    private func loadUserData() {
        user = userStorage.getUser()
        updateAgeDescription()
    }
    
    private func updateAgeDescription() {
        guard let user = user,
              let age = user.age,
              let experiments = experimentsStorage.getExperiments() else {
            ageDescription = "Ты молоденькиий котик"
            return
        }
        
        let ageExperiment = experiments.flags.age
        
        if !ageExperiment.enabled {
            ageDescription = "Ты молоденькиий котик"
            return
        }
        
        if age >= ageExperiment.young.from && age <= ageExperiment.young.to {
            ageDescription = "Ты молоденькиий котик"
        } else if age >= ageExperiment.adult.from && age <= ageExperiment.adult.to {
            ageDescription = "Ты взрослый котик"
        } else if age >= ageExperiment.old.from && age <= ageExperiment.old.to {
            ageDescription = "Ты старый котик"
        } else {
            ageDescription = "Ты молоденькиий котик"
        }
    }
    
    private func logout() {
        tokenStorage.deleteToken()
        userStorage.clearUser()
        showingMainView = true
    }
}

#Preview {
    ProfileView()
} 