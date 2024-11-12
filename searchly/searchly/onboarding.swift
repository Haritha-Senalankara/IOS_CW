import SwiftUI

struct onboarding: View {
    @State private var navigateToLoginSignup = false // State to trigger navigation
    @State private var navigateToHome = false // State to navigate directly to Home()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                Image("App Logo") // Make sure this matches the image in your assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 133, height: 121)
                    .padding(.top, 40)
                
                Text("Get Started with Your\n Account")
                    .font(.custom("Heebo-Bold", size: 26))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "#102A36"))
                    .padding(.top, 24)
                
                Text("Find the best deals online and locally. Filter products by price, location, and ratings to ensure you get the best value. Connect directly with vendors for quick and easy access to great offers.")
                    .font(.custom("Heebo-Regular", size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "#606084"))
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                Spacer()
                
                VStack(spacing: 28) {
                    Button(action: {
                        navigateToLoginSignup = true // Trigger navigation
                    }) {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#F2A213"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 30)
                    
                    Button(action: {
                        navigateToLoginSignup = true // Trigger navigation
                    }) {
                        Text("Create A Profile")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: "#F2A213"), lineWidth: 2)
                            )
                            .foregroundColor(Color(hex: "#F2A213"))
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.top, 50)
                Spacer(minLength: 160)
//                Button(action: {
//                    // Skip action (you can define behavior here if needed)
//                }) {
//                    Text("I'll do it later")
//                        .font(.custom("Heebo-Regular", size: 14))
//                        .foregroundColor(Color(hex: "#102A36"))
//                }
//                .padding(.top, 120)
//                .padding(.bottom, 30)
                
                Spacer()
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .background(
                NavigationLink(
                    destination: Login_or_Signup(), // Navigate to Login_or_Signup view
                    isActive: $navigateToLoginSignup
                ) {
                    EmptyView()
                }
                .hidden()
            )
            .background(
                NavigationLink(
                    destination: Home(), // Navigate to Home view
                    isActive: $navigateToHome
                ) {
                    EmptyView()
                }
                .hidden()
            )
            .onAppear {
                checkUserStatus()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Prevent nested NavigationViews
        .navigationBarBackButtonHidden(true)
    }

    // Check if the user is already logged in
    private func checkUserStatus() {
        if let _ = UserDefaults.standard.string(forKey: "userID") {
            // If userID is found, navigate to Home
            navigateToHome = true
        }
    }
}
//
//extension Color {
//    init(hex: String) {
//        let scanner = Scanner(string: hex)
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

#Preview {
    onboarding()
}
