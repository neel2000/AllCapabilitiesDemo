//
//  AppDelegate.swift
//  AllCapabilitiesDemo
//
//  Created by DREAMWORLD on 10/12/24.
//

import UIKit
import UserNotifications
import Intents
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager
import AVFAudio
import CallKit

var isFromCommunicationNotification = false

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let callManager = CallManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        callManager.requestCallKitPermission()
        addIQKeyboardManagerVariables()
        INPreferences.requestSiriAuthorization { status in
            print("Siri Authorization Status: \(status == .authorized ? "Authorized" : "Not Authorized")")
        }
        UNUserNotificationCenter.current().delegate = self
        requestNotificationPermission()
        
        do {
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.mixWithOthers, .allowAirPlay])
            } else {
                // Fallback on earlier versions
            }
            debugPrint("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            debugPrint("Session is Active")
        } catch {
            debugPrint(error)
        }
        
        if let activity = launchOptions?[.userActivityDictionary] as? [UIApplication.LaunchOptionsKey: Any],
           let userActivity = activity[.userActivityType] as? NSUserActivity {
          print("nihar")
        }
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        print("✅ Received URL: \(url.absoluteString)")
        let scheme = url.scheme?.lowercased()
        if scheme == "tel" || scheme == "telprompt" {
            let phoneNumber = url.absoluteString.replacingOccurrences(of: "\(scheme ?? "tel"):", with: "", options: .caseInsensitive)
            print("✅ Parsed phone number: \(phoneNumber)")
            callManager.startCall(to: phoneNumber, from: "AppCapabilitiesDemo")
            return true
        }
        return false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // Check if the user activity is from a Siri intent
        if userActivity.activityType == String(describing: SaveTextIntent.self) {
            print("Received SaveTextIntent user activity")
            if let intent = userActivity.interaction?.intent as? SaveTextIntent {
                if let widgetText = intent.widgetText {
                    print("Captured widgetText: \(widgetText)")
                    // Handle the widgetText (e.g., update UI, save to spatial audio settings)
                    handleWidgetText(widgetText)
                } else {
                    print("No widgetText found in SaveTextIntent")
                }
                return true
            }
        }
//        else if userActivity.activityType == NSUserActivityTypeStartCall {
//            if let handle = userActivity.interaction?.intent as? INStartCallIntent {
//                if let contact = handle.contacts?.first, let phoneNumber = contact.personHandle?.value {
//                    callManager.startCall(to: phoneNumber, from: contact.displayName ?? "Unknown")
//                    return true
//                }
//            }
//        }
        print("Unhandled user activity type: \(userActivity.activityType)")
        return false
    }
    
    private func handleWidgetText(_ text: String) {
        // Example: Update UI or spatial audio settings
        print("Processing widgetText: \(text)")
        
        // If related to spatial audio, update audio settings
        // Example: Save as a preset name
        if let sharedDefaults = UserDefaults(suiteName: "group.com.allcaps") {
            sharedDefaults.set(text, forKey: "spatialAudioPreset")
            sharedDefaults.synchronize()
            print("Saved spatial audio preset: \(text)")
        }
        
        // Notify view controllers or other components
        NotificationCenter.default.post(name: NSNotification.Name("WidgetTextUpdated"), object: nil, userInfo: ["widgetText": text])
    }
    
    func addIQKeyboardManagerVariables() {
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardToolbarManager.shared.isEnabled = true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert, .providesAppNotificationSettings]) { granted, error in
            if granted {
                print("✅ Permission granted.")
            } else {
                print("❌ Permission denied.")
            }
        }
    }
    
    // To show notifications in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
}

extension UIButton {
    override open func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        clipsToBounds = true
    }
}
