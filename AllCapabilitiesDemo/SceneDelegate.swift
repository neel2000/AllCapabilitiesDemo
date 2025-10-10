//
//  SceneDelegate.swift
//  AllCapabilitiesDemo
//
//  Created by DREAMWORLD on 10/12/24.
//

import UIKit
import Intents
import CloudKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let callManager = CallManager.shared
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        // If launched with a dialing intent, extract and start call here.
        if let userActivity = connectionOptions.userActivities.first {
            handle(userActivity: userActivity)
        }
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        // Fallback if the activity carries a URL like tel:123456789
        //handle(userActivity: userActivity)
        print("activityType =", userActivity.activityType)
        
        // Prefer the intent payload over webpageURL for call intents
        if let interaction = userActivity.interaction,
           let audioIntent = interaction.intent as? INStartCallIntent,
           let handle = audioIntent.contacts?.first?.personHandle?.value,
           !handle.isEmpty {
            // handle is the phone number/identifier to dial
            startCall(with: handle)
            return
        }
        
        
        //For Handling Collaboration link, Code is in "MessageCollaborationVC.swift" File
        guard let windowScene = scene as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            print("Failed to access UIWindowScene or rootViewController")
            return
        }
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL,
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           components.path.contains("share"),
           let userInfo = userActivity.userInfo,
           let cloudKitMetadataArray = userInfo["UIUserActivityCloudKitShareMetadataKey"] as? [CKShare.Metadata],
           let shareMetadata = cloudKitMetadataArray.first {
            
            // Get or create MessageCollaborationVC
            let messageVC: MessageCollaborationVC
            if let navController = rootVC as? UINavigationController,
               let existingVC = navController.topViewController as? MessageCollaborationVC {
                messageVC = existingVC
            } else if let existingVC = rootVC as? MessageCollaborationVC {
                messageVC = existingVC
            } else {
                messageVC = MessageCollaborationVC()
                let navController = UINavigationController(rootViewController: messageVC)
                navController.modalPresentationStyle = .fullScreen
                rootVC.present(navController, animated: true)
            }
            
            // Accept the share invitation using CKAcceptSharesOperation
            let acceptOperation = CKAcceptSharesOperation(shareMetadatas: [shareMetadata])
            acceptOperation.perShareCompletionBlock = { (metadata: CKShare.Metadata, share: CKShare?, error: Error?) in
                if let error = error {
                    print("Failed to accept share: \(error)")
                    DispatchQueue.main.async {
                        messageVC.showAlert(title: "Share Error", message: "Failed to accept share: \(error.localizedDescription)")
                    }
                    return
                }
                // Share accepted, now load the root record document
                guard let share = share else {
                    print("No CKShare received")
                    DispatchQueue.main.async {
                        messageVC.showAlert(title: "Share Error", message: "Invalid share received")
                    }
                    return
                }
                
                // Fetch the root record from sharedCloudDatabase using the share's rootRecordID
                messageVC.container.sharedCloudDatabase.fetch(withRecordID: share.recordID) { (record: CKRecord?, error: Error?) in
                    if let error = error {
                        print("Error fetching shared record: \(error)")
                        DispatchQueue.main.async {
                            messageVC.showAlert(title: "Load Error", message: "Could not load shared document: \(error.localizedDescription)")
                        }
                        return
                    }
                    guard let record = record else {
                        print("No record found for shared document")
                        DispatchQueue.main.async {
                            messageVC.showAlert(title: "Load Error", message: "Shared document not found")
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        // Use the existing handleShareMetadata method to load the document into textView
                        messageVC.handleShareMetadata(metadata)
                    }
                }
            }
            
            acceptOperation.acceptSharesResultBlock = { result in
                switch result {
                case .success:
                    print("Successfully accepted CloudKit share")
                case .failure(let error):
                    print("Error completing share acceptance: \(error)")
                    DispatchQueue.main.async {
                        messageVC.showAlert(title: "Share Error", message: "Failed to complete share: \(error.localizedDescription)")
                    }
                }
            }
            
            // Add operation to the container
            messageVC.container.add(acceptOperation)
        }
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        handle(userActivity: userActivity)
        return true
    }
    
    private func handle(userActivity: NSUserActivity) {
        print("activityType =", userActivity.activityType)
        
        // Prefer the intent payload over webpageURL for call intents
        if let interaction = userActivity.interaction,
           let audioIntent = interaction.intent as? INStartCallIntent,
           let handle = audioIntent.contacts?.first?.personHandle?.value,
           !handle.isEmpty {
            // handle is the phone number/identifier to dial
            startCall(with: handle)
        }
    }
    
    private func startCall(with number: String) {
        // Your CallKit flow here
        callManager.startCall(to: number, from: "AppCapabilitiesDemo")
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

}
