//
//  NotificationManager.swift
//  FridgeTag
//
//  Created by Karen Khachatryan on 21.11.24.
//

import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}

    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    DispatchQueue.main.async {
                        completion(granted)
                    }
                }
            case .denied:
                DispatchQueue.main.async {
                    self.showSettingsAlert()
                    completion(false)
                }
            case .authorized, .provisional:
                DispatchQueue.main.async {
                    completion(true)
                }
            @unknown default:
                completion(false)
            }
        }
    }
    
    // MARK: - Show Settings Alert
    private func showSettingsAlert() {
        let alert = UIAlertController(
            title: "Enable Notifications",
            message: "Please enable notifications in Settings to receive alerts.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings)
            }
        })
        
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let rootViewController = scene.windows.first?.rootViewController {
                rootViewController.present(alert, animated: true, completion: nil)
            }
    }

    func scheduleNotification(identifier: String, for date: Date, title: String, body: String) {
        guard self.isNotificationEnabled() else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(date)")
            }
        }
    }
    
    func deleteNotification(with identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Notification with identifier \(identifier) has been deleted.")
    }
    
    func isNotificationEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: "isNotificationsEnabled")
    }
}
