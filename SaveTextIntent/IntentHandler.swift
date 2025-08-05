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
        if let name = intent.widgetText {
            if let sharedDefaults = UserDefaults(suiteName: groupID) {
                sharedDefaults.set(name, forKey: "sharedText")
                sharedDefaults.synchronize()
                print("Saved: \(name)")
                
                // Notify widget to refresh
                WidgetCenter.shared.reloadAllTimelines()
            }
            completion(SaveTextIntentResponse(code: .success, userActivity: nil))
        }
        
    }
}
