import SwiftUI
import FirebaseAuth

struct Settings: View {
    @State private var isNotificationEnabled: Bool = true
    @State private var navigateToOnboarding: Bool = false // State to handle navigation to onboarding

    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
            HStack {
                Spacer()
                
                Image("notification-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 15)
                
                Image("profile-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 20)
            }
            .padding(.top, 50)
            .padding(.bottom, 10)
            
            // Settings Title
            Text("Settings")
                .font(.custom("Heebo-Bold", size: 18))
                .foregroundColor(Color(hexValue: "#606084"))
                .padding(.top, 10)
                .padding(.bottom, 20)
            
            // Settings Options
            VStack(spacing: 0) {
                HStack {
                    Image("notification-normal")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    Text("Notification")
                        .font(.custom("Heebo-Regular", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    if isNotificationEnabled {
                        Image("tick-squrae-icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                }
                .padding(.vertical, 15)
                .padding(.horizontal, 20)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.leading, 20)
                
                HStack {
                    Image("shield-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    Text("Privacy Policy")
                        .font(.custom("Heebo-Regular", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 10)
                    
                    Spacer()
                }
                .padding(.vertical, 15)
                .padding(.horizontal, 20)
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Spacer() // Push the logout button and navigation bar to the bottom
            
            // Logout Button
            Button(action: {
                logout()
            }) {
                Text("Logout")
                    .font(.custom("Heebo-Bold", size: 16))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            
            // Bottom Navigation Bar
            VStack(spacing: 0) {
                Divider()
                HStack {
                    NavigationLink(destination: Home()) {
                        BottomNavItem(iconName: "home-icon", title: "Home", isActive: false)
                    }
                    
                    Spacer()
                    NavigationLink(destination: Wishlist()) {
                        BottomNavItem(iconName: "heart-icon", title: "Favorites", isActive: false)
                    }
                    Spacer()
                    NavigationLink(destination: Settings()) {
                        BottomNavItem(iconName: "settings-icon", title: "Settings", isActive: true)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 10)
                .background(Color(hexValue: "#102A36")) // Dark color as per style guide
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 0)
                .padding(.bottom, 20) // Padding to ensure it doesn't overlap with the home indicator area
            }
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .background(
            NavigationLink(
                destination: onboarding(), // Navigate to onboarding screen
                isActive: $navigateToOnboarding
            ) {
                EmptyView()
            }
            .hidden()
        )
    }
    
    private func logout() {
        do {
            // Sign out from Firebase
            try Auth.auth().signOut()
            
            // Clear user ID from UserDefaults
            UserDefaults.standard.removeObject(forKey: "userID")
            
            // Navigate to onboarding screen
            navigateToOnboarding = true
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

// Custom extension for color initialization using hex values
//extension Color {
//    init(hexValue: String) {
//        let scanner = Scanner(string: hexValue)
//        _ = scanner.scanString("#")
//        
//        var rgb: UInt64 = 0
//        scanner.scanHexInt64(&rgb)
//        
//        let red = Double((rgb >> 16) & 0xFF) / 255.0
//        let green = Double((rgb >> 8) & 0xFF) / 255.0
//        let blue = Double(rgb & 0xFF) / 255.0
//        
//        self.init(red: red, green: green, blue: blue)
//    }
//}

// Preview for SwiftUI canvas
struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
