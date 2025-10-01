//
//  ICloudTypeViewController.swift
//  AllCapabilitiesDemo
//
//  Created by DREAMWORLD on 12/12/24.
//

import UIKit

class ICloudTypeViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
  
    @IBAction func btnCloudkitAction(_ sender: Any) {
        let vc = ICloudViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnCloudDocumentAction(_ sender: Any) {
        let vc = ICloudDocumentsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnKeyValueAction(_ sender: Any) {
        let vc = KeyValueStorageViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnInfoAction(_ sender: Any) {
        let vc = DescriptionVC()
        vc.infoText = """
        The iCloud capability lets your app securely store data in Apple’s iCloud service so users can access it across all their devices.

        🔑 Key Features

            • Data Syncing – Keep user data consistent between iPhone, iPad, and Mac.

            • File Storage – Save documents, photos, or app data in iCloud Drive.

            • Key-Value Storage – Store small amounts of data like settings, preferences, or game progress.

            • CloudKit – Use Apple’s database service for structured data, sharing, and push updates.

            • Backups – Ensure user data isn’t lost if they switch or reset devices.

        📌 Common Use Cases

            • Syncing notes, contacts, or reminders across devices.

            • Storing user documents or media in iCloud Drive.

            • Maintaining game progress or app preferences on multiple devices.

            •  Providing shared databases for collaborative apps (via CloudKit).

        ⚠️ Important Considerations

            • Requires the user to be signed into iCloud.

            • Data stored counts against the user’s iCloud storage quota.

            • Needs proper entitlements enabled in Xcode.

            • Follow Apple’s privacy rules when storing personal information.
        """
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

//import UIKit
//import HomeKit
//
//class ICloudTypeViewController: UIViewController, HMHomeManagerDelegate {
//    
//    private var homeManager: HMHomeManager!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        homeManager = HMHomeManager()
//        homeManager.delegate = self
//    }
//    
//    // Called when homes are loaded
//    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
//        if let primaryHome = manager.primaryHome {
//            print("Primary Home: \(primaryHome.name)")
//            
//            // List accessories
//            for accessory in primaryHome.accessories {
//                print("Accessory: \(accessory.name)")
//            }
//        } else {
//            print("No Home configured")
//        }
//    }
//}
