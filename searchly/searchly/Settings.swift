import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import LocalAuthentication

// MARK: - Privacy Policy Sheet
struct PrivacyPolicySheet: View {
    @Binding var text: String
    @Binding var isFetching: Bool
    @Binding var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
                if isFetching {
                    ProgressView("Loading Privacy Policy...")
                        .padding()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    ScrollView {
                        Text(text)
                            .font(.custom("Heebo-Regular", size: 16))
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                Spacer()
            }
            .navigationBarTitle("Privacy Policy", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
    
    private func dismiss() {}
}

struct Settings: View {
    @State private var isNotificationEnabled: Bool = true
    @State private var isFaceIDEnabled: Bool = true
    @State private var navigateToOnboarding: Bool = false
    @State private var privacyPolicyText: String = ""
    @State private var isPrivacyPolicyVisible: Bool = false
    @State private var isFetchingPolicy: Bool = false
    @State private var policyErrorMessage: String? = nil
    @State private var pushNotificationsEnabled: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
    
            Text("Settings")
                .font(.custom("Heebo-Bold", size: 24))
                .foregroundColor(Color(hexValue: "#606084"))
                .padding(.top, 5)
                .padding(.bottom, 20)
            
           
            ScrollView {
                VStack(spacing: 0) {
                    // Notification Toggle
                    Toggle(isOn: $isNotificationEnabled) {
                        settingsRowIconAndText(icon: "bell", text: "Notifications")
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color(hexValue: "#F2A213")))
                    .padding(.vertical, 15)
                    .padding(.horizontal, 20)
                    .onChange(of: isNotificationEnabled) { value in
                        updateNotificationStatus(to: value)
                    }
                    
                    Divider().background(Color.gray.opacity(0.3)).padding(.leading, 20)
                    
                    // Push Notifications Toggle
                    Toggle(isOn: $pushNotificationsEnabled) {
                        settingsRowIconAndText(icon: "megaphone", text: "Enable Push Notifications")
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color(hexValue: "#F2A213")))
                    .padding(.vertical, 15)
                    .padding(.horizontal, 20)
                    .onChange(of: pushNotificationsEnabled) { value in
                        updatePushNotificationStatus(to: value)
                    }

                    Divider().background(Color.gray.opacity(0.3)).padding(.leading, 20)

                    
                    // Face ID Toggle
                    Toggle(isOn: $isFaceIDEnabled) {
                        settingsRowIconAndText(icon: "faceid", text: "Enable Face ID")
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color(hexValue: "#F2A213")))
                    .padding(.vertical, 15)
                    .padding(.horizontal, 20)
                    .onChange(of: isFaceIDEnabled) { value in
                        toggleFaceID(to: value)
                    }
                    
                    Divider().background(Color.gray.opacity(0.3)).padding(.leading, 20)
                    
                    // Privacy Policy Button
                    Button(action: {
                        togglePrivacyPolicy()
                    }) {
                        settingsRowIconAndText(icon: "shield", text: "Privacy Policy")
                    }
                    .padding(.vertical, 15)
                    .padding(.horizontal, 20)
                }
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            
            Spacer()
            
            // Logout and Delete Buttons
            VStack(spacing: 10) {
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
                
                // Delete Account Button
                Button(action: {
                    deleteAccount()
                }) {
                    Text("Delete Account")
                        .font(.custom("Heebo-Bold", size: 16))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 30)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .background(
            NavigationLink(
                destination: Login_or_Signup(),
                isActive: $navigateToOnboarding
            ) {
                EmptyView()
            }
                .hidden()
        )
        .onAppear {
            fetchFaceIDStatus() // Only fetches the toggle state without triggering Face ID verification
            loadPushNotificationStatus()
        }
        
        .sheet(isPresented: $isPrivacyPolicyVisible) {
            PrivacyPolicySheet(
                text: $privacyPolicyText,
                isFetching: $isFetchingPolicy,
                errorMessage: $policyErrorMessage
            )
        }
    }
    private func updatePushNotificationStatus(to status: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        let db = Firestore.firestore()
        db.collection("customers").document(uid).updateData(["push_notifications": status]) { error in
            if let error = error {
                print("Error updating push notification status: \(error.localizedDescription)")
            } else {
                print("Push notifications status updated: \(status)")
            }
        }
    }

