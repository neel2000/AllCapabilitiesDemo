//
//  ManagedAppInstallationUIVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 07/10/25.
//

import UIKit

class ManagedAppInstallationUIVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnInfoAction(_ sender: Any) {
        let vc = DescriptionVC()
        vc.infoText = """
            • The Managed App Installation UI is designed for organizations that control iPhones or iPads using Mobile Device Management (MDM).

            • It allows managed apps to display a standard, system-provided interface when installing, updating, or setting up the app.

            • Users don’t need to manually enter configuration information or make complex decisions—the system handles this automatically for a smooth experience.

            • IT administrators can remotely push apps and their settings onto users’ devices, saving time and minimizing errors.

            • This capability ensures companies and schools can quickly deploy necessary apps with clear guidance shown by the device itself, rather than requiring users to work through complicated, custom in-app setups.

            • The feature is especially useful for large deployments, as it streamlines installation and configuration processes for both administrators and end users.

            • Overall, it simplifies how essential apps are installed and managed on multiple devices within organizations.
            
            📲 Key Aspects of Managed App Installation UI Capability in iOS Apps

            • Used by enterprise or school apps deployed through MDM systems.

            • Enabled in the app's Xcode project via an entitlement.

            • Installation and updates are managed remotely by IT admins.

            • iOS presents a standard system interface during install/update.

            • No need for custom installation UI in the app itself.

            • Common in business or educational apps distributed internally.

            • MDM handles triggering the installation UI automatically.

            • Ensures a smooth, consistent deployment experience for users.

            """
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
