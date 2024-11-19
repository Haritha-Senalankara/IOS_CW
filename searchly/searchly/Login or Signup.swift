import SwiftUI
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import FirebaseFirestore
import LocalAuthentication
import Security
import Foundation // Ensure this import is present

struct Login_or_Signup: View {
    @State private var errorMessage: String = ""
    @State private var showAlert = false
    @State private var navigateToEmailLogin = false
    private let db = Firestore.firestore()
    @State private var navigateToHome = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                Image("App Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 133, height: 121)
                    .padding(.top, 40)
                
                Text("Login or Sign Up")
                    .font(.custom("Heebo-Bold", size: 26))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "#102A36"))
                
                Text("Log in or sign up to track your favorite products, set price alerts and unlock many features.")
                    .font(.custom("Heebo-Regular", size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "#606084"))
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                
                Spacer()
                
                VStack(spacing: 15) {
                    // Apple Login Button (Implementation needed)
                    Button(action: {
                        // Apple login action
                    }) {
                        HStack {
                            Image("Apple Logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Continue with Apple")
                                .font(.custom("Heebo-Bold", size: 17))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 30)
                    
                    // Google Login Button
                    Button(action: {
                        signInWithGoogle()
                    }) {
                        HStack {
                            Image("Google Logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Continue with Google")
                                .font(.custom("Heebo-Bold", size: 17))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .foregroundColor(Color.black)
                    }
                    .padding(.horizontal, 30)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Authentication Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                    }
                    
                    // Email Login Button
                    Button(action: {
                        navigateToEmailLogin = true
                    }) {
                        HStack {
                            Image("Email Logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Continue with Email")
                                .font(.custom("Heebo-Bold", size: 17))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hex: "#F2A213"), lineWidth: 2)
                        )
                        .foregroundColor(Color(hex: "#F2A213"))
                    }
                    .padding(.horizontal, 30)
                    
                    // Face ID Authentication Button
                    Button(action: {
                        authenticateWithFaceID()
                    }) {
                        HStack {
                            Image(systemName: "faceid")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Continue with Face ID")
                                .font(.custom("Heebo-Bold", size: 17))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.bottom, 50)
                
                Spacer(minLength: 100)
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .background(
                NavigationLink(
                    destination: Login_Via_Email(),
                    isActive: $navigateToEmailLogin
                ) {
                    EmptyView()
                }
                    .hidden()
            )
            .background(
                NavigationLink(
                    destination: Home(),
                    isActive: $navigateToHome
                ) {
                    EmptyView()
                }
                    .hidden()
            )
            .onAppear {
                if let userIDData = KeychainHelper.shared.read(key: "authenticatedUser"),
                   let userID = String(data: userIDData, encoding: .utf8) {
                    //                    authenticateWihFaceID()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Google Sign-In
    
    func signInWithGoogle() {
        guard let presentingViewController = UIApplication.shared.windows.first?.rootViewController else {
            self.errorMessage = "Unable to access root view controller."
            self.showAlert = true
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error = error {
                self.errorMessage = "Google Sign-In failed: \(error.localizedDescription)"
                self.showAlert = true
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.errorMessage = "Unable to fetch Google ID token."
                self.showAlert = true
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.errorMessage = "Firebase Sign-In failed: \(error.localizedDescription)"
                    self.showAlert = true
                    return
                }
                
                if let authUser = authResult?.user {
                    // Store userID securely in Keychain
                    storeUserID(authUser.uid)
                    
                    // Optionally store in UserDefaults for quick access
                    UserDefaults.standard.set(authUser.uid, forKey: "userID")
                    
                    checkUserExistsAndSave(
                        userID: authUser.uid,
                        email: authUser.email ?? "Unknown Email",
                        firstName: user.profile?.givenName ?? "Unknown",
                        lastName: user.profile?.familyName ?? "Unknown",
                        profileImage: user.profile?.imageURL(withDimension: 200)?.absoluteString ?? ""
                    )
                    
                    navigateToHome = true
                }
            }
        }
    }
    
    // MARK: - User Existence Check and Save
    
    func checkUserExistsAndSave(userID: String, email: String, firstName: String, lastName: String, profileImage: String) {
        db.collection("customers").document(userID).getDocument { document, error in
            if let error = error {
                print("Error checking user existence: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                print("User already exists in Firestore.")
            } else {
                saveUserToFirestore(userID: userID, email: email, firstName: firstName, lastName: lastName, profileImage: profileImage)
            }
        }
    }
    
    func saveUserToFirestore(userID: String, email: String, firstName: String, lastName: String, profileImage: String) {
        let userData: [String: Any] = [
            "email_address": email,
            "name": "\(firstName) \(lastName)",
            "profile_image": profileImage,
            "created_at": Timestamp()
        ]
        
        db.collection("customers").document(userID).setData(userData) { error in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
            } else {
                print("User data saved successfully.")
            }
        }
    }
    
    // MARK: - Face ID Authentication
    
    func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access your account"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // Retrieve user ID from UserDefaults and proceed
                        if let userID = UserDefaults.standard.string(forKey: "userID") {
                            print("Authenticated with Face ID. User ID retrieved: \(userID)")
                            self.navigateToHome = true
                        } else {
                            self.errorMessage = "Face ID authentication succeeded, but user ID was not found."
                            self.showAlert = true
                        }
                    } else {
                        // Handle Face ID authentication failure
                        print("Face ID failed: \(authenticationError?.localizedDescription ?? "Unknown error")")
                        self.errorMessage = "Face ID authentication failed. Please try again."
                        self.showAlert = true
                    }
                }
            }
        } else {
            // Handle case where Face ID is unavailable
            DispatchQueue.main.async {
                self.errorMessage = "Face ID is not available on this device."
                self.showAlert = true
            }
        }
    }
    
    
    
    // MARK: - Helper Function to Store User ID
    func storeUserID(_ userID: String) {
        let userIDData = Data(userID.utf8)
        KeychainHelper.shared.save(key: "authenticatedUser", data: userIDData)
        print("User ID saved to Keychain: \(userID)")
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

#Preview {
    Login_or_Signup()
}

