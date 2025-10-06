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
import CloudKit
import AppTrackingTransparency
import AdSupport
import Airbridge

var isFromCommunicationNotification = false

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let callManager = CallManager()
    var observer: Any?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        callManager.requestCallKitPermission()
        addIQKeyboardManagerVariables()
        setupAirBridge()
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
    
    func setupAirBridge() {
        let option = AirbridgeOptionBuilder(
            name: "appcapabilitiesdemo",
            token: "a77216e442ec433d9b15763164acb28a"
        ).setAutoDetermineTrackingAuthorizationTimeout(
            second: 30
        ).setAutoStartTrackingEnabled(
            true
        ).build()
        
        Airbridge
            .initializeSDK(
                option: option
            )
        
        observer = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .authorized:
                        // User allowed tracking
                        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                        print("IDFA: \(idfa)")
                    case .denied:
                        print("Tracking denied")
                    case .restricted:
                        print("Tracking restricted")
                    case .notDetermined:
                        print("Permission not determined yet")
                    @unknown default:
                        break
                    }
                }
            }
            if let observer = self?.observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }
        
        _ = Airbridge.handleDeferredDeeplink() { url in
            // when handleDeferredDeeplink is called firstly after install
            if let url {
                self.handleAirbridgeDeeplink(url: url)
            }
        }
    }
    
    // when app is opened with airbridge deeplink
    func handleAirbridgeDeeplink(url: URL) {
        // show proper content using url (YOUR_SCHEME://...)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems
        
        let sender_id = queryItems?.first(where: { $0.name == "sender_id" })?.value
        let post_id = queryItems?.first(where: { $0.name == "post_id" })?.value
        let user_id = queryItems?.first(where: { $0.name == "user_id" })?.value
        let event_id = queryItems?.first(where: { $0.name == "event_id" })?.value
        let group_id = queryItems?.first(where: { $0.name == "group_id" })?.value
        let verified_guest_only = queryItems?.first(where: { $0.name == "verified_guest_only" })?.value
        
        print("Received sender_id: \(sender_id ?? "")")
        print("Received post_id: \(post_id ?? "")")
        print("Received user_id: \(user_id ?? "")")
        print("Received event_id: \(event_id ?? "")")
        print("Received group_id: \(group_id ?? "")")
        print("Received verified_guest_only: \(verified_guest_only ?? "")")
        
        // Extract action type (shareprofile / sharepost)
        let action = url.host ?? ""  // because "kardder://shareprofile" → host = "shareprofile"
        print("DeepLink Action: \(action)")
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        print("✅ Received URL: \(url.absoluteString)")
        
        // Airbridge deeplink
        Airbridge.trackDeeplink(url: url)
        let isAirbridgeDeeplink = Airbridge.handleDeeplink(url: url) { deeplinkUrl in
            // When app is opened with Airbridge deeplink
            self.handleAirbridgeDeeplink(url: deeplinkUrl)
        }
        if isAirbridgeDeeplink {
            return true
        }
        
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
        
        // ✅ 1. Track & handle Airbridge deeplink
        Airbridge.trackDeeplink(userActivity: userActivity)
        
        let isAirbridgeDeeplink = Airbridge.handleDeeplink(userActivity: userActivity) { url in
            // When app is opened with Airbridge deeplink
            self.handleAirbridgeDeeplink(url: url)
        }
        
        if isAirbridgeDeeplink {
            return true
        }
        
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
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let dict = userInfo as? [String: NSObject]
        if let notification = CKNotification(fromRemoteNotificationDictionary: dict!) as? CKDatabaseNotification {
            if let recordVC = (self.window?.rootViewController as? UINavigationController)?.topViewController as? MessageCollaborationVC,
               let recordID = recordVC.currentRecord?.recordID {
                let database = recordVC.currentRecord?.share != nil ? recordVC.container.sharedCloudDatabase : recordVC.database
                database?.fetch(withRecordID: recordID) { updatedRecord, error in
                    if let updatedRecord = updatedRecord {
                        DispatchQueue.main.async {
                            recordVC.textView.text = updatedRecord["content"] as? String ?? ""
                            recordVC.textView.textColor = .label
                            recordVC.currentRecord = updatedRecord
                        }
                        completionHandler(.newData)
                    } else {
                        completionHandler(.failed)
                    }
                }
            } else {
                completionHandler(.noData)
            }
        }
    }
    
}

extension UIButton {
    override open func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        clipsToBounds = true
    }
}
