//
//  AppGroupsViewController.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 31/07/25.
//

import UIKit
import WidgetKit

class AppGroupsViewController: UIViewController {
    
    @IBOutlet weak var tf: UITextField!
    let groupID = "group.com.allcaps"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnInfoAction(_ sender: Any) {
        let vc = DescriptionVC()
        vc.infoText = """
            In iOS, App Groups is a capability that allows multiple apps (or app extensions) created by the same developer to share data and resources securely.

            🔑 Key Use Cases for App Groups:
            
            1. Sharing Data Between App and Extensions
            
            For example:
                • Share data between your main app and a widget (like UserDefaults or files).
                • Share login tokens between the main app and a share extension or Siri shortcut.

            2. Shared Containers
                • Store and access files in a shared directory accessible to both the app and its extensions (e.g., FileManager, UserDefaults(suiteName:)).

            3. Secure Inter-App Communication
                • If your team builds multiple apps, you can exchange data between them using a shared App Group.

            """
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnSaveAction(_ sender: UIButton) {
        guard let text = tf.text, !text.isEmpty else {
            print("Text field is empty")
            return
        }
        
        // Save to shared UserDefaults
        if let sharedDefaults = UserDefaults(suiteName: groupID) {
            sharedDefaults.set(text, forKey: "sharedText")
            sharedDefaults.synchronize()
            print("Saved: \(text)")
            
            // Notify widget to refresh
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

}
