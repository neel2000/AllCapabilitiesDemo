//
//  SiriVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 04/08/25.
//

import UIKit

class SiriVC: UIViewController {
    
    @IBOutlet weak var lblCoffeeOrder: UILabel!
    let groupID = "group.com.allcaps"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateText(_:)), name: NSNotification.Name("TextUpdate"), object: nil)
    }
    
    @objc func updateText(_ notification: Notification) {
        let defaults = UserDefaults(suiteName: groupID)
        if let savedText = defaults?.string(forKey: "sharedText") {
            lblCoffeeOrder.text = savedText
        } else {
            lblCoffeeOrder.text = "No text saved yet"
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
