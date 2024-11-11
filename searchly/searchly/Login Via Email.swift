import SwiftUI
import FirebaseAuth

struct Login_Via_Email: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var showAlert = false
    @State private var navigateToSignup = false // State for navigation to signup
    @State private var navigateToHome = false  // State for navigation to home

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                Image("App Logo") // Make sure this matches the image in your assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 133, height: 121)
                    .padding(.top, 30)
                
                Text("Login")
                    .font(.custom("Heebo-Bold", size: 26))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "#102A36"))
                    .bold()
                    .padding(.bottom, 10)
                
                Text("Log in to track your favorite products, set price alerts and unlock many features.")
                    .font(.custom("Heebo-Regular", size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "#606084"))
                    .padding(.horizontal, 25)
                
                Spacer()
                
                VStack(spacing: 40) {
                    HStack {
                        TextField("Enter your email", text: $username)
                            .font(.custom("Heebo-Regular", size: 16))
                            .padding()
                            .padding(.horizontal, -15)
                        
                        if !username.isEmpty {
                            Button(action: {
                                username = ""
                            }) {
                                Image("icon-x")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                            }
                        }
                    }
                    .overlay(Rectangle().frame(height: 1).padding(.top, 20), alignment: .bottom)
                    .foregroundColor(Color.gray)
                    .padding(.horizontal, 30)
                    
                    HStack {
                        SecureField("Enter your password", text: $password)
                            .font(.custom("Heebo-Regular", size: 16))
                            .padding()
                            .padding(.horizontal, -15)
                        
                        if !password.isEmpty {
                            Button(action: {
                                password = ""
                            }) {
                                Image("icon-x")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                            }
                        }
                    }
                    .overlay(Rectangle().frame(height: 1).padding(.top, 35), alignment: .bottom)
                    .foregroundColor(Color.gray)
                    .padding(.horizontal, 30)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            // Forgot Password action
                        }) {
                            Text("Forgot Password?")
                                .font(.custom("Heebo-Regular", size: 14))
                                .foregroundColor(Color(hex: "#606084"))
                        }
                        .padding(.trailing, 30)
                        .padding(.bottom, 20)
                    }
                }
                
                Button(action: {
                    login()
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#F2A213"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Login"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
                
                Button(action: {
                    navigateToSignup = true // Navigate to signup
                }) {
                    Text("Sign Up")
                        .font(.custom("Heebo-Regular", size: 14))
                        .foregroundColor(Color(hex: "#102A36"))
                }
                .padding(.top, 80)
                
                Spacer()
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .background(
                Group {
                    NavigationLink(
                        destination: Signup_Via_Email(), // Navigate to the Signup view
                        isActive: $navigateToSignup
                    ) {
                        EmptyView()
                    }
                    .hidden()
                    
                    NavigationLink(
                        destination: Home(), // Navigate to the Home view
                        isActive: $navigateToHome
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Prevent nested NavigationViews
        .navigationBarBackButtonHidden(true)
    }
    
    private func login() {
        // Basic validation
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in both email and password."
            showAlert = true
            return
        }
        
        // Attempt to sign in with Firebase
        Auth.auth().signIn(withEmail: username, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
                return
            }
            
            // Successfully signed in
            if let user = authResult?.user {
                // Save user ID locally for future use
                UserDefaults.standard.set(user.uid, forKey: "userID")
                print("User ID saved locally: \(user.uid)")
                
                // Navigate to Home page
                navigateToHome = true
            }
        }
    }
}

//// Placeholder Home View
//struct Home: View {
//    var body: some View {
//        Text("Welcome to Home!")
//            .font(.title)
//            .padding()
//    }
//}

// Preview
#Preview {
    Login_Via_Email()
}

// Extensions for Hex Colors
//extension Color {
//    init(hex: String) {
//        let scanner = Scanner(string: hex)
//        _ = scanner.scanString("#")
//        var rgb: UInt64 = 0
//        scanner.scanHexInt64(&rgb)
//        let r = Double((rgb >> 16) & 0xFF) / 255.0
//        let g = Double((rgb >> 8) & 0xFF) / 255.0
//        let b = Double(rgb & 0xFF) / 255.0
//        self.init(red: r, green: g, blue: b)
//    }
//}
