//
//  Notifications.swift
//  searchly
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
    @State private var notifications: [[String: Any]] = []
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
                    List(notifications.indices, id: \.self) { index in
                        let notification = notifications[index]
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(Color(hexValue: "#F2A213"))
                                .padding(.trailing, 10)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text(notification["title"] as? String ?? "New Notification")
                                    .font(.custom("Heebo-Bold", size: 16))
                                    .foregroundColor(Color(hexValue: "#102A36"))
                                
                                Text(notification["body"] as? String ?? "No details available")
                                    .font(.custom("Heebo-Regular", size: 14))
                                    .foregroundColor(.gray)
                                    .lineLimit(nil)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // Remove individual notification
                                removeNotification(at: index)
                            }) {
                                Image(systemName: "trash")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    .listStyle(InsetGroupedListStyle())
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
        if let uid = UserDefaults.standard.string(forKey: "userID"), !uid.isEmpty {
            self.userID = uid
            loadNotifications()
        } else {
            self.errorMessage = "User not logged in."
            self.isLoading = false
            print("User ID not found in UserDefaults")
        }
    }
    
    private func loadNotifications() {
        guard !userID.isEmpty else { return }
        let customerRef = db.collection("customers").document(userID)
        
        customerRef.getDocument { document, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load notifications."
                    self.isLoading = false
                }
                print("Error fetching notifications: \(error.localizedDescription)")
                return
            }
            
            guard let data = document?.data() else {
                DispatchQueue.main.async {
                    self.notifications = []
                    self.isLoading = false
                }
                return
            }
            
            // Check notification status
            if let notifStatus = data["notification_status"] as? Bool {
                DispatchQueue.main.async {
                    self.notificationEnabled = notifStatus
                    if !notifStatus {
                        // If notifications are disabled, stop loading immediately
                        self.isLoading = false
                        self.notifications = []
                    }
                }
            }
            
            // Load notifications only if enabled
            if let notifArray = data["notifications"] as? [[String: Any]], self.notificationEnabled {
                DispatchQueue.main.async {
                    self.notifications = notifArray
                    self.isLoading = false
                }
            } else {
                // Stop loading if no notifications are available
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }

    // MARK: - Remove Individual Notification
    private func removeNotification(at index: Int) {
        let notification = notifications[index]
        notifications.remove(at: index) // Update UI immediately
        
        // Update Firestore to remove the notification
        guard !userID.isEmpty else { return }
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
        guard !userID.isEmpty else { return }
        let customerRef = db.collection("customers").document(userID)
        
        customerRef.updateData([
            "notifications": []
        ]) { error in
            if let error = error {
                print("Error clearing all notifications: \(error.localizedDescription)")
            } else {
                print("All notifications cleared successfully.")
                DispatchQueue.main.async {
                    self.notifications.removeAll()
                }
            }
        }
    }

    // MARK: - Preview Provider
    struct Notifications_Previews: PreviewProvider {
        static var previews: some View {
            Notifications()
        }
    }
}
