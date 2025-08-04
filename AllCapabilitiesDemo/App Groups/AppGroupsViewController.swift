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
