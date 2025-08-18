//
//  IntentHandler.swift
//  SaveTextIntent
//
//  Created by Nihar Dudhat on 04/08/25.
//

import Intents
import WidgetKit

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        guard intent is SaveTextIntent else {
            fatalError("Unhandled intent error: \(intent) ")
        }
        return SaveTextIntentHandler()
    }
}

class SaveTextIntentHandler: NSObject, SaveTextIntentHandling {
    
    let groupID = "group.com.allcaps"
    
    func resolveWidgetText(for intent: SaveTextIntent, with completion: @escaping (SaveTextWidgetTextResolutionResult) -> Void) {
        guard let name  = intent.widgetText else {
            completion(SaveTextWidgetTextResolutionResult.needsValue())
            return
        }
        completion(SaveTextWidgetTextResolutionResult.success(with: name ))
    }
  
    func handle(intent: SaveTextIntent, completion: @escaping (SaveTextIntentResponse) -> Void) {
        
        guard let name = intent.widgetText, !name.isEmpty else {
            print("No valid widgetText provided")
            completion(SaveTextIntentResponse(code: .failure, userActivity: nil))
            return
        }
        
        if let name = intent.widgetText {
            if let sharedDefaults = UserDefaults(suiteName: groupID) {
                sharedDefaults.set(name, forKey: "sharedText")
                sharedDefaults.synchronize()
                print("Saved: \(name)")
                
                // Create NSUserActivity to trigger app launch
                let userActivity = NSUserActivity(activityType: "com.appcaps.SaveTextIntent")
                userActivity.title = "Add text in AppDemo"
                userActivity.userInfo = ["text": "Ronit"]
                userActivity.isEligibleForHandoff = true
                userActivity.isEligibleForSearch = true
                userActivity.isEligibleForPrediction = true
                
                // Donate interaction to Siri
                let interaction = INInteraction(intent: intent, response: nil)
                interaction.donate { error in
                    if let error = error {
                        print("Interaction donation failed: \(error.localizedDescription)")
                    } else {
                        print("Interaction donated successfully for widgetText: \(name)")
                    }
                }
                
                // Notify widget to refresh
                WidgetCenter.shared.reloadAllTimelines()
            }
            completion(SaveTextIntentResponse(code: .success, userActivity: nil))
        } else {
            print("Failed to access UserDefaults for group: \(groupID)")
            completion(SaveTextIntentResponse(code: .failure, userActivity: nil))
        }
        
    }
}
