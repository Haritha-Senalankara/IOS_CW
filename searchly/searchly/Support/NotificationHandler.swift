import Foundation
import FirebaseFirestore
import UserNotifications
import FirebaseAuth

class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationHandler()
    private let db = Firestore.firestore()
    private var userID: String?

    private override init() {
        super.init()
        setupUserID()
        UNUserNotificationCenter.current().delegate = self
    }

    private func setupUserID() {
        // Fetch User ID from UserDefaults
        if let uid = UserDefaults.standard.string(forKey: "userID") {
            self.userID = uid
            setupRealtimeListener()
        } else {
            print("User not logged in. No notifications will be fetched.")
        }
    }

    private func setupRealtimeListener() {
        guard let userID = userID else { return }
        let customerRef = db.collection("customers").document(userID)

        customerRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching notifications: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data(),
                  let notifications = data["notifications"] as? [[String: Any]], // Notifications as array of dictionaries
                  let notificationStatus = data["notification_status"] as? Bool,
                  let pushNotificationStatus = data["push_notifications"] as? Bool else {
                print("Required fields missing or invalid in Firestore document.")
                return
            }

            // Check if both notifications and push notifications are enabled
            if notificationStatus && pushNotificationStatus {
                self.processAndScheduleNotifications(notifications, for: customerRef)
            } else {
                print("Either notifications or push notifications are disabled.")
            }
        }
    }

    private func processAndScheduleNotifications(_ notifications: [[String: Any]], for customerRef: DocumentReference) {
        var updatedNotifications = notifications // Mutable copy of the notifications

        for (index, notification) in notifications.enumerated() {
            // Use the index as the unique identifier for this notification
            guard let displayed = notification["displayed"] as? Bool, !displayed else {
                continue // Skip already displayed notifications
            }

            let content = UNMutableNotificationContent()
            content.title = notification["title"] as? String ?? "New Alert"
            content.body = notification["body"] as? String ?? "You have a new notification"
            content.sound = .default

            // Use immediate trigger
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

            let request = UNNotificationRequest(identifier: "notification_\(index)", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { [weak self] error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    print("Notification scheduled: notification_\(index)")

                    // Mark this notification as displayed
                    updatedNotifications[index]["displayed"] = true
                    self?.updateNotificationsInFirestore(updatedNotifications, customerRef: customerRef)
                }
            }
        }
    }

    private func updateNotificationsInFirestore(_ notifications: [[String: Any]], customerRef: DocumentReference) {
        customerRef.updateData(["notifications": notifications]) { error in
            if let error = error {
                print("Error updating notifications in Firestore: \(error.localizedDescription)")
            } else {
                print("Notifications successfully updated in Firestore.")
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
