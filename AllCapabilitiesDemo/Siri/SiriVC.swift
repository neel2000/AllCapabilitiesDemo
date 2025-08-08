//
//  SiriVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 04/08/25.
//

import UIKit
import OSLog
import Intents
import WidgetKit

class SiriVC: UIViewController {
    
    @IBOutlet weak var tf: UITextField!
    
    let groupID = "group.com.allcaps"
    let defaultsKey = "sharedText"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        INPreferences.requestSiriAuthorization { status in
            os_log("Siri Authorization Status: %@", log: .default, type: .info, status == .authorized ? "Authorized" : "Not Authorized")
        }
        
        updateTextLabel()
        
        // Suggest Siri Shortcut
        let activity = NSUserActivity(activityType: "com.appcaps.SaveTextIntent")
        activity.title = "Save text to widget in AppCapabilitiesDemo"
        activity.userInfo = ["text": "Ronit"]
        activity.isEligibleForPrediction = true
        activity.persistentIdentifier = "com.allcaps.SaveTextIntent"
        self.userActivity = activity
        userActivity?.becomeCurrent()
        donateInteraction(text: "Sample Text")
        
//        donateInteraction()
//        NotificationCenter.default.addObserver(self, selector: #selector(updateText(_:)), name: NSNotification.Name("TextUpdate"), object: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let text = ["Note 1", "Note 2", "Note 3"].randomElement() ?? "Sample Text"
        saveText(text)
        updateTextLabel()
        donateInteraction(text: text)
    }
    
    private func saveText(_ text: String) {
        guard let defaults = UserDefaults(suiteName: groupID) else {
            os_log("Failed to access UserDefaults for group: %@", log: .default, type: .error, groupID)
            tf.text = "Shared Text: Error"
            return
        }
        defaults.set(text, forKey: defaultsKey)
        defaults.synchronize()
        os_log("Saved text: %@", log: .default, type: .info, text)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func donateInteraction(text: String) {
        let intent = SaveTextIntent()
        intent.widgetText = text
        intent.suggestedInvocationPhrase = "Save text to widget in AppCapabilitiesDemo"
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error = error {
                os_log("Interaction donation failed: %@", log: .default, type: .error, error.localizedDescription)
            } else {
                os_log("Successfully donated interaction for %@", log: .default, type: .info, text)
            }
        }
    }
    
    private func updateTextLabel() {
        guard let defaults = UserDefaults(suiteName: groupID) else {
            tf.text = "Shared Text: No access"
            return
        }
        let text = defaults.string(forKey: defaultsKey) ?? "None"
        tf.text = "Shared Text: \(text)"
    }
    
}
