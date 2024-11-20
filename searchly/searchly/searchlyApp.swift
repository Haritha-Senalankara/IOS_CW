import SwiftUI
import Firebase
import UserNotifications

@main
struct searchlyApp: App {
    
    init() {
        FirebaseApp.configure()
        NotificationHandler.shared // Initialize the NotificationHandler
        registerForPushNotifications()
    }
    
    var body: some Scene {
        WindowGroup {
            Splash_View()
        }
    }
    
    private func registerForPushNotifications() {
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            } else if granted {
                print("Notification permission granted")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Notification permission denied")
            }
        }
        
        // Set up the UNUserNotificationCenter delegate
        UNUserNotificationCenter.current().delegate = NotificationHandler.shared
    }
}
