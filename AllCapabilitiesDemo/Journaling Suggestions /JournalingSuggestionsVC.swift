//
//  JournalingSuggestionsVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 22/08/25.
//

import UIKit
import SwiftUI

class JournalingSuggestionsVC: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnInfoAction(_ sender: Any) {
        let vc = DescriptionVC()
        vc.infoText = """
            This capability provides users with intelligent prompts and ideas to help them document daily experiences in the Journal app. By using on-device intelligence, it suggests meaningful moments such as recent photos, workouts, locations, or contacts you interacted with, making it easier to reflect and capture memories.
            """
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnJournalingSuggestionsAction(_ sender: Any) {
        if #available(iOS 18.0, *) {
            let vc = JournalingDemo()
            let hostingVC = UIHostingController(rootView: vc)
            self.navigationController?.pushViewController(hostingVC, animated: true)
        } else {
            showAlert(message: "Journaling Suggestions is available on iOS 18.0 and later")
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
