//
//  searchlyApp.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI
import Firebase
import UserNotifications

@main
struct searchlyApp: App {
    
    // Initialize Firebase
    init() {
        FirebaseApp.configure()
        print("Firebase configured")
        registerForPushNotifications()
        
        // Fetch the FCM token
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error retrieving FCM token: \(error.localizedDescription)")
            } else if let token = token {
                print("FCM Token: \(token)")
            }
        }
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
        
        // Set up Firebase Messaging delegate
        Messaging.messaging().delegate = NotificationHandler.shared
    }
}

// Singleton to handle notifications
class NotificationHandler: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    static let shared = NotificationHandler()
    
    // Handle FCM token updates
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            print("FCM Token: \(token)")
            // You can send this token to your server for push notifications
        }
    }
    
    // Handle notifications received in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Foreground notification received: \(notification.request.content.userInfo)")
        completionHandler([.alert, .sound, .badge])
    }
    
    // Handle notifications when the app is tapped/opened
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification tapped/opened: \(response.notification.request.content.userInfo)")
        completionHandler()
    }
}
