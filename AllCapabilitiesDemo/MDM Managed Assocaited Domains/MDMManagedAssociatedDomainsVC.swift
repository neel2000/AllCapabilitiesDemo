//
//  MDMManagedAssociatedDomainsVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 07/10/25.
//

import UIKit

class MDMManagedAssociatedDomainsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func btnInfoAction(_ sender: Any) {
        let vc = DescriptionVC()
        vc.infoText =
        """
        The MDM Managed Associated Domain capability in iOS Swift refers to a security and management feature used in Mobile Device Management (MDM) environments that helps organizations establish trusted connections between their managed apps and certain web domains.

        Explanation:
        
            • It creates a secure, managed association between an iOS app and specific web domains.
                    
            • This association enables features like Universal Links (deep linking), Shared Web Credentials (auto fill passwords), and Handoff.

            • The domain association is managed under MDM policies, so only authorized domains are trusted for these capabilities.
                    
            • It allows apps to open links directly inside the app (instead of Safari) and securely share credentials with enterprise websites.
                    
            • The configuration involves setting up an apple-app-site-association file on the web server and adding associated domain entitlements in the iOS app's Xcode project.
                    
            • MDM can enforce these policies and ensure that only managed domains are allowed, enhancing security and control in corporate or school environments.
                    
            • This capability is important for enterprises to secure app communication with their web services while providing seamless user experiences and preserving management control.
        
        """
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
