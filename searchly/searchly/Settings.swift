//
//  Settings.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-11-18.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct Settings: View {
    @State private var isNotificationEnabled: Bool = true
    @State private var navigateToOnboarding: Bool = false // State to handle navigation to onboarding
    
    // State variables for Privacy Policy
    @State private var privacyPolicyText: String = ""
    @State private var isPrivacyPolicyVisible: Bool = false
    @State private var isFetchingPolicy: Bool = false
    @State private var policyErrorMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Settings Title
            Text("Settings")
                .font(.custom("Heebo-Bold", size: 24))
                .foregroundColor(Color(hexValue: "#606084"))
                .padding(.top, 5)
                .padding(.bottom, 20)
            
            // Settings Options
            VStack(spacing: 0) {
                // Notification Toggle
                Toggle(isOn: $isNotificationEnabled) {
                    HStack {
                        Image(systemName: "bell")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.black)
                        
                        Text("Notifications")
                            .font(.custom("Heebo-Regular", size: 16))
                            .foregroundColor(.black)
                            .padding(.leading, 10)
                        
                        Spacer()
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: Color(hexValue: "#F2A213")))
                .padding(.vertical, 15)
                .padding(.horizontal, 20)
                .onChange(of: isNotificationEnabled) { value in
                    updateNotificationStatus(to: value)
                }
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.leading, 20)
                
                // Privacy Policy Button
                Button(action: {
                    togglePrivacyPolicy()
                }) {
                    HStack {
                        Image(systemName: "shield")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.black)
                        
                        Text("Privacy Policy")
                            .font(.custom("Heebo-Regular", size: 16))
                            .foregroundColor(.black)
                            .padding(.leading, 10)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 15)
                .padding(.horizontal, 20)
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Spacer() // Push the logout button to the bottom
            
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
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .background(
            NavigationLink(
                destination: onboarding(), // Replace with your actual Onboarding view
                isActive: $navigateToOnboarding
            ) {
                EmptyView()
            }
            .hidden()
        )
        // Privacy Policy Sheet
        .sheet(isPresented: $isPrivacyPolicyVisible) {
            PrivacyPolicySheet(text: $privacyPolicyText, isFetching: $isFetchingPolicy, errorMessage: $policyErrorMessage)
        }
    }
    
    // MARK: - Update Notification Status in Firestore
    private func updateNotificationStatus(to status: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("customers").document(uid).updateData([
            "notification_status": status
        ]) { error in
            if let error = error {
                print("Error updating notification status: \(error.localizedDescription)")
            } else {
                print("Notification status updated to \(status).")
            }
        }
    }
    
    // MARK: - Toggle Privacy Policy Visibility and Fetch Policy
    private func togglePrivacyPolicy() {
        if isPrivacyPolicyVisible {
            // If already visible, hide it
            isPrivacyPolicyVisible = false
        } else {
            // Show and fetch the privacy policy
            isPrivacyPolicyVisible = true
            fetchPrivacyPolicy()
        }
    }
    
    // MARK: - Fetch Privacy Policy from Firestore
    private func fetchPrivacyPolicy() {
        // If already fetched, don't fetch again
        if !privacyPolicyText.isEmpty {
            return
        }
        
        isFetchingPolicy = true
        policyErrorMessage = nil
        
        let db = Firestore.firestore()
        let policyRef = db.collection("system_info").document("policy")
        
        policyRef.getDocument { snapshot, error in
            isFetchingPolicy = false
            
            if let error = error {
                print("Error fetching privacy policy: \(error.localizedDescription)")
                policyErrorMessage = "Failed to load Privacy Policy."
                return
            }
            
            guard let data = snapshot?.data(),
                  let desc = data["desc"] as? String else {
                print("Privacy policy data is missing.")
                policyErrorMessage = "Privacy Policy not available."
                return
            }
            
            DispatchQueue.main.async {
                self.privacyPolicyText = desc
            }
        }
    }
    
    // MARK: - Logout Function
    private func logout() {
        do {
            // Sign out from Firebase
            try Auth.auth().signOut()
            
            // Clear user ID from UserDefaults
            UserDefaults.standard.removeObject(forKey: "userID")
            
            // Clear Keychain data if applicable
            // KeychainHelper.shared.delete(key: "authenticatedUser")
            // print("Cleared User ID from Keychain.")
            
            // Navigate to onboarding screen
            navigateToOnboarding = true
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

// MARK: - Privacy Policy Sheet View
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
                // Dismiss the sheet
                dismiss()
            })
        }
    }
    
    // Dismiss the sheet
    private func dismiss() {
        // This function will be implemented by the parent view
    }
}


struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