    private func loadPushNotificationStatus() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("customers").document(uid).getDocument { document, error in
            if let error = error {
                print("Error fetching notification statuses: \(error.localizedDescription)")
                return
            }
            
            if let data = document?.data() {
                // Update push notifications status
                if let pushStatus = data["push_notifications"] as? Bool {
                    DispatchQueue.main.async {
                        self.pushNotificationsEnabled = pushStatus
                    }
                    print("Fetched push notifications status: \(pushStatus)")
                } else {
                    print("Push notifications status not found, setting default to true.")
                    DispatchQueue.main.async {
                        self.pushNotificationsEnabled = true // Default value
                    }
                }
                
                // Update notification status
                if let notificationStatus = data["notification_status"] as? Bool {
                    DispatchQueue.main.async {
                        self.isNotificationEnabled = notificationStatus
                    }
                    print("Fetched notification status: \(notificationStatus)")
                } else {
                    print("Notification status not found, setting default to true.")
                    DispatchQueue.main.async {
                        self.isNotificationEnabled = true
                    }
                }
            } else {
                print("Document not found, setting notification statuses to default.")
                DispatchQueue.main.async {
                    self.pushNotificationsEnabled = true
                    self.isNotificationEnabled = true
                }
            }
        }
    }

    private func fetchFaceIDStatus() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        let db = Firestore.firestore()
        db.collection("customers").document(uid).getDocument { document, error in
            if let error = error {
                print("Error fetching Face ID status: \(error.localizedDescription)")
                return
            }
            if let data = document?.data(), let faceIDStatus = data["isFaceIDEnabled"] as? Bool {
                DispatchQueue.main.async {
                    self.isFaceIDEnabled = faceIDStatus
                }
                print("Fetched Face ID status: \(faceIDStatus)")
            } else {
                print("Face ID status not found in Firestore.")
            }
        }
    }
    
    
    
    // Helper for Settings Rows
    private func settingsRowIconAndText(icon: String, text: String) -> some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.black)
            Text(text)
                .font(.custom("Heebo-Regular", size: 16))
                .foregroundColor(.black)
                .padding(.leading, 10)
            Spacer()
        }
    }
    
    // MARK: - Update Notification Status
    private func updateNotificationStatus(to status: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        let db = Firestore.firestore()
        db.collection("customers").document(uid).updateData(["notification_status": status]) { error in
            if let error = error {
                print("Error updating notification status: \(error.localizedDescription)")
            }
        }
    }
    
    private func toggleFaceID(to isEnabled: Bool) {
        let context = LAContext()
        var error: NSError?
        let db = Firestore.firestore()
        
        if isEnabled {
            // Trigger Face ID authentication only when enabling
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Enable Face ID for secure access.") { success, error in
                    DispatchQueue.main.async {
                        if success {
                            if let user = Auth.auth().currentUser {
                                UserDefaults.standard.set(true, forKey: "isFaceIDEnabled")
                                db.collection("customers").document(user.uid).updateData(["isFaceIDEnabled": true]) { error in
                                    if let error = error {
                                        print("Error saving Face ID status: \(error.localizedDescription)")
                                    } else {
                                        print("Face ID enabled successfully.")
                                    }
                                }
                            }
                        } else {
                            // Revert toggle state if Face ID verification fails
                            self.isFaceIDEnabled = false
                            print("Face ID verification failed: \(error?.localizedDescription ?? "Unknown error")")
                        }
                    }
                }
            } else {
                // Revert toggle state if Face ID is not available
                self.isFaceIDEnabled = false
                print("Face ID not available: \(error?.localizedDescription ?? "Unknown error")")
            }
        } else {
            // Disable Face ID without authentication
            if let user = Auth.auth().currentUser {
                UserDefaults.standard.set(false, forKey: "isFaceIDEnabled")
                db.collection("customers").document(user.uid).updateData(["isFaceIDEnabled": false]) { error in
                    if let error = error {
                        print("Error disabling Face ID: \(error.localizedDescription)")
                    } else {
                        print("Face ID disabled successfully.")
                    }
                }
            }
        }
    }
    
    

    private func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Enable Face ID for easier access.") { success, error in
                DispatchQueue.main.async {
                    if success {
                        UserDefaults.standard.set(true, forKey: "isFaceIDEnabled")
                    } else {
                        self.isFaceIDEnabled = false
                    }
                }
            }
        } else {
            self.isFaceIDEnabled = false
        }
    }
    
    // MARK: - Toggle Privacy Policy
    private func togglePrivacyPolicy() {
        if isPrivacyPolicyVisible {
            isPrivacyPolicyVisible = false
        } else {
            isPrivacyPolicyVisible = true
            fetchPrivacyPolicy()
        }
    }
    
    private func fetchPrivacyPolicy() {
        if !privacyPolicyText.isEmpty { return }
        isFetchingPolicy = true
        policyErrorMessage = nil
        let db = Firestore.firestore()
        db.collection("system_info").document("policy").getDocument { snapshot, error in
            isFetchingPolicy = false
            if let error = error {
                policyErrorMessage = "Failed to load Privacy Policy."
                return
            }
            if let data = snapshot?.data(),
               let desc = data["desc"] as? String {
                self.privacyPolicyText = desc
            }
        }
    }
    
    private func logout() {
        do {
            // Save logout status in UserDefaults
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "isLoggedOut")
            defaults.synchronize()
            
            // Navigate back to onboarding or login
            navigateToOnboarding = true
            print("User successfully logged out. Logout status saved in UserDefaults.")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    
    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        let db = Firestore.firestore()
        

        let confirmationAlert = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to delete your account? This action cannot be undone.",
            preferredStyle: .alert
        )
        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        confirmationAlert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { _ in
            db.collection("customers").document(uid).delete { error in
                if let error = error {
                    print("Error deleting customer data: \(error.localizedDescription)")
                }
            }
            
            db.collection("products").whereField("userID", isEqualTo: uid).getDocuments { snapshot, error in
                snapshot?.documents.forEach { $0.reference.delete() }
            }
            
            // Delete the Firebase user
            user.delete { error in
                if error == nil {
                    clearAllUserDefaults()
                    navigateToOnboarding = true
                } else {
                    print("Error deleting user: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }))
        
        UIApplication.shared.windows.first?.rootViewController?.present(confirmationAlert, animated: true)
    }
    
    private func clearAllUserDefaults() {
        let defaults = UserDefaults.standard
        
        if defaults.dictionaryRepresentation().isEmpty {
            print("UserDefaults are already empty.")
            return
        }
        
        // Remove all keys
        for key in defaults.dictionaryRepresentation().keys {
            defaults.removeObject(forKey: key)
        }
        
        // Synchronize changes to ensure they take effect immediately
        defaults.synchronize()
        print("All UserDefaults have been cleared.")
    }
    
    
}

// MARK: - Preview
struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
