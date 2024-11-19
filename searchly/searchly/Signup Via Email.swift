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
    @State private var navigateToLogin = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                Image("App Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                
                Text("Sign Up")
                    .font(.custom("Heebo-Bold", size: 26))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(hex: "#102A36"))
                
                Text("Sign up to track your favorite products, set price alerts, and unlock many features.")
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
                    destination: Login_Via_Email(),
                    isActive: $navigateToLogin
                ) {
                    EmptyView()
                }
                    .hidden()
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
    }
    
    private func signUp() {
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
            
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "name": "\(firstName) \(lastName)",
                "email_address": email,
                "createdAt": FieldValue.serverTimestamp()
            ]
            
            db.collection("customers").document(user.uid).setData(userData) { error in
                if let error = error {
                    errorMessage = "Error saving user data: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = "\(firstName) \(lastName)"
                changeRequest.commitChanges { error in
                    if let error = error {
                        errorMessage = "Error updating profile: \(error.localizedDescription)"
                    } else {
                        errorMessage = "Sign Up Successful! Redirecting to Login..."
                        showAlert = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            navigateToLogin = true
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    Signup_Via_Email()
}


