import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct Signup_Via_Email: View {
    @State private var email: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String = ""
    @State private var showAlert = false
    @State private var navigateToLogin = false // State for navigation to the login page

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                Image("App Logo") // Make sure this matches the image in your assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                
                Text("Sign Up")
                    .font(.custom("Heebo-Bold", size: 26))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "#102A36"))
                
                Text("Sign Up to track your favorite products, set price alerts and unlock many features.")
                    .font(.custom("Heebo-Regular", size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "#606084"))
                    .padding(.horizontal, 20)
                
                VStack(spacing: 15) {
                    CustomTextField(placeholder: "Enter your email address", text: $email)
                    CustomTextField(placeholder: "Enter your first name", text: $firstName)
                    CustomTextField(placeholder: "Enter your last name", text: $lastName)
                    CustomSecureField(placeholder: "Enter your password", text: $password)
                    CustomSecureField(placeholder: "Re-enter your password", text: $confirmPassword)
                }
                .padding(.horizontal, 30)
                
                Button(action: {
                    signUp()
                }) {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#F2A213"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Sign Up"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
                
                Spacer()
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .background(
                NavigationLink(
                    destination: Login_Via_Email(), // Navigate to the Login_Via_Email view
                    isActive: $navigateToLogin
                ) {
                    EmptyView()
                }
                .hidden()
            )
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Prevent nested NavigationViews
        .navigationBarBackButtonHidden(true)
    }
    
    private func signUp() {
        // Validate fields
        guard !email.isEmpty, !firstName.isEmpty, !lastName.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill out all fields."
            showAlert = true
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            showAlert = true
            return
        }
        
        // Create a new user with Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = "Error: \(error.localizedDescription)"
                showAlert = true
                return
            }
            
            guard let user = authResult?.user else {
                errorMessage = "Error: Unable to retrieve user information."
                showAlert = true
                return
            }
            
            // Save user information to Firestore
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "name": firstName + " " + lastName,
                "email_address": email,
                "createdAt": FieldValue.serverTimestamp()
            ]
            
            db.collection("customers").document(user.uid).setData(userData) { error in
                if let error = error {
                    errorMessage = "Error saving user data: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                
                // Optional: Update user profile with display name
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = "\(firstName) \(lastName)"
                changeRequest.commitChanges { error in
                    if let error = error {
                        errorMessage = "Error updating profile: \(error.localizedDescription)"
                    } else {
                        // Navigate to Login page on success
                        navigateToLogin = true
                    }
                    showAlert = true
                }
            }
        }
    }
}


// Custom TextField Component
struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .font(.custom("Heebo-Regular", size: 16))
                .padding()
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
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
    }
}

// Custom SecureField Component
struct CustomSecureField: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            SecureField(placeholder, text: $text)
                .font(.custom("Heebo-Regular", size: 16))
                .padding()
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
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
    }
}

//// Utility to create a color from hex value
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
    Signup_Via_Email()
}
