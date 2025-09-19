//
//  ClassKitVC.swift
//  AllCapabilitiesDemo
//
//  Created by Nihar Dudhat on 16/09/25.
//

import UIKit

class ClassKitVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func btnInfoAction(_ sender: Any) {
        let vc = DescriptionVC()
        vc.infoText = """
            
            ClassKit is Apple’s framework that allows educational apps to integrate with the Schoolwork app used in classrooms. When you enable this capability, your app can create activities (like quizzes, reading tasks, or practice exercises) that teachers assign to students and track their progress.

            🔑 Key Points:

                    • Activities & Contexts

                        • Use CLSContext to define sections of your app (like lessons, topics, or quizzes).

                        • Use CLSActivity to represent the actual task (e.g., answering 10 math questions).

                    • Progress Tracking

                        • Report progress using progress (e.g., 0.0 → 1.0).

                        • Save and update progress with CLSDataStore.

                    • Integration with Schoolwork

                        • Teachers can assign activities directly from your app via the Schoolwork app.

                        • Students’ progress is automatically shared with teachers.

                    • Privacy First

                        • Only activities explicitly assigned by a teacher are reported.
            
                        • Student personal data is not shared without permission.

            ✅ When to Use

                    • If your app is educational and you want to integrate with Apple Schoolwork for assignments, tracking, and progress reporting.

                    • Ideal for apps with quizzes, practice exercises, lessons, or interactive content.
            
            
            ✅ Requirements for ClassKit Capability

            1. Enable the Capability in Xcode

                • Go to Signing & Capabilities → + Capability → add ClassKit.

                • This adds the com.apple.developer.ClassKit-environment entitlement to your app.

            2. App Type

                • Your app should be educational (Apple expects it to be used in a teaching/learning context).

            3. Schoolwork App (on Student & Teacher devices)

                • ClassKit only shows its real power when paired with Apple Schoolwork (used by teachers to assign and track progress).

            4. Device & OS

                • iOS 11.4 or later.

                • Works on iPad and iPhone, but mostly targeted for iPads in classrooms.

            5. App Store / Distribution

                • For production use, Apple may require your app to be approved as an educational app.

                • (Some ClassKit features are only visible in apps installed via Apple School Manager / MDM in schools).

            6. Implementation in Code

                • Use CLSContext to describe lessons/sections/quizzes.

                • Create CLSActivity to represent tasks.

                • Report progress via CLSActivity.progress and save with CLSDataStore.

            7. Privacy & Permissions

                • Progress is only reported if the activity was assigned by a teacher in Schoolwork.

                • No sensitive student data is shared automatically.
            
            """
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

}
