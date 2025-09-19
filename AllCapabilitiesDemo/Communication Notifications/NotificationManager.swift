//
//  NotificationManager.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 18/09/25.
//

import UserNotifications
import Intents

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    // Singleton instance for easy access
    static let shared = NotificationManager()
    
    let callManager = CallManager()
        
    // Request permission for notifications
    func requestNotificationPermission(completion: @escaping (Bool, Error?) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        // Request authorization for alerts, sounds, badges, and critical alerts
        center.requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
            completion(granted, error)
        }
    }
    
    // Configure communication notification
    func scheduleCommunicationNotification(callerName: String, callHandle: String, isVideo: Bool) {
        // Ensure categories are set
        setupNotificationCategories()
        
        // Use CallManager to report incoming call
        let callUUID = UUID()
        //CallManager.shared.reportIncomingCall(from: callerName, handle: callHandle)
        
        // Schedule a local notification only if fallback is enabled
        let content = UNMutableNotificationContent()
        content.title = "Incoming Call"
        content.subtitle = callerName
        content.body = isVideo ? "Video Call" : "Audio Call"
        content.sound = UNNotificationSound.defaultCritical
        content.categoryIdentifier = "COMMUNICATION_NOTIFICATION"
        content.userInfo = [
            "callerName": callerName,
            "callHandle": callHandle,
            "isVideo": isVideo,
            "callUUID": callUUID.uuidString
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Communication notification scheduled as fallback")
            }
        }
    }
    
    // Handle notifications in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification banner only if fallback is enabled
        completionHandler([.banner, .sound, .list])
    }
    
    // Handle notification interactions
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let callerName = userInfo["callerName"] as? String ?? "Unknown"
        let callHandle = userInfo["callHandle"] as? String ?? "Unknown"
        let isVideo = userInfo["isVideo"] as? Bool ?? false
        let callUUIDString = userInfo["callUUID"] as? String
        let callUUID = callUUIDString.flatMap { UUID(uuidString: $0) }
        
        switch response.actionIdentifier {
        case "ACCEPT_CALL":
            print("Accept button clicked for \(callerName), \(callHandle), Video: \(isVideo)")
            if let callUUID = callUUID {
                isFromCommunicationNotification = true
                callManager.startCall(to: callHandle, from: "AppCapabilitiesDemo")
//                let action = CXAnswerCallAction(call: callUUID)
//                CallManager.shared.callController.request(CXTransaction(action: action)) { error in
//                    if let error = error {
//                        print("Error answering call: \(error)")
//                    } else {
//                        print("Call answered via CallKit")
//                    }
//                }
            } else {
                print("Error: No valid call UUID for accepting call")
            }
            
        case "DECLINE_CALL":
            print("Decline button clicked for \(callerName), \(callHandle), Video: \(isVideo)")
            if let callUUID = callUUID {
                //CallManager.shared.endActiveCall()
            } else {
                print("Error: No valid call UUID for declining call")
            }
            
        case UNNotificationDefaultActionIdentifier:
            print("Notification tapped (no action): \(callerName), \(callHandle)")
            // Handle tap on the notification itself (e.g., open app)
            
        case UNNotificationDismissActionIdentifier:
            print("Notification dismissed")
            // Handle dismissal
            if let callUUID = callUUID {
                //CallManager.shared.endActiveCall()
            }
            
        default:
            print("Unknown action: \(response.actionIdentifier)")
        }
        
        completionHandler()
    }
    
    // Set up notification categories for actions
    func setupNotificationCategories() {
        let acceptAction = UNNotificationAction(
            identifier: "ACCEPT_CALL",
            title: "Accept",
            options: [.foreground]
        )
        
        let declineAction = UNNotificationAction(
            identifier: "DECLINE_CALL",
            title: "Decline",
            options: [.destructive]
        )
        
        let category = UNNotificationCategory(
            identifier: "COMMUNICATION_NOTIFICATION",
            actions: [acceptAction, declineAction],
            intentIdentifiers: ["NStartCallIntent.identifier"],
            options: [.customDismissAction]
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        print("Notification categories registered")
    }
}

// Usage example
extension NotificationManager {
    func configure() {
        // Set up notification categories
        setupNotificationCategories()
        
        // Request notification permission
        requestNotificationPermission { granted, error in
            if granted {
                print("Notification permission granted")
                // Schedule a sample communication notification
                self.scheduleCommunicationNotification(
                    callerName: "John Doe",
                    callHandle: "+7845968510",
                    isVideo: false
                )
            } else {
                print("Notification permission denied")
            }
        }
    }
}
