//
//  Notifications.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct Notifications: View {
    // Firestore reference
    private let db = Firestore.firestore()
    
    // Current user ID
    @State private var userID: String = ""
    
    // Notifications data
    @State private var notifications: [String] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    @State private var notificationEnabled: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Notification List
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView("Loading Notifications...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if !notificationEnabled {
                    // Display message when notifications are disabled
                    Text("Notifications are disabled.")
                        .foregroundColor(.gray)
                        .font(.custom("Heebo-Regular", size: 16))
                        .padding()
                } else if notifications.isEmpty {
                    Text("No Notifications")
                        .foregroundColor(.gray)
                        .font(.custom("Heebo-Regular", size: 16))
                        .padding()
                } else {
                    ForEach(notifications.indices, id: \.self) { index in
                        HStack {
                            Text(notifications[index])
                                .font(.custom("Heebo-Regular", size: 14))
                                .foregroundColor(Color(hexValue: "#102A36"))
                                .lineLimit(nil)
                            
                            Spacer()
                            
                            Button(action: {
                                // Remove individual notification
                                removeNotification(notifications[index])
                            }) {
                                Image(systemName: "trash") // Use your remove icon here
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.red) // Optional: Change color to indicate removal
                            }
                            .padding(.leading, 10)
                        }
                        .padding(.vertical, 15)
                        .padding(.horizontal, 20)
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                            .padding(.leading, 20)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Spacer()
            
            // Clear All Button
            Button(action: {
                // Clear all notifications action
                clearAllNotifications()
            }) {
                Text("Clear All")
                    .font(.custom("Heebo-Bold", size: 16))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hexValue: "#F2A213"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            fetchUserID()
        }
    }
    
    // MARK: - Fetch User ID from UserDefaults
    private func fetchUserID() {
        if let uid = UserDefaults.standard.string(forKey: "userID") {
            self.userID = uid
            fetchNotifications()
        } else {
            self.errorMessage = "User not logged in."
            self.isLoading = false
            print("User ID not found in UserDefaults")
        }
    }
    
    private func fetchNotifications() {
        let customerRef = db.collection("customers").document(userID)
        
        // Real-time Listener
        customerRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching notifications: \(error.localizedDescription)")
                self.errorMessage = "Failed to load notifications."
                self.isLoading = false
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No data found for user ID: \(userID)")
                self.notifications = []
                self.notificationEnabled = false // Assume notifications are disabled if no data
                self.isLoading = false
                return
            }
            
            // Fetch notification_status
            if let notifStatus = data["notification_status"] as? Bool {
                DispatchQueue.main.async {
                    self.notificationEnabled = notifStatus
                }
            } else {
                // Default to true if the field is missing
                DispatchQueue.main.async {
                    self.notificationEnabled = true
                }
            }
            
            // Fetch notifications only if notifications are enabled
            if let notifData = data["notifications"] as? [String], notificationEnabled {
                DispatchQueue.main.async {
                    self.notifications = notifData
                    self.isLoading = false
                }
            } else {
                // If notifications are disabled or no notifications, clear the list
                DispatchQueue.main.async {
                    self.notifications = []
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Remove Individual Notification
    private func removeNotification(_ notification: String) {
        let customerRef = db.collection("customers").document(userID)
        
        customerRef.updateData([
            "notifications": FieldValue.arrayRemove([notification])
        ]) { error in
            if let error = error {
                print("Error removing notification: \(error.localizedDescription)")
            } else {
                print("Notification removed successfully.")
            }
        }
    }
    
    // MARK: - Clear All Notifications
    private func clearAllNotifications() {
        let customerRef = db.collection("customers").document(userID)
        
        customerRef.updateData([
            "notifications": []
        ]) { error in
            if let error = error {
                print("Error clearing all notifications: \(error.localizedDescription)")
            } else {
                print("All notifications cleared successfully.")
                // No need to manually clear the local array if using real-time listener
            }
        }
    }
    
    // Preview Provider
    struct Notifications_Previews: PreviewProvider {
        static var previews: some View {
            Notifications()
        }
    }
}
